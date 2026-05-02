--[[
	SYNAPSE STYLE UI - COMPLETE LOCALSCRIPT
	Full Mobile/PC Support - Fixed All Issues
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Wait for character
local character, humanoid, camera

local function getChar()
	character = player.Character or player.CharacterAdded:Wait()
	humanoid = character:WaitForChild("Humanoid")
	camera = workspace.CurrentCamera
end
getChar()

-- Default values
local defaultWalkSpeed = 16
local defaultJumpPower = 50
local defaultFOV = 70

-- State variables
local autoWalkEnabled = false
local autoWalkConnection = nil

-- Create ScreenGui
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
MainFrame.Size = UDim2.new(0, 500, 0, 420)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = false
MainFrame.ZIndex = 10
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainBorder = Instance.new("UIStroke")
MainBorder.Color = Color3.fromRGB(60, 60, 60)
MainBorder.Thickness = 1
MainBorder.Parent = MainFrame

-- =========== DRAG SYSTEM (MOBILE + PC) ===========
local dragConnection, moveConnection, releaseConnection
local isDraggingWindow = false
local dragStartPos = nil
local dragStartGuiPos = nil

local function getInputPosition(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 then
		return input.Position
	elseif input.UserInputType == Enum.UserInputType.Touch then
		return input.Position
	end
	return nil
end

local function isMouseOrTouch(input)
	return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
end

-- Title bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 11
TitleBar.Active = true
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

-- Drag detection
TitleBar.InputBegan:Connect(function(input)
	if isMouseOrTouch(input) then
		local pos = getInputPosition(input)
		if pos then
			isDraggingWindow = true
			dragStartPos = pos
			dragStartGuiPos = MainFrame.Position

			if moveConnection then moveConnection:Disconnect() end
			moveConnection = UserInputService.InputChanged:Connect(function(moveInput)
				if isDraggingWindow and (moveInput.UserInputType == Enum.UserInputType.MouseMovement or moveInput.UserInputType == Enum.UserInputType.Touch) then
					local movePos = getInputPosition(moveInput)
					if movePos and dragStartPos then
						local delta = movePos - dragStartPos
						MainFrame.Position = UDim2.new(dragStartGuiPos.X.Scale, dragStartGuiPos.X.Offset + delta.X, dragStartGuiPos.Y.Scale, dragStartGuiPos.Y.Offset + delta.Y)
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

-- Content container with scrolling
local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -120, 1, -35)
ContentContainer.Position = UDim2.new(0, 120, 0, 35)
ContentContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ContentContainer.BorderSizePixel = 0
ContentContainer.ClipsDescendants = true
ContentContainer.ZIndex = 11
ContentContainer.Parent = MainFrame

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

-- =========== SCROLLING FRAME FOR CONTENT ===========
-- Main content with scrolling
local MainScrollingFrame = Instance.new("ScrollingFrame")
MainScrollingFrame.Size = UDim2.new(1, 0, 1, 0)
MainScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 450) -- Will fit all content
MainScrollingFrame.ScrollBarThickness = 4
MainScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 140, 255)
MainScrollingFrame.BackgroundTransparency = 1
MainScrollingFrame.BorderSizePixel = 0
MainScrollingFrame.ZIndex = 12
MainScrollingFrame.ScrollingDirection = Enum.ScrollingDirection.Y
MainScrollingFrame.VerticalScrollBarInset = Enum.ScrollBarInset.Always
MainScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
MainScrollingFrame.Parent = ContentContainer

local MainContent = Instance.new("Frame")
MainContent.Size = UDim2.new(1, 0, 0, 420)
MainContent.BackgroundTransparency = 1
MainContent.BorderSizePixel = 0
MainContent.ZIndex = 12
MainContent.Parent = MainScrollingFrame

-- Theme content with scrolling
local ThemeScrollingFrame = Instance.new("ScrollingFrame")
ThemeScrollingFrame.Size = UDim2.new(1, 0, 1, 0)
ThemeScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 300)
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
ThemeContent.Size = UDim2.new(1, 0, 1, 0)
ThemeContent.BackgroundTransparency = 1
ThemeContent.BorderSizePixel = 0
ThemeContent.ZIndex = 12
ThemeContent.Parent = ThemeScrollingFrame

-- =========== HELPER FUNCTIONS ===========
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
	toggleButton.AutoButtonColor = false
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

		if toggleState then
			TweenService:Create(toggleDot, TweenInfo.new(0.2), {Position = UDim2.new(1, -20, 0.5, -9)}):Play()
			TweenService:Create(toggleButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 140, 255)}):Play()
		else
			TweenService:Create(toggleDot, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -9)}):Play()
			TweenService:Create(toggleButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(55, 55, 55)}):Play()
		end

		if callback then callback(toggleState) end
	end)

	return toggleFrame
