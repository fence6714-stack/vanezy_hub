--[[
	SYNAPSE STYLE UI - COMPLETE LOCALSCRIPT
	Place this inside StarterGui or StarterPlayerScripts
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local camera = workspace.CurrentCamera

-- Установка дефолтных значений
local defaultWalkSpeed = 16
local defaultJumpPower = 50
local defaultFOV = 70

-- Переменные состояния
local autoWalkEnabled = false
local autoWalkConnection = nil

-- Создание GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SynapseUI"
ScreenGui.Parent = player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- =========== LOADING SCREEN ===========
local LoadingFrame = Instance.new("Frame")
LoadingFrame.Size = UDim2.new(1, 0, 1, 0)
LoadingFrame.BackgroundTransparency = 1
LoadingFrame.ZIndex = 100
LoadingFrame.Parent = ScreenGui

local LoadingText = Instance.new("TextLabel")
LoadingText.Text = "loading..."
LoadingText.Font = Enum.Font.GothamBold
LoadingText.TextSize = 24
LoadingText.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadingText.BackgroundTransparency = 1
LoadingText.TextTransparency = 1
LoadingText.Size = UDim2.new(0, 200, 0, 50)
LoadingText.Position = UDim2.new(0.5, -100, 0.5, -25)
LoadingText.ZIndex = 101
LoadingText.Parent = LoadingFrame

-- Fade in loading text
local fadeIn = TweenService:Create(LoadingText, TweenInfo.new(0.5), {TextTransparency = 0})
fadeIn:Play()
fadeIn.Completed:Connect(function()
	task.wait(1.2)
	local fadeOut = TweenService:Create(LoadingText, TweenInfo.new(0.5), {TextTransparency = 1})
	fadeOut:Play()
	fadeOut.Completed:Connect(function()
		LoadingFrame:Destroy()
	end)
end)

-- =========== MAIN WINDOW ===========
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 500, 0, 380)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.ZIndex = 10
MainFrame.Parent = ScreenGui

-- Subtle border
local MainBorder = Instance.new("UIStroke")
MainBorder.Color = Color3.fromRGB(60, 60, 60)
MainBorder.Thickness = 1
MainBorder.Parent = MainFrame

-- Title bar (drag handle)
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 11
TitleBar.Parent = MainFrame

local TitleText = Instance.new("TextLabel")
TitleText.Text = "synapse interface"
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 14
TitleText.TextColor3 = Color3.fromRGB(200, 200, 200)
TitleText.BackgroundTransparency = 1
TitleText.Size = UDim2.new(1, -110, 1, 0)
TitleText.Position = UDim2.new(0, 12, 0, 0)
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.ZIndex = 12
TitleText.Parent = TitleBar

-- Minimize button
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 28, 1, -4)
MinimizeButton.Position = UDim2.new(1, -66, 0, 2)
MinimizeButton.Text = "—"
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.TextSize = 16
MinimizeButton.TextColor3 = Color3.fromRGB(180, 180, 180)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MinimizeButton.BorderSizePixel = 0
MinimizeButton.ZIndex = 12
MinimizeButton.Parent = TitleBar

-- Close button
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 28, 1, -4)
CloseButton.Position = UDim2.new(1, -34, 0, 2)
CloseButton.Text = "✕"
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 14
CloseButton.TextColor3 = Color3.fromRGB(180, 180, 180)
CloseButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
CloseButton.BorderSizePixel = 0
CloseButton.ZIndex = 12
CloseButton.Parent = TitleBar

-- Tab frame
local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(0, 120, 1, -35)
TabFrame.Position = UDim2.new(0, 0, 0, 35)
TabFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
TabFrame.BorderSizePixel = 0
TabFrame.ZIndex = 11
TabFrame.Parent = MainFrame

-- Main tab button
local MainTab = Instance.new("TextButton")
MainTab.Text = "Main"
MainTab.Font = Enum.Font.GothamBold
MainTab.TextSize = 13
MainTab.Size = UDim2.new(1, -20, 0, 32)
MainTab.Position = UDim2.new(0, 10, 0, 15)
MainTab.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainTab.TextColor3 = Color3.fromRGB(200, 200, 200)
MainTab.BorderSizePixel = 0
MainTab.ZIndex = 12
MainTab.Parent = TabFrame

