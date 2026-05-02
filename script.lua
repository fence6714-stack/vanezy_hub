--[[
	SYNAPSE HUB v11 - FULL ULTIMATE
	by Vanezy Scripts
	Telegram: @VanezyScripts
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local GuiService = game:GetService("GuiService")
local Clipboard = game:GetService("Clipboard") or setclipboard or function() end

local player = Players.LocalPlayer

-- =========== НАСТРОЙКИ ПО УМОЛЧАНИЮ ===========
local settings = {
	walkSpeed = 16,
	jumpPower = 50,
	fov = 70,
	autoRun = false,
	autoRunSpeed = 16,
	espPlayers = false,
	espChests = false,
	espMobs = false,
	espSize = 1.5,
	espHealth = true,
	espDistance = true,
	flyEnabled = false,
	flySpeed = 50,
	noclip = false,
	noclipWalls = true,
	noclipFloor = false,
	noclipCeiling = false,
	speedHack = false,
	speedHackValue = 50,
	infiniteJump = false,
	rainbow = false
}

-- =========== ЗАГРУЗКА СОХРАНЕНИЙ ===========
local StorageValues = Instance.new("Folder")
StorageValues.Name = "UISettings"
StorageValues.Parent = player

local function loadValue(name, default)
	local val = StorageValues:GetAttribute(name)
	if val ~= nil then return val end
	return default
end

local function saveValue(name, value)
	StorageValues:SetAttribute(name, value)
end

for key, default in pairs(settings) do
	settings[key] = loadValue(key, default)
end

-- =========== ПЕРЕМЕННЫЕ ===========
local camera = Workspace.CurrentCamera
local autoRunConnection = nil
local flyConnection = nil
local noClipConnection = nil
local bodyVelocity = nil
local rainbowHue = 0
local rainbowConnection = nil

local espPlayersList = {}
local espChestsList = {}
local espMobsList = {}

-- =========== БЕЗОПАСНОЕ СОЗДАНИЕ GUI ===========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SynapseHub"
ScreenGui.ResetOnSpawn = false

local playerGui = player:FindFirstChild("PlayerGui")
if not playerGui then
	playerGui = Instance.new("PlayerGui")
	playerGui.Parent = player
	task.wait(0.5)
end
ScreenGui.Parent = playerGui

-- =========== РЕКЛАМА ===========
local AdFrame = Instance.new("Frame")
AdFrame.Size = UDim2.new(0, 340, 0, 220)
AdFrame.Position = UDim2.new(0.5, -170, 0.5, -110)
AdFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
AdFrame.BackgroundTransparency = 0.05
AdFrame.BorderSizePixel = 0
AdFrame.ZIndex = 200
AdFrame.Parent = ScreenGui

local adCorner = Instance.new("UICorner")
adCorner.CornerRadius = UDim.new(0, 16)
adCorner.Parent = AdFrame

local AdTitle = Instance.new("TextLabel")
AdTitle.Text = "✨ Vanezy Scripts ✨"
AdTitle.Font = Enum.Font.GothamBold
AdTitle.TextSize = 18
AdTitle.TextColor3 = Color3.fromRGB(0, 180, 255)
AdTitle.BackgroundTransparency = 1
AdTitle.Size = UDim2.new(1, 0, 0, 35)
AdTitle.Position = UDim2.new(0, 0, 0, 10)
AdTitle.ZIndex = 201
AdTitle.Parent = AdFrame

local SubText = Instance.new("TextLabel")
SubText.Text = "Подпишитесь на нас в Telegram!\nСледите за обновлениями\nи получайте новые скрипты!"
SubText.Font = Enum.Font.Gotham
SubText.TextSize = 12
SubText.TextColor3 = Color3.fromRGB(180, 180, 200)
SubText.BackgroundTransparency = 1
SubText.Size = UDim2.new(1, -20, 0, 60)
SubText.Position = UDim2.new(0, 10, 0, 50)
SubText.ZIndex = 201
SubText.TextXAlignment = Enum.TextXAlignment.Center
SubText.Parent = AdFrame

local TelegramButton = Instance.new("TextButton")
TelegramButton.Text = "📱 TELEGRAM CHANNEL"
TelegramButton.Font = Enum.Font.GothamBold
TelegramButton.TextSize = 14
TelegramButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TelegramButton.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
TelegramButton.Size = UDim2.new(0, 240, 0, 40)
TelegramButton.Position = UDim2.new(0.5, -120, 0, 130)
TelegramButton.BorderSizePixel = 0
TelegramButton.ZIndex = 202
TelegramButton.Parent = AdFrame

local telegramCorner = Instance.new("UICorner")
telegramCorner.CornerRadius = UDim.new(0, 8)
telegramCorner.Parent = TelegramButton

local TimerText = Instance.new("TextLabel")
TimerText.Text = "05"
TimerText.Font = Enum.Font.GothamBold
TimerText.TextSize = 24
TimerText.TextColor3 = Color3.fromRGB(200, 200, 200)
TimerText.BackgroundTransparency = 1
TimerText.Size = UDim2.new(0, 50, 0, 40)
TimerText.Position = UDim2.new(0.5, -25, 0, 180)
TimerText.ZIndex = 201
TimerText.TextXAlignment = Enum.TextXAlignment.Center
TimerText.Parent = AdFrame

local CloseAdButton = Instance.new("TextButton")
CloseAdButton.Size = UDim2.new(0, 32, 0, 32)
CloseAdButton.Position = UDim2.new(1, -42, 0, 8)
CloseAdButton.Text = "✕"
CloseAdButton.Font = Enum.Font.GothamBold
CloseAdButton.TextSize = 18
CloseAdButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseAdButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseAdButton.BorderSizePixel = 0
CloseAdButton.ZIndex = 202
CloseAdButton.Visible = false
CloseAdButton.Parent = AdFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = CloseAdButton

-- Показываем рекламу
local adAppear = TweenService:Create(AdFrame, TweenInfo.new(0.5), {BackgroundTransparency = 0.05})
adAppear:Play()

-- Кнопка Telegram - копирует ссылку и пытается открыть
TelegramButton.MouseButton1Click:Connect(function()
	local success, err = pcall(function()
		local telegramLink = "https://t.me/VanezyScripts"
		if Clipboard and Clipboard.set then
			Clipboard:set(telegramLink)
		elseif setclipboard then
			setclipboard(telegramLink)
		elseif toclipboard then
			toclipboard(telegramLink)
		end
		print("✅ Ссылка скопирована: " .. telegramLink)
	end)
	if GuiService and GuiService.ShowMessageBox then
		pcall(function()
			GuiService:ShowMessageBox("Ссылка скопирована!\nhttps://t.me/VanezyScripts", "OK", "")
		end)
	end
end)

-- Таймер 5 секунд
local timer = 5
local timerConnection
timerConnection = RunService.Heartbeat:Connect(function(dt)
	timer = timer - dt
	if timer <= 0 then
		timerConnection:Disconnect()
		TimerText.Text = "✓"
		TimerText.TextColor3 = Color3.fromRGB(100, 255, 100)
		CloseAdButton.Visible = true
	else
		TimerText.Text = string.format("%02d", math.floor(timer))
	end
end)

local function closeAd()
	local adFade = TweenService:Create(AdFrame, TweenInfo.new(0.3), {BackgroundTransparency = 1})
	adFade:Play()
	adFade.Completed:Connect(function()
		AdFrame:Destroy()
	end)
	if timerConnection then timerConnection:Disconnect() end
end

CloseAdButton.MouseButton1Click:Connect(closeAd)

-- =========== ЗАГРУЗОЧНЫЙ ЭКРАН ===========
local LoadingFrame = Instance.new("Frame")
LoadingFrame.Size = UDim2.new(1, 0, 1, 0)
LoadingFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
LoadingFrame.BackgroundTransparency = 0.4
LoadingFrame.ZIndex = 150
LoadingFrame.Parent = ScreenGui

local LoadingContainer = Instance.new("Frame")
LoadingContainer.Size = UDim2.new(0, 280, 0, 100)
LoadingContainer.Position = UDim2.new(0.5, -140, 0.5, -50)
LoadingContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
LoadingContainer.BackgroundTransparency = 0.1
LoadingContainer.BorderSizePixel = 0
LoadingContainer.ZIndex = 151
LoadingContainer.Parent = LoadingFrame

local loadCorner = Instance.new("UICorner")
loadCorner.CornerRadius = UDim.new(0, 16)
loadCorner.Parent = LoadingContainer

local LoadText = Instance.new("TextLabel")
LoadText.Text = "loading..."
LoadText.Font = Enum.Font.GothamBold
LoadText.TextSize = 24
LoadText.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadText.BackgroundTransparency = 1
LoadText.Size = UDim2.new(1, 0, 0, 35)
LoadText.Position = UDim2.new(0, 0, 0, 20)
LoadText.ZIndex = 152
LoadText.Parent = LoadingContainer

local ByText = Instance.new("TextLabel")
ByText.Text = "by Vanezy Scripts"
ByText.Font = Enum.Font.Gotham
ByText.TextSize = 12
ByText.TextColor3 = Color3.fromRGB(150, 150, 180)
ByText.BackgroundTransparency = 1
ByText.Size = UDim2.new(1, 0, 0, 20)
ByText.Position = UDim2.new(0, 0, 0, 65)
ByText.ZIndex = 152
ByText.Parent = LoadingContainer

task.wait(1.5)
local fadeOut = TweenService:Create(LoadText, TweenInfo.new(0.5), {TextTransparency = 1})
local byFadeOut = TweenService:Create(ByText, TweenInfo.new(0.5), {TextTransparency = 1})
fadeOut:Play()
byFadeOut:Play()
task.wait(0.5)
LoadingFrame:Destroy()

-- =========== ГЛАВНОЕ МЕНЮ ===========
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 350, 0, 520)
MainFrame.Position = UDim2.new(0, 5, 0.5, -260)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 25)
MainFrame.BackgroundTransparency = 0.05
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = MainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(0, 140, 255)
mainStroke.Thickness = 1.5
mainStroke.Parent = MainFrame

