--[[
	SYNAPSE HUB v7 - FULL SAVE SYSTEM + AUTO START + ADVERTISEMENT
	by Vanezy Scripts
	No ?. operator, full nil protection, executor compatible
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
if not player then
	warn("Player not found! Waiting...")
	player = Players.LocalPlayer or Players.PlayerAdded:Wait()
end

-- Values storage
local StorageValues = Instance.new("Folder")
StorageValues.Name = "UISettings"
StorageValues.Parent = player

local function loadValue(name, default)
	local val = StorageValues:GetAttribute(name)
	if val ~= nil then
		return val
	end
	return default
end

local function saveValue(name, value)
	StorageValues:SetAttribute(name, value)
end

-- Load settings
local savedWalkSpeed = loadValue("WalkSpeed", 16)
local savedJumpPower = loadValue("JumpPower", 50)
local savedFOV = loadValue("FOV", 70)
local savedAutoWalk = loadValue("AutoWalk", false)
local savedESP = loadValue("ESP", false)
local savedRainbow = loadValue("Rainbow", false)
local savedAutoStart = loadValue("AutoStart", true)

-- State
local autoWalkEnabled = savedAutoWalk
local autoWalkConnection = nil
local espEnabled = savedESP
local espHighlights = {}
local espBillboards = {}
local rainbowEnabled = savedRainbow
local rainbowHue = 0
local rainbowConnection = nil

-- Character variables
local character = nil
local humanoid = nil
local camera = nil

local function getChar()
	local char = player.Character
	if char then
		character = char
		local hum = char:FindFirstChild("Humanoid")
		if hum then
			humanoid = hum
			humanoid.WalkSpeed = savedWalkSpeed
			humanoid.JumpPower = savedJumpPower
		end
	end
	if workspace.CurrentCamera then
		camera = workspace.CurrentCamera
		camera.FieldOfView = savedFOV
	end
end

getChar()

if not character then
	character = player.CharacterAdded:Wait()
	humanoid = character:WaitForChild("Humanoid")
	humanoid.WalkSpeed = savedWalkSpeed
	humanoid.JumpPower = savedJumpPower
end
if not camera then
	camera = workspace.CurrentCamera
	if camera then
		camera.FieldOfView = savedFOV
	end
end

-- Safe PlayerGui getter
local function getGui()
	local gui = player:FindFirstChild("PlayerGui")
	if not gui then
		pcall(function()
			gui = player:WaitForChild("PlayerGui", 5)
		end)
	end
	return gui
end

-- Create ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SynapseHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local parentGui = getGui()
if parentGui then
	ScreenGui.Parent = parentGui
else
	local success = pcall(function()
		local CoreGui = game:GetService("CoreGui")
		ScreenGui.Parent = CoreGui
	end)
	if not success then
		ScreenGui.Parent = game:GetService("StarterGui")
	end
end

-- =========== ADVERTISEMENT (5 seconds, unskippable) ===========
local AdFrame = Instance.new("Frame")
AdFrame.Size = UDim2.new(0, 320, 0, 200)
AdFrame.Position = UDim2.new(0.5, -160, 0.5, -100)
AdFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
AdFrame.BackgroundTransparency = 1
AdFrame.BorderSizePixel = 0
AdFrame.ZIndex = 200
AdFrame.Parent = ScreenGui

local adCorner = Instance.new("UICorner")
adCorner.CornerRadius = UDim.new(0, 16)
adCorner.Parent = AdFrame

local adStroke = Instance.new("UIStroke")
adStroke.Color = Color3.fromRGB(0, 140, 255)
adStroke.Thickness = 1.5
adStroke.Parent = AdFrame

-- Title
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

-- Subscribe text
local SubText = Instance.new("TextLabel")
SubText.Text = "Подпишитесь на нас в Telegram!\nСледите за обновлениями экзекьютеров\nи получайте самые новые скрипты!"
SubText.Font = Enum.Font.Gotham
SubText.TextSize = 12
SubText.TextColor3 = Color3.fromRGB(180, 180, 200)
SubText.BackgroundTransparency = 1
SubText.Size = UDim2.new(1, -20, 0, 60)
SubText.Position = UDim2.new(0, 10, 0, 50)
SubText.ZIndex = 201
SubText.TextXAlignment = Enum.TextXAlignment.Center
SubText.Parent = AdFrame

-- Telegram button
local TelegramButton = Instance.new("TextButton")
TelegramButton.Text = "📱 TELEGRAM CHANNEL"
TelegramButton.Font = Enum.Font.GothamBold
TelegramButton.TextSize = 14
TelegramButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TelegramButton.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
TelegramButton.Size = UDim2.new(0, 220, 0, 40)
TelegramButton.Position = UDim2.new(0.5, -110, 0, 120)
TelegramButton.BorderSizePixel = 0
TelegramButton.ZIndex = 202
TelegramButton.Parent = AdFrame

local telegramCorner = Instance.new("UICorner")
telegramCorner.CornerRadius = UDim.new(0, 8)
telegramCorner.Parent = TelegramButton

-- Timer text / Close button
local TimerText = Instance.new("TextLabel")
TimerText.Text = "05"
TimerText.Font = Enum.Font.GothamBold
TimerText.TextSize = 24
TimerText.TextColor3 = Color3.fromRGB(200, 200, 200)
TimerText.BackgroundTransparency = 1
TimerText.Size = UDim2.new(0, 50, 0, 40)
TimerText.Position = UDim2.new(0, 10, 0, 150)
TimerText.ZIndex = 201
TimerText.TextXAlignment = Enum.TextXAlignment.Center
TimerText.Parent = AdFrame

local AdLabel = Instance.new("TextLabel")
AdLabel.Text = "AD"
AdLabel.Font = Enum.Font.GothamBold
AdLabel.TextSize = 12
AdLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
AdLabel.BackgroundTransparency = 1
AdLabel.Size = UDim2.new(0, 30, 0, 20)
AdLabel.Position = UDim2.new(0, 15, 0, 170)
AdLabel.ZIndex = 201
AdLabel.Parent = AdFrame

local CloseAdButton = Instance.new("TextButton")
CloseAdButton.Text = "✕"
CloseAdButton.Font = Enum.Font.GothamBold
CloseAdButton.TextSize = 16
CloseAdButton.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseAdButton.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
CloseAdButton.Size = UDim2.new(0, 30, 0, 30)
CloseAdButton.Position = UDim2.new(1, -40, 0, 10)
CloseAdButton.BorderSizePixel = 0
CloseAdButton.ZIndex = 202
CloseAdButton.Visible = false
CloseAdButton.Parent = AdFrame

local closeAdCorner = Instance.new("UICorner")
closeAdCorner.CornerRadius = UDim.new(1, 0)
closeAdCorner.Parent = CloseAdButton

-- Плавное появление рекламы
local adAppear = TweenService:Create(AdFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {BackgroundTransparency = 0.1})
adAppear:Play()

-- Таймер 5 секунд
local timer = 5
local timerConnection
timerConnection = RunService.Heartbeat:Connect(function(dt)
	timer = timer - dt
	if timer <= 0 then
		timerConnection:Disconnect()
		TimerText.Text = "00"
		TimerText.TextColor3 = Color3.fromRGB(100, 255, 100)
		CloseAdButton.Visible = true
	else
		TimerText.Text = string.format("%02d", math.floor(timer))
	end
end)

-- Закрытие рекламы
local function closeAd()
	local adFade = TweenService:Create(AdFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundTransparency = 1})
	adFade:Play()
	adFade.Completed:Connect(function()
		AdFrame:Destroy()
	end)
	if timerConnection then timerConnection:Disconnect() end
end

CloseAdButton.MouseButton1Click:Connect(closeAd)

-- Кнопка Telegram
TelegramButton.MouseButton1Click:Connect(function()
	local success = pcall(function()
		setclipboard or toclipboard or setclipboard or function() end
	end)
	pcall(function()
		game:GetService("GuiService"):ShowMessageBox("Открыть Telegram канал?\nhttps://t.me/VanezyScripts", "Открыть", "Отмена")
	end)
end)

-- =========== LOADING SCREEN with BY VANEZY ===========
local LoadingFrame = Instance.new("Frame")
LoadingFrame.Size = UDim2.new(1, 0, 1, 0)
LoadingFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
LoadingFrame.BackgroundTransparency = 0.4
LoadingFrame.ZIndex = 150
LoadingFrame.Visible = false
LoadingFrame.Parent = ScreenGui

local LoadingContainer = Instance.new("Frame")
LoadingContainer.Size = UDim2.new(0, 280, 0, 110)
LoadingContainer.Position = UDim2.new(0.5, -140, 0.5, -55)
LoadingContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
LoadingContainer.BackgroundTransparency = 0.1
LoadingContainer.BorderSizePixel = 0
LoadingContainer.ZIndex = 151
LoadingContainer.Parent = LoadingFrame

local loadContainerCorner = Instance.new("UICorner")
loadContainerCorner.CornerRadius = UDim.new(0, 16)
loadContainerCorner.Parent = LoadingContainer

local loadContainerStroke = Instance.new("UIStroke")
loadContainerStroke.Color = Color3.fromRGB(0, 140, 255)
loadContainerStroke.Thickness = 1.5
loadContainerStroke.Transparency = 0.5
loadContainerStroke.Parent = LoadingContainer

local LoadingText = Instance.new("TextLabel")
LoadingText.Text = "loading..."
LoadingText.Font = Enum.Font.GothamBold
LoadingText.TextSize = 26
LoadingText.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadingText.BackgroundTransparency = 1
LoadingText.TextTransparency = 1
LoadingText.Size = UDim2.new(1, 0, 0, 40)
LoadingText.Position = UDim2.new(0, 0, 0, 20)
LoadingText.ZIndex = 152
LoadingText.Parent = LoadingContainer

local ByText = Instance.new("TextLabel")
ByText.Text = "by Vanezy Scripts"
ByText.Font = Enum.Font.Gotham
ByText.TextSize = 12
ByText.TextColor3 = Color3.fromRGB(150, 150, 180)
ByText.BackgroundTransparency = 1
ByText.TextTransparency = 1
ByText.Size = UDim2.new(1, 0, 0, 20)
ByText.Position = UDim2.new(0, 0, 0, 65)
ByText.ZIndex = 152
ByText.Parent = LoadingContainer

-- Показать загрузку
LoadingFrame.Visible = true
local loadFadeIn = TweenService:Create(LoadingText, TweenInfo.new(0.5), {TextTransparency = 0})
local byFadeIn = TweenService:Create(ByText, TweenInfo.new(0.5), {TextTransparency = 0})
loadFadeIn:Play()
byFadeIn:Play()
loadFadeIn.Completed:Connect(function()
	task.wait(2)
	local loadFadeOut = TweenService:Create(LoadingText, TweenInfo.new(0.5), {TextTransparency = 1})
	local byFadeOut = TweenService:Create(ByText, TweenInfo.new(0.5), {TextTransparency = 1})
	loadFadeOut:Play()
	byFadeOut:Play()
	loadFadeOut.Completed:Connect(function()
		LoadingFrame:Destroy()
	end)
end)

-- =========== MAIN WINDOW ===========
local MainContainer = Instance.new("Frame")
MainContainer.Size = UDim2.new(0, 520, 0, 460)
MainContainer.Position = UDim2.new(0.5, -260, 0.5, -230)
MainContainer.BackgroundTransparency = 1
MainContainer.ZIndex = 10
MainContainer.Visible = false
MainContainer.Parent = ScreenGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(1, 0, 1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.ZIndex = 10
MainFrame.Parent = MainContainer

local MainBorder = Instance.new("UIStroke")
MainBorder.Color = Color3.fromRGB(0, 140, 255)
MainBorder.Thickness = 1.5
MainBorder.Parent = MainFrame

-- Drag system
local isDraggingWindow = false
local dragStartPos = nil
local dragStartGuiPos = nil
local moveConnection = nil
local releaseConnection = nil

local function getInputPosition(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		return input.Position
	elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
		return input.Position
	elseif input.UserInputType == Enum.UserInputType.Touch then
		return input.Position
	end
	return nil
end

-- Title bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 11
TitleBar.Active = true
TitleBar.Parent = MainFrame

local TitleText = Instance.new("TextLabel")
TitleText.Text = "SYNAPSE HUB"
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 16
TitleText.TextColor3 = Color3.fromRGB(0, 160, 255)
TitleText.BackgroundTransparency = 1
TitleText.Size = UDim2.new(1, -120, 1, 0)
TitleText.Position = UDim2.new(0, 12, 0, 0)
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.ZIndex = 12
TitleText.Parent = TitleBar

local ByVanezy = Instance.new("TextLabel")
ByVanezy.Text = "by Vanezy Scripts"
ByVanezy.Font = Enum.Font.Gotham
ByVanezy.TextSize = 10
ByVanezy.TextColor3 = Color3.fromRGB(120, 120, 150)
ByVanezy.BackgroundTransparency = 1
ByVanezy.Size = UDim2.new(1, -120, 0, 15)
ByVanezy.Position = UDim2.new(0, 12, 0, 24)
ByVanezy.TextXAlignment = Enum.TextXAlignment.Left
ByVanezy.ZIndex = 12
ByVanezy.Parent = TitleBar

TitleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		local pos = getInputPosition(input)
		if pos then
			isDraggingWindow = true
			dragStartPos = pos
			dragStartGuiPos = MainContainer.Position

			if moveConnection then moveConnection:Disconnect() end
			moveConnection = UserInputService.InputChanged:Connect(function(moveInput)
				if isDraggingWindow then
					if moveInput.UserInputType == Enum.UserInputType.MouseMovement or moveInput.UserInputType == Enum.UserInputType.Touch then
						local movePos = getInputPosition(moveInput)
						if movePos and dragStartPos then
							local delta = movePos - dragStartPos
							MainContainer.Position = UDim2.new(
								dragStartGuiPos.X.Scale, 
								dragStartGuiPos.X.Offset + delta.X, 
								dragStartGuiPos.Y.Scale, 
								dragStartGuiPos.Y.Offset + delta.Y
							)
						end
					end
				end
			end)

			if releaseConnection then releaseConnection:Disconnect() end
			releaseConnection = UserInputService.InputEnded:Connect(function(endInput)
				if endInput.UserInputType == input.UserInputType then
					isDraggingWindow = false
					dragStartPos = nil
					if moveConnection then moveConnection:Disconnect() end
					if releaseConnection then releaseConnection:Disconnect() end
				end
			end)
		end
	end
end)

-- Minimize button
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 30, 1, -8)
MinimizeButton.Position = UDim2.new(1, -70, 0, 4)
MinimizeButton.Text = "—"
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.TextSize = 18
MinimizeButton.TextColor3 = Color3.fromRGB(180, 180, 180)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MinimizeButton.BorderSizePixel = 0
MinimizeButton.ZIndex = 12
MinimizeButton.Parent = TitleBar

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 6)
minCorner.Parent = MinimizeButton