-- Theme tab button
local ThemeTab = Instance.new("TextButton")
ThemeTab.Text = "Theme"
ThemeTab.Font = Enum.Font.GothamBold
ThemeTab.TextSize = 13
ThemeTab.Size = UDim2.new(1, -20, 0, 32)
ThemeTab.Position = UDim2.new(0, 10, 0, 55)
ThemeTab.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ThemeTab.TextColor3 = Color3.fromRGB(150, 150, 150)
ThemeTab.BorderSizePixel = 0
ThemeTab.ZIndex = 12
ThemeTab.Parent = TabFrame

-- Content container
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -120, 1, -35)
ContentFrame.Position = UDim2.new(0, 120, 0, 35)
ContentFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ContentFrame.BorderSizePixel = 0
ContentFrame.ZIndex = 11
ContentFrame.Parent = MainFrame

-- =========== MAIN TAB CONTENT ===========
local MainContent = Instance.new("Frame")
MainContent.Size = UDim2.new(1, 0, 1, 0)
MainContent.BackgroundTransparency = 1
MainContent.BorderSizePixel = 0
MainContent.ZIndex = 12
MainContent.Parent = ContentFrame

-- Helper function to create a toggle
local function createToggle(name, yPos, callback)
	local toggleFrame = Instance.new("Frame")
	toggleFrame.Size = UDim2.new(1, -30, 0, 45)
	toggleFrame.Position = UDim2.new(0, 15, 0, yPos)
	toggleFrame.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
	toggleFrame.BorderSizePixel = 0
	toggleFrame.ZIndex = 13
	toggleFrame.Parent = MainContent

	local toggleLabel = Instance.new("TextLabel")
	toggleLabel.Text = name
	toggleLabel.Font = Enum.Font.Gotham
	toggleLabel.TextSize = 13
	toggleLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
	toggleLabel.BackgroundTransparency = 1
	toggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
	toggleLabel.Position = UDim2.new(0, 10, 0, 0)
	toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
	toggleLabel.ZIndex = 14
	toggleLabel.Parent = toggleFrame

	local toggleButton = Instance.new("TextButton")
	toggleButton.Size = UDim2.new(0, 48, 0, 22)
	toggleButton.Position = UDim2.new(1, -60, 0.5, -11)
	toggleButton.Text = ""
	toggleButton.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
	toggleButton.BorderSizePixel = 0
	toggleButton.ZIndex = 14
	toggleButton.Parent = toggleFrame

	local toggleDot = Instance.new("Frame")
	toggleDot.Size = UDim2.new(0, 18, 0, 18)
	toggleDot.Position = UDim2.new(0, 2, 0.5, -9)
	toggleDot.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
	toggleDot.BorderSizePixel = 0
	toggleDot.ZIndex = 15
	toggleDot.Parent = toggleButton

	local toggleState = false

	toggleButton.MouseButton1Click:Connect(function()
		toggleState = not toggleState
		local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

		if toggleState then
			toggleDot:TweenPosition(UDim2.new(1, -20, 0.5, -9), "Out", "Quad", 0.2)
			toggleButton:TweenSize(UDim2.new(0, 48, 0, 22), "Out", "Quad", 0.2, true)
			local bgTween = TweenService:Create(toggleButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 140, 255)})
			bgTween:Play()
		else
			toggleDot:TweenPosition(UDim2.new(0, 2, 0.5, -9), "Out", "Quad", 0.2)
			local bgTween = TweenService:Create(toggleButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(55, 55, 55)})
			bgTween:Play()
		end

		if callback then
			callback(toggleState)
		end
	end)

	return toggleFrame
end

