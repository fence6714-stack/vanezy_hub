--[[
	SYNAPSE HUB v15 - WITH RESIZE & NOTIFICATIONS
	by Vanezy Scripts
]]

print("START - Synapse Hub v15")

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
if not player then
	player = Players.PlayerAdded:Wait()
end

-- =========== CLIPBOARD ===========
local Clipboard = setclipboard or toclipboard or function() end

-- =========== НАСТРОЙКИ ПО УМОЛЧАНИЮ ===========
local DEFAULT_SETTINGS = {
	walkSpeed = 16,
	jumpPower = 50,
	fov = 70,
	espPlayers = false,
	espChests = false,
	espMobs = false,
	espSize = 1.5,
	espHealth = true,
	espDistance = true,
	flyEnabled = false,
	flySpeed = 50,
	noclip = false,
	speedHack = false,
	speedHackValue = 50,
	infiniteJump = false,
	rainbow = false,
	windowWidth = 400,
	windowHeight = 300
}

-- =========== ТЕКУЩИЕ НАСТРОЙКИ ===========
local settings = {}

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

for key, default in pairs(DEFAULT_SETTINGS) do
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
local espConnection = nil

local espPlayersList = {}
local espChestsList = {}
local espMobsList = {}

local isMinimized = false
local floatingButton = nil

-- =========== СОЗДАНИЕ GUI ===========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SynapseHub"
ScreenGui.ResetOnSpawn = false

local playerGui = player:WaitForChild("PlayerGui")
pcall(function()
	ScreenGui.Parent = playerGui
end)

if not ScreenGui.Parent then
	ScreenGui.Parent = playerGui
end

-- =========== ПЛАВАЮЩАЯ КНОПКА ===========
local function createFloatingButton()
	if floatingButton then
		floatingButton:Destroy()
		floatingButton = nil
	end
	
	floatingButton = Instance.new("TextButton")
	floatingButton.Size = UDim2.new(0, 50, 0, 50)
	floatingButton.Position = UDim2.new(0, 10, 0.5, -25)
	floatingButton.Text = "✨"
	floatingButton.Font = Enum.Font.GothamBold
	floatingButton.TextSize = 24
	floatingButton.TextColor3 = Color3.fromRGB(0, 160, 255)
	floatingButton.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
	floatingButton.BackgroundTransparency = 0.1
	floatingButton.BorderSizePixel = 0
	floatingButton.ZIndex = 400
	floatingButton.Visible = false
	floatingButton.Parent = ScreenGui
	
	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(1, 0)
	btnCorner.Parent = floatingButton
	
	local btnStroke = Instance.new("UIStroke")
	btnStroke.Color = Color3.fromRGB(0, 140, 255)
	btnStroke.Thickness = 1.5
	btnStroke.Parent = floatingButton
	
	local btnDragging = false
	local btnDragStart, btnStartPos
	
	floatingButton.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			btnDragging = true
			btnDragStart = input.Position
			btnStartPos = floatingButton.Position
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if btnDragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
			local delta = input.Position - btnDragStart
			floatingButton.Position = UDim2.new(
				btnStartPos.X.Scale,
				math.clamp(btnStartPos.X.Offset + delta.X, 0, 500),
				btnStartPos.Y.Scale,
				math.clamp(btnStartPos.Y.Offset + delta.Y, 0, 700)
			)
		end
	end)
	
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			btnDragging = false
		end
	end)
	
	floatingButton.MouseButton1Click:Connect(function()
		restoreMenu()
	end)
	
	return floatingButton
end

-- =========== СИСТЕМА УВЕДОМЛЕНИЙ (СПРАВА СВЕРХУ) ===========
local activeNotifications = {}
local notificationContainer = nil