-- Close button
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 1, -8)
CloseButton.Position = UDim2.new(1, -36, 0, 4)
CloseButton.Text = "✘"
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 16
CloseButton.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
CloseButton.BorderSizePixel = 0
CloseButton.ZIndex = 12
CloseButton.Parent = TitleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = CloseButton

-- Tab frame
local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(0, 130, 1, -40)
TabFrame.Position = UDim2.new(0, 0, 0, 40)
TabFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
TabFrame.BorderSizePixel = 0
TabFrame.ZIndex = 11
TabFrame.Parent = MainFrame

-- Content container
local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -130, 1, -40)
ContentContainer.Position = UDim2.new(0, 130, 0, 40)
ContentContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ContentContainer.BorderSizePixel = 0
ContentContainer.ClipsDescendants = true
ContentContainer.ZIndex = 11
ContentContainer.Parent = MainFrame

-- Tab buttons
local HomeTab = Instance.new("TextButton")
HomeTab.Text = "🏠 HOME"
HomeTab.Font = Enum.Font.GothamBold
HomeTab.TextSize = 13
HomeTab.Size = UDim2.new(1, -20, 0, 36)
HomeTab.Position = UDim2.new(0, 10, 0, 15)
HomeTab.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
HomeTab.TextColor3 = Color3.fromRGB(0, 160, 255)
HomeTab.BorderSizePixel = 0
HomeTab.ZIndex = 12
HomeTab.AutoButtonColor = false
HomeTab.Parent = TabFrame

