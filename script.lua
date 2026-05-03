--[[
	SYNAPSE HUB v28 - COMPLETE FIXED ORDER
	by Vanezy Scripts
]]

print("START - Synapse Hub v28")

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
if not player then
	player = Players.PlayerAdded:Wait()
end

-- =========== АДМИН ===========
local ADMIN_USER_ID = 1594386985
local isAdmin = (player.UserId == ADMIN_USER_ID)
if isAdmin then print("✅ ADMIN MODE ACTIVATED") end

-- =========== GUI ===========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SynapseHub"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = player:WaitForChild("PlayerGui") end)
if not ScreenGui.Parent then ScreenGui.Parent = CoreGui end

-- =========== ПЕРЕМЕННЫЕ ===========
local camera = Workspace.CurrentCamera
local flyConnection, noClipConnection, bodyVelocity, rainbowConnection, espConnection, killLoopConnection = nil, nil, nil, nil, nil, nil
local rainbowHue, killLoopActive = 0, false
local frozenPlayers = {}
local isMinimized, floatingButton, currentTab = false, nil, "HOME"
local goodModeActive, goodModeConnection = false, nil
local MIN_W, MAX_W, MIN_H, MAX_H = 150, 450, 100, 350

-- =========== FORWARD DECLARATIONS ===========
local walkSlider, jumpSlider, fovSlider, flySpeedSlider
local speedHackSlider, espSizeSlider, fogSlider, brightnessSlider
local minimizeMenu, restoreMenu, updateESP

-- =========== ХРАНИЛИЩЕ ===========
local StorageValues = Instance.new("Folder")
StorageValues.Name = "UISettings"
StorageValues.Parent = player
local function loadValue(name, d) local v = StorageValues:GetAttribute(name); return v ~= nil and v or d end
local function saveValue(name, v) StorageValues:SetAttribute(name, v) end

local DEFAULT_SETTINGS = {
	walkSpeed = 16, jumpPower = 50, fov = 70,
	espPlayers = false, espChests = false, espMobs = false, espSize = 1.5, espHealth = true, espDistance = true,
	flyEnabled = false, flySpeed = 50, noclip = false, speedHack = false, speedHackValue = 50,
	infiniteJump = false, rainbow = false, goodMode = false, windowWidth = 450, windowHeight = 420,
	floatingX = 10, floatingY = 300
}
local settings = {}
for k, d in pairs(DEFAULT_SETTINGS) do settings[k] = loadValue(k, d) end

-- =========== ФУНКЦИИ (ВСЕ ЗАРАНЕЕ) ===========
local function createNotification(text, duration)
	if not ScreenGui then return end
	local container = ScreenGui:FindFirstChild("NotificationContainer")
	if not container then
		container = Instance.new("Frame")
		container.Name = "NotificationContainer"
		container.Size = UDim2.new(0, 300, 0, 0)
		container.Position = UDim2.new(1, -10, 0, 5)
		container.AnchorPoint = Vector2.new(1, 0)
		container.BackgroundTransparency = 1
		container.ZIndex = 300
		container.Parent = ScreenGui
	end

	local n = Instance.new("Frame")
	n.Size = UDim2.new(1, 0, 0, 38)
	n.Position = UDim2.new(0, 0, 0, 0)
	n.BackgroundColor3 = Color3.fromRGB(20, 20, 32)
	n.BackgroundTransparency = 0.08
	n.BorderSizePixel = 0
	n.ZIndex = 301
	n.Parent = container

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = n

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(0, 155, 255)
	stroke.Thickness = 1
	stroke.Transparency = 0.3
	stroke.Parent = n

	local label = Instance.new("TextLabel")
	label.Text = text
	label.Font = Enum.Font.GothamBold
	label.TextSize = 12
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, -15, 1, 0)
	label.Position = UDim2.new(0, 12, 0, 0)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.Parent = n

	local bar = Instance.new("Frame")
	bar.Size = UDim2.new(1, -20, 0, 2)
	bar.Position = UDim2.new(0, 10, 1, -4)
	bar.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
	bar.BorderSizePixel = 0
	bar.Parent = n

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new(1, 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
	fill.BorderSizePixel = 0
	fill.Parent = bar
	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(1, 0)
	fillCorner.Parent = fill

	n.BackgroundTransparency = 1
	n.Size = UDim2.new(1, 0, 0, 0)
	TweenService:Create(n, TweenInfo.new(0.25), {BackgroundTransparency = 0.08, Size = UDim2.new(1, 0, 0, 38)}):Play()
	TweenService:Create(fill, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 1, 0)}):Play()

	task.delay(duration, function()
		if n and n.Parent then
			TweenService:Create(n, TweenInfo.new(0.25), {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0)}):Play()
			task.wait(0.3)
			n:Destroy()
		end
	end)
end

local function createSection(parent, name, yPos)
	local s = Instance.new("Frame")
	s.Size = UDim2.new(1, -20, 0, 28)
	s.Position = UDim2.new(0, 10, 0, yPos)
	s.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
	s.BackgroundTransparency = 0.5
	s.BorderSizePixel = 0
	s.Parent = parent
	Instance.new("UICorner").CornerRadius = UDim.new(0, 8)
	local txt = Instance.new("TextLabel")
	txt.Text = name
	txt.Font = Enum.Font.GothamBold
	txt.TextSize = 12
	txt.TextColor3 = Color3.fromRGB(0, 160, 255)
	txt.BackgroundTransparency = 1
	txt.Size = UDim2.new(1, -10, 1, 0)
	txt.Position = UDim2.new(0, 10, 0, 0)
	txt.TextXAlignment = Enum.TextXAlignment.Left
	txt.TextYAlignment = Enum.TextYAlignment.Center
	txt.Parent = s
end

local function createToggle(parent, name, yPos, defaultState, callback)
	local f = Instance.new("Frame")
	f.Size = UDim2.new(1, -20, 0, 36)
	f.Position = UDim2.new(0, 10, 0, yPos)
	f.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
	f.BorderSizePixel = 0
	f.Parent = parent
	Instance.new("UICorner").CornerRadius = UDim.new(0, 8)
	local l = Instance.new("TextLabel")
	l.Text = name
	l.Font = Enum.Font.Gotham
	l.TextSize = 12
	l.TextColor3 = Color3.fromRGB(180, 180, 200)
	l.BackgroundTransparency = 1
	l.Size = UDim2.new(0.65, 0, 1, 0)
	l.Position = UDim2.new(0, 10, 0, 0)
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Parent = f
	local btn = Instance.new("Frame")
	btn.Size = UDim2.new(0, 44, 0, 24)
	btn.Position = UDim2.new(1, -54, 0.5, -12)
	btn.BackgroundColor3 = defaultState and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(200, 50, 50)
	btn.BorderSizePixel = 0
	btn.Parent = f
	Instance.new("UICorner").CornerRadius = UDim.new(1, 0)
	local dot = Instance.new("Frame")
	dot.Size = UDim2.new(0, 18, 0, 18)
	dot.Position = defaultState and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
	dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	dot.BorderSizePixel = 0
	dot.Parent = btn
	Instance.new("UICorner").CornerRadius = UDim.new(1, 0)
	local hit = Instance.new("TextButton")
	hit.Size = UDim2.new(1, 0, 1, 0)
	hit.BackgroundTransparency = 1
	hit.Text = ""
	hit.Parent = btn
	local state = defaultState
	hit.MouseButton1Click:Connect(function()
		state = not state
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = state and Color3.fromRGB(0,200,100) or Color3.fromRGB(200,50,50)}):Play()
		TweenService:Create(dot, TweenInfo.new(0.15), {Position = state and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,3,0.5,-9)}):Play()
		if callback then callback(state) end
	end)
	return f
end

