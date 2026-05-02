--[[
	SYNAPSE STYLE UI - COMPLETE LOCALSCRIPT v3
	Fixed: minimize bug, auto walk, save system, ESP, reset button, mobile optimization
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Values storage using Instance attributes
local StorageValues = Instance.new("Folder")
StorageValues.Name = "UISettings"
StorageValues.Parent = player

-- Load saved values or defaults
local function loadValue(name, default)
	local val = StorageValues:GetAttribute(name)
	return val ~= nil and val or default
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

-- State
local autoWalkEnabled = savedAutoWalk
local autoWalkConnection = nil
local espEnabled = savedESP
local espHighlights = {}
local espBillboards = {}

-- Wait for character
local character, humanoid, camera
local function getChar()
	character = player.Character or player.CharacterAdded:Wait()
	humanoid = character:WaitForChild("Humanoid")
	camera = workspace.CurrentCamera
	humanoid.WalkSpeed = savedWalkSpeed
	humanoid.JumpPower = savedJumpPower
	camera.FieldOfView = savedFOV
end
getChar()

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
local MainContainer = Instance.new("Frame")
MainContainer.Size = UDim2.new(0, 500, 0, 420)
MainContainer.Position = UDim2.new(0.5, -250, 0.5, -210)
MainContainer.BackgroundTransparency = 1
MainContainer.ZIndex = 10
MainContainer.Parent = ScreenGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(1, 0, 1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.ZIndex = 10
MainFrame.Parent = MainContainer

local MainBorder = Instance.new("UIStroke")
MainBorder.Color = Color3.fromRGB(60, 60, 60)
MainBorder.Thickness = 1
MainBorder.Parent = MainFrame

-- =========== DRAG SYSTEM ===========
local isDraggingWindow = false
local dragStartPos = nil
local dragStartGuiPos = nil
local moveConnection = nil
local releaseConnection = nil

local function getInputPosition(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or 
	   input.UserInputType == Enum.UserInputType.MouseButton1 or 
	   input.UserInputType == Enum.UserInputType.Touch then
		return input.Position
	end
	return nil
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

TitleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		local pos = getInputPosition(input)
		if pos then
			isDraggingWindow = true
			dragStartPos = pos
			dragStartGuiPos = MainContainer.Position

			if moveConnection then moveConnection:Disconnect() end
			moveConnection = UserInputService.InputChanged:Connect(function(moveInput)
				if isDraggingWindow and (moveInput.UserInputType == Enum.UserInputType.MouseMovement or moveInput.UserInputType == Enum.UserInputType.Touch) then
					local movePos = getInputPosition(moveInput)
					if movePos and dragStartPos then
						local delta = movePos - dragStartPos
						MainContainer.Position = UDim2.new(dragStartGuiPos.X.Scale, dragStartGuiPos.X.Offset + delta.X, dragStartGuiPos.Y.Scale, dragStartGuiPos.Y.Offset + delta.Y)
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

-- Close button with X symbol using Unicode
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 28, 1, -4)
CloseButton.Position = UDim2.new(1, -34, 0, 2)
CloseButton.Text = "✘"  -- Heavy X symbol
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 16
CloseButton.TextColor3 = Color3.fromRGB(255, 80, 80)  -- Red X
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

-- Buttons
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
MainTab.AutoButtonColor = false
MainTab.Parent = TabFrame

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
ThemeTab.AutoButtonColor = false
ThemeTab.Parent = TabFrame

-- =========== SCROLLING FRAMES ===========
local MainScrollingFrame = Instance.new("ScrollingFrame")
MainScrollingFrame.Size = UDim2.new(1, 0, 1, 0)
MainScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 480)
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
MainContent.Size = UDim2.new(1, 0, 0, 450)
MainContent.BackgroundTransparency = 1
MainContent.BorderSizePixel = 0
MainContent.ZIndex = 12
MainContent.Parent = MainScrollingFrame

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
local function createToggle(name, yPos, defaultState, callback)
	local toggleFrame = Instance.new("Frame")
	toggleFrame.Size = UDim2.new(1, -30, 0, 55)
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
	toggleLabel.Size = UDim2.new(0.65, 0, 1, 0)
	toggleLabel.Position = UDim2.new(0, 12, 0, 0)
	toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
	toggleLabel.ZIndex = 14
	toggleLabel.Parent = toggleFrame

	local toggleButton = Instance.new("TextButton")
	toggleButton.Size = UDim2.new(0, 52, 0, 26)
	toggleButton.Position = UDim2.new(1, -64, 0.5, -13)
	toggleButton.Text = ""
	toggleButton.BackgroundColor3 = defaultState and Color3.fromRGB(0, 140, 255) or Color3.fromRGB(55, 55, 55)
	toggleButton.BorderSizePixel = 0
	toggleButton.ZIndex = 14
	toggleButton.AutoButtonColor = false
	toggleButton.Parent = toggleFrame

	local toggleDot = Instance.new("Frame")
	toggleDot.Size = UDim2.new(0, 20, 0, 20)
	toggleDot.Position = defaultState and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
	toggleDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	toggleDot.BorderSizePixel = 0
	toggleDot.ZIndex = 15
	toggleDot.Parent = toggleButton

	local toggleState = defaultState

	toggleButton.MouseButton1Click:Connect(function()
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

	if callback and defaultState then
		task.spawn(function() callback(defaultState) end)
	end

	return toggleFrame
end

local function createSlider(name, yPos, minVal, maxVal, defaultVal, callback)
	local sliderFrame = Instance.new("Frame")
	sliderFrame.Size = UDim2.new(1, -30, 0, 80)
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
	sliderBar.Size = UDim2.new(1, -24, 0, 8)
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
	sliderButton.Size = UDim2.new(0, 20, 0, 20)
	sliderButton.Position = UDim2.new(ratio, -10, 0.5, -10)
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
		local relativeX = (input.Position.X - barAbsPos.X) / barAbsSize.X
		relativeX = math.clamp(relativeX, 0, 1)

		local value = minVal + (maxVal - minVal) * relativeX
		value = math.floor(value * 10 + 0.5) / 10

		sliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
		sliderButton.Position = UDim2.new(relativeX, -10, 0.5, -10)
		sliderLabel.Text = name .. " [" .. tostring(value) .. "]"
		currentValue = value

		if callback then callback(value) end
	end

	sliderButton.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			isDragging = true
		end
	end)

	sliderBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			isDragging = true
			updateSlider(input)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			updateSlider(input)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and isDragging then
			isDragging = false
		end
	end)

	if callback then callback(defaultVal) end

	return {frame = sliderFrame, setValue = function(val) 
		local r = (val - minVal) / (maxVal - minVal)
		sliderFill.Size = UDim2.new(r, 0, 1, 0)
		sliderButton.Position = UDim2.new(r, -10, 0.5, -10)
		sliderLabel.Text = name .. " [" .. tostring(val) .. "]"
		currentValue = val
		if callback then callback(val) end
	end}
end

-- =========== MAIN TAB CONTENT ===========
-- Auto Walk Toggle
createToggle("Auto Walk", 10, savedAutoWalk, function(state)
	autoWalkEnabled = state
	saveValue("AutoWalk", state)

	if autoWalkConnection then
		autoWalkConnection:Disconnect()
		autoWalkConnection = nil
	end

	if autoWalkEnabled then
		autoWalkConnection = RunService.Heartbeat:Connect(function()
			local char = player.Character
			if char and char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart") then
				local hum = char.Humanoid
				local rootPart = char.HumanoidRootPart
				if hum.MoveDirection.Magnitude < 0.1 then
					local forwardDir = rootPart.CFrame.LookVector * Vector3.new(1, 0, 1)
					if forwardDir.Magnitude > 0.01 then
						hum:Move(forwardDir.Unit, false)
					else
						hum:Move(Vector3.new(0, 0, -1), false)
					end
				end
			end
		end)
	end
end)

-- Walk Speed Slider
local walkSpeedSlider = createSlider("Walk Speed", 75, 8, 100, savedWalkSpeed, function(value)
	if player.Character and player.Character:FindFirstChild("Humanoid") then
		player.Character.Humanoid.WalkSpeed = value
	end
	saveValue("WalkSpeed", value)
end)

-- Jump Power Slider
local jumpPowerSlider = createSlider("Jump Power", 165, 10, 200, savedJumpPower, function(value)
	if player.Character and player.Character:FindFirstChild("Humanoid") then
		player.Character.Humanoid.JumpPower = value
	end
	saveValue("JumpPower", value)
end)

-- FOV Slider
local fovSlider = createSlider("Field of View", 255, 30, 120, savedFOV, function(value)
	camera.FieldOfView = value
	saveValue("FOV", value)
end)

-- ESP Toggle
createToggle("ESP Players", 345, savedESP, function(state)
	espEnabled = state
	saveValue("ESP", state)

	if not state then
		for _, hl in pairs(espHighlights) do
			pcall(function() hl:Destroy() end)
		end
		espHighlights = {}
		for _, bb in pairs(espBillboards) do
			pcall(function() bb:Destroy() end)
		end
		espBillboards = {}
	end
end)

-- Reset Button
local ResetButton = Instance.new("TextButton")
ResetButton.Text = "↻ Reset Settings"
ResetButton.Font = Enum.Font.GothamBold
ResetButton.TextSize = 13
ResetButton.TextColor3 = Color3.fromRGB(255, 180, 180)
ResetButton.BackgroundColor3 = Color3.fromRGB(45, 30, 30)
ResetButton.BorderSizePixel = 0
ResetButton.ZIndex = 14
ResetButton.Size = UDim2.new(1, -30, 0, 40)
ResetButton.Position = UDim2.new(0, 15, 0, 410)
ResetButton.AutoButtonColor = false
ResetButton.Parent = MainContent

ResetButton.MouseEnter:Connect(function()
	TweenService:Create(ResetButton, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(60, 30, 30)}):Play()
end)
ResetButton.MouseLeave:Connect(function()
	TweenService:Create(ResetButton, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(45, 30, 30)}):Play()
end)