local homeCorner = Instance.new("UICorner")
homeCorner.CornerRadius = UDim.new(0, 8)
homeCorner.Parent = HomeTab

local MainTab = Instance.new("TextButton")
MainTab.Text = "⚙️ MAIN"
MainTab.Font = Enum.Font.GothamBold
MainTab.TextSize = 13
MainTab.Size = UDim2.new(1, -20, 0, 36)
MainTab.Position = UDim2.new(0, 10, 0, 60)
MainTab.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainTab.TextColor3 = Color3.fromRGB(150, 150, 150)
MainTab.BorderSizePixel = 0
MainTab.ZIndex = 12
MainTab.AutoButtonColor = false
MainTab.Parent = TabFrame

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 8)
mainCorner.Parent = MainTab

local ThemeTab = Instance.new("TextButton")
ThemeTab.Text = "🎨 THEME"
ThemeTab.Font = Enum.Font.GothamBold
ThemeTab.TextSize = 13
ThemeTab.Size = UDim2.new(1, -20, 0, 36)
ThemeTab.Position = UDim2.new(0, 10, 0, 105)
ThemeTab.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ThemeTab.TextColor3 = Color3.fromRGB(150, 150, 150)
ThemeTab.BorderSizePixel = 0
ThemeTab.ZIndex = 12
ThemeTab.AutoButtonColor = false
ThemeTab.Parent = TabFrame

local themeCorner = Instance.new("UICorner")
themeCorner.CornerRadius = UDim.new(0, 8)
themeCorner.Parent = ThemeTab

-- Scrolling frames
local HomeScrollingFrame = Instance.new("ScrollingFrame")
HomeScrollingFrame.Size = UDim2.new(1, 0, 1, 0)
HomeScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 300)
HomeScrollingFrame.ScrollBarThickness = 4
HomeScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 140, 255)
HomeScrollingFrame.BackgroundTransparency = 1
HomeScrollingFrame.BorderSizePixel = 0
HomeScrollingFrame.ZIndex = 12
HomeScrollingFrame.ScrollingDirection = Enum.ScrollingDirection.Y
HomeScrollingFrame.VerticalScrollBarInset = Enum.ScrollBarInset.Always
HomeScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
HomeScrollingFrame.Parent = ContentContainer