local function createSlider(parent, name, yPos, minVal, maxVal, defaultVal, callback)
	local f = Instance.new("Frame")
	f.Size = UDim2.new(1, -20, 0, 58)
	f.Position = UDim2.new(0, 10, 0, yPos)
	f.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
	f.BorderSizePixel = 0
	f.Parent = parent
	Instance.new("UICorner").CornerRadius = UDim.new(0, 8)
	local l = Instance.new("TextLabel")
	l.Text = name .. " [" .. tostring(defaultVal) .. "]"
	l.Font = Enum.Font.Gotham
	l.TextSize = 12
	l.TextColor3 = Color3.fromRGB(180, 180, 200)
	l.BackgroundTransparency = 1
	l.Size = UDim2.new(1, -20, 0, 22)
	l.Position = UDim2.new(0, 10, 0, 5)
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Parent = f
	local bar = Instance.new("Frame")
	bar.Size = UDim2.new(1, -24, 0, 4)
	bar.Position = UDim2.new(0, 12, 0, 38)
	bar.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
	bar.BorderSizePixel = 0
	bar.Parent = f
	Instance.new("UICorner").CornerRadius = UDim.new(1, 0)
	local ratio = (defaultVal - minVal) / (maxVal - minVal)
	local fill = Instance.new("Frame")
	fill.Size = UDim2.new(ratio, 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
	fill.BorderSizePixel = 0
	fill.Parent = bar
	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 16, 0, 16)
	knob.Position = UDim2.new(ratio, -8, 0.5, -8)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.BorderSizePixel = 0
	knob.Parent = bar
	Instance.new("UICorner").CornerRadius = UDim.new(1, 0)
	local dragging = false
	local cur = defaultVal
	local function update(input)
		local pos = bar.AbsolutePosition
		local sz = bar.AbsoluteSize
		if not pos or not sz then return end
		local x = (input.Position.X - pos.X) / sz.X
		x = math.clamp(x, 0, 1)
		local val = minVal + (maxVal - minVal) * x
		val = math.floor(val * 10 + 0.5) / 10
		fill.Size = UDim2.new(x, 0, 1, 0)
		knob.Position = UDim2.new(x, -8, 0.5, -8)
		l.Text = name .. " [" .. tostring(val) .. "]"
		cur = val
		if callback then callback(val) end
	end
	knob.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
	end)
	bar.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			update(i)
		end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement) then update(i) end
	end)
	UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
	end)
	if callback then callback(defaultVal) end
	return {setValue = function(val)
		local r = (val - minVal) / (maxVal - minVal)
		r = math.clamp(r, 0, 1)
		fill.Size = UDim2.new(r, 0, 1, 0)
		knob.Position = UDim2.new(r, -8, 0.5, -8)
		l.Text = name .. " [" .. tostring(val) .. "]"
		cur = val
		if callback then callback(val) end
	end}
end

-- =========== GOOD MODE ===========
local function enableGoodMode()
	if goodModeActive then return end
	goodModeActive = true
	local char = player.Character
	if char and char:FindFirstChild("Humanoid") then
		char.Humanoid.BreakJointsOnDeath = false
		goodModeConnection = RunService.Stepped:Connect(function()
			local c = player.Character
			if c and c:FindFirstChild("Humanoid") then
				c.Humanoid.Health = c.Humanoid.MaxHealth
			end
		end)
	end
	createNotification("🛡️ GOOD MODE ON", 1.5)
end
local function disableGoodMode()
	if not goodModeActive then return end
	goodModeActive = false
	if goodModeConnection then goodModeConnection:Disconnect() end
	local char = player.Character
	if char and char:FindFirstChild("Humanoid") then
		char.Humanoid.BreakJointsOnDeath = true
	end
	createNotification("🛡️ GOOD MODE OFF", 1.5)
end

-- =========== СОХРАНЕНИЯ ===========
local teleportPoints = {}
for i = 1, 6 do
	local d = loadValue("TP_" .. i, nil)
	if d then teleportPoints[i] = {name = d.name or ("home "..i), pos = CFrame.new(unpack(d.pos))} end
end
local function saveTP()
	for i = 1, 6 do
		if teleportPoints[i] then
			local p = teleportPoints[i].pos
			saveValue("TP_" .. i, {name = teleportPoints[i].name, pos = {p.X, p.Y, p.Z, p.X, p.Y, p.Z, p.X, p.Y, p.Z, p.X, p.Y, p.Z}})
		else saveValue("TP_" .. i, nil) end
	end
end

-- =========== GUI ===========
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, settings.windowWidth, 0, settings.windowHeight)
MainFrame.Position = UDim2.new(0.5, -settings.windowWidth/2, 0.5, -settings.windowHeight/2)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 25)
MainFrame.BackgroundTransparency = 0.05
MainFrame.BorderSizePixel = 0
MainFrame.Visible = true
MainFrame.Parent = ScreenGui
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 16)
local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(0, 140, 255)
mainStroke.Thickness = 1.8

-- =========== РЕСАЙЗ ===========
local function createResizeZone(cur, pos, sz)
	local z = Instance.new("Frame")
	z.Size = UDim2.new(0, sz, 0, sz)
	z.Position = pos
	z.BackgroundTransparency = 1
	z.ZIndex = 100
	z.Parent = MainFrame
	local isR = false
	local stPos, stSize, stMouse
	z.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
			isR = true
			stPos = MainFrame.Position
			stSize = MainFrame.Size
			stMouse = i.Position
			z.BackgroundTransparency = 0.5
			z.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
		end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if isR and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement) then
			local d = i.Position - stMouse
			local nw, nh = stSize.X.Offset, stSize.Y.Offset
			if cur == "br" then
				nw = math.clamp(stSize.X.Offset + d.X, MIN_W, MAX_W)
				nh = math.clamp(stSize.Y.Offset + d.Y, MIN_H, MAX_H)
				MainFrame.Size = UDim2.new(0, nw, 0, nh)
			elseif cur == "bl" then
				nw = math.clamp(stSize.X.Offset - d.X, MIN_W, MAX_W)
				nh = math.clamp(stSize.Y.Offset + d.Y, MIN_H, MAX_H)
				local nx = stPos.X.Offset + (stSize.X.Offset - nw)
				MainFrame.Size = UDim2.new(0, nw, 0, nh)
				MainFrame.Position = UDim2.new(stPos.X.Scale, nx, stPos.Y.Scale, stPos.Y.Offset)
			elseif cur == "tr" then
				nw = math.clamp(stSize.X.Offset + d.X, MIN_W, MAX_W)
				nh = math.clamp(stSize.Y.Offset - d.Y, MIN_H, MAX_H)
				local ny = stPos.Y.Offset + (stSize.Y.Offset - nh)
				MainFrame.Size = UDim2.new(0, nw, 0, nh)
				MainFrame.Position = UDim2.new(stPos.X.Scale, stPos.X.Offset, stPos.Y.Scale, ny)
			elseif cur == "tl" then
				nw = math.clamp(stSize.X.Offset - d.X, MIN_W, MAX_W)
				nh = math.clamp(stSize.Y.Offset - d.Y, MIN_H, MAX_H)
				local nx = stPos.X.Offset + (stSize.X.Offset - nw)
				local ny = stPos.Y.Offset + (stSize.Y.Offset - nh)
				MainFrame.Size = UDim2.new(0, nw, 0, nh)
				MainFrame.Position = UDim2.new(stPos.X.Scale, nx, stPos.Y.Scale, ny)
			end
			settings.windowWidth = nw
			settings.windowHeight = nh
		end
	end)
	UserInputService.InputEnded:Connect(function(i)
		if isR and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1) then
			isR = false
			z.BackgroundTransparency = 1
		end
	end)
	local m = Instance.new("Frame")
	m.Size = UDim2.new(0, 8, 0, 8)
	m.Position = UDim2.new(0.5, -4, 0.5, -4)
	m.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
	m.BackgroundTransparency = 0.5
	m.BorderSizePixel = 0
	m.Parent = z
	Instance.new("UICorner").CornerRadius = UDim.new(1, 0)
	return z
end
createResizeZone("br", UDim2.new(1, -12, 1, -12), 20)
createResizeZone("bl", UDim2.new(0, -8, 1, -12), 20)
createResizeZone("tr", UDim2.new(1, -12, 0, -8), 20)
createResizeZone("tl", UDim2.new(0, -8, 0, -8), 20)

-- =========== ЗАГОЛОВОК ===========
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
TitleBar.BorderSizePixel = 0
TitleBar.Active = true
TitleBar.Parent = MainFrame
Instance.new("UICorner").CornerRadius = UDim.new(0, 12)
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
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -70, 0, 5)
MinBtn.Text = "−"
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 22
MinBtn.TextColor3 = Color3.fromRGB(255, 210, 0)
MinBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
MinBtn.BorderSizePixel = 0
MinBtn.Parent = TitleBar
Instance.new("UICorner").CornerRadius = UDim.new(0, 8)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -36, 0, 5)
CloseBtn.Text = "✕"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TitleBar
Instance.new("UICorner").CornerRadius = UDim.new(0, 8)

-- =========== DRAG ===========
local drag = false
local dragStartPos, dragStartGui
TitleBar.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
		drag = true
		dragStartPos = i.Position
		dragStartGui = MainFrame.Position
	end
end)
UserInputService.InputChanged:Connect(function(i)
	if drag and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement) then
		local d = i.Position - dragStartPos
		MainFrame.Position = UDim2.new(dragStartGui.X.Scale, dragStartGui.X.Offset + d.X, dragStartGui.Y.Scale, dragStartGui.Y.Offset + d.Y)
	end
end)
UserInputService.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
end)

