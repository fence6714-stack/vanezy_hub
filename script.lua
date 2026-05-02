--[[
	CLONE HUB v1 - ПРОСТОЕ КЛОНИРОВАНИЕ
	by Vanezy Scripts
]]

print("START - Clone Hub")

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
if not player then
	player = Players.PlayerAdded:Wait()
end

-- =========== ПЕРЕМЕННЫЕ ===========
local clones = {}  -- Таблица для хранения клонов
local cloneCount = 0
local maxClones = 10

-- =========== СОЗДАНИЕ GUI ===========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CloneHub"
ScreenGui.ResetOnSpawn = false

local playerGui = player:WaitForChild("PlayerGui")
ScreenGui.Parent = playerGui

-- =========== ГЛАВНОЕ МЕНЮ ===========
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 150)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -75)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BackgroundTransparency = 0.05
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = MainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(0, 140, 255)
mainStroke.Thickness = 1.5
mainStroke.Parent = MainFrame

-- Заголовок
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
TitleBar.BorderSizePixel = 0
TitleBar.Active = true
TitleBar.Parent = MainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Text = "🧬 CLONE HUB"
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 14
TitleText.TextColor3 = Color3.fromRGB(0, 160, 255)
TitleText.BackgroundTransparency = 1
TitleText.Size = UDim2.new(1, -60, 1, 0)
TitleText.Position = UDim2.new(0, 12, 0, 0)
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

-- Кнопка закрытия
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -32, 0, 5)
CloseBtn.Text = "✕"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TitleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
	ScreenGui:Destroy()
end)

-- Drag система
local dragging = false
local dragStart, startPos

TitleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = MainFrame.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
		local delta = input.Position - dragStart
		MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

-- =========== СЧЁТЧИК ТЕКСТ ===========
local CounterLabel = Instance.new("TextLabel")
CounterLabel.Text = "📊 Clones: 0"
CounterLabel.Font = Enum.Font.GothamBold
CounterLabel.TextSize = 16
CounterLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
CounterLabel.BackgroundTransparency = 1
CounterLabel.Size = UDim2.new(1, 0, 0, 30)
CounterLabel.Position = UDim2.new(0, 0, 0, 45)
CounterLabel.Parent = MainFrame

-- =========== КНОПКИ ===========
local MinusBtn = Instance.new("TextButton")
MinusBtn.Size = UDim2.new(0, 60, 0, 40)
MinusBtn.Position = UDim2.new(0.1, 0, 0, 85)
MinusBtn.Text = "− REMOVE"
MinusBtn.Font = Enum.Font.GothamBold
MinusBtn.TextSize = 14
MinusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinusBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
MinusBtn.BorderSizePixel = 0
MinusBtn.Parent = MainFrame

local minusCorner = Instance.new("UICorner")
minusCorner.CornerRadius = UDim.new(0, 8)
minusCorner.Parent = MinusBtn

local PlusBtn = Instance.new("TextButton")
PlusBtn.Size = UDim2.new(0, 60, 0, 40)
PlusBtn.Position = UDim2.new(0.55, 0, 0, 85)
PlusBtn.Text = "+ ADD"
PlusBtn.Font = Enum.Font.GothamBold
PlusBtn.TextSize = 14
PlusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PlusBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
PlusBtn.BorderSizePixel = 0
PlusBtn.Parent = MainFrame

local plusCorner = Instance.new("UICorner")
plusCorner.CornerRadius = UDim.new(0, 8)
plusCorner.Parent = PlusBtn

local ClearBtn = Instance.new("TextButton")
ClearBtn.Size = UDim2.new(0.8, 0, 0, 35)
ClearBtn.Position = UDim2.new(0.1, 0, 0, 135)
ClearBtn.Text = "🗑️ REMOVE ALL"
ClearBtn.Font = Enum.Font.GothamBold
ClearBtn.TextSize = 12
ClearBtn.TextColor3 = Color3.fromRGB(255, 200, 200)
ClearBtn.BackgroundColor3 = Color3.fromRGB(100, 40, 40)
ClearBtn.BorderSizePixel = 0
ClearBtn.Parent = MainFrame

local clearCorner = Instance.new("UICorner")
clearCorner.CornerRadius = UDim.new(0, 8)
clearCorner.Parent = ClearBtn