local HomeContent = Instance.new("Frame")
HomeContent.Size = UDim2.new(1, 0, 0, 280)
HomeContent.BackgroundTransparency = 1
HomeContent.BorderSizePixel = 0
HomeContent.ZIndex = 12
HomeContent.Parent = HomeScrollingFrame

local MainScrollingFrame = Instance.new("ScrollingFrame")
MainScrollingFrame.Size = UDim2.new(1, 0, 1, 0)
MainScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 500)
MainScrollingFrame.ScrollBarThickness = 4
MainScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 140, 255)
MainScrollingFrame.BackgroundTransparency = 1
MainScrollingFrame.BorderSizePixel = 0
MainScrollingFrame.ZIndex = 12
MainScrollingFrame.ScrollingDirection = Enum.ScrollingDirection.Y
MainScrollingFrame.VerticalScrollBarInset = Enum.ScrollBarInset.Always
MainScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
MainScrollingFrame.Visible = false
MainScrollingFrame.Parent = ContentContainer

local MainContent = Instance.new("Frame")
MainContent.Size = UDim2.new(1, 0, 0, 480)
MainContent.BackgroundTransparency = 1
MainContent.BorderSizePixel = 0
MainContent.ZIndex = 12
MainContent.Parent = MainScrollingFrame

local ThemeScrollingFrame = Instance.new("ScrollingFrame")
ThemeScrollingFrame.Size = UDim2.new(1, 0, 1, 0)
ThemeScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 350)
ThemeScrollingFrame.ScrollBarThickness = 4
ThemeScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 140, 255)
ThemeScrollingFrame.BackgroundTransparency = 1
ThemeScrollingFrame.BorderSizePixel = 0
ThemeScrollingFrame.ZIndex = 12
ThemeScrollingFrame.ScrollingDirection = Enum.ScrollingDirection.Y
ThemeScrollingFrame.VerticalScrollBarInset = Enum.ScrollBarInset.Always
ThemeScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ThemeScrollingFrame.Visible = false
ThemeScrollingFrame.Parent = ContentContainer

local ThemeContent = Instance.new("Frame")
ThemeContent.Size = UDim2.new(1, 0, 0, 330)
ThemeContent.BackgroundTransparency = 1
ThemeContent.BorderSizePixel = 0
ThemeContent.ZIndex = 12
ThemeContent.Parent = ThemeScrollingFrame

-- =========== RAINBOW FUNCTION ===========
local function startRainbow()
	if rainbowConnection then return end
	rainbowConnection = RunService.RenderStepped:Connect(function()
		if rainbowEnabled then
			rainbowHue = (rainbowHue + 0.002) % 1
			local col = Color3.fromHSV(rainbowHue, 1, 1)
			MainBorder.Color = col
			HomeTab.TextColor3 = col
			MainTab.TextColor3 = col
			ThemeTab.TextColor3 = col
			TitleText.TextColor3 = col
		end
	end)
end

local function stopRainbow()
	if rainbowConnection then
		rainbowConnection:Disconnect()
		rainbowConnection = nil
	end
	MainBorder.Color = Color3.fromRGB(0, 140, 255)
	HomeTab.TextColor3 = Color3.fromRGB(0, 160, 255)
	MainTab.TextColor3 = Color3.fromRGB(150, 150, 150)
	ThemeTab.TextColor3 = Color3.fromRGB(150, 150, 150)
	TitleText.TextColor3 = Color3.fromRGB(0, 160, 255)
end

if rainbowEnabled then startRainbow() end

-- =========== ROUNDED TOGGLE ===========
local function createToggle(parent, name, yPos, defaultState, callback)
	local toggleFrame = Instance.new("Frame")
	toggleFrame.Size = UDim2.new(1, -30, 0, 50)
	toggleFrame.Position = UDim2.new(0, 15, 0, yPos)
	toggleFrame.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
	toggleFrame.BorderSizePixel = 0
	toggleFrame.ZIndex = 13
	toggleFrame.Parent = parent
	
	local frameCorner = Instance.new("UICorner")
	frameCorner.CornerRadius = UDim.new(0, 8)
	frameCorner.Parent = toggleFrame

	local toggleLabel = Instance.new("TextLabel")
	toggleLabel.Text = name
	toggleLabel.Font = Enum.Font.Gotham
	toggleLabel.TextSize = 13
	toggleLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
	toggleLabel.BackgroundTransparency = 1
	toggleLabel.Size = UDim2.new(0.65, 0, 1, 0)
	toggleLabel.Position = UDim2.new(0, 12, 0, 0)
	toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
	toggleLabel.ZIndex = 14
	toggleLabel.Parent = toggleFrame

	local toggleButton = Instance.new("Frame")
	toggleButton.Size = UDim2.new(0, 50, 0, 26)
	toggleButton.Position = UDim2.new(1, -62, 0.5, -13)
	toggleButton.BackgroundColor3 = defaultState and Color3.fromRGB(0, 140, 255) or Color3.fromRGB(55, 55, 55)
	toggleButton.BorderSizePixel = 0
	toggleButton.ZIndex = 14
	toggleButton.Parent = toggleFrame
	
	local toggleCorner = Instance.new("UICorner")
	toggleCorner.CornerRadius = UDim.new(1, 0)
	toggleCorner.Parent = toggleButton

	local toggleDot = Instance.new("Frame")
	toggleDot.Size = UDim2.new(0, 20, 0, 20)
	toggleDot.Position = defaultState and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
	toggleDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	toggleDot.BorderSizePixel = 0
	toggleDot.ZIndex = 15
	toggleDot.Parent = toggleButton
	
	local dotCorner = Instance.new("UICorner")
	dotCorner.CornerRadius = UDim.new(1, 0)
	dotCorner.Parent = toggleDot
	
	local hitbox = Instance.new("TextButton")
	hitbox.Size = UDim2.new(1, 0, 1, 0)
	hitbox.BackgroundTransparency = 1
	hitbox.Text = ""
	hitbox.ZIndex = 16
	hitbox.Parent = toggleButton

	local toggleState = defaultState or false

	hitbox.MouseButton1Click:Connect(function()
		toggleState = not toggleState
		if toggleState then
			TweenService:Create(toggleDot, TweenInfo.new(0.2), {Position = UDim2.new(1, -23, 0.5, -10)}):Play()
			TweenService:Create(toggleButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 140, 255)}):Play()
		else
			TweenService:Create(toggleDot, TweenInfo.new(0.2), {Position = UDim2.new(0, 3, 0.5, -10)}):Play()
			TweenService:Create(toggleButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(55, 55, 55)}):Play()
		end
		if callback then callback(toggleState) end
	end)
	if callback and toggleState then task.spawn(function() callback(toggleState) end) end
	return toggleFrame