-- =========== FLOATING BUTTON ===========
local function createFloatingButton()
	if floatingButton then floatingButton:Destroy() end
	floatingButton = Instance.new("TextButton")
	floatingButton.Size = UDim2.new(0, 45, 0, 45)
	floatingButton.Position = UDim2.new(0, settings.floatingX, 0, settings.floatingY)
	floatingButton.Text = "✨"
	floatingButton.TextScaled = true
	floatingButton.Font = Enum.Font.GothamBold
	floatingButton.TextColor3 = Color3.fromRGB(0, 160, 255)
	floatingButton.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
	floatingButton.BackgroundTransparency = 0.1
	floatingButton.BorderSizePixel = 0
	floatingButton.Parent = ScreenGui
	Instance.new("UICorner").CornerRadius = UDim.new(1, 0)
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(0, 140, 255)
	stroke.Thickness = 2
	stroke.Parent = floatingButton
	local btnDrag = false
	local btnStart, btnPos
	floatingButton.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
			btnDrag = true
			btnStart = i.Position
			btnPos = floatingButton.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if btnDrag and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement) then
			local d = i.Position - btnStart
			local nx = math.clamp(btnPos.X.Offset + d.X, 5, 500)
			local ny = math.clamp(btnPos.Y.Offset + d.Y, 50, 700)
			floatingButton.Position = UDim2.new(0, nx, 0, ny)
			settings.floatingX = nx
			settings.floatingY = ny
		end
	end)
	UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then btnDrag = false end
	end)
	floatingButton.MouseButton1Click:Connect(function()
		if isMinimized then restoreMenu() else minimizeMenu() end
	end)
	if isAdmin then
		local ad = Instance.new("Frame")
		ad.Size = UDim2.new(0, 10, 0, 10)
		ad.Position = UDim2.new(1, -6, 0, -2)
		ad.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
		ad.BorderSizePixel = 0
		ad.Parent = floatingButton
		Instance.new("UICorner").CornerRadius = UDim.new(1, 0)
	end
	return floatingButton
end

-- =========== MINIMIZE / RESTORE ===========
function minimizeMenu()
	if isMinimized then return end
	isMinimized = true
	TweenService:Create(MainFrame, TweenInfo.new(0.3), {BackgroundTransparency = 1, Size = UDim2.new(0, 0, 0, 0)}):Play()
	task.wait(0.3)
	MainFrame.Visible = false
	if floatingButton then
		TweenService:Create(floatingButton, TweenInfo.new(0.2), {Size = UDim2.new(0, 50, 0, 50)}):Play()
		task.wait(0.1)
		TweenService:Create(floatingButton, TweenInfo.new(0.1), {Size = UDim2.new(0, 45, 0, 45)}):Play()
	end
end
function restoreMenu()
	if not isMinimized then return end
	isMinimized = false
	MainFrame.Visible = true
	MainFrame.Size = UDim2.new(0, 0, 0, 0)
	MainFrame.BackgroundTransparency = 1
	TweenService:Create(MainFrame, TweenInfo.new(0.3), {BackgroundTransparency = 0.05, Size = UDim2.new(0, settings.windowWidth, 0, settings.windowHeight)}):Play()
	if floatingButton then
		TweenService:Create(floatingButton, TweenInfo.new(0.2), {Size = UDim2.new(0, 50, 0, 50)}):Play()
		task.wait(0.1)
		TweenService:Create(floatingButton, TweenInfo.new(0.1), {Size = UDim2.new(0, 45, 0, 45)}):Play()
	end
end
MinBtn.MouseButton1Click:Connect(minimizeMenu)
CloseBtn.MouseButton1Click:Connect(function()
	if floatingButton then floatingButton:Destroy() end
	ScreenGui:Destroy()
end)

-- =========== TABS ===========
local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(0, 100, 1, -40)
TabFrame.Position = UDim2.new(0, 0, 0, 40)
TabFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
TabFrame.BorderSizePixel = 0
TabFrame.Parent = MainFrame
local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -100, 1, -40)
ContentContainer.Position = UDim2.new(0, 100, 0, 40)
ContentContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
ContentContainer.BorderSizePixel = 0
ContentContainer.ClipsDescendants = true
ContentContainer.Parent = MainFrame

local tabs = {}
local function addTab(name, textColor, y)
	local btn = Instance.new("TextButton")
	btn.Text = name
	btn.Font = Enum.Font.GothamBold
	btn.TextColor3 = textColor or Color3.fromRGB(150,150,170)
	btn.TextSize = 11
	btn.Size = UDim2.new(1, -10, 0, 35)
	btn.Position = UDim2.new(0, 5, 0, y)
	btn.BackgroundColor3 = Color3.fromRGB(25,25,35)
	btn.BorderSizePixel = 0
	btn.AutoButtonColor = false
	btn.Parent = TabFrame
	Instance.new("UICorner").CornerRadius = UDim.new(0, 8)
	btn.MouseEnter:Connect(function()
		if btn.BackgroundColor3 ~= Color3.fromRGB(35,35,45) then
			TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(30,30,40)}):Play()
		end
	end)
	btn.MouseLeave:Connect(function()
		if btn.BackgroundColor3 ~= Color3.fromRGB(35,35,45) then
			TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(25,25,35)}):Play()
		end
	end)
	return btn
end
local HomeBtn = addTab("🏠 HOME", Color3.fromRGB(0,160,255), 10)
local MoveBtn = addTab("🏃 MOVE", nil, 55)
local CombatBtn = addTab("⚔️ COMBAT", nil, 100)
local ESPBtn = addTab("👁️ ESP", nil, 145)
local VisualBtn = addTab("🎨 VISUAL", nil, 190)
local TrollBtn = addTab("🤡 TROLL", nil, 235)
local TeleportBtn = addTab("🚀 TELEPORT", nil, 280)
local AdminBtn = isAdmin and addTab("👑 ADMIN", Color3.fromRGB(255,80,80), 325) or nil

-- =========== CONTENT CONTAINERS ===========
local HomeContainer = Instance.new("ScrollingFrame")
HomeContainer.Size = UDim2.new(1,0,1,0)
HomeContainer.CanvasSize = UDim2.new(0,0,0,240)
HomeContainer.ScrollBarThickness = 4
HomeContainer.ScrollBarImageColor3 = Color3.fromRGB(0,140,255)
HomeContainer.BackgroundTransparency = 1
HomeContainer.Parent = ContentContainer
local HomeContent = Instance.new("Frame")
HomeContent.Size = UDim2.new(1,0,0,240)
HomeContent.BackgroundTransparency = 1
HomeContent.Parent = HomeContainer

local MoveContainer, MoveContent = nil, nil
local CombatContainer, CombatContent = nil, nil
local ESPContainer, ESPContent = nil, nil
local VisualContainer, VisualContent = nil, nil
local TrollContainer, TrollContent = nil, nil
local TeleportContainer, TeleportContent = nil, nil
local AdminContainer, AdminContent = nil, nil