-- Заголовок (Drag)
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 45)
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
TitleBar.BorderSizePixel = 0
TitleBar.Active = true
TitleBar.Parent = MainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Text = "SYNAPSE HUB"
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 16
TitleText.TextColor3 = Color3.fromRGB(0, 160, 255)
TitleText.BackgroundTransparency = 1
TitleText.Size = UDim2.new(1, -80, 0, 25)
TitleText.Position = UDim2.new(0, 12, 0, 5)
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

local ByLabel = Instance.new("TextLabel")
ByLabel.Text = "by Vanezy Scripts"
ByLabel.Font = Enum.Font.Gotham
ByLabel.TextSize = 10
ByLabel.TextColor3 = Color3.fromRGB(120, 120, 150)
ByLabel.BackgroundTransparency = 1
ByLabel.Size = UDim2.new(1, -80, 0, 15)
ByLabel.Position = UDim2.new(0, 12, 0, 26)
ByLabel.TextXAlignment = Enum.TextXAlignment.Left
ByLabel.Parent = TitleBar

-- Кнопки
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 32, 0, 32)
MinimizeBtn.Position = UDim2.new(1, -74, 0, 6)
MinimizeBtn.Text = "−"
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 20
MinimizeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
MinimizeBtn.BorderSizePixel = 0
MinimizeBtn.Parent = TitleBar