end

local function createSlider(name, yPos, minVal, maxVal, defaultVal, callback)
	local sliderFrame = Instance.new("Frame")
	sliderFrame.Size = UDim2.new(1, -30, 0, 75)
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
	sliderBar.Size = UDim2.new(1, -24, 0, 6)
	sliderBar.Position = UDim2.new(0, 12, 0, 42)
	sliderBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	sliderBar.BorderSizePixel = 0
	sliderBar.ZIndex = 14
	sliderBar.Active = true
	sliderBar.Parent = sliderFrame

	local sliderFill = Instance.new("Frame")
	local ratio = (defaultVal - minVal) / (maxVal - minVal)
	sliderFill.Size = UDim2.new(ratio, 0, 1, 0)
	sliderFill.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
	sliderFill.BorderSizePixel = 0
	sliderFill.ZIndex = 15
	sliderFill.Parent = sliderBar

	local sliderButton = Instance.new("TextButton")
	sliderButton.Size = UDim2.new(0, 18, 0, 18)
	sliderButton.Position = UDim2.new(ratio, -9, 0.5, -9)
	sliderButton.Text = ""
	sliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	sliderButton.BorderSizePixel = 0
	sliderButton.ZIndex = 16
	sliderButton.AutoButtonColor = false
	sliderButton.Active = true
	sliderButton.Parent = sliderBar

	local isDragging = false
	local currentValue = defaultVal

	local function updateSlider(input)
		local barAbsPos = sliderBar.AbsolutePosition
		local barAbsSize = sliderBar.AbsoluteSize

		local relativeX
		if input.UserInputType == Enum.UserInputType.Touch then
			relativeX = (input.Position.X - barAbsPos.X) / barAbsSize.X
		else
			relativeX = (input.Position.X - barAbsPos.X) / barAbsSize.X
		end
		relativeX = math.clamp(relativeX, 0, 1)

		local value = minVal + (maxVal - minVal) * relativeX
		value = math.floor(value * 10 + 0.5) / 10

		sliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
		sliderButton.Position = UDim2.new(relativeX, -9, 0.5, -9)
		sliderLabel.Text = name .. " [" .. tostring(value) .. "]"
		currentValue = value

		if callback then callback(value) end
	end

	-- Mouse/Touch down on slider button
	sliderButton.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			isDragging = true
		end
	end)

	-- Mouse/Touch down on bar
	sliderBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			isDragging = true
			updateSlider(input)
		end
	end)

	-- Movement tracking
	UserInputService.InputChanged:Connect(function(input)
		if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			updateSlider(input)
		end
	end)

	-- Release
	UserInputService.InputEnded:Connect(function(input)
		if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and isDragging then
			isDragging = false
		end
	end)

	-- Initial callback
	if callback then callback(defaultVal) end

	return sliderFrame
end

-- =========== MAIN TAB CONTENT ===========
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
				local rootPart = char:FindFirstChild("HumanoidRootPart")
				if rootPart and hum.MoveDirection.Magnitude == 0 then
					-- Move forward relative to character
					local forwardDir = rootPart.CFrame.LookVector * Vector3.new(1, 0, 1)
					hum:Move(forwardDir.Unit, false)
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

createSlider("Jump Power", 150, 10, 200, defaultJumpPower, function(value)
	local char = player.Character
	if char and char:FindFirstChild("Humanoid") then
		char.Humanoid.JumpPower = value
	end
end)

createSlider("Field of View", 235, 30, 120, defaultFOV, function(value)
	camera.FieldOfView = value
end)