end

-- =========== ROUNDED SLIDER ===========
local function createSlider(parent, name, yPos, minVal, maxVal, defaultVal, callback)
	local sliderFrame = Instance.new("Frame")
	sliderFrame.Size = UDim2.new(1, -30, 0, 70)
	sliderFrame.Position = UDim2.new(0, 15, 0, yPos)
	sliderFrame.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
	sliderFrame.BorderSizePixel = 0
	sliderFrame.ZIndex = 13
	sliderFrame.Parent = parent
	
	local frameCorner = Instance.new("UICorner")
	frameCorner.CornerRadius = UDim.new(0, 8)
	frameCorner.Parent = sliderFrame

	local sliderLabel = Instance.new("TextLabel")
	sliderLabel.Text = name .. " [" .. tostring(defaultVal) .. "]"
	sliderLabel.Font = Enum.Font.Gotham
	sliderLabel.TextSize = 13
	sliderLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
	sliderLabel.BackgroundTransparency = 1
	sliderLabel.Size = UDim2.new(1, -20, 0, 25)
	sliderLabel.Position = UDim2.new(0, 10, 0, 5)
	sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
	sliderLabel.ZIndex = 14
	sliderLabel.Parent = sliderFrame

	local sliderBar = Instance.new("Frame")
	sliderBar.Size = UDim2.new(1, -24, 0, 6)
	sliderBar.Position = UDim2.new(0, 12, 0, 42)
	sliderBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	sliderBar.BorderSizePixel = 0
	sliderBar.ZIndex = 14
	sliderBar.Active = true
	sliderBar.Parent = sliderFrame
	
	local barCorner = Instance.new("UICorner")
	barCorner.CornerRadius = UDim.new(1, 0)
	barCorner.Parent = sliderBar

	local ratio = (defaultVal - minVal) / (maxVal - minVal)
	
	local sliderFill = Instance.new("Frame")
	sliderFill.Size = UDim2.new(ratio, 0, 1, 0)
	sliderFill.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
	sliderFill.BorderSizePixel = 0
	sliderFill.ZIndex = 15
	sliderFill.Parent = sliderBar
	
	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(1, 0)
	fillCorner.Parent = sliderFill

	local sliderButton = Instance.new("Frame")
	sliderButton.Size = UDim2.new(0, 18, 0, 18)
	sliderButton.Position = UDim2.new(ratio, -9, 0.5, -9)
	sliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	sliderButton.BorderSizePixel = 0
	sliderButton.ZIndex = 16
	sliderButton.Parent = sliderBar
	
	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(1, 0)
	buttonCorner.Parent = sliderButton

	local isDragging = false
	local currentValue = defaultVal

	local function updateSlider(input)
		local barAbsPos = sliderBar.AbsolutePosition
		local barAbsSize = sliderBar.AbsoluteSize
		if not barAbsPos or not barAbsSize then return end
		
		local relativeX = (input.Position.X - barAbsPos.X) / barAbsSize.X
		relativeX = math.clamp(relativeX, 0, 1)
		local value = minVal + (maxVal - minVal) * relativeX
		value = math.floor(value * 10 + 0.5) / 10
		sliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
		sliderButton.Position = UDim2.new(relativeX, -9, 0.5, -9)
		sliderLabel.Text = name .. " [" .. tostring(value) .. "]"
		currentValue = value
		if callback then callback(value) end
	end

	sliderButton.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isDragging = true end
	end)
	sliderBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			isDragging = true
			updateSlider(input)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then updateSlider(input) end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isDragging = false end
	end)
	if callback then callback(defaultVal) end
	return {
		frame = sliderFrame, 
		setValue = function(val) 
			local r = (val - minVal) / (maxVal - minVal)
			r = math.clamp(r, 0, 1)
			sliderFill.Size = UDim2.new(r, 0, 1, 0)
			sliderButton.Position = UDim2.new(r, -9, 0.5, -9)
			sliderLabel.Text = name .. " [" .. tostring(val) .. "]"
			currentValue = val
			if callback then callback(val) end
		end
	}
end

-- =========== HOME TAB CONTENT ===========
local HomeTitle = Instance.new("TextLabel")
HomeTitle.Text = "SYNAPSE HUB"
HomeTitle.Font = Enum.Font.GothamBold
HomeTitle.TextSize = 22
HomeTitle.TextColor3 = Color3.fromRGB(0, 160, 255)
HomeTitle.BackgroundTransparency = 1
HomeTitle.Size = UDim2.new(1, -30, 0, 40)
HomeTitle.Position = UDim2.new(0, 15, 0, 15)
HomeTitle.TextXAlignment = Enum.TextXAlignment.Center
HomeTitle.ZIndex = 20
HomeTitle.Parent = HomeContent

local HomeSub = Instance.new("TextLabel")
HomeSub.Text = "by Vanezy Scripts"
HomeSub.Font = Enum.Font.Gotham
HomeSub.TextSize = 12
HomeSub.TextColor3 = Color3.fromRGB(150, 150, 180)
HomeSub.BackgroundTransparency = 1
HomeSub.Size = UDim2.new(1, -30, 0, 20)
HomeSub.Position = UDim2.new(0, 15, 0, 55)
HomeSub.TextXAlignment = Enum.TextXAlignment.Center
HomeSub.ZIndex = 20
HomeSub.Parent = HomeContent

-- Auto Start Toggle
createToggle(HomeContent, "🔌 Auto Start Script", 100, savedAutoStart, function(state)
	saveValue("AutoStart", state)
	savedAutoStart = state
end)

-- Save Settings Button
local SaveButton = Instance.new("TextButton")
SaveButton.Text = "💾 SAVE ALL SETTINGS"
SaveButton.Font = Enum.Font.GothamBold
SaveButton.TextSize = 14
SaveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveButton.BackgroundColor3 = Color3.fromRGB(0, 120, 100)
SaveButton.Size = UDim2.new(1, -60, 0, 45)
SaveButton.Position = UDim2.new(0, 30, 0, 160)
SaveButton.BorderSizePixel = 0
SaveButton.ZIndex = 20
SaveButton.Parent = HomeContent