local minBtnCorner = Instance.new("UICorner")
minBtnCorner.CornerRadius = UDim.new(0, 8)
minBtnCorner.Parent = MinimizeBtn

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -38, 0, 6)
CloseBtn.Text = "✕"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TitleBar

local closeBtnCorner = Instance.new("UICorner")
closeBtnCorner.CornerRadius = UDim.new(0, 8)
closeBtnCorner.Parent = CloseBtn

-- Drag System
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

-- =========== СКРОЛЛИНГ КОНТЕЙНЕР ===========
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, 0, 1, -45)
ScrollFrame.Position = UDim2.new(0, 0, 0, 45)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 900)
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 140, 255)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.Parent = MainFrame

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, 0, 0, 900)
Content.BackgroundTransparency = 1
Content.Parent = ScrollFrame

-- =========== ФУНКЦИИ СОЗДАНИЯ UI ===========
local function createSection(parent, name, yPos)
	local section = Instance.new("Frame")
	section.Size = UDim2.new(1, -20, 0, 35)
	section.Position = UDim2.new(0, 10, 0, yPos)
	section.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	section.BackgroundTransparency = 0.5
	section.BorderSizePixel = 0
	section.Parent = parent
	
	local secCorner = Instance.new("UICorner")
	secCorner.CornerRadius = UDim.new(0, 6)
	secCorner.Parent = section
	
	local secText = Instance.new("TextLabel")
	secText.Text = name
	secText.Font = Enum.Font.GothamBold
	secText.TextSize = 13
	secText.TextColor3 = Color3.fromRGB(0, 160, 255)
	secText.BackgroundTransparency = 1
	secText.Size = UDim2.new(1, -10, 1, 0)
	secText.Position = UDim2.new(0, 10, 0, 0)
	secText.TextXAlignment = Enum.TextXAlignment.Left
	secText.TextYAlignment = Enum.TextYAlignment.Center
	secText.Parent = section
	
	return section
end

local function createToggle(parent, name, yPos, defaultState, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -20, 0, 40)
	frame.Position = UDim2.new(0, 10, 0, yPos)
	frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
	frame.BorderSizePixel = 0
	frame.Parent = parent
	
	local fCorner = Instance.new("UICorner")
	fCorner.CornerRadius = UDim.new(0, 6)
	fCorner.Parent = frame
	
	local label = Instance.new("TextLabel")
	label.Text = name
	label.Font = Enum.Font.Gotham
	label.TextSize = 12
	label.TextColor3 = Color3.fromRGB(180, 180, 200)
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(0.65, 0, 1, 0)
	label.Position = UDim2.new(0, 12, 0, 0)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame
	
	local btn = Instance.new("Frame")
	btn.Size = UDim2.new(0, 46, 0, 24)
	btn.Position = UDim2.new(1, -58, 0.5, -12)
	btn.BackgroundColor3 = defaultState and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(200, 50, 50)
	btn.BorderSizePixel = 0
	btn.Parent = frame
	
	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(1, 0)
	btnCorner.Parent = btn
	
	local dot = Instance.new("Frame")
	dot.Size = UDim2.new(0, 18, 0, 18)
	dot.Position = defaultState and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
	dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	dot.BorderSizePixel = 0
	dot.Parent = btn
	
	local dotCorner = Instance.new("UICorner")
	dotCorner.CornerRadius = UDim.new(1, 0)
	dotCorner.Parent = dot
	
	local hitbox = Instance.new("TextButton")
	hitbox.Size = UDim2.new(1, 0, 1, 0)
	hitbox.BackgroundTransparency = 1
	hitbox.Text = ""
	hitbox.Parent = btn
	
	local state = defaultState
	
	hitbox.MouseButton1Click:Connect(function()
		state = not state
		local targetColor = state and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(200, 50, 50)
		local targetPos = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = targetColor}):Play()
		TweenService:Create(dot, TweenInfo.new(0.15), {Position = targetPos}):Play()
		if callback then callback(state) end
	end)
	
	return frame, function() return state end
end