-- Helper function to create a slider
local function createSlider(name, yPos, minVal, maxVal, defaultVal, callback)
	local sliderFrame = Instance.new("Frame")
	sliderFrame.Size = UDim2.new(1, -30, 0, 70)
	sliderFrame.Position = UDim2.new(0, 15, 0, yPos)
	sliderFrame.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
	sliderFrame.BorderSizePixel = 0
	sliderFrame.ZIndex = 13
	sliderFrame.Parent = MainContent

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
	sliderBar.Size = UDim2.new(1, -24, 0, 4)
	sliderBar.Position = UDim2.new(0, 12, 0, 40)
	sliderBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	sliderBar.BorderSizePixel = 0
	sliderBar.ZIndex = 14
	sliderBar.Parent = sliderFrame

	local sliderFill = Instance.new("Frame")
	sliderFill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
	sliderFill.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
	sliderFill.BorderSizePixel = 0
	sliderFill.ZIndex = 15
	sliderFill.Parent = sliderBar

	local sliderButton = Instance.new("TextButton")
	sliderButton.Size = UDim2.new(0, 14, 0, 14)
	sliderButton.Position = UDim2.new((defaultVal - minVal) / (maxVal - minVal), -7, 0.5, -7)
	sliderButton.Text = ""
	sliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	sliderButton.BorderSizePixel = 0
	sliderButton.ZIndex = 16
	sliderButton.Parent = sliderBar

	local isDragging = false
	local currentValue = defaultVal

	local function updateValue(input)
		local relativePos = (input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X
		relativePos = math.clamp(relativePos, 0, 1)
		local value = minVal + (maxVal - minVal) * relativePos
		value = math.floor(value * 10 + 0.5) / 10

		sliderFill.Size = UDim2.new(relativePos, 0, 1, 0)
		sliderButton.Position = UDim2.new(relativePos, -7, 0.5, -7)
		sliderLabel.Text = name .. " [" .. tostring(value) .. "]"

		if value ~= currentValue then
			currentValue = value
			if callback then
				callback(value)
			end
		end
	end

	sliderButton.MouseButton1Down:Connect(function()
		isDragging = true
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			isDragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			updateValue(input)
		end
	end)

	sliderBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			isDragging = true
			updateValue(input)
		end
	end)

	if callback then
		callback(defaultVal)
	end

	return sliderFrame
end

-- Create Main tab elements
createToggle("Auto Walk", 10, function(state)
	autoWalkEnabled = state
	if autoWalkConnection then
		autoWalkConnection:Disconnect()
		autoWalkConnection = nil
	end
	if autoWalkEnabled then
		autoWalkConnection = RunService.Heartbeat:Connect(function()
			local char = player.Character
			if char and char:FindFirstChild("Humanoid") then
				local hum = char.Humanoid
				if hum.MoveDirection.Magnitude == 0 then
					hum:Move(Vector3.new(0, 0, -1), false)
				end
			end
		end)
	end
end)

createSlider("Walk Speed", 65, 8, 100, defaultWalkSpeed, function(value)
	local char = player.Character
	if char and char:FindFirstChild("Humanoid") then
		char.Humanoid.WalkSpeed = value
	end
end)

createSlider("Jump Power", 145, 10, 200, defaultJumpPower, function(value)
	local char = player.Character
	if char and char:FindFirstChild("Humanoid") then
		char.Humanoid.JumpPower = value
	end
end)

createSlider("Field of View", 225, 30, 120, defaultFOV, function(value)
	camera.FieldOfView = value
end)

-- =========== THEME TAB CONTENT ===========
local ThemeContent = Instance.new("Frame")
ThemeContent.Size = UDim2.new(1, 0, 1, 0)
ThemeContent.BackgroundTransparency = 1
ThemeContent.BorderSizePixel = 0
ThemeContent.ZIndex = 12
ThemeContent.Visible = false
ThemeContent.Parent = ContentFrame

local ThemeLabel = Instance.new("TextLabel")
ThemeLabel.Text = "Interface Theme"
ThemeLabel.Font = Enum.Font.GothamBold
ThemeLabel.TextSize = 16
ThemeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
ThemeLabel.BackgroundTransparency = 1
ThemeLabel.Size = UDim2.new(1, -30, 0, 30)
ThemeLabel.Position = UDim2.new(0, 15, 0, 15)
ThemeLabel.TextXAlignment = Enum.TextXAlignment.Left
ThemeLabel.ZIndex = 14
ThemeLabel.Parent = ThemeContent

local themes = {
	{name = "Red", color = Color3.fromRGB(200, 40, 40), accent = Color3.fromRGB(180, 30, 30)},
	{name = "Blue", color = Color3.fromRGB(0, 140, 255), accent = Color3.fromRGB(0, 100, 200)},
	{name = "Green", color = Color3.fromRGB(40, 180, 80), accent = Color3.fromRGB(30, 140, 60)},
	{name = "Yellow", color = Color3.fromRGB(255, 200, 30), accent = Color3.fromRGB(200, 160, 20)},
}