local saveCorner = Instance.new("UICorner")
saveCorner.CornerRadius = UDim.new(0, 10)
saveCorner.Parent = SaveButton

SaveButton.MouseButton1Click:Connect(function()
	saveValue("WalkSpeed", savedWalkSpeed)
	saveValue("JumpPower", savedJumpPower)
	saveValue("FOV", savedFOV)
	saveValue("AutoWalk", autoWalkEnabled)
	saveValue("ESP", espEnabled)
	saveValue("Rainbow", rainbowEnabled)
	saveValue("AutoStart", savedAutoStart)
	
	SaveButton.Text = "✓ SAVED!"
	TweenService:Create(SaveButton, TweenInfo.new(2), {TextColor3 = Color3.fromRGB(100, 255, 100)}):Play()
	task.wait(2)
	SaveButton.Text = "💾 SAVE ALL SETTINGS"
	TweenService:Create(SaveButton, TweenInfo.new(0.5), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
end)

-- Reset All Button
local ResetAllButton = Instance.new("TextButton")
ResetAllButton.Text = "🗑️ RESET TO DEFAULTS"
ResetAllButton.Font = Enum.Font.GothamBold
ResetAllButton.TextSize = 14
ResetAllButton.TextColor3 = Color3.fromRGB(255, 200, 200)
ResetAllButton.BackgroundColor3 = Color3.fromRGB(100, 40, 40)
ResetAllButton.Size = UDim2.new(1, -60, 0, 45)
ResetAllButton.Position = UDim2.new(0, 30, 0, 220)
ResetAllButton.BorderSizePixel = 0
ResetAllButton.ZIndex = 20
ResetAllButton.Parent = HomeContent

local resetCorner = Instance.new("UICorner")
resetCorner.CornerRadius = UDim.new(0, 10)
resetCorner.Parent = ResetAllButton

ResetAllButton.MouseButton1Click:Connect(function()
	walkSpeedSlider.setValue(16)
	jumpPowerSlider.setValue(50)
	fovSlider.setValue(70)
	
	autoWalkEnabled = false
	if autoWalkConnection then autoWalkConnection:Disconnect() autoWalkConnection = nil end
	
	espEnabled = false
	for _, hl in pairs(espHighlights) do pcall(function() hl:Destroy() end) end
	espHighlights = {}
	for _, bb in pairs(espBillboards) do pcall(function() bb:Destroy() end) end
	espBillboards = {}
	
	rainbowEnabled = false
	stopRainbow()
	
	saveValue("WalkSpeed", 16)
	saveValue("JumpPower", 50)
	saveValue("FOV", 70)
	saveValue("AutoWalk", false)
	saveValue("ESP", false)
	saveValue("Rainbow", false)
	
	ResetAllButton.Text = "✓ RESET!"
	TweenService:Create(ResetAllButton, TweenInfo.new(2), {TextColor3 = Color3.fromRGB(150, 255, 150)}):Play()
	task.wait(2)
	ResetAllButton.Text = "🗑️ RESET TO DEFAULTS"
	TweenService:Create(ResetAllButton, TweenInfo.new(0.5), {TextColor3 = Color3.fromRGB(255, 200, 200)}):Play()
end)

-- Developer Info
local DevText = Instance.new("TextLabel")
DevText.Text = "👨‍💻 Developer: Vanezy\n📢 Telegram: @VanezyScripts"
DevText.Font = Enum.Font.Gotham
DevText.TextSize = 11
DevText.TextColor3 = Color3.fromRGB(100, 100, 130)
DevText.BackgroundTransparency = 1
DevText.Size = UDim2.new(1, -30, 0, 40)
DevText.Position = UDim2.new(0, 15, 0, 280)
DevText.TextXAlignment = Enum.TextXAlignment.Center
DevText.ZIndex = 20
DevText.Parent = HomeContent

-- =========== MAIN TAB CONTENT ===========
createToggle(MainContent, "🚶 Auto Walk", 10, autoWalkEnabled, function(state)
	autoWalkEnabled = state
	saveValue("AutoWalk", state)
	if autoWalkConnection then autoWalkConnection:Disconnect() autoWalkConnection = nil end
	if autoWalkEnabled then
		autoWalkConnection = RunService.Heartbeat:Connect(function()
			local char = player.Character
			if not char then return end
			local hum = char:FindFirstChild("Humanoid")
			local rootPart = char:FindFirstChild("HumanoidRootPart")
			if not hum or not rootPart then return end
			if hum.MoveDirection.Magnitude < 0.1 then
				local forwardDir = rootPart.CFrame.LookVector * Vector3.new(1, 0, 1)
				if forwardDir.Magnitude > 0.01 then
					hum:Move(forwardDir.Unit, false)
				else
					hum:Move(Vector3.new(0, 0, -1), false)
				end
			end
		end)
	end
end)

local walkSpeedSlider = createSlider(MainContent, "🏃 Walk Speed", 70, 8, 120, savedWalkSpeed, function(value)
	savedWalkSpeed = value
	local char = player.Character
	if char then
		local hum = char:FindFirstChild("Humanoid")
		if hum then hum.WalkSpeed = value end
	end
end)

local jumpPowerSlider = createSlider(MainContent, "🦘 Jump Power", 150, 30, 250, savedJumpPower, function(value)
	savedJumpPower = value
	local char = player.Character
	if char then
		local hum = char:FindFirstChild("Humanoid")
		if hum then hum.JumpPower = value end
	end
end)

local fovSlider = createSlider(MainContent, "👁️ Field of View", 230, 30, 120, savedFOV, function(value)
	savedFOV = value
	if camera then camera.FieldOfView = value end
end)

createToggle(MainContent, "👤 ESP Players", 310, espEnabled, function(state)
	espEnabled = state
	saveValue("ESP", state)
	if not state then
		for _, hl in pairs(espHighlights) do pcall(function() hl:Destroy() end) end
		espHighlights = {}
		for _, bb in pairs(espBillboards) do pcall(function() bb:Destroy() end) end
		espBillboards = {}
	end
end)

-- =========== THEME TAB CONTENT ===========
local ThemeLabel = Instance.new("TextLabel")
ThemeLabel.Text = "🎨 SELECT THEME"
ThemeLabel.Font = Enum.Font.GothamBold
ThemeLabel.TextSize = 16
ThemeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
ThemeLabel.BackgroundTransparency = 1
ThemeLabel.Size = UDim2.new(1, -30, 0, 30)
ThemeLabel.Position = UDim2.new(0, 15, 0, 15)
ThemeLabel.TextXAlignment = Enum.TextXAlignment.Left
ThemeLabel.ZIndex = 20
ThemeLabel.Parent = ThemeContent

createToggle(ThemeContent, "🌈 RAINBOW MODE (Slow Pulse)", 55, rainbowEnabled, function(state)
	rainbowEnabled = state
	saveValue("Rainbow", state)
	if state then
		startRainbow()
	else
		stopRainbow()
	end
end)

local themes = {
	{name = "🔵 Blue", color = Color3.fromRGB(0, 140, 255)},
	{name = "🔴 Red", color = Color3.fromRGB(200, 40, 40)},
	{name = "🟢 Green", color = Color3.fromRGB(40, 180, 70)},
	{name = "🟡 Yellow", color = Color3.fromRGB(255, 180, 30)},
	{name = "🟣 Purple", color = Color3.fromRGB(160, 60, 200)},
	{name = "⚪ White", color = Color3.fromRGB(200, 200, 200)},
}

for i, theme in ipairs(themes) do
	local yPos = 115 + (i - 1) * 48
	local themeButton = Instance.new("TextButton")
	themeButton.Text = theme.name
	themeButton.Font = Enum.Font.GothamBold
	themeButton.TextSize = 14
	themeButton.Size = UDim2.new(1, -50, 0, 38)
	themeButton.Position = UDim2.new(0, 25, 0, yPos)
	themeButton.BackgroundColor3 = theme.color
	themeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	themeButton.BorderSizePixel = 0
	themeButton.ZIndex = 20
	themeButton.AutoButtonColor = false
	themeButton.Parent = ThemeContent
	
	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 8)
	btnCorner.Parent = themeButton
	
	themeButton.MouseButton1Click:Connect(function()
		MainBorder.Color = theme.color
		HomeTab.TextColor3 = theme.color
		TitleText.TextColor3 = theme.color
		if not rainbowEnabled then
			MainBorder.Color = theme.color
			HomeTab.TextColor3 = theme.color
			MainTab.TextColor3 = Color3.fromRGB(150, 150, 150)
			ThemeTab.TextColor3 = Color3.fromRGB(150, 150, 150)
			TitleText.TextColor3 = theme.color
		end
	end)