local function createNotification(text, duration)
	if not notificationContainer then
		notificationContainer = Instance.new("Frame")
		notificationContainer.Name = "NotificationContainer"
		notificationContainer.Size = UDim2.new(0, 320, 0, 0)
		notificationContainer.Position = UDim2.new(1, -340, 0, 10)
		notificationContainer.BackgroundTransparency = 1
		notificationContainer.ClipsDescendants = false
		notificationContainer.ZIndex = 300
		notificationContainer.Parent = ScreenGui
	end
	
	local notification = Instance.new("Frame")
	notification.Size = UDim2.new(1, 0, 0, 50)
	notification.Position = UDim2.new(0, 0, 1, 0)
	notification.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	notification.BackgroundTransparency = 0.1
	notification.BorderSizePixel = 0
	notification.ZIndex = 301
	notification.Parent = notificationContainer
	
	local notifCorner = Instance.new("UICorner")
	notifCorner.CornerRadius = UDim.new(0, 10)
	notifCorner.Parent = notification
	
	local notifStroke = Instance.new("UIStroke")
	notifStroke.Color = mainStroke and mainStroke.Color or Color3.fromRGB(0, 140, 255)
	notifStroke.Thickness = 1
	notifStroke.Parent = notification
	
	local textLabel = Instance.new("TextLabel")
	textLabel.Text = text
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextSize = 12
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.BackgroundTransparency = 1
	textLabel.Size = UDim2.new(1, -15, 0, 30)
	textLabel.Position = UDim2.new(0, 10, 0, 5)
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.ZIndex = 302
	textLabel.Parent = notification
	
	local progressBar = Instance.new("Frame")
	progressBar.Size = UDim2.new(1, -20, 0, 3)
	progressBar.Position = UDim2.new(0, 10, 0, 42)
	progressBar.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
	progressBar.BorderSizePixel = 0
	progressBar.ZIndex = 302
	progressBar.Parent = notification
	
	local progressCorner = Instance.new("UICorner")
	progressCorner.CornerRadius = UDim.new(1, 0)
	progressCorner.Parent = progressBar
	
	local progressFill = Instance.new("Frame")
	progressFill.Size = UDim2.new(1, 0, 1, 0)
	progressFill.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
	progressFill.BorderSizePixel = 0
	progressFill.ZIndex = 303
	progressFill.Parent = progressBar
	
	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(1, 0)
	fillCorner.Parent = progressFill
	
	-- Анимация появления
	notification.BackgroundTransparency = 1
	notification.Size = UDim2.new(1, 0, 0, 0)
	
	local appearTween = TweenService:Create(notification, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
		BackgroundTransparency = 0.1,
		Size = UDim2.new(1, 0, 0, 50)
	})
	appearTween:Play()
	
	-- Сдвигаем существующие уведомления вниз
	for i, notif in ipairs(activeNotifications) do
		local newY = (i) * 60
		TweenService:Create(notif.frame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
			Position = UDim2.new(0, 0, 0, newY)
		}):Play()
	end
	
	local notificationData = {
		frame = notification,
		progressFill = progressFill,
		textLabel = textLabel,
		duration = duration
	}
	table.insert(activeNotifications, 1, notificationData)
	
	notification.Position = UDim2.new(0, 0, 0, 0)
	
	-- Анимация ползунка (уменьшается)
	local progressTween = TweenService:Create(progressFill, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
		Size = UDim2.new(0, 0, 1, 0)
	})
	progressTween:Play()
	
	-- Удаление через время
	task.spawn(function()
		task.wait(duration)
		
		for i, data in ipairs(activeNotifications) do
			if data.frame == notification then
				table.remove(activeNotifications, i)
				
				local fadeOut = TweenService:Create(notification, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 0)
				})
				fadeOut:Play()
				fadeOut.Completed:Connect(function()
					notification:Destroy()
				end)
				
				-- Сдвигаем оставшиеся уведомления вверх
				for j, remaining in ipairs(activeNotifications) do
					local newY = (j - 1) * 60
					TweenService:Create(remaining.frame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
						Position = UDim2.new(0, 0, 0, newY)
					}):Play()
				end
				break
			end
		end
	end)
	
	return notification
end

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

local adAppear = TweenService:Create(AdFrame, TweenInfo.new(0.5), {BackgroundTransparency = 0.05})
adAppear:Play()

TelegramButton.MouseButton1Click:Connect(function()
	local telegramLink = "https://t.me/VanezyScripts"
	pcall(function()
		Clipboard(telegramLink)
	end)
	createNotification("🔗 Link Copied! 📋", 2)
end)

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
MainFrame.Size = UDim2.new(0, settings.windowWidth, 0, settings.windowHeight)
MainFrame.Position = UDim2.new(0.5, -settings.windowWidth/2, 0.5, -settings.windowHeight/2)
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