ResetButton.MouseButton1Click:Connect(function()
	-- Reset all settings
	walkSpeedSlider.setValue(16)
	jumpPowerSlider.setValue(50)
	fovSlider.setValue(70)
	saveValue("WalkSpeed", 16)
	saveValue("JumpPower", 50)
	saveValue("FOV", 70)
	
	-- Reset toggles (they'll be recreated next time, but values are saved)
	saveValue("AutoWalk", false)
	saveValue("ESP", false)
	autoWalkEnabled = false
	if autoWalkConnection then
		autoWalkConnection:Disconnect()
		autoWalkConnection = nil
	end
	
	espEnabled = false
	for _, hl in pairs(espHighlights) do
		pcall(function() hl:Destroy() end)
	end
	espHighlights = {}
	for _, bb in pairs(espBillboards) do
		pcall(function() bb:Destroy() end)
	end
	espBillboards = {}
end)

-- =========== ESP SYSTEM (Name + Distance) ===========
RunService.Heartbeat:Connect(function()
	if not espEnabled then return end
	
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr == player or not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then
			-- Clean up if exists
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
		
		local char = plr.Character
		local rootPart = char.HumanoidRootPart
		local head = char:FindFirstChild("Head")
		
		-- Create or update highlight
		if not espHighlights[plr.UserId] or espHighlights[plr.UserId].Parent ~= char then
			if espHighlights[plr.UserId] then espHighlights[plr.UserId]:Destroy() end
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
		
		-- Create or update billboard
		if head then
			if not espBillboards[plr.UserId] or espBillboards[plr.UserId].Parent ~= head then
				if espBillboards[plr.UserId] then espBillboards[plr.UserId]:Destroy() end
				
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
				nameLabel.Name = "Name"
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
			
			-- Update distance
			if espBillboards[plr.UserId] then
				local billboard = espBillboards[plr.UserId]
				local distFrame = billboard:FindFirstChild("Frame")
				if distFrame then
					local distLabel = distFrame:FindFirstChild("Distance")
					if distLabel and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
						local myPos = player.Character.HumanoidRootPart.Position
						local theirPos = rootPart.Position
						local distance = (myPos - theirPos).Magnitude
						distLabel.Text = string.format("%.1fm", distance)
					end
				end
			end
		end
	end
	
	-- Clean up disconnected players
	for userId, _ in pairs(espHighlights) do
		if not Players:GetPlayerByUserId(userId) then
			pcall(function() espHighlights[userId]:Destroy() end)
			espHighlights[userId] = nil
		end
	end
	for userId, _ in pairs(espBillboards) do
		if not Players:GetPlayerByUserId(userId) then
			pcall(function() espBillboards[userId]:Destroy() end)
			espBillboards[userId] = nil
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
		MainScrollingFrame.ScrollBarImageColor3 = theme.main
		ThemeScrollingFrame.ScrollBarImageColor3 = theme.main
	end)
end

-- =========== TAB SWITCHING ===========
local function switchTab(tab)
	if tab == "Main" then
		MainScrollingFrame.Visible = true
		ThemeScrollingFrame.Visible = false
		TweenService:Create(MainTab, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 35), TextColor3 = Color3.fromRGB(200, 200, 200)}):Play()
		TweenService:Create(ThemeTab, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 30), TextColor3 = Color3.fromRGB(150, 150, 150)}):Play()
	else
		MainScrollingFrame.Visible = false
		ThemeScrollingFrame.Visible = true
		TweenService:Create(MainTab, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 30), TextColor3 = Color3.fromRGB(150, 150, 150)}):Play()
		TweenService:Create(ThemeTab, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 35), TextColor3 = Color3.fromRGB(200, 200, 200)}):Play()
	end