end

-- =========== ESP SYSTEM ===========
RunService.Heartbeat:Connect(function()
	if not espEnabled then return end
	
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr == player then continue end
		
		local char = plr.Character
		if not char then
			if espHighlights[plr.UserId] then
				espHighlights[plr.UserId]:Destroy()
				espHighlights[plr.UserId] = nil
			end
			if espBillboards[plr.UserId] then
				espBillboards[plr.UserId]:Destroy()
				espBillboards[plr.UserId] = nil
			end
			continue
		end
		
		local rootPart = char:FindFirstChild("HumanoidRootPart")
		local head = char:FindFirstChild("Head")
		if not rootPart then continue end
		
		local existingHL = espHighlights[plr.UserId]
		if not existingHL or existingHL.Parent ~= char then
			if existingHL then existingHL:Destroy() end
			local highlight = Instance.new("Highlight")
			highlight.FillColor = Color3.fromRGB(255, 60, 60)
			highlight.FillTransparency = 0.4
			highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
			highlight.OutlineTransparency = 0.2
			highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			highlight.Adornee = char
			highlight.Parent = char
			espHighlights[plr.UserId] = highlight
		end
		
		if head then
			local existingBB = espBillboards[plr.UserId]
			if not existingBB or existingBB.Parent ~= head then
				if existingBB then existingBB:Destroy() end
				
				local billboard = Instance.new("BillboardGui")
				billboard.Size = UDim2.new(0, 200, 0, 50)
				billboard.StudsOffset = Vector3.new(0, 2, 0)
				billboard.AlwaysOnTop = true
				billboard.MaxDistance = 500
				billboard.Parent = head
				billboard.Adornee = head
				
				local frame = Instance.new("Frame")
				frame.Size = UDim2.new(1, 0, 1, 0)
				frame.BackgroundTransparency = 1
				frame.Parent = billboard
				
				local nameLabel = Instance.new("TextLabel")
				nameLabel.Text = plr.Name
				nameLabel.Font = Enum.Font.GothamBold
				nameLabel.TextSize = 14
				nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
				nameLabel.BackgroundTransparency = 1
				nameLabel.Size = UDim2.new(1, 0, 0, 22)
				nameLabel.TextStrokeTransparency = 0.5
				nameLabel.Parent = frame
				
				local distLabel = Instance.new("TextLabel")
				distLabel.Name = "Distance"
				distLabel.Text = "0m"
				distLabel.Font = Enum.Font.Gotham
				distLabel.TextSize = 12
				distLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
				distLabel.BackgroundTransparency = 1
				distLabel.Size = UDim2.new(1, 0, 0, 18)
				distLabel.Position = UDim2.new(0, 0, 0, 22)
				distLabel.TextStrokeTransparency = 0.5
				distLabel.Parent = frame
				
				espBillboards[plr.UserId] = billboard
			end
			
			local bb = espBillboards[plr.UserId]
			if bb then
				local distFrame = bb:FindFirstChild("Frame")
				if distFrame then
					local distLabel = distFrame:FindFirstChild("Distance")
					if distLabel then
						local myChar = player.Character
						if myChar then
							local myRoot = myChar:FindFirstChild("HumanoidRootPart")
							if myRoot then
								local distance = (myRoot.Position - rootPart.Position).Magnitude
								distLabel.Text = string.format("%.1fm", distance)
							end
						end
					end
				end
			end
		end
	end
	
	local toRemove = {}
	for userId, _ in pairs(espHighlights) do
		local plr = Players:GetPlayerByUserId(userId)
		if not plr then table.insert(toRemove, userId) end
	end
	for _, userId in ipairs(toRemove) do
		if espHighlights[userId] then espHighlights[userId]:Destroy() espHighlights[userId] = nil end
		if espBillboards[userId] then espBillboards[userId]:Destroy() espBillboards[userId] = nil end
	end
end)