-- =========== СИСТЕМА РАЗМЕРА ЗА УГЛЫ ===========
local resizeZones = {}

local function createResizeZone(cursor, position, size)
	local zone = Instance.new("Frame")
	zone.Size = UDim2.new(0, size, 0, size)
	zone.Position = position
	zone.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	zone.BackgroundTransparency = 1
	zone.BorderSizePixel = 0
	zone.ZIndex = 100
	zone.Parent = MainFrame
	
	local isResizing = false
	local startPos, startSize, startMouse
	
	zone.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			isResizing = true
			startPos = MainFrame.Position
			startSize = MainFrame.Size
			startMouse = input.Position
			
			zone.BackgroundTransparency = 0.5
			zone.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if isResizing and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
			local delta = input.Position - startMouse
			local newWidth = startSize.X.Offset
			local newHeight = startSize.Y.Offset
			
			if cursor == "bottomRight" then
				newWidth = math.clamp(startSize.X.Offset + delta.X, 150, 450)
				newHeight = math.clamp(startSize.Y.Offset + delta.Y, 100, 350)
				MainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
			elseif cursor == "bottomLeft" then
				newWidth = math.clamp(startSize.X.Offset - delta.X, 150, 450)
				newHeight = math.clamp(startSize.Y.Offset + delta.Y, 100, 350)
				local newX = startPos.X.Offset + (startSize.X.Offset - newWidth)
				MainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
				MainFrame.Position = UDim2.new(startPos.X.Scale, newX, startPos.Y.Scale, startPos.Y.Offset)
			elseif cursor == "topRight" then
				newWidth = math.clamp(startSize.X.Offset + delta.X, 150, 450)
				newHeight = math.clamp(startSize.Y.Offset - delta.Y, 100, 350)
				local newY = startPos.Y.Offset + (startSize.Y.Offset - newHeight)
				MainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
				MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset, startPos.Y.Scale, newY)
			elseif cursor == "topLeft" then
				newWidth = math.clamp(startSize.X.Offset - delta.X, 150, 450)
				newHeight = math.clamp(startSize.Y.Offset - delta.Y, 100, 350)
				local newX = startPos.X.Offset + (startSize.X.Offset - newWidth)
				local newY = startPos.Y.Offset + (startSize.Y.Offset - newHeight)
				MainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
				MainFrame.Position = UDim2.new(startPos.X.Scale, newX, startPos.Y.Scale, newY)
			end
			
			settings.windowWidth = newWidth
			settings.windowHeight = newHeight
		end
	end)
	
	UserInputService.InputEnded:Connect(function(input)
		if isResizing and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) then
			isResizing = false
			zone.BackgroundTransparency = 1
		end
	end)
	
	return zone
end

-- Создаём зоны для ресайза по углам
local bottomRight = createResizeZone("bottomRight", UDim2.new(1, -12, 1, -12), 20)
local bottomLeft = createResizeZone("bottomLeft", UDim2.new(0, -8, 1, -12), 20)
local topRight = createResizeZone("topRight", UDim2.new(1, -12, 0, -8), 20)
local topLeft = createResizeZone("topLeft", UDim2.new(0, -8, 0, -8), 20)

-- Украшаем зоны ресайза (визуальные маркеры)
for _, zone in pairs({bottomRight, bottomLeft, topRight, topLeft}) do
	local marker = Instance.new("Frame")
	marker.Size = UDim2.new(0, 8, 0, 8)
	marker.Position = UDim2.new(0.5, -4, 0.5, -4)
	marker.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
	marker.BackgroundTransparency = 0.5
	marker.BorderSizePixel = 0
	marker.Parent = zone
	
	local markerCorner = Instance.new("UICorner")
	markerCorner.CornerRadius = UDim.new(1, 0)
	markerCorner.Parent = marker
end

-- Заголовок для Drag
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
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
ByLabel.Position = UDim2.new(0, 12, 0, 24)
ByLabel.TextXAlignment = Enum.TextXAlignment.Left
ByLabel.Parent = TitleBar

-- Кнопки
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -70, 0, 5)
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
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -36, 0, 5)
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