local function createSlider(parent, name, yPos, minVal, maxVal, defaultVal, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -20, 0, 65)
	frame.Position = UDim2.new(0, 10, 0, yPos)
	frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
	frame.BorderSizePixel = 0
	frame.Parent = parent
	
	local fCorner = Instance.new("UICorner")
	fCorner.CornerRadius = UDim.new(0, 6)
	fCorner.Parent = frame
	
	local label = Instance.new("TextLabel")
	label.Text = name .. " [" .. tostring(defaultVal) .. "]"
	label.Font = Enum.Font.Gotham
	label.TextSize = 12
	label.TextColor3 = Color3.fromRGB(180, 180, 200)
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, -20, 0, 25)
	label.Position = UDim2.new(0, 10, 0, 5)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame
	
	local bar = Instance.new("Frame")
	bar.Size = UDim2.new(1, -24, 0, 5)
	bar.Position = UDim2.new(0, 12, 0, 38)
	bar.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
	bar.BorderSizePixel = 0
	bar.Parent = frame
	
	local barCorner = Instance.new("UICorner")
	barCorner.CornerRadius = UDim.new(1, 0)
	barCorner.Parent = bar
	
	local ratio = (defaultVal - minVal) / (maxVal - minVal)
	
	local fill = Instance.new("Frame")
	fill.Size = UDim2.new(ratio, 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
	fill.BorderSizePixel = 0
	fill.Parent = bar
	
	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(1, 0)
	fillCorner.Parent = fill
	
	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 16, 0, 16)
	knob.Position = UDim2.new(ratio, -8, 0.5, -8)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.BorderSizePixel = 0
	knob.Parent = bar
	
	local knobCorner = Instance.new("UICorner")
	knobCorner.CornerRadius = UDim.new(1, 0)
	knobCorner.Parent = knob
	
	local dragging = false
	local currentVal = defaultVal
	
	local function updateSlider(input)
		local barPos = bar.AbsolutePosition
		local barSize = bar.AbsoluteSize
		if not barPos or not barSize then return end
		local relX = (input.Position.X - barPos.X) / barSize.X
		relX = math.clamp(relX, 0, 1)
		local val = minVal + (maxVal - minVal) * relX
		val = math.floor(val * 10 + 0.5) / 10
		fill.Size = UDim2.new(relX, 0, 1, 0)
		knob.Position = UDim2.new(relX, -8, 0.5, -8)
		label.Text = name .. " [" .. tostring(val) .. "]"
		currentVal = val
		if callback then callback(val) end
	end
	
	knob.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
		end
	end)
	
	bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			updateSlider(input)
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
			updateSlider(input)
		end
	end)
	
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
	
	callback(defaultVal)
	
	return {
		setValue = function(val)
			local r = (val - minVal) / (maxVal - minVal)
			r = math.clamp(r, 0, 1)
			fill.Size = UDim2.new(r, 0, 1, 0)
			knob.Position = UDim2.new(r, -8, 0.5, -8)
			label.Text = name .. " [" .. tostring(val) .. "]"
			currentVal = val
			if callback then callback(val) end
		end
	}
end

-- =========== СОЗДАНИЕ UI ===========
local yOffset = 10

-- Раздел MOVEMENT
createSection(Content, "MOVEMENT", yOffset)
yOffset = yOffset + 45

local walkSlider = createSlider(Content, "Walk Speed", yOffset, 8, 120, settings.walkSpeed, function(v)
	settings.walkSpeed = v
	saveValue("walkSpeed", v)
	local char = player.Character
	if char and char:FindFirstChild("Humanoid") then
		char.Humanoid.WalkSpeed = v
	end
end)
yOffset = yOffset + 75

local jumpSlider = createSlider(Content, "Jump Power", yOffset, 30, 250, settings.jumpPower, function(v)
	settings.jumpPower = v
	saveValue("jumpPower", v)
	local char = player.Character
	if char and char:FindFirstChild("Humanoid") then
		char.Humanoid.JumpPower = v
	end
end)
yOffset = yOffset + 75

local fovSlider = createSlider(Content, "Field of View", yOffset, 50, 120, settings.fov, function(v)
	settings.fov = v
	saveValue("fov", v)
	if camera then camera.FieldOfView = v end
end)
yOffset = yOffset + 75

-- Раздел AUTO RUN
createSection(Content, "AUTO RUN", yOffset)
yOffset = yOffset + 45

local autoRunToggle, getAutoRunState = createToggle(Content, "Auto Run", yOffset, settings.autoRun, function(v)
	settings.autoRun = v
	saveValue("autoRun", v)
	
	if autoRunConnection then
		autoRunConnection:Disconnect()
		autoRunConnection = nil
	end
	
	if v then
		autoRunConnection = RunService.Heartbeat:Connect(function()
			local char = player.Character
			if not char then return end
			local hum = char:FindFirstChild("Humanoid")
			local root = char:FindFirstChild("HumanoidRootPart")
			if hum and root then
				local dir = root.CFrame.LookVector * Vector3.new(1, 0, 1)
				if dir.Magnitude > 0.01 then
					hum:Move(dir.Unit, true)
				end
			end
		end)
	end
end)
yOffset = yOffset + 50

local autoRunSlider = createSlider(Content, "Auto Run Speed", yOffset, 8, 120, settings.autoRunSpeed, function(v)
	settings.autoRunSpeed = v
	saveValue("autoRunSpeed", v)
end)
yOffset = yOffset + 75

-- Раздел FLY
createSection(Content, "FLY SYSTEM", yOffset)
yOffset = yOffset + 45