end

MainTab.MouseButton1Click:Connect(function() switchTab("Main") end)
ThemeTab.MouseButton1Click:Connect(function() switchTab("Theme") end)

-- =========== MINIMIZE & CLOSE ===========
local isMinimized = false
local originalSize = MainContainer.Size

MinimizeButton.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized
	if isMinimized then
		MainContainer:TweenSize(UDim2.new(0, 500, 0, 35), "Out", "Quad", 0.3)
	else
		MainContainer:TweenSize(originalSize, "Out", "Quad", 0.3)
	end
end)

CloseButton.MouseButton1Click:Connect(function()
	TweenService:Create(MainContainer, TweenInfo.new(0.25), {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}):Play()
	task.wait(0.25)
	ScreenGui:Destroy()
end)

-- =========== BUTTON HOVER EFFECTS ===========
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

-- =========== CHARACTER RESPAWN HANDLER ===========
player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	humanoid = newCharacter:WaitForChild("Humanoid")
	camera = workspace.CurrentCamera
	
	-- Apply saved settings
	humanoid.WalkSpeed = loadValue("WalkSpeed", 16)
	humanoid.JumpPower = loadValue("JumpPower", 50)
	camera.FieldOfView = loadValue("FOV", 70)
	
	-- Restart auto walk if enabled
	if autoWalkEnabled then
		if autoWalkConnection then autoWalkConnection:Disconnect() end
		autoWalkConnection = RunService.Heartbeat:Connect(function()
			local char = player.Character
			if char and char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart") then
				local hum = char.Humanoid
				local rootPart = char.HumanoidRootPart
				if hum.MoveDirection.Magnitude < 0.1 then
					local forwardDir = rootPart.CFrame.LookVector * Vector3.new(1, 0, 1)
					if forwardDir.Magnitude > 0.01 then
						hum:Move(forwardDir.Unit, false)
					else
						hum:Move(Vector3.new(0, 0, -1), false)
					end
				end
			end
		end)
	end
	
	-- Clear ESP highlights for old character
	for userId, hl in pairs(espHighlights) do
		if hl.Parent ~= Players:GetPlayerByUserId(userId)?.Character then
			pcall(function() hl:Destroy() end)
		end
	end
	for userId, bb in pairs(espBillboards) do
		pcall(function() bb:Destroy() end)
	end
	espBillboards = {}
end)

-- =========== INITIAL AUTO WALK (if saved) ===========
if savedAutoWalk then
	autoWalkConnection = RunService.Heartbeat:Connect(function()
		local char = player.Character
		if char and char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart") then
			local hum = char.Humanoid
			local rootPart = char.HumanoidRootPart
			if hum.MoveDirection.Magnitude < 0.1 then
				local forwardDir = rootPart.CFrame.LookVector * Vector3.new(1, 0, 1)
				if forwardDir.Magnitude > 0.01 then
					hum:Move(forwardDir.Unit, false)
				else
					hum:Move(Vector3.new(0, 0, -1), false)
				end
			end
		end
	end)
end