-- =========== ФУНКЦИИ СВОРАЧИВАНИЯ ===========
local function minimizeMenu()
	if isMinimized then return end
	isMinimized = true
	
	local hideTween = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 0, 0, 0)
	})
	hideTween:Play()
	hideTween.Completed:Connect(function()
		MainFrame.Visible = false
	end)
	
	if not floatingButton then
		createFloatingButton()
	end
	floatingButton.Visible = true
	local btnAppear = TweenService:Create(floatingButton, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
		BackgroundTransparency = 0.1,
		Size = UDim2.new(0, 55, 0, 55)
	})
	btnAppear:Play()
end

local function restoreMenu()
	if not isMinimized then return end
	isMinimized = false
	
	local btnHide = TweenService:Create(floatingButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 0, 0, 0)
	})
	btnHide:Play()
	btnHide.Completed:Connect(function()
		floatingButton.Visible = false
	end)
	
	MainFrame.Visible = true
	MainFrame.Size = UDim2.new(0, settings.windowWidth, 0, settings.windowHeight)
	MainFrame.BackgroundTransparency = 0.05
	local showTween = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
		BackgroundTransparency = 0.05,
		Size = UDim2.new(0, settings.windowWidth, 0, settings.windowHeight)
	})
	showTween:Play()
end

MinimizeBtn.MouseButton1Click:Connect(minimizeMenu)

CloseBtn.MouseButton1Click:Connect(function()
	if floatingButton then
		floatingButton:Destroy()
		floatingButton = nil
	end
	TweenService:Create(MainFrame, TweenInfo.new(0.25), {BackgroundTransparency = 1, Size = UDim2.new(0, 0, 0, 0)}):Play()
	task.wait(0.25)
	ScreenGui:Destroy()
end)

-- =========== СКРОЛЛИНГ КОНТЕЙНЕР ===========
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, 0, 1, -40)
ScrollFrame.Position = UDim2.new(0, 0, 0, 40)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 550)
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 140, 255)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.Parent = MainFrame

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, 0, 0, 580)
Content.BackgroundTransparency = 1
Content.Parent = ScrollFrame

-- =========== ФУНКЦИИ UI ===========
local function createSection(parent, name, yPos)
	local section = Instance.new("Frame")
	section.Size = UDim2.new(1, -20, 0, 28)
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
	secText.TextSize = 11
	secText.TextColor3 = Color3.fromRGB(0, 160, 255)
	secText.BackgroundTransparency = 1
	secText.Size = UDim2.new(1, -10, 1, 0)
	secText.Position = UDim2.new(0, 10, 0, 0)
	secText.TextXAlignment = Enum.TextXAlignment.Left
	secText.TextYAlignment = Enum.TextYAlignment.Center
	secText.Parent = section
end

local function createToggle(parent, name, yPos, defaultState, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -20, 0, 35)
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
	label.TextSize = 11
	label.TextColor3 = Color3.fromRGB(180, 180, 200)
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(0.6, 0, 1, 0)
	label.Position = UDim2.new(0, 10, 0, 0)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame
	
	local btn = Instance.new("Frame")
	btn.Size = UDim2.new(0, 42, 0, 22)
	btn.Position = UDim2.new(1, -52, 0.5, -11)
	btn.BackgroundColor3 = defaultState and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(200, 50, 50)
	btn.BorderSizePixel = 0
	btn.Parent = frame
	
	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(1, 0)
	btnCorner.Parent = btn
	
	local dot = Instance.new("Frame")
	dot.Size = UDim2.new(0, 16, 0, 16)
	dot.Position = defaultState and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
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
		local targetPos = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = targetColor}):Play()
		TweenService:Create(dot, TweenInfo.new(0.15), {Position = targetPos}):Play()
		if callback then callback(state) end
	end)
	
	return frame
end