local flyToggle, getFlyState = createToggle(Content, "Fly Mode", yOffset, settings.flyEnabled, function(v)
	settings.flyEnabled = v
	saveValue("flyEnabled", v)
	
	if flyConnection then
		flyConnection:Disconnect()
		flyConnection = nil
	end
	
	if bodyVelocity then
		bodyVelocity:Destroy()
		bodyVelocity = nil
	end
	
	local char = player.Character
	if v and char then
		local hrp = char:FindFirstChild("HumanoidRootPart")
		local hum = char:FindFirstChild("Humanoid")
		if hrp and hum then
			hum.PlatformStand = true
			bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
			bodyVelocity.Parent = hrp
			
			flyConnection = RunService.Heartbeat:Connect(function()
				if not settings.flyEnabled then return end
				local newChar = player.Character
				if not newChar then return end
				local newHrp = newChar:FindFirstChild("HumanoidRootPart")
				local newHum = newChar:FindFirstChild("Humanoid")
				if not newHrp or not newHum then return end
				
				if bodyVelocity and bodyVelocity.Parent ~= newHrp then
					bodyVelocity.Parent = newHrp
				end
				
				local move = Vector3.new()
				local cam = workspace.CurrentCamera
				local f = cam.CFrame.LookVector
				local r = cam.CFrame.RightVector
				
				if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + f end
				if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - f end
				if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + r end
				if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - r end
				if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
				if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0, 1, 0) end
				
				if move.Magnitude > 0 then
					bodyVelocity.Velocity = move.Unit * settings.flySpeed
				else
					bodyVelocity.Velocity = Vector3.new(0, 0, 0)
				end
			end)
		end
	end
	
	if not v and char and char:FindFirstChild("Humanoid") then
		char.Humanoid.PlatformStand = false
	end
end)
yOffset = yOffset + 50

local flySpeedSlider = createSlider(Content, "Fly Speed", yOffset, 30, 200, settings.flySpeed, function(v)
	settings.flySpeed = v
	saveValue("flySpeed", v)
end)
yOffset = yOffset + 75

-- Раздел NOCLIP
createSection(Content, "NOCLIP", yOffset)
yOffset = yOffset + 45

local noclipToggle, getNoclipState = createToggle(Content, "Noclip (All)", yOffset, settings.noclip, function(v)
	settings.noclip = v
	saveValue("noclip", v)
	
	if noClipConnection then
		noClipConnection:Disconnect()
		noClipConnection = nil
	end
	
	if v then
		noClipConnection = RunService.Stepped:Connect(function()
			if not settings.noclip then return end
			local char = player.Character
			if not char then return end
			for _, part in pairs(char:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
				end
			end
		end)
	end
end)
yOffset = yOffset + 50

local noclipWallsToggle = createToggle(Content, "Through Walls", yOffset, settings.noclipWalls, function(v)
	settings.noclipWalls = v
	saveValue("noclipWalls", v)
end)
yOffset = yOffset + 50

local noclipFloorToggle = createToggle(Content, "Through Floor", yOffset, settings.noclipFloor, function(v)
	settings.noclipFloor = v
	saveValue("noclipFloor", v)
end)
yOffset = yOffset + 50

local noclipCeilingToggle = createToggle(Content, "Through Ceiling", yOffset, settings.noclipCeiling, function(v)
	settings.noclipCeiling = v
	saveValue("noclipCeiling", v)
end)
yOffset = yOffset + 60

-- Раздел COMBAT
createSection(Content, "COMBAT", yOffset)
yOffset = yOffset + 45

local speedHackToggle, getSpeedHackState = createToggle(Content, "Speed Hack", yOffset, settings.speedHack, function(v)
	settings.speedHack = v
	saveValue("speedHack", v)
end)
yOffset = yOffset + 50

local speedHackSlider = createSlider(Content, "Speed Hack Value", yOffset, 20, 200, settings.speedHackValue, function(v)
	settings.speedHackValue = v
	saveValue("speedHackValue", v)
end)
yOffset = yOffset + 75

local infiniteJumpToggle, getInfiniteJumpState = createToggle(Content, "Infinite Jump", yOffset, settings.infiniteJump, function(v)
	settings.infiniteJump = v
	saveValue("infiniteJump", v)
end)
yOffset = yOffset + 60

-- Раздел ESP
createSection(Content, "ESP", yOffset)
yOffset = yOffset + 45

local espPlayersToggle, getEspPlayersState = createToggle(Content, "ESP Players", yOffset, settings.espPlayers, function(v)
	settings.espPlayers = v
	saveValue("espPlayers", v)
end)
yOffset = yOffset + 50

local espChestsToggle, getEspChestsState = createToggle(Content, "ESP Chests", yOffset, settings.espChests, function(v)
	settings.espChests = v
	saveValue("espChests", v)
end)
yOffset = yOffset + 50

local espMobsToggle, getEspMobsState = createToggle(Content, "ESP Mobs", yOffset, settings.espMobs, function(v)
	settings.espMobs = v
	saveValue("espMobs", v)
end)
yOffset = yOffset + 50

local espSizeSlider = createSlider(Content, "ESP Size", yOffset, 0.5, 3, settings.espSize, function(v)
	settings.espSize = v
	saveValue("espSize", v)
end)
yOffset = yOffset + 75

local espHealthToggle, getEspHealthState = createToggle(Content, "ESP Health", yOffset, settings.espHealth, function(v)
	settings.espHealth = v
	saveValue("espHealth", v)
end)
yOffset = yOffset + 50

local espDistanceToggle, getEspDistanceState = createToggle(Content, "ESP Distance", yOffset, settings.espDistance, function(v)
	settings.espDistance = v
	saveValue("espDistance", v)
end)
yOffset = yOffset + 60

-- Раздел THEME
createSection(Content, "THEME", yOffset)
yOffset = yOffset + 45

local rainbowToggle, getRainbowState = createToggle(Content, "Rainbow Mode", yOffset, settings.rainbow, function(v)
	settings.rainbow = v
	saveValue("rainbow", v)
	
	if rainbowConnection then
		rainbowConnection:Disconnect()
		rainbowConnection = nil
	end
	
	if v then
		rainbowConnection = RunService.RenderStepped:Connect(function()
			rainbowHue = (rainbowHue + 0.002) % 1
			local col = Color3.fromHSV(rainbowHue, 1, 1)
			mainStroke.Color = col
			TitleText.TextColor3 = col
		end)
	end
end)
yOffset = yOffset + 60

-- Save button
local SaveBtn = Instance.new("TextButton")
SaveBtn.Size = UDim2.new(1, -20, 0, 45)
SaveBtn.Position = UDim2.new(0, 10, 0, yOffset)
SaveBtn.Text = "💾 SAVE ALL SETTINGS"
SaveBtn.Font = Enum.Font.GothamBold
SaveBtn.TextSize = 14
SaveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 80)
SaveBtn.BorderSizePixel = 0
SaveBtn.Parent = Content