local function makeContainers()
	MoveContainer = Instance.new("ScrollingFrame")
	MoveContainer.Size = UDim2.new(1,0,1,0)
	MoveContainer.CanvasSize = UDim2.new(0,0,0,370)
	MoveContainer.ScrollBarThickness = 4
	MoveContainer.ScrollBarImageColor3 = Color3.fromRGB(0,140,255)
	MoveContainer.BackgroundTransparency = 1
	MoveContainer.Visible = false
	MoveContainer.Parent = ContentContainer
	MoveContent = Instance.new("Frame")
	MoveContent.Size = UDim2.new(1,0,0,390)
	MoveContent.BackgroundTransparency = 1
	MoveContent.Parent = MoveContainer

	CombatContainer = Instance.new("ScrollingFrame")
	CombatContainer.Size = UDim2.new(1,0,1,0)
	CombatContainer.CanvasSize = UDim2.new(0,0,0,300)
	CombatContainer.ScrollBarThickness = 4
	CombatContainer.ScrollBarImageColor3 = Color3.fromRGB(0,140,255)
	CombatContainer.BackgroundTransparency = 1
	CombatContainer.Visible = false
	CombatContainer.Parent = ContentContainer
	CombatContent = Instance.new("Frame")
	CombatContent.Size = UDim2.new(1,0,0,320)
	CombatContent.BackgroundTransparency = 1
	CombatContent.Parent = CombatContainer

	ESPContainer = Instance.new("ScrollingFrame")
	ESPContainer.Size = UDim2.new(1,0,1,0)
	ESPContainer.CanvasSize = UDim2.new(0,0,0,340)
	ESPContainer.ScrollBarThickness = 4
	ESPContainer.ScrollBarImageColor3 = Color3.fromRGB(0,140,255)
	ESPContainer.BackgroundTransparency = 1
	ESPContainer.Visible = false
	ESPContainer.Parent = ContentContainer
	ESPContent = Instance.new("Frame")
	ESPContent.Size = UDim2.new(1,0,0,360)
	ESPContent.BackgroundTransparency = 1
	ESPContent.Parent = ESPContainer

	VisualContainer = Instance.new("ScrollingFrame")
	VisualContainer.Size = UDim2.new(1,0,1,0)
	VisualContainer.CanvasSize = UDim2.new(0,0,0,280)
	VisualContainer.ScrollBarThickness = 4
	VisualContainer.ScrollBarImageColor3 = Color3.fromRGB(0,140,255)
	VisualContainer.BackgroundTransparency = 1
	VisualContainer.Visible = false
	VisualContainer.Parent = ContentContainer
	VisualContent = Instance.new("Frame")
	VisualContent.Size = UDim2.new(1,0,0,300)
	VisualContent.BackgroundTransparency = 1
	VisualContent.Parent = VisualContainer

	TrollContainer = Instance.new("ScrollingFrame")
	TrollContainer.Size = UDim2.new(1,0,1,0)
	TrollContainer.CanvasSize = UDim2.new(0,0,0,520)
	TrollContainer.ScrollBarThickness = 4
	TrollContainer.ScrollBarImageColor3 = Color3.fromRGB(0,140,255)
	TrollContainer.BackgroundTransparency = 1
	TrollContainer.Visible = false
	TrollContainer.Parent = ContentContainer
	TrollContent = Instance.new("Frame")
	TrollContent.Size = UDim2.new(1,0,0,540)
	TrollContent.BackgroundTransparency = 1
	TrollContent.Parent = TrollContainer

	TeleportContainer = Instance.new("ScrollingFrame")
	TeleportContainer.Size = UDim2.new(1,0,1,0)
	TeleportContainer.CanvasSize = UDim2.new(0,0,0,480)
	TeleportContainer.ScrollBarThickness = 4
	TeleportContainer.ScrollBarImageColor3 = Color3.fromRGB(0,140,255)
	TeleportContainer.BackgroundTransparency = 1
	TeleportContainer.Visible = false
	TeleportContainer.Parent = ContentContainer
	TeleportContent = Instance.new("Frame")
	TeleportContent.Size = UDim2.new(1,0,0,500)
	TeleportContent.BackgroundTransparency = 1
	TeleportContent.Parent = TeleportContainer

	if isAdmin then
		AdminContainer = Instance.new("ScrollingFrame")
		AdminContainer.Size = UDim2.new(1,0,1,0)
		AdminContainer.CanvasSize = UDim2.new(0,0,0,600)
		AdminContainer.ScrollBarThickness = 4
		AdminContainer.ScrollBarImageColor3 = Color3.fromRGB(0,140,255)
		AdminContainer.BackgroundTransparency = 1
		AdminContainer.Visible = false
		AdminContainer.Parent = ContentContainer
		AdminContent = Instance.new("Frame")
		AdminContent.Size = UDim2.new(1,0,0,620)
		AdminContent.BackgroundTransparency = 1
		AdminContent.Parent = AdminContainer
	end
end
makeContainers()

-- =========== UI ELEMENTS ===========
local homeY = 10
createSection(HomeContent, "📌 INFO", homeY); homeY = homeY + 36
local info = Instance.new("TextLabel")
info.Text = "SYNAPSE HUB v28\nby Vanezy Scripts"
info.Font = Enum.Font.GothamBold
info.TextSize = 14
info.TextColor3 = Color3.fromRGB(0,160,255)
info.BackgroundTransparency = 1
info.Size = UDim2.new(1, -30, 0, 50)
info.Position = UDim2.new(0, 15, 0, homeY)
info.TextXAlignment = Enum.TextXAlignment.Center
info.Parent = HomeContent
homeY = homeY + 60
createSection(HomeContent, "💾 SETTINGS", homeY); homeY = homeY + 36
local SaveBtn = Instance.new("TextButton")
SaveBtn.Size = UDim2.new(0.45, -15, 0, 42)
SaveBtn.Position = UDim2.new(0.03, 0, 0, homeY)
SaveBtn.Text = "💾 SAVE ALL"
SaveBtn.Font = Enum.Font.GothamBold
SaveBtn.TextSize = 12
SaveBtn.TextColor3 = Color3.fromRGB(255,255,255)
SaveBtn.BackgroundColor3 = Color3.fromRGB(0,100,80)
SaveBtn.BorderSizePixel = 0
SaveBtn.Parent = HomeContent
Instance.new("UICorner").CornerRadius = UDim.new(0, 8)
local ResetBtn = Instance.new("TextButton")
ResetBtn.Size = UDim2.new(0.45, -15, 0, 42)
ResetBtn.Position = UDim2.new(0.52, 0, 0, homeY)
ResetBtn.Text = "🗑️ RESET"
ResetBtn.Font = Enum.Font.GothamBold
ResetBtn.TextSize = 12
ResetBtn.TextColor3 = Color3.fromRGB(255,200,200)
ResetBtn.BackgroundColor3 = Color3.fromRGB(100,40,40)
ResetBtn.BorderSizePixel = 0
ResetBtn.Parent = HomeContent
Instance.new("UICorner").CornerRadius = UDim.new(0, 8)

SaveBtn.MouseButton1Click:Connect(function()
	for k,v in pairs(settings) do saveValue(k,v) end
	saveValue("windowWidth", settings.windowWidth)
	saveValue("windowHeight", settings.windowHeight)
	saveTP()
	createNotification("💾 Saved!", 1.5)
end)
ResetBtn.MouseButton1Click:Connect(function()
	for k,d in pairs(DEFAULT_SETTINGS) do settings[k] = d; saveValue(k,d) end
	if walkSlider then walkSlider.setValue(16) end
	if jumpSlider then jumpSlider.setValue(50) end
	if fovSlider then fovSlider.setValue(70) end
	if flySpeedSlider then flySpeedSlider.setValue(50) end
	if speedHackSlider then speedHackSlider.setValue(50) end
	if espSizeSlider then espSizeSlider.setValue(1.5) end
	settings.windowWidth = 450
	settings.windowHeight = 420
	MainFrame.Size = UDim2.new(0,450,0,420)
	MainFrame.Position = UDim2.new(0.5,-225,0.5,-210)
	if flyConnection then flyConnection:Disconnect() end
	if bodyVelocity then bodyVelocity:Destroy() end
	if noClipConnection then noClipConnection:Disconnect() end
	if rainbowConnection then rainbowConnection:Disconnect() end
	disableGoodMode()
	local c = player.Character
	if c and c:FindFirstChild("Humanoid") then
		c.Humanoid.WalkSpeed = 16
		c.Humanoid.JumpPower = 50
		c.Humanoid.PlatformStand = false
	end
	updateESP()
	createNotification("🗑️ Reset to defaults", 1.5)
end)
homeY = homeY + 60
HomeContent.Size = UDim2.new(1,0,0,homeY+10)
HomeContainer.CanvasSize = UDim2.new(0,0,0,homeY+20)

-- MOVE TAB
local moveY = 10
createSection(MoveContent, "🏃 WALK", moveY); moveY = moveY + 36
walkSlider = createSlider(MoveContent, "Walk Speed", moveY, 8, 120, settings.walkSpeed, function(v)
	settings.walkSpeed = v
	saveValue("walkSpeed", v)
	local c = player.Character
	if c and c:FindFirstChild("Humanoid") then c.Humanoid.WalkSpeed = v end
end)
moveY = moveY + 68
jumpSlider = createSlider(MoveContent, "Jump Power", moveY, 30, 250, settings.jumpPower, function(v)
	settings.jumpPower = v
	saveValue("jumpPower", v)
	local c = player.Character
	if c and c:FindFirstChild("Humanoid") then c.Humanoid.JumpPower = v end
end)
moveY = moveY + 68
createSection(MoveContent, "🕊️ FLY", moveY); moveY = moveY + 36
createToggle(MoveContent, "Fly Mode", moveY, settings.flyEnabled, function(v)
	settings.flyEnabled = v
	saveValue("flyEnabled", v)
	if flyConnection then flyConnection:Disconnect() end
	if bodyVelocity then bodyVelocity:Destroy() end
	local c = player.Character
	if v and c then
		local hrp = c:FindFirstChild("HumanoidRootPart")
		local hum = c:FindFirstChild("Humanoid")
		if hrp and hum then
			hum.PlatformStand = true
			bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.MaxForce = Vector3.new(1e6,1e6,1e6)
			bodyVelocity.Parent = hrp
			flyConnection = RunService.Heartbeat:Connect(function()
				if not settings.flyEnabled then return end
				local cc = player.Character
				if not cc then return end
				local hh = cc:FindFirstChild("HumanoidRootPart")
				if not hh then return end
				if bodyVelocity and bodyVelocity.Parent ~= hh then bodyVelocity.Parent = hh end
				local move = Vector3.new()
				local cam = workspace.CurrentCamera
				if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
				if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0,1,0) end
				bodyVelocity.Velocity = move.Magnitude > 0 and move.Unit * settings.flySpeed or Vector3.zero
			end)
		end
	end
	if not v and c and c:FindFirstChild("Humanoid") then c.Humanoid.PlatformStand = false end