for i, theme in ipairs(themes) do
	local yPos = 60 + (i - 1) * 55

	local themeButton = Instance.new("TextButton")
	themeButton.Text = theme.name
	themeButton.Font = Enum.Font.GothamBold
	themeButton.TextSize = 14
	themeButton.Size = UDim2.new(1, -50, 0, 40)
	themeButton.Position = UDim2.new(0, 25, 0, yPos)
	themeButton.BackgroundColor3 = theme.color
	themeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	themeButton.BorderSizePixel = 0
	themeButton.ZIndex = 14
	themeButton.Parent = ThemeContent

	themeButton.MouseEnter:Connect(function()
		TweenService:Create(themeButton, TweenInfo.new(0.2), {BackgroundColor3 = theme.accent}):Play()
	end)

	themeButton.MouseLeave:Connect(function()
		TweenService:Create(themeButton, TweenInfo.new(0.2), {BackgroundColor3 = theme.color}):Play()
	end)

	themeButton.MouseButton1Click:Connect(function()
		local uiColor = theme.color
		local uiAccent = theme.accent

		local elementsToUpdate = {
			{MainFrame, "BackgroundColor3", Color3.fromRGB(
				math.clamp(uiColor.R * 255 * 0.12, 15, 35),
				math.clamp(uiColor.G * 255 * 0.12, 15, 35),
				math.clamp(uiColor.B * 255 * 0.12, 15, 35)
			)},
			{TitleBar, "BackgroundColor3", Color3.fromRGB(
				math.clamp(uiColor.R * 255 * 0.15, 20, 40),
				math.clamp(uiColor.G * 255 * 0.15, 20, 40),
				math.clamp(uiColor.B * 255 * 0.15, 20, 40)
			)},
			{TabFrame, "BackgroundColor3", Color3.fromRGB(
				math.clamp(uiColor.R * 255 * 0.10, 15, 30),
				math.clamp(uiColor.G * 255 * 0.10, 15, 30),
				math.clamp(uiColor.B * 255 * 0.10, 15, 30)
			)},
			{MainBorder, "Color", uiAccent},
		}

		for _, data in ipairs(elementsToUpdate) do
			TweenService:Create(data[1], TweenInfo.new(0.3), {[data[2]] = data[3]}):Play()
		end
	end)
end

-- =========== TAB SWITCHING ===========
local function switchTab(tab)
	local mainVisible = (tab == "Main")
	MainContent.Visible = mainVisible
	ThemeContent.Visible = not mainVisible

	local mainActive = mainVisible
	MainTab.BackgroundColor3 = mainActive and Color3.fromRGB(35, 35, 35) or Color3.fromRGB(30, 30, 30)
	MainTab.TextColor3 = mainActive and Color3.fromRGB(200, 200, 200) or Color3.fromRGB(150, 150, 150)

	ThemeTab.BackgroundColor3 = not mainActive and Color3.fromRGB(35, 35, 35) or Color3.fromRGB(30, 30, 30)
	ThemeTab.TextColor3 = not mainActive and Color3.fromRGB(200, 200, 200) or Color3.fromRGB(150, 150, 150)
end

MainTab.MouseButton1Click:Connect(function() switchTab("Main") end)
ThemeTab.MouseButton1Click:Connect(function() switchTab("Theme") end)

-- =========== DRAG FUNCTIONALITY ===========
local isDraggingWindow = false
local dragStart = nil
local startPos = nil

TitleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		isDraggingWindow = true
		dragStart = input.Position
		startPos = MainFrame.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if isDraggingWindow and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		isDraggingWindow = false
	end
end)

-- =========== MINIMIZE & CLOSE ===========
local isMinimized = false
local originalSize = MainFrame.Size

MinimizeButton.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized
	if isMinimized then
		MainFrame:TweenSize(UDim2.new(0, 500, 0, 35), "Out", "Quad", 0.3)
	else
		MainFrame:TweenSize(originalSize, "Out", "Quad", 0.3)
	end
end)

CloseButton.MouseButton1Click:Connect(function()
	local fadeOut = TweenService:Create(MainFrame, TweenInfo.new(0.25), {BackgroundTransparency = 1, Size = UDim2.new(0, 0, 0, 0)})
	fadeOut:Play()
	fadeOut.Completed:Connect(function()
		ScreenGui:Destroy()
	end)
end)

-- =========== BUTTON HOVER EFFECTS ===========
local function addHoverEffect(button)
	button.MouseEnter:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
	end)
	button.MouseLeave:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
	end)
end

addHoverEffect(MinimizeButton)
addHoverEffect(CloseButton)

-- =========== CHARACTER RESPAWN HANDLER ===========
player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	humanoid = newCharacter:WaitForChild("Humanoid")

	if autoWalkEnabled and autoWalkConnection then
		autoWalkConnection:Disconnect()
		autoWalkConnection = RunService.Heartbeat:Connect(function()
			if newCharacter and newCharacter:FindFirstChild("Humanoid") then
				local hum = newCharacter.Humanoid
				if hum.MoveDirection.Magnitude == 0 then
					hum:Move(Vector3.new(0, 0, -1), false)
				end
			end
		end)
	end
end)