local saveCorner = Instance.new("UICorner")
saveCorner.CornerRadius = UDim.new(0, 8)
saveCorner.Parent = SaveBtn

SaveBtn.MouseButton1Click:Connect(function()
	for k, v in pairs(settings) do
		saveValue(k, v)
	end
	SaveBtn.Text = "✓ SAVED!"
	TweenService:Create(SaveBtn, TweenInfo.new(1.5), {TextColor3 = Color3.fromRGB(100, 255, 100)}):Play()
	task.wait(1.5)
	SaveBtn.Text = "💾 SAVE ALL SETTINGS"
	TweenService:Create(SaveBtn, TweenInfo.new(0.5), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
end)

yOffset = yOffset + 60

-- Reset button
local ResetBtn = Instance.new("TextButton")
ResetBtn.Size = UDim2.new(1, -20, 0, 45)
ResetBtn.Position = UDim2.new(0, 10, 0, yOffset)
ResetBtn.Text = "🗑️ RESET TO DEFAULTS"
ResetBtn.Font = Enum.Font.GothamBold
ResetBtn.TextSize = 14
ResetBtn.TextColor3 = Color3.fromRGB(255, 200, 200)
ResetBtn.BackgroundColor3 = Color3.fromRGB(100, 40, 40)
ResetBtn.BorderSizePixel = 0
ResetBtn.Parent = Content

local resetCorner = Instance.new("UICorner")
resetCorner.CornerRadius = UDim.new(0, 8)
resetCorner.Parent = ResetBtn

ResetBtn.MouseButton1Click:Connect(function()
	walkSlider.setValue(16)
	jumpSlider.setValue(50)
	fovSlider.setValue(70)
	autoRunSlider.setValue(16)
	flySpeedSlider.setValue(50)
	speedHackSlider.setValue(50)
	espSizeSlider.setValue(1.5)
	
	settings.walkSpeed = 16
	settings.jumpPower = 50
	settings.fov = 70
	settings.autoRun = false
	settings.autoRunSpeed = 16
	settings.flyEnabled = false
	settings.flySpeed = 50
	settings.noclip = false
	settings.noclipWalls = false
	settings.noclipFloor = false
	settings.noclipCeiling = false
	settings.speedHack = false
	settings.speedHackValue = 50
	settings.infiniteJump = false
	settings.espPlayers = false
	settings.espChests = false
	settings.espMobs = false
	settings.espSize = 1.5
	settings.espHealth = true
	settings.espDistance = true
	settings.rainbow = false
	
	if autoRunConnection then autoRunConnection:Disconnect() autoRunConnection = nil end
	if flyConnection then flyConnection:Disconnect() flyConnection = nil end
	if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
	if noClipConnection then noClipConnection:Disconnect() noClipConnection = nil end
	if rainbowConnection then rainbowConnection:Disconnect() rainbowConnection = nil end
	
	local char = player.Character
	if char then
		local hum = char:FindFirstChild("Humanoid")
		if hum then
			hum.WalkSpeed = 16
			hum.JumpPower = 50
			hum.PlatformStand = false
		end
	end
	
	ResetBtn.Text = "✓ RESET!"
	TweenService:Create(ResetBtn, TweenInfo.new(1.5), {TextColor3 = Color3.fromRGB(150, 255, 150)}):Play()
	task.wait(1.5)
	ResetBtn.Text = "🗑️ RESET TO DEFAULTS"
	TweenService:Create(ResetBtn, TweenInfo.new(0.5), {TextColor3 = Color3.fromRGB(255, 200, 200)}):Play()
end)

-- =========== ФУНКЦИЯ SPEED HACK ===========
RunService.Heartbeat:Connect(function()
	if settings.speedHack then
		local char = player.Character
		if char and char:FindFirstChild("Humanoid") then
			char.Humanoid.WalkSpeed = settings.speedHackValue
		end
	end
end)

-- =========== ФУНКЦИЯ INFINITE JUMP ===========
UserInputService.JumpRequest:Connect(function()
	if settings.infiniteJump then
		local char = player.Character
		if char and char:FindFirstChild("Humanoid") then
			char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end
end)

-- =========== ФУНКЦИЯ ESP ===========
local espConnectionESP = nil

local function updateESP()
	if espConnectionESP then
		espConnectionESP:Disconnect()
		espConnectionESP = nil
	end
	
	if not (settings.espPlayers or settings.espChests or settings.espMobs) then return end
	
	espConnectionESP = RunService.Heartbeat:Connect(function()
		if not (settings.espPlayers or settings.espChests or settings.espMobs) then return end
		
		local myChar = player.Character
		local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
		
		-- ESP Players
		if settings.espPlayers then
			for _, plr in pairs(Players:GetPlayers()) do
				if plr == player then continue end
				local char = plr.Character
				if not char then continue end
				local hrp = char:FindFirstChild("HumanoidRootPart")
				local hum = char:FindFirstChild("Humanoid")
				if not hrp then continue end
				
				local existing = espPlayersList[plr.UserId]
				if not existing then
					local hl = Instance.new("Highlight")
					hl.FillColor = Color3.fromRGB(255, 50, 50)
					hl.FillTransparency = 0.5
					hl.OutlineColor = Color3.fromRGB(255, 255, 255)
					hl.OutlineTransparency = 0.2
					hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
					hl.Adornee = char
					hl.Parent = char
					
					local bill = Instance.new("BillboardGui")
					bill.Size = UDim2.new(0, 200, 0, 50)
					bill.StudsOffset = Vector3.new(0, 2.5, 0)
					bill.AlwaysOnTop = true
					bill.MaxDistance = 500
					bill.Parent = char:FindFirstChild("Head") or hrp
					
					local frame = Instance.new("Frame")
					frame.Size = UDim2.new(1, 0, 1, 0)
					frame.BackgroundTransparency = 1
					frame.Parent = bill
					
					local nameLbl = Instance.new("TextLabel")
					nameLbl.Text = plr.Name
					nameLbl.Font = Enum.Font.GothamBold
					nameLbl.TextSize = 14
					nameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
					nameLbl.BackgroundTransparency = 1
					nameLbl.Size = UDim2.new(1, 0, 0, 25)
					nameLbl.TextStrokeTransparency = 0.3
					nameLbl.Parent = frame
					
					local hpLbl = Instance.new("TextLabel")
					hpLbl.Name = "Health"
					hpLbl.Font = Enum.Font.Gotham
					hpLbl.TextSize = 11
					hpLbl.TextColor3 = Color3.fromRGB(100, 255, 100)
					hpLbl.BackgroundTransparency = 1
					hpLbl.Size = UDim2.new(1, 0, 0, 18)
					hpLbl.Position = UDim2.new(0, 0, 0, 25)
					hpLbl.TextStrokeTransparency = 0.3
					hpLbl.Parent = frame
					
					local distLbl = Instance.new("TextLabel")
					distLbl.Name = "Distance"
					distLbl.Font = Enum.Font.Gotham
					distLbl.TextSize = 10
					distLbl.TextColor3 = Color3.fromRGB(180, 180, 180)
					distLbl.BackgroundTransparency = 1
					distLbl.Size = UDim2.new(1, 0, 0, 14)
					distLbl.Position = UDim2.new(0, 0, 0, 43)
					distLbl.TextStrokeTransparency = 0.3
					distLbl.Parent = frame
					
					espPlayersList[plr.UserId] = {highlight = hl, billboard = bill, name = nameLbl, health = hpLbl, distance = distLbl}
				end
				
				local data = espPlayersList[plr.UserId]
				if data then
					if settings.espHealth and hum then
						local hp = hum.Health
						local maxHp = hum.MaxHealth
						local percent = (hp / maxHp) * 100
						data.health.Text = string.format("❤️ %.0f%%", percent)
						data.health.Visible = true
					elseif data.health then
						data.health.Visible = false
					end
					
					if settings.espDistance and myRoot then
						local dist = (myRoot.Position - hrp.Position).Magnitude
						data.distance.Text = string.format("%.1f m", dist)
						data.distance.Visible = true
					elseif data.distance then
						data.distance.Visible = false
					end
				end
			end
		else
			for id, data in pairs(espPlayersList) do
				pcall(function() data.highlight:Destroy() end)
				pcall(function() data.billboard:Destroy() end)
				espPlayersList[id] = nil
			end
		end
		
		-- ESP Chests (Suspicious Блоки)
		if settings.espChests then
			for _, obj in pairs(Workspace:GetDescendants()) do
				if obj:IsA("BasePart") and (obj.Name:lower():find("chest") or obj.Name:lower():find("crate") or obj.Name:lower():find("barrel")) then
					local existing = espChestsList[obj]
					if not existing then
						local hl = Instance.new("Highlight")
						hl.FillColor = Color3.fromRGB(255, 200, 50)
						hl.FillTransparency = 0.4
						hl.OutlineColor = Color3.fromRGB(255, 255, 100)
						hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
						hl.Adornee = obj
						hl.Parent = obj
						espChestsList[obj] = hl
					end
				end
			end
		else
			for obj, hl in pairs(espChestsList) do
				pcall(function() hl:Destroy() end)
				espChestsList[obj] = nil
			end
		end
		
		-- ESP Mobs (NPC/Enemies)
		if settings.espMobs then
			for _, obj in pairs(Workspace:GetDescendants()) do
				if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj ~= myChar then
					local existing = espMobsList[obj]
					if not existing then
						local hl = Instance.new("Highlight")
						hl.FillColor = Color3.fromRGB(255, 100, 255)
						hl.FillTransparency = 0.5
						hl.OutlineColor = Color3.fromRGB(255, 255, 255)
						hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
						hl.Adornee = obj
						hl.Parent = obj
						espMobsList[obj] = hl
					end
				end
			end
		else
			for obj, hl in pairs(espMobsList) do
				pcall(function() hl:Destroy() end)
				espMobsList[obj] = nil
			end
		end
		
		-- ESP Size
		local espSize = settings.espSize
		for _, data in pairs(espPlayersList) do
			if data.billboard then
				data.billboard.Size = UDim2.new(0, 200 * espSize, 0, 50 * espSize)
			end
		end
	end)
end

-- Запускаем ESP
updateESP()

-- Подписываемся на изменения
for _, event in pairs({Players.PlayerAdded, Players.PlayerRemoving}) do
	event:Connect(function() task.wait(0.5) updateESP() end)
end

-- =========== ОБРАБОТКА ПЕРЕЗАХОДА ===========
player.CharacterAdded:Connect(function(char)
	task.wait(1)
	local hum = char:FindFirstChild("Humanoid")
	if hum then
		hum.WalkSpeed = settings.walkSpeed
		hum.JumpPower = settings.jumpPower
	end
	
	if settings.flyEnabled then
		task.wait(0.5)
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if hrp and hum then
			hum.PlatformStand = true
			if bodyVelocity then bodyVelocity:Destroy() end
			bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
			bodyVelocity.Parent = hrp
		end
	end
	
	if settings.noclip then
		task.wait(0.5)
		if noClipConnection then noClipConnection:Disconnect() end
		noClipConnection = RunService.Stepped:Connect(function()
			if not settings.noclip then return end
			local newChar = player.Character
			if not newChar then return end
			for _, part in pairs(newChar:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
				end
			end
		end)
	end
	
	if settings.autoRun then
		if autoRunConnection then autoRunConnection:Disconnect() end
		autoRunConnection = RunService.Heartbeat:Connect(function()
			local c = player.Character
			if not c then return end
			local h = c:FindFirstChild("Humanoid")
			local r = c:FindFirstChild("HumanoidRootPart")
			if h and r then
				local dir = r.CFrame.LookVector * Vector3.new(1, 0, 1)
				if dir.Magnitude > 0.01 then
					h:Move(dir.Unit, true)
				end
			end
		end)
	end
end)

-- =========== АВТОЗАПУСК ФУНКЦИЙ (Auto Start) ===========
local autoStart = loadValue("AutoStart", true)

if autoStart then
	task.wait(2)
	if settings.autoRun then
		autoRunConnection = RunService.Heartbeat:Connect(function()
			local c = player.Character
			if not c then return end
			local h = c:FindFirstChild("Humanoid")
			local r = c:FindFirstChild("HumanoidRootPart")
			if h and r then
				local dir = r.CFrame.LookVector * Vector3.new(1, 0, 1)
				if dir.Magnitude > 0.01 then
					h:Move(dir.Unit, true)
				end
			end
		end)
	end
	
	if settings.flyEnabled then
		task.wait(1)
		local char = player.Character
		if char then
			local hrp = char:FindFirstChild("HumanoidRootPart")
			local hum = char:FindFirstChild("Humanoid")
			if hrp and hum then
				hum.PlatformStand = true
				bodyVelocity = Instance.new("BodyVelocity")
				bodyVelocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
				bodyVelocity.Parent = hrp
				flyConnection = RunService.Heartbeat:Connect(function()
					if not settings.flyEnabled then return end
					local newChar = player.Character
					if not newChar then return end
					local newHrp = newChar:FindFirstChild("HumanoidRootPart")
					local newHum = newChar:FindFirstChild("Humanoid")
					if not newHrp or not newHum then return end
					if bodyVelocity and bodyVelocity.Parent ~= newHrp then bodyVelocity.Parent = newHrp end
					local move = Vector3.new()
					local cam = workspace.CurrentCamera
					if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
					if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
					if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
					if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
					if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
					if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0, 1, 0) end
					bodyVelocity.Velocity = move.Magnitude > 0 and move.Unit * settings.flySpeed or Vector3.zero
				end)
			end
		end
	end
	
	if settings.noclip then
		noClipConnection = RunService.Stepped:Connect(function()
			if not settings.noclip then return end
			local char = player.Character
			if not char then return end
			for _, part in pairs(char:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
				end
			end
		end)
	end
end

-- =========== ПОКАЗЫВАЕМ МЕНЮ ===========
task.wait(5.5)
MainFrame.Visible = true
local menuAppear = TweenService:Create(MainFrame, TweenInfo.new(0.4), {BackgroundTransparency = 0.05})
menuAppear:Play()

MinimizeBtn.MouseButton1Click:Connect(function()
	MainFrame.Visible = not MainFrame.Visible
end)

CloseBtn.MouseButton1Click:Connect(function()
	TweenService:Create(MainFrame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
	task.wait(0.3)
	ScreenGui:Destroy()
end)

print("✅ Synapse Hub v11 loaded!")
print("📢 Telegram: @VanezyScripts")