end)
moveY = moveY + 46
flySpeedSlider = createSlider(MoveContent, "Fly Speed", moveY, 30, 200, settings.flySpeed, function(v)
	settings.flySpeed = v
	saveValue("flySpeed", v)
end)
moveY = moveY + 68
MoveContent.Size = UDim2.new(1,0,0,moveY+20)
MoveContainer.CanvasSize = UDim2.new(0,0,0,moveY+30)

-- COMBAT TAB
local combatY = 10
createSection(CombatContent, "🛡️ DEFENSE", combatY); combatY = combatY + 36
createToggle(CombatContent, "GOOD MODE (Immortal)", combatY, settings.goodMode, function(v)
	settings.goodMode = v
	saveValue("goodMode", v)
	if v then enableGoodMode() else disableGoodMode() end
end)
combatY = combatY + 46
createToggle(CombatContent, "Noclip", combatY, settings.noclip, function(v)
	settings.noclip = v
	saveValue("noclip", v)
	if noClipConnection then noClipConnection:Disconnect() end
	if v then
		noClipConnection = RunService.Stepped:Connect(function()
			if not settings.noclip then return end
			local c = player.Character
			if not c then return end
			for _,p in pairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
		end)
	else
		local c = player.Character
		if c then for _,p in pairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true end end end
	end
end)
combatY = combatY + 46
createToggle(CombatContent, "Speed Hack", combatY, settings.speedHack, function(v)
	settings.speedHack = v
	saveValue("speedHack", v)
end)
combatY = combatY + 46
speedHackSlider = createSlider(CombatContent, "Speed Hack Value", combatY, 20, 200, settings.speedHackValue, function(v)
	settings.speedHackValue = v
	saveValue("speedHackValue", v)
end)
combatY = combatY + 68
createToggle(CombatContent, "Infinite Jump", combatY, settings.infiniteJump, function(v)
	settings.infiniteJump = v
	saveValue("infiniteJump", v)
end)
combatY = combatY + 56
CombatContent.Size = UDim2.new(1,0,0,combatY+20)
CombatContainer.CanvasSize = UDim2.new(0,0,0,combatY+30)

-- ESP TAB
local espY = 10
createSection(ESPContent, "👁️ ESP", espY); espY = espY + 36
createToggle(ESPContent, "ESP Players", espY, settings.espPlayers, function(v)
	settings.espPlayers = v
	saveValue("espPlayers", v)
	updateESP()
end)
espY = espY + 46
createToggle(ESPContent, "ESP Chests", espY, settings.espChests, function(v)
	settings.espChests = v
	saveValue("espChests", v)
	updateESP()
end)
espY = espY + 46
createToggle(ESPContent, "ESP Mobs", espY, settings.espMobs, function(v)
	settings.espMobs = v
	saveValue("espMobs", v)
	updateESP()
end)
espY = espY + 46
espSizeSlider = createSlider(ESPContent, "ESP Size", espY, 0.5, 3, settings.espSize, function(v)
	settings.espSize = v
	saveValue("espSize", v)
end)
espY = espY + 68
createToggle(ESPContent, "ESP Health", espY, settings.espHealth, function(v)
	settings.espHealth = v
	saveValue("espHealth", v)
end)
espY = espY + 46
createToggle(ESPContent, "ESP Distance", espY, settings.espDistance, function(v)
	settings.espDistance = v
	saveValue("espDistance", v)
end)
espY = espY + 56
ESPContent.Size = UDim2.new(1,0,0,espY+20)
ESPContainer.CanvasSize = UDim2.new(0,0,0,espY+30)

-- VISUAL TAB
local visualY = 10
createSection(VisualContent, "🎨 VISUAL", visualY); visualY = visualY + 36
fovSlider = createSlider(VisualContent, "Field of View", visualY, 50, 120, settings.fov, function(v)
	settings.fov = v
	saveValue("fov", v)
	if camera then camera.FieldOfView = v end
end)
visualY = visualY + 68
createToggle(VisualContent, "Rainbow Mode", visualY, settings.rainbow, function(v)
	settings.rainbow = v
	saveValue("rainbow", v)
	if rainbowConnection then rainbowConnection:Disconnect() end
	if v then
		rainbowConnection = RunService.RenderStepped:Connect(function()
			rainbowHue = (rainbowHue + 0.003) % 1
			local col = Color3.fromHSV(rainbowHue,1,1)
			mainStroke.Color = col
			TitleText.TextColor3 = col
			if floatingButton then
				local s = floatingButton:FindFirstChild("UIStroke")
				if s then s.Color = col end
			end
		end)
	end
end)
visualY = visualY + 56
VisualContent.Size = UDim2.new(1,0,0,visualY+20)
VisualContainer.CanvasSize = UDim2.new(0,0,0,visualY+30)

-- TROLL TAB
local trollY = 10
createSection(TrollContent, "🤡 SELECT TARGET", trollY); trollY = trollY + 36
local targetName = Instance.new("TextBox")
targetName.Size = UDim2.new(1, -20, 0, 36)
targetName.Position = UDim2.new(0, 10, 0, trollY)
targetName.PlaceholderText = "👤 Player name"
targetName.Text = ""
targetName.TextColor3 = Color3.fromRGB(255,255,255)
targetName.BackgroundColor3 = Color3.fromRGB(35,35,45)
targetName.BorderSizePixel = 0
targetName.Font = Enum.Font.Gotham
targetName.TextSize = 12
targetName.Parent = TrollContent
Instance.new("UICorner").CornerRadius = UDim.new(0, 8)
trollY = trollY + 46
local function getTarget()
	local n = targetName.Text
	for _,p in pairs(Players:GetPlayers()) do
		if p.Name:lower() == n:lower() or (p.DisplayName and p.DisplayName:lower() == n:lower()) then return p end
	end
	return nil
end
local function trollBtn(name, color, cb)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, -20, 0, 38)
	b.Position = UDim2.new(0, 10, 0, trollY)
	b.Text = name
	b.Font = Enum.Font.GothamBold
	b.TextSize = 13
	b.TextColor3 = Color3.fromRGB(255,255,255)
	b.BackgroundColor3 = color
	b.BorderSizePixel = 0
	b.Parent = TrollContent
	Instance.new("UICorner").CornerRadius = UDim.new(0, 8)
	b.MouseButton1Click:Connect(function() local t = getTarget(); if t then cb(t) else createNotification("❌ Player not found", 1) end end)
	return b