local function createSlider(parent, name, yPos, minVal, maxVal, defaultVal, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -20, 0, 55)
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
	label.TextSize = 11
	label.TextColor3 = Color3.fromRGB(180, 180, 200)
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, -20, 0, 20)
	label.Position = UDim2.new(0, 10, 0, 5)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame
	
	local bar = Instance.new("Frame")
	bar.Size = UDim2.new(1, -24, 0, 4)
	bar.Position = UDim2.new(0, 12, 0, 35)
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
	knob.Size = UDim2.new(0, 14, 0, 14)
	knob.Position = UDim2.new(ratio, -7, 0.5, -7)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.BorderSizePixel = 0
	knob.Parent = bar
	
	local knobCorner = Instance.new("UICorner")
	knobCorner.CornerRadius = UDim.new(1, 0)
	knobCorner.Parent = knob
	
	local isDragging = false
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
		knob.Position = UDim2.new(relX, -7, 0.5, -7)
		label.Text = name .. " [" .. tostring(val) .. "]"
		currentVal = val
		if callback then callback(val) end
	end
	
	knob.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			isDragging = true
		end
	end)
	
	bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			isDragging = true
			updateSlider(input)
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if isDragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
			updateSlider(input)
		end
	end)
	
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			isDragging = false
		end
	end)
	
	callback(defaultVal)
	
	return {
		setValue = function(val)
			local r = (val - minVal) / (maxVal - minVal)
			r = math.clamp(r, 0, 1)
			fill.Size = UDim2.new(r, 0, 1, 0)
			knob.Position = UDim2.new(r, -7, 0.5, -7)
			label.Text = name .. " [" .. tostring(val) .. "]"
			currentVal = val
			if callback then callback(val) end
		end
	}
end

-- =========== СОЗДАНИЕ UI ===========
local yOffset = 10

createSection(Content, "MOVEMENT", yOffset)
yOffset = yOffset + 36

local walkSlider = createSlider(Content, "Walk Speed", yOffset, 8, 120, settings.walkSpeed, function(v)
	settings.walkSpeed = v
	saveValue("walkSpeed", v)
	local char = player.Character
	if char and char:FindFirstChild("Humanoid") then
		char.Humanoid.WalkSpeed = v
	end
end)
yOffset = yOffset + 63

local jumpSlider = createSlider(Content, "Jump Power", yOffset, 30, 250, settings.jumpPower, function(v)
	settings.jumpPower = v
	saveValue("jumpPower", v)
	local char = player.Character
	if char and char:FindFirstChild("Humanoid") then
		char.Humanoid.JumpPower = v
	end
end)
yOffset = yOffset + 63

local fovSlider = createSlider(Content, "Field of View", yOffset, 50, 120, settings.fov, function(v)
	settings.fov = v
	saveValue("fov", v)
	if camera then camera.FieldOfView = v end
end)
yOffset = yOffset + 63

createSection(Content, "FLY SYSTEM", yOffset)
yOffset = yOffset + 36