-- =========== TAB SWITCHING ===========
local function switchTab(tab)
	if tab == "Home" then
		HomeScrollingFrame.Visible = true
		MainScrollingFrame.Visible = false
		ThemeScrollingFrame.Visible = false
		TweenService:Create(HomeTab, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 35), TextColor3 = rainbowEnabled and Color3.fromHSV(rainbowHue, 1, 1) or Color3.fromRGB(0, 160, 255)}):Play()
		TweenService:Create(MainTab, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 30), TextColor3 = Color3.fromRGB(150, 150, 150)}):Play()
		TweenService:Create(ThemeTab, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 30), TextColor3 = Color3.fromRGB(150, 150, 150)}):Play()
	elseif tab == "Main" then
		HomeScrollingFrame.Visible = false
		MainScrollingFrame.Visible = true
		ThemeScrollingFrame.Visible = false
		TweenService:Create(HomeTab, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 30), TextColor3 = Color3.fromRGB(150, 150, 150)}):Play()
		TweenService:Create(MainTab, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 35), TextColor3 = rainbowEnabled and Color3.fromHSV(rainbowHue, 1, 1) or Color3.fromRGB(0, 160, 255)}):Play()
		TweenService:Create(ThemeTab, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 30), TextColor3 = Color3.fromRGB(150, 150, 150)}):Play()
	else
		HomeScrollingFrame.Visible = false
		MainScrollingFrame.Visible = false
		ThemeScrollingFrame.Visible = true
		TweenService:Create(HomeTab, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 30), TextColor3 = Color3.fromRGB(150, 150, 150)}):Play()
		TweenService:Create(MainTab, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 30), TextColor3 = Color3.fromRGB(150, 150, 150)}):Play()
		TweenService:Create(ThemeTab, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 35), TextColor3 = rainbowEnabled and Color3.fromHSV(rainbowHue, 1, 1) or Color3.fromRGB(0, 160, 255)}):Play()
	end
end

HomeTab.MouseButton1Click:Connect(function() switchTab("Home") end)
MainTab.MouseButton1Click:Connect(function() switchTab("Main") end)
ThemeTab.MouseButton1Click:Connect(function() switchTab("Theme") end)

-- =========== MINIMIZE & CLOSE ===========
local isMinimized = false
local originalSize = MainContainer.Size

MinimizeButton.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized
	if isMinimized then
		MainContainer:TweenSize(UDim2.new(0, 520, 0, 40), "Out", "Quad", 0.3)
		TabFrame.Visible = false
		ContentContainer.Visible = false
	else
		MainContainer:TweenSize(originalSize, "Out", "Quad", 0.3)
		TabFrame.Visible = true
		ContentContainer.Visible = true
	end
end)

CloseButton.MouseButton1Click:Connect(function()
	TweenService:Create(MainContainer, TweenInfo.new(0.25), {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}):Play()
	task.wait(0.25)
	ScreenGui:Destroy()
end)

-- =========== HOVER EFFECTS ===========
local function addHoverEffect(button, defaultColor)
	button.MouseEnter:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(55, 55, 55)}):Play()
	end)
	button.MouseLeave:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.15), {BackgroundColor3 = defaultColor or Color3.fromRGB(40, 40, 40)}):Play()
	end)
end

addHoverEffect(MinimizeButton, Color3.fromRGB(40, 40, 40))
addHoverEffect(CloseButton, Color3.fromRGB(40, 40, 40))

-- =========== CHARACTER RESPAWN ===========
player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	humanoid = newCharacter:WaitForChild("Humanoid")
	camera = workspace.CurrentCamera
	
	if humanoid then
		humanoid.WalkSpeed = savedWalkSpeed
		humanoid.JumpPower = savedJumpPower
	end
	if camera then
		camera.FieldOfView = savedFOV
	end
	
	if autoWalkEnabled then
		if autoWalkConnection then autoWalkConnection:Disconnect() end
		autoWalkConnection = RunService.Heartbeat:Connect(function()
			local char = player.Character
			if not char then return end
			local hum = char:FindFirstChild("Humanoid")
			local rootPart = char:FindFirstChild("HumanoidRootPart")
			if not hum or not rootPart then return end
			if hum.MoveDirection.Magnitude < 0.1 then
				local forwardDir = rootPart.CFrame.LookVector * Vector3.new(1, 0, 1)
				if forwardDir.Magnitude > 0.01 then
					hum:Move(forwardDir.Unit, false)
				else
					hum:Move(Vector3.new(0, 0, -1), false)
				end
			end
		end)
	end
	
	for userId, hl in pairs(espHighlights) do
		local targetPlayer = Players:GetPlayerByUserId(userId)
		if not targetPlayer or hl.Parent ~= targetPlayer.Character then
			pcall(function() hl:Destroy() end)
			espHighlights[userId] = nil
		end
	end
	for userId, bb in pairs(espBillboards) do
		pcall(function() bb:Destroy() end)
		espBillboards[userId] = nil
	end
end)

-- =========== AUTO START ON RESPAWN ===========
if savedAutoStart then
	autoWalkEnabled = savedAutoWalk
	if autoWalkEnabled then
		autoWalkConnection = RunService.Heartbeat:Connect(function()
			local char = player.Character
			if not char then return end
			local hum = char:FindFirstChild("Humanoid")
			local rootPart = char:FindFirstChild("HumanoidRootPart")
			if not hum or not rootPart then return end
			if hum.MoveDirection.Magnitude < 0.1 then
				local forwardDir = rootPart.CFrame.LookVector * Vector3.new(1, 0, 1)
				if forwardDir.Magnitude > 0.01 then
					hum:Move(forwardDir.Unit, false)
				else
					hum:Move(Vector3.new(0, 0, -1), false)
				end
			end
		end)
	end
end

-- Показать главное меню после рекламы
task.wait(5.5)
MainContainer.Visible = true
local menuAppear = TweenService:Create(MainContainer, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {BackgroundTransparency = 0})
menuAppear:Play()

print("✅ Synapse Hub v7 loaded successfully!")
print("📢 Telegram: @VanezyScripts")