end
trollY = trollY + 48
trollBtn("🔒 JAIL (10 sec)", Color3.fromRGB(200,100,0), function(t) local c = t.Character; local h = c and c:FindFirstChild("HumanoidRootPart"); if h then local j=Instance.new("Part"); j.Size=Vector3.new(5,5,5); j.Position=h.Position; j.Anchored=true; j.CanCollide=true; j.Transparency=0.5; j.Color=Color3.fromRGB(255,0,0); j.Material=Enum.Material.Neon; j.Parent=Workspace; Instance.new("SelectionBox").Adornee=j; t.Character.HumanoidRootPart.CFrame=j.CFrame; task.delay(10,function() j:Destroy() end) createNotification("🔒 Jailed "..t.Name,1.5) end end)
trollY = trollY + 48
trollBtn("💥 EXPLODE", Color3.fromRGB(200,80,0), function(t) local c=t.Character; local h=c and c:FindFirstChild("HumanoidRootPart"); if h then local e=Instance.new("Explosion"); e.Position=h.Position; e.BlastRadius=5; e.Parent=Workspace; createNotification("💥 Boomed "..t.Name,1.5) end end)
trollY = trollY + 48
trollBtn("💨 SLAP", Color3.fromRGB(180,120,0), function(t) local c=t.Character; local h=c and c:FindFirstChild("HumanoidRootPart"); if h then h.Velocity=Vector3.new(0,50,0); createNotification("💨 Slapped "..t.Name,1.5) end end)
trollY = trollY + 48
trollBtn("🔄 LOOP KICK", Color3.fromRGB(200,60,60), function(t) for i=1,5 do task.wait(0.2) pcall(function() t:Kick("🔁 Loop kicked") end) end createNotification("🔄 Loop kicking "..t.Name,1.5) end)
trollY = trollY + 48
trollBtn("👁️ BLIND", Color3.fromRGB(100,100,200), function(t) local head=t.Character and t.Character:FindFirstChild("Head"); if head then local b=Instance.new("Part"); b.Size=Vector3.new(10,10,10); b.Position=head.Position+Vector3.new(0,0,5); b.Anchored=true; b.CanCollide=false; b.Transparency=0.3; b.Color=Color3.fromRGB(0,0,0); b.Parent=head; task.delay(5,function() b:Destroy() end) createNotification("👁️ Blinded "..t.Name,1.5) end end)
trollY = trollY + 48
trollBtn("🔨 FAKE BAN", Color3.fromRGB(200,50,50), function(t) pcall(function() t:Kick("🔨 You have been banned (jk)") end) createNotification("🔨 Fake banned "..t.Name,1.5) end)
trollY = trollY + 56
createSection(TrollContent, "——— ALL ———", trollY); trollY = trollY + 36
trollBtn("💀 KILL ALL (DANGER)", Color3.fromRGB(180,0,0), function() for _,p in pairs(Players:GetPlayers()) do if p~=player then local c=p.Character; if c and c:FindFirstChild("Humanoid") then c.Humanoid.Health=0 end end end createNotification("💀 Killed all",1.5) end)
trollY = trollY + 48
local loopKillAllBtn = trollBtn("🔄 KILL LOOP (DANGER)", Color3.fromRGB(150,0,0), function() killLoopActive = not killLoopActive; if killLoopActive then if killLoopConnection then killLoopConnection:Disconnect() end; killLoopConnection = RunService.Heartbeat:Connect(function() if killLoopActive then for _,p in pairs(Players:GetPlayers()) do if p~=player then local c=p.Character; if c and c:FindFirstChild("Humanoid") then c.Humanoid.Health=0 end end end end end); createNotification("🔄 Kill loop ON",1.5) else if killLoopConnection then killLoopConnection:Disconnect() end; createNotification("🔄 Kill loop OFF",1.5) end; loopKillAllBtn.Text = killLoopActive and "🔄 KILL LOOP: ON" or "🔄 KILL LOOP: OFF" end)
loopKillAllBtn.Text = "🔄 KILL LOOP: OFF"
trollY = trollY + 48
trollBtn("🔒 SERVER LOCK", Color3.fromRGB(0,100,150), function() game.Players.PlayerAdded:Connect(function(plr) pcall(function() plr:Kick("🔒 Server locked by admin") end) end); createNotification("🔒 Server locked",1.5) end)
trollY = trollY + 48
trollBtn("💬 CHAT SPAM (10x)", Color3.fromRGB(150,100,50), function() for i=1,10 do pcall(function() ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Vanezy Scripts is here! https://t.me/VanezyScripts","All") end); task.wait(0.1) end; createNotification("💬 Spam sent",1.5) end)
trollY = trollY + 60
TrollContent.Size = UDim2.new(1,0,0,trollY+20)
TrollContainer.CanvasSize = UDim2.new(0,0,0,trollY+30)

-- TELEPORT TAB
local tpY = 10
createSection(TeleportContent, "🏠 TELEPORT POINTS", tpY); tpY = tpY + 36
local function updateTPUI()
	for _,c in pairs(TeleportContent:GetChildren()) do if c:IsA("Frame") and c.Name:find("TP_") then c:Destroy() end end
	local y = tpY
	for i=1,6 do
		local data = teleportPoints[i]
		local exists = data ~= nil
		local fr = Instance.new("Frame")
		fr.Name = "TP_"..i
		fr.Size = UDim2.new(1, -20, 0, 55)
		fr.Position = UDim2.new(0, 10, 0, y)
		fr.BackgroundColor3 = Color3.fromRGB(28,28,38)
		fr.BackgroundTransparency = exists and 0 or 0.5
		fr.BorderSizePixel = 0
		fr.Parent = TeleportContent
		Instance.new("UICorner").CornerRadius = UDim.new(0, 12)
		local num = Instance.new("TextLabel")
		num.Text = tostring(i)
		num.Font = Enum.Font.GothamBold
		num.TextSize = 16
		num.TextColor3 = Color3.fromRGB(0,160,255)
		num.BackgroundTransparency = 1
		num.Size = UDim2.new(0, 35, 1, 0)
		num.Position = UDim2.new(0, 5, 0, 0)
		num.TextXAlignment = Enum.TextXAlignment.Center
		num.Parent = fr
		local sep = Instance.new("Frame")
		sep.Size = UDim2.new(0, 2, 0, 35)
		sep.Position = UDim2.new(0, 45, 0.5, -17.5)
		sep.BackgroundColor3 = Color3.fromRGB(60,60,80)
		sep.BorderSizePixel = 0
		sep.Parent = fr
		local nameBox = Instance.new("TextBox")
		nameBox.Size = UDim2.new(0, 200, 0, 35)
		nameBox.Position = UDim2.new(0, 55, 0.5, -17.5)
		nameBox.BackgroundColor3 = Color3.fromRGB(35,35,45)
		nameBox.BorderSizePixel = 0
		nameBox.Font = Enum.Font.Gotham
		nameBox.TextSize = 12
		nameBox.TextColor3 = Color3.fromRGB(255,255,255)
		nameBox.Text = exists and data.name or ("home "..i)
		nameBox.PlaceholderText = "home "..i
		nameBox.Parent = fr
		Instance.new("UICorner").CornerRadius = UDim.new(0, 8)
		nameBox.FocusLost:Connect(function(ep)
			if ep and exists then data.name = nameBox.Text; saveTP(); createNotification("📝 Renamed",1) end
		end)
		if exists then
			local tel = Instance.new("TextButton")
			tel.Size = UDim2.new(0, 40, 0, 35)
			tel.Position = UDim2.new(1, -100, 0.5, -17.5)
			tel.Text = "🚀"
			tel.Font = Enum.Font.GothamBold
			tel.TextSize = 18
			tel.TextColor3 = Color3.fromRGB(0,200,255)
			tel.BackgroundColor3 = Color3.fromRGB(0,80,100)
			tel.BorderSizePixel = 0
			tel.Parent = fr
			Instance.new("UICorner").CornerRadius = UDim.new(0, 8)
			tel.MouseButton1Click:Connect(function()
				local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
				if hrp then hrp.CFrame = data.pos; createNotification("🚀 Teleported to "..data.name,1.5) end
			end)
			local rem = Instance.new("TextButton")
			rem.Size = UDim2.new(0, 40, 0, 35)
			rem.Position = UDim2.new(1, -55, 0.5, -17.5)
			rem.Text = "−"
			rem.Font = Enum.Font.GothamBold
			rem.TextSize = 18
			rem.TextColor3 = Color3.fromRGB(255,100,100)
			rem.BackgroundColor3 = Color3.fromRGB(100,40,40)
			rem.BorderSizePixel = 0
			rem.Parent = fr
			Instance.new("UICorner").CornerRadius = UDim.new(0, 8)
			rem.MouseButton1Click:Connect(function()
				teleportPoints[i] = nil
				saveTP()
				updateTPUI()
				createNotification("🗑️ Point "..i.." removed",1.5)
			end)
		else
			local add = Instance.new("TextButton")
			add.Size = UDim2.new(0, 80, 0, 35)
			add.Position = UDim2.new(1, -90, 0.5, -17.5)
			add.Text = "+ ADD"
			add.Font = Enum.Font.GothamBold
			add.TextSize = 14
			add.TextColor3 = Color3.fromRGB(255,255,255)
			add.BackgroundColor3 = Color3.fromRGB(0,100,80)
			add.BorderSizePixel = 0
			add.Parent = fr
			Instance.new("UICorner").CornerRadius = UDim.new(0, 8)
			add.MouseButton1Click:Connect(function()
				local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
				if hrp then
					teleportPoints[i] = {name = nameBox.Text or ("home "..i), pos = hrp.CFrame}
					saveTP()
					updateTPUI()
					createNotification("📍 Point "..i.." saved",1.5)
				end
			end)
		end
		y = y + 65
	end
	TeleportContent.Size = UDim2.new(1,0,0,y+10)
	TeleportContainer.CanvasSize = UDim2.new(0,0,0,y+20)
end
updateTPUI()

-- ADMIN TAB
if isAdmin then
	local admY = 10
	createSection(AdminContent, "📊 STATS", admY); admY = admY + 36
	local statF = Instance.new("Frame")
	statF.Size = UDim2.new(1, -20, 0, 90)
	statF.Position = UDim2.new(0, 10, 0, admY)
	statF.BackgroundColor3 = Color3.fromRGB(28,28,38)
	statF.BorderSizePixel = 0
	statF.Parent = AdminContent
	Instance.new("UICorner").CornerRadius = UDim.new(0, 8)
	local launchL = Instance.new("TextLabel")
	launchL.Text = "🏆 Total Launches: "..totalLaunches
	launchL.Font = Enum.Font.GothamBold
	launchL.TextSize = 13
	launchL.TextColor3 = Color3.fromRGB(0,200,255)
	launchL.BackgroundTransparency = 1
	launchL.Size = UDim2.new(1,-20,0,25)
	launchL.Position = UDim2.new(0,10,0,5)
	launchL.TextXAlignment = Enum.TextXAlignment.Left
	launchL.Parent = statF
	local serverL = Instance.new("TextLabel")
	serverL.Text = "👥 Server Players: "..#Players:GetPlayers()
	serverL.Font = Enum.Font.GothamBold
	serverL.TextSize = 13
	serverL.TextColor3 = Color3.fromRGB(255,200,100)
	serverL.BackgroundTransparency = 1
	serverL.Size = UDim2.new(1,-20,0,25)
	serverL.Position = UDim2.new(0,10,0,35)
	serverL.TextXAlignment = Enum.TextXAlignment.Left
	serverL.Parent = statF
	task.spawn(function() while true do task.wait(1) serverL.Text = "👥 Server Players: "..#Players:GetPlayers() end end)
	admY = admY + 100
	createSection(AdminContent, "🎮 CONTROL", admY); admY = admY + 36
	local admBtn = function(name,color,cb)
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(1, -20, 0, 40)
		b.Position = UDim2.new(0, 10, 0, admY)
		b.Text = name
		b.Font = Enum.Font.GothamBold
		b.TextSize = 13
		b.TextColor3 = Color3.fromRGB(255,255,255)
		b.BackgroundColor3 = color
		b.BorderSizePixel = 0
		b.Parent = AdminContent
		Instance.new("UICorner").CornerRadius = UDim.new(0, 8)
		b.MouseButton1Click:Connect(cb)
		admY = admY + 50
		return b
	end
	local bcIn = Instance.new("TextBox")
	bcIn.Size = UDim2.new(1, -20, 0, 36)
	bcIn.Position = UDim2.new(0, 10, 0, admY)
	bcIn.PlaceholderText = "📢 Broadcast message"
	bcIn.Text = ""
	bcIn.TextColor3 = Color3.fromRGB(255,255,255)
	bcIn.BackgroundColor3 = Color3.fromRGB(35,35,45)
	bcIn.BorderSizePixel = 0
	bcIn.Font = Enum.Font.Gotham
	bcIn.TextSize = 12
	bcIn.Parent = AdminContent
	Instance.new("UICorner").CornerRadius = UDim.new(0, 8)
	admY = admY + 46
	admBtn("📢 SEND BROADCAST", Color3.fromRGB(0,100,150), function()
		if bcIn.Text ~= "" then
			for _,p in pairs(Players:GetPlayers()) do
				pcall(function()
					local n = Instance.new("BillboardGui")
					n.Size = UDim2.new(0,400,0,100)
					n.StudsOffset = Vector3.new(0,3,0)
					n.AlwaysOnTop = true
					local fr = Instance.new("Frame")
					fr.Size = UDim2.new(1,0,1,0)
					fr.BackgroundColor3 = Color3.fromRGB(0,0,0)
					fr.BackgroundTransparency = 0.3
					Instance.new("UICorner").CornerRadius = UDim.new(0,12)
					local txt = Instance.new("TextLabel")
					txt.Text = bcIn.Text
					txt.Font = Enum.Font.GothamBold
					txt.TextSize = 14
					txt.TextColor3 = Color3.fromRGB(255,255,255)
					txt.BackgroundTransparency = 1
					txt.Size = UDim2.new(1,-20,1,0)
					txt.Position = UDim2.new(0,10,0,0)
					txt.TextWrapped = true
					txt.Parent = fr
					fr.Parent = n
					if p.Character and p.Character:FindFirstChild("Head") then n.Parent = p.Character.Head else n.Parent = p.CharacterAdded:Wait():WaitForChild("Head") end
					task.delay(5,function() n:Destroy() end)
				end)
			end
			createNotification("📢 Broadcast sent",1.5)
			bcIn.Text = ""
		end
	end)
	local plrBox = Instance.new("TextBox")
	plrBox.Size = UDim2.new(1, -20, 0, 36)
	plrBox.Position = UDim2.new(0, 10, 0, admY)
	plrBox.PlaceholderText = "👤 Player name"
	plrBox.Text = ""
	plrBox.TextColor3 = Color3.fromRGB(255,255,255)
	plrBox.BackgroundColor3 = Color3.fromRGB(35,35,45)
	plrBox.BorderSizePixel = 0
	plrBox.Font = Enum.Font.Gotham
	plrBox.TextSize = 12
	plrBox.Parent = AdminContent
	Instance.new("UICorner").CornerRadius = UDim.new(0, 8)
	admY = admY + 46
	local function getAdmTarget()
		local n = plrBox.Text
		for _,p in pairs(Players:GetPlayers()) do if p.Name:lower() == n:lower() or (p.DisplayName and p.DisplayName:lower() == n:lower()) then return p end end
		return nil
	end
	admBtn("❌ DISABLE SCRIPT (KICK ALL)", Color3.fromRGB(150,40,40), function() ScreenGui:Destroy() end)
	admBtn("🔨 KICK PLAYER", Color3.fromRGB(200,60,60), function() local t = getAdmTarget(); if t then pcall(function() t:Kick("Kicked by Admin") end); createNotification("🔨 Kicked",1.5) else createNotification("❌ Not found",1) end end)
	admBtn("🧊 FREEZE/UNFREEZE", Color3.fromRGB(100,100,200), function()
		local t = getAdmTarget()
		if t then
			if frozenPlayers[t.UserId] then
				local c = t.Character; if c and c:FindFirstChild("Humanoid") then c.Humanoid.PlatformStand = false end
				frozenPlayers[t.UserId] = nil
				createNotification("❄️ Unfrozen",1.5)
			else
				local c = t.Character; if c and c:FindFirstChild("Humanoid") then c.Humanoid.PlatformStand = true end
				frozenPlayers[t.UserId] = true
				createNotification("❄️ Frozen",1.5)
			end
		else createNotification("❌ Not found",1) end
	end)
	admBtn("✨ TELEPORT TO PLAYER", Color3.fromRGB(0,150,150), function()
		local t = getAdmTarget()
		if t and player.Character and t.Character then
			local hrp = player.Character:FindFirstChild("HumanoidRootPart")
			local thrp = t.Character:FindFirstChild("HumanoidRootPart")
			if hrp and thrp then hrp.CFrame = thrp.CFrame + Vector3.new(0,3,0); createNotification("✨ Teleported",1.5) end
		else createNotification("❌ Not found",1) end
	end)
	admBtn("🔄 BRING PLAYER", Color3.fromRGB(150,0,150), function()
		local t = getAdmTarget()
		if t and player.Character and t.Character then
			local hrp = player.Character:FindFirstChild("HumanoidRootPart")
			local thrp = t.Character:FindFirstChild("HumanoidRootPart")
			if hrp and thrp then thrp.CFrame = hrp.CFrame + Vector3.new(0,3,0); createNotification("🔄 Brought",1.5) end
		else createNotification("❌ Not found",1) end
	end)
	AdminContent.Size = UDim2.new(1,0,0,admY+20)
	AdminContainer.CanvasSize = UDim2.new(0,0,0,admY+30)
end

-- =========== SWITCH TAB ===========
local function switch(tab)
	currentTab = tab
	HomeContainer.Visible = (tab == "HOME")
	MoveContainer.Visible = (tab == "MOVE")
	CombatContainer.Visible = (tab == "COMBAT")
	ESPContainer.Visible = (tab == "ESP")
	VisualContainer.Visible = (tab == "VISUAL")
	TrollContainer.Visible = (tab == "TROLL")
	TeleportContainer.Visible = (tab == "TELEPORT")
	if isAdmin and AdminContainer then AdminContainer.Visible = (tab == "ADMIN") end
	local colors = {
		HOME = {Color3.fromRGB(35,35,45), Color3.fromRGB(0,160,255)},
		MOVE = {Color3.fromRGB(25,25,35), Color3.fromRGB(150,150,170)},
		COMBAT = {Color3.fromRGB(25,25,35), Color3.fromRGB(150,150,170)},
		ESP = {Color3.fromRGB(25,25,35), Color3.fromRGB(150,150,170)},
		VISUAL = {Color3.fromRGB(25,25,35), Color3.fromRGB(150,150,170)},
		TROLL = {Color3.fromRGB(25,25,35), Color3.fromRGB(150,150,170)},
		TELEPORT = {Color3.fromRGB(25,25,35), Color3.fromRGB(150,150,170)},
		ADMIN = {Color3.fromRGB(25,25,35), Color3.fromRGB(150,150,170)}
	}
	colors[tab] = {Color3.fromRGB(35,35,45), tab == "HOME" and Color3.fromRGB(0,160,255) or tab == "TROLL" and Color3.fromRGB(0,200,100) or tab == "TELEPORT" and Color3.fromRGB(0,200,200) or tab == "ADMIN" and Color3.fromRGB(255,80,80) or Color3.fromRGB(0,160,255)}
	TweenService:Create(HomeBtn, TweenInfo.new(0.15), {BackgroundColor3 = colors.HOME[1], TextColor3 = colors.HOME[2]}):Play()
	TweenService:Create(MoveBtn, TweenInfo.new(0.15), {BackgroundColor3 = colors.MOVE[1], TextColor3 = colors.MOVE[2]}):Play()
	TweenService:Create(CombatBtn, TweenInfo.new(0.15), {BackgroundColor3 = colors.COMBAT[1], TextColor3 = colors.COMBAT[2]}):Play()
	TweenService:Create(ESPBtn, TweenInfo.new(0.15), {BackgroundColor3 = colors.ESP[1], TextColor3 = colors.ESP[2]}):Play()
	TweenService:Create(VisualBtn, TweenInfo.new(0.15), {BackgroundColor3 = colors.VISUAL[1], TextColor3 = colors.VISUAL[2]}):Play()
	TweenService:Create(TrollBtn, TweenInfo.new(0.15), {BackgroundColor3 = colors.TROLL[1], TextColor3 = colors.TROLL[2]}):Play()
	TweenService:Create(TeleportBtn, TweenInfo.new(0.15), {BackgroundColor3 = colors.TELEPORT[1], TextColor3 = colors.TELEPORT[2]}):Play()
	if isAdmin and AdminBtn then TweenService:Create(AdminBtn, TweenInfo.new(0.15), {BackgroundColor3 = colors.ADMIN[1], TextColor3 = colors.ADMIN[2]}):Play() end
end
HomeBtn.MouseButton1Click:Connect(function() switch("HOME") end)
MoveBtn.MouseButton1Click:Connect(function() switch("MOVE") end)
CombatBtn.MouseButton1Click:Connect(function() switch("COMBAT") end)
ESPBtn.MouseButton1Click:Connect(function() switch("ESP") end)
VisualBtn.MouseButton1Click:Connect(function() switch("VISUAL") end)
TrollBtn.MouseButton1Click:Connect(function() switch("TROLL") end)
TeleportBtn.MouseButton1Click:Connect(function() switch("TELEPORT") end)
if isAdmin and AdminBtn then AdminBtn.MouseButton1Click:Connect(function() switch("ADMIN") end) end
switch("HOME")

-- =========== ESP ===========
local espPlayers, espChests, espMobs = {},{},{}
function updateESP()
	if espConnection then espConnection:Disconnect() end
	for _,d in pairs(espPlayers) do pcall(function() d.hl:Destroy(); d.bb:Destroy() end) end
	for _,h in pairs(espChests) do pcall(function() h:Destroy() end) end
	for _,h in pairs(espMobs) do pcall(function() h:Destroy() end) end
	espPlayers, espChests, espMobs = {},{},{}
	if not settings.espPlayers then return end
	espConnection = RunService.Heartbeat:Connect(function()
		if not settings.espPlayers then return end
		for _,p in pairs(Players:GetPlayers()) do if p~=player then
			local c = p.Character
			if c and c:FindFirstChild("HumanoidRootPart") then
				local h = c:FindFirstChild("Humanoid")
				if not espPlayers[p.UserId] then
					local hl = Instance.new("Highlight")
					hl.FillColor = Color3.fromRGB(255,60,60)
					hl.FillTransparency = 0.5
					hl.OutlineColor = Color3.fromRGB(255,255,255)
					hl.OutlineTransparency = 0.2
					hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
					hl.Adornee = c
					hl.Parent = c
					local head = c:FindFirstChild("Head") or c.HumanoidRootPart
					local bb = Instance.new("BillboardGui")
					bb.Size = UDim2.new(0, 200*settings.espSize, 0, 50*settings.espSize)
					bb.StudsOffset = Vector3.new(0,2.5,0)
					bb.AlwaysOnTop = true
					bb.Parent = head
					local fr = Instance.new("Frame")
					fr.Size = UDim2.new(1,0,1,0)
					fr.BackgroundTransparency = 1
					local n = Instance.new("TextLabel")
					n.Text = p.Name
					n.Font = Enum.Font.GothamBold
					n.TextSize = 14
					n.TextColor3 = Color3.fromRGB(255,255,255)
					n.BackgroundTransparency = 1
					n.Size = UDim2.new(1,0,0,25)
					n.Parent = fr
					local hp = Instance.new("TextLabel")
					hp.Name = "Health"
					hp.Font = Enum.Font.Gotham
					hp.TextSize = 11
					hp.TextColor3 = Color3.fromRGB(100,255,100)
					hp.BackgroundTransparency = 1
					hp.Size = UDim2.new(1,0,0,18)
					hp.Position = UDim2.new(0,0,0,25)
					hp.Parent = fr
					local d = Instance.new("TextLabel")
					d.Name = "Distance"
					d.Font = Enum.Font.Gotham
					d.TextSize = 10
					d.TextColor3 = Color3.fromRGB(180,180,180)
					d.BackgroundTransparency = 1
					d.Size = UDim2.new(1,0,0,14)
					d.Position = UDim2.new(0,0,0,43)
					d.Parent = fr
					fr.Parent = bb
					espPlayers[p.UserId] = {hl=hl, bb=bb, health=hp, distance=d}
				end
				local d = espPlayers[p.UserId]
				if d.bb then d.bb.Size = UDim2.new(0,200*settings.espSize,0,50*settings.espSize) end
				if settings.espHealth and h then d.health.Text = "❤️ "..math.floor(h.Health); d.health.Visible=true else d.health.Visible=false end
				if settings.espDistance then
					local my = player.Character
					local myr = my and my:FindFirstChild("HumanoidRootPart")
					if myr then d.distance.Text = string.format("%.1fm", (myr.Position - c.HumanoidRootPart.Position).Magnitude); d.distance.Visible=true else d.distance.Visible=false end
				else d.distance.Visible=false end
			end
		end end
		if settings.espChests then
			for _,o in pairs(Workspace:GetDescendants()) do
				if o:IsA("BasePart") and (o.Name:lower():find("chest") or o.Name:lower():find("crate")) then
					if not espChests[o] then
						local hl = Instance.new("Highlight")
						hl.FillColor = Color3.fromRGB(255,200,50)
						hl.FillTransparency = 0.4
						hl.OutlineColor = Color3.fromRGB(255,255,100)
						hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
						hl.Adornee = o
						hl.Parent = o
						espChests[o] = hl
					end
				end
			end
		end
		if settings.espMobs then
			for _,o in pairs(Workspace:GetDescendants()) do
				if o:IsA("Model") and o:FindFirstChild("Humanoid") and o~=player.Character then
					if not espMobs[o] then
						local hl = Instance.new("Highlight")
						hl.FillColor = Color3.fromRGB(255,100,255)
						hl.FillTransparency = 0.5
						hl.OutlineColor = Color3.fromRGB(255,255,255)
						hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
						hl.Adornee = o
						hl.Parent = o
						espMobs[o] = hl
					end
				end
			end
		end
	end)
end
updateESP()

-- =========== BACKGROUND LOOPS ===========
RunService.Heartbeat:Connect(function()
	if settings.speedHack then
		local c = player.Character
		if c and c:FindFirstChild("Humanoid") then c.Humanoid.WalkSpeed = settings.speedHackValue end
	end
end)
UserInputService.JumpRequest:Connect(function()
	if settings.infiniteJump then
		local c = player.Character
		if c and c:FindFirstChild("Humanoid") then c.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
	end
end)
player.CharacterAdded:Connect(function()
	task.wait(1)
	local c = player.Character
	local h = c and c:FindFirstChild("Humanoid")
	if h then
		h.WalkSpeed = settings.walkSpeed
		h.JumpPower = settings.jumpPower
	end
	if bodyVelocity then bodyVelocity:Destroy() end
	if settings.flyEnabled then
		task.wait(0.5)
		local hrp = c and c:FindFirstChild("HumanoidRootPart")
		if hrp and h then
			h.PlatformStand = true
			bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.MaxForce = Vector3.new(1e6,1e6,1e6)
			bodyVelocity.Parent = hrp
		end
	end
	if settings.noclip then
		if noClipConnection then noClipConnection:Disconnect() end
		noClipConnection = RunService.Stepped:Connect(function()
			if not settings.noclip then return end
			local cc = player.Character
			if not cc then return end
			for _,p in pairs(cc:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
		end)
	end
	if settings.goodMode then enableGoodMode() end
end)

-- =========== LAUNCH ===========
task.wait(8.5)
createFloatingButton()
floatingButton.Visible = true
floatingButton.Position = UDim2.new(0, 10, 0.5, -22)
if floatingButton then
	settings.floatingX = 10
	settings.floatingY = math.floor(floatingButton.Position.Y.Offset)
end
isMinimized = false
MainFrame.Visible = true
MainFrame.Size = UDim2.new(0, settings.windowWidth, 0, settings.windowHeight)
MainFrame.BackgroundTransparency = 0.05
TweenService:Create(MainFrame, TweenInfo.new(0.4), {BackgroundTransparency = 0.05}):Play()
createNotification("✨ Synapse Hub v28 Ready! ✨", 2.5)
print("✅ Synapse Hub v28 loaded - Full order fixed")