local flyToggle = createToggle(Content, "Fly Mode", yOffset, settings.flyEnabled, function(v)
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
yOffset = yOffset + 43

local flySpeedSlider = createSlider(Content, "Fly Speed", yOffset, 30, 200, settings.flySpeed, function(v)
	settings.flySpeed = v
	saveValue("flySpeed", v)
end)
yOffset = yOffset + 63

createSection(Content, "COMBAT", yOffset)
yOffset = yOffset + 36

local noclipToggle = createToggle(Content, "Noclip", yOffset, settings.noclip, function(v)
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
yOffset = yOffset + 43

local speedHackToggle = createToggle(Content, "Speed Hack", yOffset, settings.speedHack, function(v)
	settings.speedHack = v
	saveValue("speedHack", v)
end)
yOffset = yOffset + 43

local speedHackSlider = createSlider(Content, "Speed Hack Value", yOffset, 20, 200, settings.speedHackValue, function(v)
	settings.speedHackValue = v
	saveValue("speedHackValue", v)
end)
yOffset = yOffset + 63

local infiniteJumpToggle = createToggle(Content, "Infinite Jump", yOffset, settings.infiniteJump, function(v)
	settings.infiniteJump = v
	saveValue("infiniteJump", v)
end)
yOffset = yOffset + 50

createSection(Content, "ESP", yOffset)
yOffset = yOffset + 36

local espPlayersToggle = createToggle(Content, "ESP Players", yOffset, settings.espPlayers, function(v)
	settings.espPlayers = v
	saveValue("espPlayers", v)
	updateESP()
end)
yOffset = yOffset + 43

local espChestsToggle = createToggle(Content, "ESP Chests", yOffset, settings.espChests, function(v)
	settings.espChests = v
	saveValue("espChests", v)
	updateESP()
end)
yOffset = yOffset + 43

local espMobsToggle = createToggle(Content, "ESP Mobs", yOffset, settings.espMobs, function(v)
	settings.espMobs = v
	saveValue("espMobs", v)
	updateESP()
end)
yOffset = yOffset + 43

local espSizeSlider = createSlider(Content, "ESP Size", yOffset, 0.5, 3, settings.espSize, function(v)
	settings.espSize = v
	saveValue("espSize", v)
end)
yOffset = yOffset + 63

local espHealthToggle = createToggle(Content, "ESP Health", yOffset, settings.espHealth, function(v)
	settings.espHealth = v
	saveValue("espHealth", v)
end)
yOffset = yOffset + 43

local espDistanceToggle = createToggle(Content, "ESP Distance", yOffset, settings.espDistance, function(v)
	settings.espDistance = v
	saveValue("espDistance", v)
end)
yOffset = yOffset + 50

createSection(Content, "THEME", yOffset)
yOffset = yOffset + 36

local rainbowToggle = createToggle(Content, "Rainbow Mode", yOffset, settings.rainbow, function(v)
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
yOffset = yOffset + 50

-- Кнопки
local SaveBtn = Instance.new("TextButton")
SaveBtn.Size = UDim2.new(0.45, -15, 0, 35)
SaveBtn.Position = UDim2.new(0.03, 0, 0, yOffset)
SaveBtn.Text = "💾 SAVE"
SaveBtn.Font = Enum.Font.GothamBold
SaveBtn.TextSize = 12
SaveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 80)
SaveBtn.BorderSizePixel = 0
SaveBtn.Parent = Content

local saveCorner = Instance.new("UICorner")
saveCorner.CornerRadius = UDim.new(0, 6)
saveCorner.Parent = SaveBtn

SaveBtn.MouseButton1Click:Connect(function()
	for k, v in pairs(settings) do
		saveValue(k, v)
	end
	saveValue("windowWidth", settings.windowWidth)
	saveValue("windowHeight", settings.windowHeight)
	createNotification("💾 Settings Saved! ✓", 2)
	
	SaveBtn.Text = "✓ SAVED!"
	TweenService:Create(SaveBtn, TweenInfo.new(1), {TextColor3 = Color3.fromRGB(100, 255, 100)}):Play()
	task.wait(1)
	SaveBtn.Text = "💾 SAVE"
	TweenService:Create(SaveBtn, TweenInfo.new(0.5), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
end)

local ResetBtn = Instance.new("TextButton")
ResetBtn.Size = UDim2.new(0.45, -15, 0, 35)
ResetBtn.Position = UDim2.new(0.52, 0, 0, yOffset)
ResetBtn.Text = "🗑️ RESET"
ResetBtn.Font = Enum.Font.GothamBold
ResetBtn.TextSize = 12
ResetBtn.TextColor3 = Color3.fromRGB(255, 200, 200)
ResetBtn.BackgroundColor3 = Color3.fromRGB(100, 40, 40)
ResetBtn.BorderSizePixel = 0
ResetBtn.Parent = Content

local resetCorner = Instance.new("UICorner")
resetCorner.CornerRadius = UDim.new(0, 6)
resetCorner.Parent = ResetBtn

ResetBtn.MouseButton1Click:Connect(function()
	for key, default in pairs(DEFAULT_SETTINGS) do
		settings[key] = default
		saveValue(key, default)
	end
	
	walkSlider.setValue(16)
	jumpSlider.setValue(50)
	fovSlider.setValue(70)
	flySpeedSlider.setValue(50)
	speedHackSlider.setValue(50)
	espSizeSlider.setValue(1.5)
	settings.windowWidth = 400
	settings.windowHeight = 300
	MainFrame.Size = UDim2.new(0, 400, 0, 300)
	MainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
	
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
	
	updateESP()
	createNotification("🗑️ Reset to Defaults ✓", 2)
	
	ResetBtn.Text = "✓ RESET!"
	TweenService:Create(ResetBtn, TweenInfo.new(1), {TextColor3 = Color3.fromRGB(150, 255, 150)}):Play()
	task.wait(1)
	ResetBtn.Text = "🗑️ RESET"
	TweenService:Create(ResetBtn, TweenInfo.new(0.5), {TextColor3 = Color3.fromRGB(255, 200, 200)}):Play()
end)

yOffset = yOffset + 50
Content.Size = UDim2.new(1, 0, 0, yOffset + 10)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset + 20)

-- =========== ФУНКЦИИ ===========
RunService.Heartbeat:Connect(function()
	if settings.speedHack then
		local char = player.Character
		if char and char:FindFirstChild("Humanoid") then
			char.Humanoid.WalkSpeed = settings.speedHackValue
		end
	end
end)

UserInputService.JumpRequest:Connect(function()
	if settings.infiniteJump then
		local char = player.Character
		if char and char:FindFirstChild("Humanoid") then
			char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end
end)

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

-- =========== ESP (С ПОЛНОЙ ОЧИСТКОЙ ПРИ ОТКЛЮЧЕНИИ) ===========
function updateESP()
	if espConnection then
		espConnection:Disconnect()
		espConnection = nil
	end
	
	-- Полная очистка всех ESP объектов ПРИ ЛЮБОМ ВЫЗОВЕ
	for id, data in pairs(espPlayersList) do
		pcall(function() data.highlight:Destroy() end)
		pcall(function() data.billboard:Destroy() end)
		espPlayersList[id] = nil
	end
	
	for obj, hl in pairs(espChestsList) do
		pcall(function() hl:Destroy() end)
		espChestsList[obj] = nil
	end
	
	for obj, hl in pairs(espMobsList) do
		pcall(function() hl:Destroy() end)
		espMobsList[obj] = nil
	end
	
	if not settings.espPlayers then return end
	
	espConnection = RunService.Heartbeat:Connect(function()
		if not settings.espPlayers then return end
		
		for _, plr in pairs(Players:GetPlayers()) do
			if plr == player then continue end
			local char = plr.Character
			if not char then continue end
			local hrp = char:FindFirstChild("HumanoidRootPart")
			local hum = char:FindFirstChild("Humanoid")
			if not hrp then continue end
			
			if not espPlayersList[plr.UserId] then
				local hl = Instance.new("Highlight")
				hl.FillColor = Color3.fromRGB(255, 50, 50)
				hl.FillTransparency = 0.5
				hl.OutlineColor = Color3.fromRGB(255, 255, 255)
				hl.OutlineTransparency = 0.2
				hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				hl.Adornee = char
				hl.Parent = char
				
				local head = char:FindFirstChild("Head") or hrp
				local bill = Instance.new("BillboardGui")
				bill.Size = UDim2.new(0, 200 * settings.espSize, 0, 50 * settings.espSize)
				bill.StudsOffset = Vector3.new(0, 2.5, 0)
				bill.AlwaysOnTop = true
				bill.MaxDistance = 500
				bill.Parent = head
				
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
				if data.billboard then
					data.billboard.Size = UDim2.new(0, 200 * settings.espSize, 0, 50 * settings.espSize)
				end
				
				if settings.espHealth and hum then
					local hp = math.floor(hum.Health)
					data.health.Text = "❤️ " .. hp
					data.health.Visible = true
				elseif data.health then
					data.health.Visible = false
				end
				
				if settings.espDistance then
					local myChar = player.Character
					local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
					if myRoot then
						local dist = (myRoot.Position - hrp.Position).Magnitude
						data.distance.Text = string.format("%.1f m", dist)
						data.distance.Visible = true
					end
				elseif data.distance then
					data.distance.Visible = false
				end
			end
		end
		
		-- ESP Chests
		if settings.espChests then
			for _, obj in pairs(Workspace:GetDescendants()) do
				if obj:IsA("BasePart") and (obj.Name:lower():find("chest") or obj.Name:lower():find("crate") or obj.Name:lower():find("barrel")) then
					if not espChestsList[obj] then
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
		end
		
		-- ESP Mobs
		if settings.espMobs then
			for _, obj in pairs(Workspace:GetDescendants()) do
				if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj ~= player.Character then
					if not espMobsList[obj] then
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
		end
	end)
end

updateESP()

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
end)

-- =========== АВТОЗАПУСК ===========
local autoStart = loadValue("AutoStart", true)

if autoStart then
	task.wait(2)
	
	if settings.flyEnabled then
		task.wait(0.5)
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

createNotification("✨ Script Loaded!", 2)

print("✅ Synapse Hub v15 loaded!")
print("📢 Telegram: @VanezyScripts")