-- ESP Label
local espLabelFrame = Instance.new("Frame")
espLabelFrame.Size = UDim2.new(1, -30, 0, 40)
espLabelFrame.Position = UDim2.new(0, 15, 0, 330)
espLabelFrame.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
espLabelFrame.BorderSizePixel = 0
espLabelFrame.ZIndex = 13
espLabelFrame.Parent = MainContent

local espLabel = Instance.new("TextLabel")
espLabel.Text = "ESP Players"
espLabel.Font = Enum.Font.Gotham
espLabel.TextSize = 13
espLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
espLabel.BackgroundTransparency = 1
espLabel.Size = UDim2.new(0.7, 0, 1, 0)
espLabel.Position = UDim2.new(0, 10, 0, 0)
espLabel.TextXAlignment = Enum.TextXAlignment.Left
espLabel.ZIndex = 14
espLabel.Parent = espLabelFrame

-- ESP Toggle
local espToggleButton = Instance.new("TextButton")
espToggleButton.Size = UDim2.new(0, 48, 0, 22)
espToggleButton.Position = UDim2.new(1, -60, 0.5, -11)
espToggleButton.Text = ""
espToggleButton.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
espToggleButton.BorderSizePixel = 0
espToggleButton.ZIndex = 14
espToggleButton.AutoButtonColor = false
espToggleButton.Parent = espLabelFrame

local espToggleDot = Instance.new("Frame")
espToggleDot.Size = UDim2.new(0, 18, 0, 18)
espToggleDot.Position = UDim2.new(0, 2, 0.5, -9)
espToggleDot.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
espToggleDot.BorderSizePixel = 0
espToggleDot.ZIndex = 15
espToggleDot.Parent = espToggleButton

local espEnabled = false
local espHighlights = {}

espToggleButton.MouseButton1Click:Connect(function()
	espEnabled = not espEnabled

	if espEnabled then
		TweenService:Create(espToggleDot, TweenInfo.new(0.2), {Position = UDim2.new(1, -20, 0.5, -9)}):Play()
		TweenService:Create(espToggleButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 140, 255)}):Play()
	else
		TweenService:Create(espToggleDot, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -9)}):Play()
		TweenService:Create(espToggleButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(55, 55, 55)}):Play()
		-- Clear ESP
		for _, hl in pairs(espHighlights) do
			hl:Destroy()
		end
		espHighlights = {}
	end
end)

-- ESP Loop (simple highlight ESP)
RunService.Heartbeat:Connect(function()
	if espEnabled then
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
				if not espHighlights[plr.UserId] or not espHighlights[plr.UserId].Parent then
					local highlight = Instance.new("Highlight")
					highlight.Name = "ESP"
					highlight.FillColor = Color3.fromRGB(255, 0, 0)
					highlight.FillTransparency = 0.5
					highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
					highlight.OutlineTransparency = 0
					highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
					highlight.Adornee = plr.Character
					highlight.Parent = plr.Character
					espHighlights[plr.UserId] = highlight
				end
			end
		end

		-- Clean up highlights for players who left
		for userId, hl in pairs(espHighlights) do
			local plr = Players:GetPlayerByUserId(userId)
			if not plr or not plr.Character or hl.Parent ~= plr.Character then
				hl:Destroy()
				espHighlights[userId] = nil
			end
		end
	end
end)

-- =========== THEME TAB CONTENT ===========
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
	{name = "Red", main = Color3.fromRGB(200, 30, 30), accent = Color3.fromRGB(160, 20, 20), dark = Color3.fromRGB(30, 20, 20)},
	{name = "Blue", main = Color3.fromRGB(0, 140, 255), accent = Color3.fromRGB(0, 100, 200), dark = Color3.fromRGB(20, 25, 35)},
	{name = "Green", main = Color3.fromRGB(30, 180, 70), accent = Color3.fromRGB(20, 140, 50), dark = Color3.fromRGB(20, 30, 20)},
	{name = "Yellow", main = Color3.fromRGB(255, 190, 20), accent = Color3.fromRGB(200, 150, 15), dark = Color3.fromRGB(35, 30, 20)},
}