-- =========== ФУНКЦИЯ СОЗДАНИЯ КЛОНА ===========
local function createClone()
	local char = player.Character
	if not char then
		print("Character not found")
		return nil
	end
	
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then
		print("HumanoidRootPart not found")
		return nil
	end
	
	-- Создаём копию персонажа
	local clone = player.Character:Clone()
	clone.Name = "Clone_" .. player.Name .. "_" .. cloneCount + 1
	clone.Parent = workspace
	
	-- Позиционируем спереди или сбоку
	local offset = CFrame.new(3, 0, 3) * (cloneCount + 1)
	clone:SetPrimaryPartCFrame(hrp.CFrame * offset)
	
	-- Настраиваем Humanoid
	local hum = clone:FindFirstChild("Humanoid")
	if hum then
		hum.PlatformStand = true
		hum.WalkSpeed = 0
		hum.JumpPower = 0
		hum.BreakJointsOnDeath = false
	end
	
	-- Убираем оружие и аксессуары (чтобы не создавали ошибок)
	for _, child in pairs(clone:GetChildren()) do
		if child:IsA("Tool") or child:IsA("Accessory") then
			child:Destroy()
		end
	end
	
	-- Делаем всех частей коллизию активной
	for _, part in pairs(clone:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CanCollide = true
			part.Massless = true
		end
	end
	
	-- Добавляем подсветку для клона (чтобы отличать)
	for _, part in pairs(clone:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Color = Color3.fromRGB(100, 100, 255)
			part.Material = Enum.Material.Neon
		end
	end
	
	-- Сохраняем в таблицу
	clones[clone] = true
	cloneCount = cloneCount + 1
	
	-- Обновляем счётчик
	CounterLabel.Text = "📊 Clones: " .. cloneCount
	
	-- Автоудаление через 60 секунд
	task.spawn(function()
		task.wait(60)
		if clone and clone.Parent then
			removeClone(clone)
		end
	end)
	
	-- Визуальный эффект при создании
	local beam = Instance.new("Part")
	beam.Size = Vector3.new(1, 1, 1)
	beam.Shape = Enum.PartType.Ball
	beam.Color = Color3.fromRGB(0, 255, 100)
	beam.Material = Enum.Material.Neon
	beam.Anchored = true
	beam.CanCollide = false
	beam.Parent = clone.HumanoidRootPart
	
	TweenService:Create(beam, TweenInfo.new(0.5), {Size = Vector3.new(3, 3, 3), Transparency = 1}):Play()
	task.wait(0.5)
	beam:Destroy()
	
	print("✅ Clone created: " .. clone.Name)
	return clone
end

-- =========== ФУНКЦИЯ УДАЛЕНИЯ КЛОНА ===========
local function removeClone(clone)
	if not clone or not clone.Parent then return end
	
	-- Визуальный эффект при удалении
	for _, part in pairs(clone:GetDescendants()) do
		if part:IsA("BasePart") then
			TweenService:Create(part, TweenInfo.new(0.3), {Transparency = 1}):Play()
		end
	end
	
	task.wait(0.3)
	
	-- Удаляем клона
	if clones[clone] then
		clones[clone] = nil
	end
	clone:Destroy()
	
	-- Обновляем счётчик
	cloneCount = cloneCount - 1
	if cloneCount < 0 then cloneCount = 0 end
	CounterLabel.Text = "📊 Clones: " .. cloneCount
	
	print("🗑️ Clone removed")
end

-- =========== ФУНКЦИЯ УДАЛЕНИЯ ВСЕХ КЛОНОВ ===========
local function removeAllClones()
	for clone, _ in pairs(clones) do
		pcall(function()
			if clone and clone.Parent then
				clone:Destroy()
			end
		end)
	end
	clones = {}
	cloneCount = 0
	CounterLabel.Text = "📊 Clones: 0"
	print("🗑️ All clones removed")
end

-- =========== НАЗНАЧАЕМ КНОПКИ ===========
PlusBtn.MouseButton1Click:Connect(function()
	if cloneCount >= maxClones then
		print("Max clones reached! (" .. maxClones .. ")")
		-- Визуальный эффект ошибки
		PlusBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
		task.wait(0.2)
		PlusBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
		return
	end
	createClone()
end)

MinusBtn.MouseButton1Click:Connect(function()
	if cloneCount <= 0 then
		print("No clones to remove!")
		MinusBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
		task.wait(0.2)
		MinusBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
		return
	end
	
	-- Удаляем последнего клона
	local lastClone = nil
	for clone, _ in pairs(clones) do
		lastClone = clone
	end
	if lastClone then
		removeClone(lastClone)
	end
end)

ClearBtn.MouseButton1Click:Connect(function()
	removeAllClones()
end)

-- =========== ДОПОЛНИТЕЛЬНО: КЛАВИША C ДЛЯ СОЗДАНИЯ КЛОНА ===========
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	if input.KeyCode == Enum.KeyCode.C then
		if cloneCount >= maxClones then
			print("Max clones reached!")
			return
		end
		createClone()
	elseif input.KeyCode == Enum.KeyCode.X then
		local lastClone = nil
		for clone, _ in pairs(clones) do
			lastClone = clone
		end
		if lastClone then
			removeClone(lastClone)
		end
	elseif input.KeyCode == Enum.KeyCode.Z then
		removeAllClones()
	end
end)

-- =========== ОБРАБОТКА РЕСПАВНА ===========
player.CharacterAdded:Connect(function()
	-- Удаляем клонов при смерти игрока
	removeAllClones()
end)

print("✅ Clone Hub loaded!")
print("📌 Controls: C = Add Clone | X = Remove Last | Z = Remove All")