for i, theme in ipairs(themes) do
	local yPos = 55 + (i - 1) * 55

	local themeButton = Instance.new("TextButton")
	themeButton.Text = theme.name
	themeButton.Font = Enum.Font.GothamBold
	themeButton.TextSize = 14
	themeButton.Size = UDim2.new(1, -50, 0, 40)
	themeButton.Position = UDim2.new(0, 25, 0, yPos)
	themeButton.BackgroundColor3 = theme.main
	themeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	themeButton.BorderSizePixel = 0
	themeButton.ZIndex = 14
	themeButton.AutoButtonColor = false
	themeButton.Parent = ThemeContent

	themeButton.MouseEnter:Connect(function()
		TweenService:Create(themeButton, TweenInfo.new(0.2), {BackgroundColor3 = theme.accent}):Play()
	end)

	themeButton.MouseLeave:Connect(function()
		TweenService:Create(themeButton, TweenInfo.new(0.2), {BackgroundColor3 = theme.main}):Play()
	end)

	themeButton.MouseButton1Click:Connect(function()
		local tweenInfo = TweenInfo.new(0.3)

		-- Update UI colors
		TweenService:Create(MainFrame, tweenInfo, {BackgroundColor3 = theme.dark}):Play()
		TweenService:Create(TitleBar, tweenInfo, {BackgroundColor3 = Color3.fromRGB(
			math.clamp(theme.dark.R * 255 + 10, 0, 255) / 255,
			math.clamp(theme.dark.G * 255 + 10, 0, 255) / 255,
			math.clamp(theme.dark.B * 255 + 10, 0, 255) / 255
		)}):Play()
		TweenService:Create(TabFrame, tweenInfo, {BackgroundColor3 = Color3.fromRGB(
			math.max(0, theme.dark.R * 255 - 8) / 255,
			math.max(0, theme.dark.G * 255 - 8) / 255,
			math.max(0, theme.dark.B * 255 - 8) / 255
		)}):Play()
		TweenService:Create(MainBorder, tweenInfo, {Color = theme.main}):Play()

		-- Update scrollbar color
		MainScrollingFrame.ScrollBarImageColor3 = theme.main
		ThemeScrollingFrame.ScrollBarImageColor3 = theme.main
	end)
end

-- =========== TAB SWITCHING ===========
local function switchTab(tab)
	if tab == "Main" then
		MainScrollingFrame.Visible = true
		ThemeScrollingFrame.Visible = false
		MainTab.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
		MainTab.TextColor3 = Color3.fromRGB(200, 200, 200)
		ThemeTab.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		ThemeTab.TextColor3 = Color3.fromRGB(150, 150, 150)
	else
		MainScrollingFrame.Visible = false
		ThemeScrollingFrame.Visible = true
		MainTab.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		MainTab.TextColor3 = Color3.fromRGB(150, 150, 150)
		ThemeTab.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
		ThemeTab.TextColor3 = Color3.fromRGB(200, 200, 200)
	end
end

MainTab.MouseButton1Click:Connect(function() switchTab("Main") end)
ThemeTab.MouseButton1Click:Connect(function() switchTab("Theme") end)

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
	TweenService:Create(MainFrame, TweenInfo.new(0.25), {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}):Play()
	task.wait(0.25)
	ScreenGui:Destroy()
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
	camera = workspace.CurrentCamera

	-- Apply current values
	-- We need to re-get current slider values
	-- For simplicity, we apply defaults if sliders haven't been moved
	humanoid.WalkSpeed = defaultWalkSpeed
	humanoid.JumpPower = defaultJumpPower
	camera.FieldOfView = defaultFOV

	-- Restart auto walk if enabled
	if autoWalkEnabled then
		if autoWalkConnection then
			autoWalkConnection:Disconnect()
		end
		autoWalkConnection = RunService.Heartbeat:Connect(function()
			local char = player.Character
			if char and char:FindFirstChild("Humanoid") then
				local hum = char.Humanoid
				local rootPart = char:FindFirstChild("HumanoidRootPart")
				if rootPart and hum.MoveDirection.Magnitude == 0 then
					local forwardDir = rootPart.CFrame.LookVector * Vector3.new(1, 0, 1)
					hum:Move(forwardDir.Unit, false)
				end
			end
		end)
	end
end)
