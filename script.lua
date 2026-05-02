--[[
    TWKS SYNAPSE UI v7 - FULL VISUAL + Delta Compatible
    Абсолютно все функции: SpeedHack, Noclip, Fly, Infinite Jump, ESP
    Красивое меню с анимациями, градиентами, 6 цветовых тем
    НЕТ: getrawmetatable, setreadonly, __index hooks
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer

if not player then player = Players.PlayerAdded:Wait() end

-- =========== STORAGE ==========
local Storage = Instance.new("Folder")
Storage.Name = "TWKS_Settings"
pcall(function() Storage.Parent = player end)

local function load(name, default)
    local success, val = pcall(function() return Storage:GetAttribute(name) end)
    if success and val ~= nil then return val end
    return default
end

local function save(name, value)
    pcall(function() Storage:SetAttribute(name, value) end)
end

-- =========== SETTINGS ==========
local settings = {
    walkSpeed = load("WalkSpeed", 16),
    jumpPower = load("JumpPower", 50),
    fov = load("FOV", 70),
    autoWalk = load("AutoWalk", false),
    esp = load("ESP", false),
    speedHack = load("SpeedHack", false),
    noclip = load("Noclip", false),
    fly = load("Fly", false),
    infiniteJump = load("InfiniteJump", false),
    speedValue = load("SpeedValue", 50),
    jumpValue = load("JumpValue", 80),
    espColorR = load("ESPColorR", 255),
    espColorG = load("ESPColorG", 50),
    espColorB = load("ESPColorB", 50),
    theme = load("Theme", "Cyan")
}

-- =========== STATE ==========
local state = {
    autoWalk = settings.autoWalk,
    esp = settings.esp,
    speedHack = settings.speedHack,
    noclip = settings.noclip,
    fly = settings.fly,
    infiniteJump = settings.infiniteJump,
    speedValue = settings.speedValue,
    jumpValue = settings.jumpValue,
    espColor = Color3.fromRGB(settings.espColorR, settings.espColorG, settings.espColorB)
}

-- =========== VARIABLES ==========
local character, humanoid, camera
local flyVel, flyGyro, flyConn, noclipConn, autoWalkConn, infJumpConn
local keysPressed = {}
local espObjects = {}
local menuVisible = true
local lastESPUpdate = 0

-- =========== KEYBOARD ==========
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    keysPressed[input.KeyCode.Name] = true
    if input.KeyCode == Enum.KeyCode.RightAlt then
        menuVisible = not menuVisible
        if ScreenGui then ScreenGui.Enabled = menuVisible end
    end
end)
UserInputService.InputEnded:Connect(function(input) keysPressed[input.KeyCode.Name] = false end)

-- =========== CHARACTER ==========
local function refreshChar()
    pcall(function()
        local char = player.Character
        if char then
            character = char
            humanoid = char:FindFirstChild("Humanoid")
            if humanoid then
                if state.speedHack then humanoid.WalkSpeed = state.speedValue
                else humanoid.WalkSpeed = settings.walkSpeed end
                if state.infiniteJump then humanoid.JumpPower = state.jumpValue
                else humanoid.JumpPower = settings.jumpPower end
            end
        end
        camera = Workspace.CurrentCamera
        if camera then camera.FieldOfView = settings.fov end
    end)
end
refreshChar()
if not character then
    character = player.CharacterAdded:Wait()
    humanoid = character:WaitForChild("Humanoid")
end

-- =========== SPEED HACK ==========
local function applySpeed(state)
    pcall(function()
        local char = player.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then hum.WalkSpeed = state and state.speedValue or settings.walkSpeed end
        end
    end)
end

-- =========== NOCLIP ==========
local function toggleNoclip(state)
    if noclipConn then noclipConn:Disconnect() noclipConn = nil end
    if state then
        noclipConn = RunService.Stepped:Connect(function()
            if not state.noclip then return end
            local char = player.Character
            if not char then return end
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then pcall(function() part.CanCollide = false end) end
            end
        end)
    end
end

-- =========== FLY ==========
local function toggleFly(state)
    if flyConn then flyConn:Disconnect() flyConn = nil end
    if flyVel then pcall(function() flyVel:Destroy() end) flyVel = nil end
    if flyGyro then pcall(function() flyGyro:Destroy() end) flyGyro = nil end
    if not state then return end
    
    task.wait(0.1)
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    flyVel = Instance.new("BodyVelocity")
    flyVel.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    flyVel.P = 1e4
    flyVel.Parent = hrp
    
    flyGyro = Instance.new("BodyGyro")
    flyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    flyGyro.P = 1e5
    flyGyro.Parent = hrp
    
    flyConn = RunService.RenderStepped:Connect(function()
        if not state.fly then return end
        local char = player.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp or not flyVel or not flyGyro then return end
        
        local move = Vector3.new(
            (keysPressed["D"] and 1 or 0) - (keysPressed["A"] and 1 or 0),
            (keysPressed["E"] and 1 or 0) - (keysPressed["Q"] and 1 or 0),
            (keysPressed["W"] and 1 or 0) - (keysPressed["S"] and 1 or 0)
        )
        if move.Magnitude > 0 then move = move.Unit end
        
        local cam = Workspace.CurrentCamera
        if cam then
            flyVel.Velocity = (cam.CFrame.RightVector * move.X + cam.CFrame.UpVector * move.Y + cam.CFrame.LookVector * move.Z) * 80
            flyGyro.CFrame = cam.CFrame
        end
    end)
end

-- =========== INFINITE JUMP ==========
local function toggleInfiniteJump(state)
    if infJumpConn then infJumpConn:Disconnect() infJumpConn = nil end
    if state then
        infJumpConn = UserInputService.JumpRequest:Connect(function()
            local char = player.Character
            if char then
                local hum = char:FindFirstChild("Humanoid")
                if hum and hum:GetState() ~= Enum.HumanoidStateType.Jumping then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
    end
end

-- =========== ESP ==========
local function updateESP()
    if not state.esp then
        for _, obj in pairs(espObjects) do pcall(function() obj:Destroy() end) end
        espObjects = {}
        return
    end
    
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player then
            local char = plr.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                if not espObjects[plr.UserId] then
                    local bill = Instance.new("BillboardGui")
                    bill.Size = UDim2.new(0, 220, 0, 55)
                    bill.StudsOffset = Vector3.new(0, 2.5, 0)
                    bill.AlwaysOnTop = true
                    bill.Parent = root
                    
                    local frame = Instance.new("Frame")
                    frame.Size = UDim2.new(1, 0, 1, 0)
                    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
                    frame.BackgroundTransparency = 0.3
                    frame.BorderSizePixel = 0
                    frame.Parent = bill
                    local frameCorner = Instance.new("UICorner")
                    frameCorner.CornerRadius = UDim.new(0, 6)
                    frameCorner.Parent = frame
                    
                    local nameLabel = Instance.new("TextLabel")
                    nameLabel.Text = plr.Name
                    nameLabel.Font = Enum.Font.GothamBold
                    nameLabel.TextSize = 14
                    nameLabel.TextColor3 = state.espColor
                    nameLabel.BackgroundTransparency = 1
                    nameLabel.Size = UDim2.new(1, 0, 0, 25)
                    nameLabel.Position = UDim2.new(0, 0, 0, 8)
                    nameLabel.Parent = frame
                    
                    local hpLabel = Instance.new("TextLabel")
                    hpLabel.Name = "HP"
                    hpLabel.Font = Enum.Font.Gotham
                    hpLabel.TextSize = 11
                    hpLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
                    hpLabel.BackgroundTransparency = 1
                    hpLabel.Size = UDim2.new(1, 0, 0, 18)
                    hpLabel.Position = UDim2.new(0, 0, 0, 33)
                    hpLabel.Parent = frame
                    
                    espObjects[plr.UserId] = bill
                end
                
                local bill = espObjects[plr.UserId]
                if bill and bill.Parent ~= root then bill.Parent = root end
                
                local frame = bill and bill:FindFirstChildOfClass("Frame")
                if frame then
                    local nameLabel = frame:FindFirstChildOfClass("TextLabel")
                    if nameLabel then nameLabel.TextColor3 = state.espColor end
                    
                    local hpLabel = frame:FindFirstChild("HP")
                    if hpLabel and humanoid then
                        local targetHum = char:FindFirstChild("Humanoid")
                        if targetHum then
                            local hpPercent = (targetHum.Health / targetHum.MaxHealth) * 100
                            hpLabel.Text = string.format("❤️ %.0f%%", hpPercent)
                            hpLabel.TextColor3 = targetHum.Health > 50 and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
                        end
                    end
                end
            elseif espObjects[plr.UserId] then
                pcall(function() espObjects[plr.UserId]:Destroy() end)
                espObjects[plr.UserId] = nil
            end
        end
    end
end

RunService.Heartbeat:Connect(function(dt)
    lastESPUpdate = lastESPUpdate + dt
    if lastESPUpdate >= 0.25 then
        lastESPUpdate = 0
        updateESP()
    end
end)

-- =========== AUTO WALK ==========
local function updateAutoWalk()
    if autoWalkConn then autoWalkConn:Disconnect() end
    if state.autoWalk then
        autoWalkConn = RunService.Heartbeat:Connect(function()
            local char = player.Character
            if not char then return end
            local hum = char:FindFirstChild("Humanoid")
            local root = char:FindFirstChild("HumanoidRootPart")
            if not hum or not root then return end
            if hum.MoveDirection.Magnitude < 0.1 then
                local dir = root.CFrame.LookVector * Vector3.new(1, 0, 1)
                if dir.Magnitude > 0.01 then hum:Move(dir.Unit, false) end
            end
        end)
    end
end

-- =========== CREATE GUI ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TWKS_Menu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Enabled = true

local guiParent = nil
pcall(function() guiParent = player:WaitForChild("PlayerGui", 2) end)
if not guiParent then pcall(function() guiParent = game:GetService("CoreGui") end) end
if not guiParent then pcall(function() guiParent = game:GetService("StarterGui") end) end
if guiParent then pcall(function() ScreenGui.Parent = guiParent end) end

-- Loading animation
local loadingFrame = Instance.new("Frame")
loadingFrame.Size = UDim2.new(0, 300, 0, 100)
loadingFrame.Position = UDim2.new(0.5, -150, 0.5, -50)
loadingFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
loadingFrame.BackgroundTransparency = 0.15
loadingFrame.BorderSizePixel = 0
loadingFrame.Parent = ScreenGui
local loadCorner = Instance.new("UICorner")
loadCorner.CornerRadius = UDim.new(0, 12)
loadCorner.Parent = loadingFrame

local loadText = Instance.new("TextLabel")
loadText.Text = "TWKS SYNAPSE v7"
loadText.Font = Enum.Font.GothamBold
loadText.TextSize = 20
loadText.TextColor3 = Color3.fromRGB(0, 180, 255)
loadText.BackgroundTransparency = 1
loadText.Size = UDim2.new(1, 0, 0, 40)
loadText.Position = UDim2.new(0, 0, 0, 15)
loadText.Parent = loadingFrame

local loadBar = Instance.new("Frame")
loadBar.Size = UDim2.new(0.8, 0, 0, 4)
loadBar.Position = UDim2.new(0.1, 0, 0.7, 0)
loadBar.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
loadBar.BorderSizePixel = 0
loadBar.Parent = loadingFrame
local barCorner = Instance.new("UICorner")
barCorner.CornerRadius = UDim.new(1, 0)
barCorner.Parent = loadBar

local loadFill = Instance.new("Frame")
loadFill.Size = UDim2.new(0, 0, 1, 0)
loadFill.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
loadFill.BorderSizePixel = 0
loadFill.Parent = loadBar
local fillCorner = Instance.new("UICorner")
fillCorner.CornerRadius = UDim.new(1, 0)
fillCorner.Parent = loadFill

TweenService:Create(loadFill, TweenInfo.new(1.5), {Size = UDim2.new(1, 0, 1, 0)}):Play()
task.wait(1.8)
TweenService:Create(loadingFrame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
TweenService:Create(loadText, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
task.wait(0.35)
loadingFrame:Destroy()

-- =========== MAIN MENU ==========
local MainContainer = Instance.new("Frame")
MainContainer.Size = UDim2.new(0, 520, 0, 580)
MainContainer.Position = UDim2.new(0.5, -260, 0.5, -290)
MainContainer.BackgroundTransparency = 1
MainContainer.Parent = ScreenGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(1, 0, 1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
MainFrame.BackgroundTransparency = 0.08
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = MainContainer

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(0, 160, 240)
MainStroke.Thickness = 1.5
MainStroke.Transparency = 0.7
MainStroke.Parent = MainFrame

local Shadow = Instance.new("Frame")
Shadow.Size = UDim2.new(1, 0, 1, 0)
Shadow.Position = UDim2.new(0, 0, 0, 0)
Shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Shadow.BackgroundTransparency = 0.4
Shadow.BorderSizePixel = 0
Shadow.ZIndex = 0
Shadow.Parent = MainContainer

-- =========== TITLE BAR ==========
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 48)
TitleBar.BackgroundColor3 = Color3.fromRGB(0, 140, 230)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 14)
TitleCorner.Parent = TitleBar

local TitleGradient = Instance.new("UIGradient")
TitleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 120, 210)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 160, 250))
})
TitleGradient.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Text = "⚡ TWKS SYNAPSE CORE v7 ⚡"
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 18
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.BackgroundTransparency = 1
TitleText.Size = UDim2.new(1, -100, 1, 0)
TitleText.Position = UDim2.new(0, 18, 0, 0)
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

local SubText = Instance.new("TextLabel")
SubText.Text = "Delta | KRNL | Synapse"
SubText.Font = Enum.Font.Gotham
SubText.TextSize = 10
SubText.TextColor3 = Color3.fromRGB(200, 220, 255)
SubText.BackgroundTransparency = 1
SubText.Size = UDim2.new(1, -100, 0, 14)
SubText.Position = UDim2.new(0, 18, 0, 28)
SubText.TextXAlignment = Enum.TextXAlignment.Left
SubText.Parent = TitleBar

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 38, 1, -8)
MinimizeBtn.Position = UDim2.new(1, -84, 0, 4)
MinimizeBtn.Text = "−"
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 24
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 180)
MinimizeBtn.BorderSizePixel = 0
MinimizeBtn.Parent = TitleBar
local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 8)
minCorner.Parent = MinimizeBtn

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 38, 1, -8)
CloseBtn.Position = UDim2.new(1, -42, 0, 4)
CloseBtn.Text = "✕"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TitleBar
local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = CloseBtn

-- =========== DRAG ==========
local dragActive = false
local dragStart, containerStart
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragActive = true
        dragStart = input.Position
        containerStart = MainContainer.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragActive and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainContainer.Position = UDim2.new(containerStart.X.Scale, containerStart.X.Offset + delta.X, containerStart.Y.Scale, containerStart.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragActive = false end
end)

-- =========== TABS ==========
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(0, 140, 1, -48)
TabContainer.Position = UDim2.new(0, 0, 0, 48)
TabContainer.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
TabContainer.BackgroundTransparency = 0.5
TabContainer.BorderSizePixel = 0
TabContainer.Parent = MainFrame

local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -140, 1, -48)
ContentContainer.Position = UDim2.new(0, 140, 0, 48)
ContentContainer.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
ContentContainer.BackgroundTransparency = 0.3
ContentContainer.BorderSizePixel = 0
ContentContainer.ClipsDescendants = true
ContentContainer.Parent = MainFrame

local tabs = {"MAIN", "COMBAT", "VISUAL", "THEME"}
local currentTab = "MAIN"
local tabButtons = {}
local scrollingFrames = {}

for i, tabName in ipairs(tabs) do
    local btn = Instance.new("TextButton")
    btn.Text = tabName
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.Size = UDim2.new(1, -20, 0, 44)
    btn.Position = UDim2.new(0, 10, 0, 10 + (i-1) * 54)
    btn.BackgroundColor3 = i == 1 and Color3.fromRGB(0, 140, 230) or Color3.fromRGB(30, 30, 40)
    btn.TextColor3 = i == 1 and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 160, 170)
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = TabContainer
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn
    
    local sf = Instance.new("ScrollingFrame")
    sf.Size = UDim2.new(1, 0, 1, 0)
    sf.BackgroundTransparency = 1
    sf.CanvasSize = UDim2.new(0, 0, 0, 650)
    sf.ScrollBarThickness = 4
    sf.ScrollBarImageColor3 = Color3.fromRGB(0, 140, 230)
    sf.Visible = i == 1
    sf.Parent = ContentContainer
    
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 0, 650)
    content.BackgroundTransparency = 1
    content.Parent = sf
    
    tabButtons[tabName] = btn
    scrollingFrames[tabName] = {sf = sf, content = content}
    
    btn.MouseButton1Click:Connect(function()
        for _, tb in pairs(tabButtons) do
            tb.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
            tb.TextColor3 = Color3.fromRGB(160, 160, 170)
        end
        btn.BackgroundColor3 = Color3.fromRGB(0, 140, 230)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        for _, sfData in pairs(scrollingFrames) do
            sfData.sf.Visible = false
        end
        scrollingFrames[tabName].sf.Visible = true
        currentTab = tabName
    end)
end

-- Helper functions
local function addToggle(parentContent, text, y, defaultValue, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -24, 0, 52)
    frame.Position = UDim2.new(0, 12, 0, y)
    frame.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
    frame.BackgroundTransparency = 0.4
    frame.BorderSizePixel = 0
    frame.Parent = parentContent
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 10)
    frameCorner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Text = text
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextColor3 = Color3.fromRGB(220, 220, 230)
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0, 16, 0, 0)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 68, 0, 34)
    btn.Position = UDim2.new(1, -80, 0.5, -17)
    btn.Text = defaultValue and "ON" or "OFF"
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundColor3 = defaultValue and Color3.fromRGB(0, 170, 90) or Color3.fromRGB(55, 55, 68)
    btn.BorderSizePixel = 0
    btn.Parent = frame
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn
    
    local val = defaultValue
    btn.MouseButton1Click:Connect(function()
        val = not val
        btn.Text = val and "ON" or "OFF"
        btn.BackgroundColor3 = val and Color3.fromRGB(0, 170, 90) or Color3.fromRGB(55, 55, 68)
        if callback then callback(val) end
    end)
    if callback and defaultValue then task.spawn(function() callback(defaultValue) end) end
    return btn
end

local function addSlider(parentContent, text, y, minVal, maxVal, defaultVal, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -24, 0, 78)
    frame.Position = UDim2.new(0, 12, 0, y)
    frame.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
    frame.BackgroundTransparency = 0.4
    frame.BorderSizePixel = 0
    frame.Parent = parentContent
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 10)
    frameCorner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Text = text .. " [" .. tostring(defaultVal) .. "]"
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextColor3 = Color3.fromRGB(200, 200, 210)
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, -24, 0, 28)
    label.Position = UDim2.new(0, 12, 0, 8)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -32, 0, 6)
    bar.Position = UDim2.new(0, 16, 0, 52)
    bar.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    bar.BorderSizePixel = 0
    bar.Parent = frame
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(1, 0)
    barCorner.Parent = bar
    
    local ratio = (defaultVal - minVal) / (maxVal - minVal)
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(ratio, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    fill.BorderSizePixel = 0
    fill.Parent = bar
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill
    
    local valueBtn = Instance.new("TextButton")
    valueBtn.Size = UDim2.new(0, 48, 0, 24)
    valueBtn.Position = UDim2.new(ratio, -24, 0.5, -12)
    valueBtn.Text = tostring(defaultVal)
    valueBtn.Font = Enum.Font.GothamBold
    valueBtn.TextSize = 12
    valueBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    valueBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
    valueBtn.BorderSizePixel = 0
    valueBtn.Parent = frame
    local valCorner = Instance.new("UICorner")
    valCorner.CornerRadius = UDim.new(0, 6)
    valCorner.Parent = valueBtn
    
    local currentVal = defaultVal
    local dragging = false
    
    local function update(input)
        local barPos = bar.AbsolutePosition
        local barSize = bar.AbsoluteSize
        if not barPos or not barSize then return end
        local percent = math.clamp((input.Position.X - barPos.X) / barSize.X, 0, 1)
        local val = math.floor((minVal + (maxVal - minVal) * percent) * 10 + 0.5) / 10
        fill.Size = UDim2.new(percent, 0, 1, 0)
        valueBtn.Position = UDim2.new(percent, -24, 0.5, -12)
        valueBtn.Text = tostring(val)
        label.Text = text .. " [" .. tostring(val) .. "]"
        currentVal = val
        if callback then callback(val) end
    end
    
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            update(input)
        end
    end)
    valueBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            update(input)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            update(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    
    if callback then callback(defaultVal) end
    return {setValue = function(v) 
        local r = math.clamp((v - minVal) / (maxVal - minVal), 0, 1)
        fill.Size = UDim2.new(r, 0, 1, 0)
        valueBtn.Position = UDim2.new(r, -24, 0.5, -12)
        valueBtn.Text = tostring(v)
        label.Text = text .. " [" .. tostring(v) .. "]"
        if callback then callback(v) end
    end}
end

-- =========== POPULATE TABS ==========
local mainContent = scrollingFrames["MAIN"].content
addToggle(mainContent, "🚶 Auto Walk", 10, state.autoWalk, function(val)
    state.autoWalk = val
    save("AutoWalk", val)
    updateAutoWalk()
end)
addSlider(mainContent, "🏃 Walk Speed", 72, 8, 100, settings.walkSpeed, function(val)
    settings.walkSpeed = val
    save("WalkSpeed", val)
    if not state.speedHack then
        local char = player.Character
        if char then local hum = char:FindFirstChild("Humanoid") if hum then hum.WalkSpeed = val end end
    end
end)
addSlider(mainContent, "🦘 Jump Power", 160, 10, 200, settings.jumpPower, function(val)
    settings.jumpPower = val
    save("JumpPower", val)
    if not state.infiniteJump then
        local char = player.Character
        if char then local hum = char:FindFirstChild("Humanoid") if hum then hum.JumpPower = val end end
    end
end)
addSlider(mainContent, "👁️ Field of View", 248, 30, 120, settings.fov, function(val)
    settings.fov = val
    save("FOV", val)
    if camera then camera.FieldOfView = val end
end)

local combatContent = scrollingFrames["COMBAT"].content
addToggle(combatContent, "⚡ Speed Hack", 10, state.speedHack, function(val)
    state.speedHack = val
    save("SpeedHack", val)
    applySpeed(val)
end)
addSlider(combatContent, "📈 Speed Value", 72, 20, 250, state.speedValue, function(val)
    state.speedValue = val    save("SpeedValue", val)
    if state.speedHack then applySpeed(true) end
end)
addToggle(combatContent, "🌀 Noclip", 160, state.noclip, function(val)
    state.noclip = val
    save("Noclip", val)
    toggleNoclip(val)
end)
addToggle(combatContent, "🕊️ Fly Mode", 222, state.fly, function(val)
    state.fly = val
    save("Fly", val)
    toggleFly(val)
end)
addToggle(combatContent, "⭐ Infinite Jump", 284, state.infiniteJump, function(val)
    state.infiniteJump = val
    save("InfiniteJump", val)
    toggleInfiniteJump(val)
    local char = player.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.JumpPower = val and state.jumpValue or settings.jumpPower end
    end
end)
addSlider(combatContent, "🦘 Jump Value", 346, 30, 200, state.jumpValue, function(val)
    state.jumpValue = val
    save("JumpValue", val)
    if state.infiniteJump then
        local char = player.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then hum.JumpPower = val end
        end
    end
end)

local visualContent = scrollingFrames["VISUAL"].content
addToggle(visualContent, "👁️ ESP Players", 10, state.esp, function(val)
    state.esp = val
    save("ESP", val)
    updateESP()
end)

local redSlider, greenSlider, blueSlider
redSlider = addSlider(visualContent, "🔴 ESP Red", 72, 0, 255, settings.espColorR, function(val)
    settings.espColorR = val
    save("ESPColorR", val)
    state.espColor = Color3.fromRGB(val, settings.espColorG, settings.espColorB)
    updateESP()
end)
greenSlider = addSlider(visualContent, "🟢 ESP Green", 160, 0, 255, settings.espColorG, function(val)
    settings.espColorG = val
    save("ESPColorG", val)
    state.espColor = Color3.fromRGB(settings.espColorR, val, settings.espColorB)
    updateESP()
end)
blueSlider = addSlider(visualContent, "🔵 ESP Blue", 248, 0, 255, settings.espColorB, function(val)
    settings.espColorB = val
    save("ESPColorB", val)
    state.espColor = Color3.fromRGB(settings.espColorR, settings.espColorG, val)
    updateESP()
end)

local themeContent = scrollingFrames["THEME"].content
local themes = {
    {name = "💙 CYAN", main = Color3.fromRGB(0, 160, 255), accent = Color3.fromRGB(0, 130, 210), bg = Color3.fromRGB(18, 22, 32)},
    {name = "❤️ RED", main = Color3.fromRGB(230, 50, 50), accent = Color3.fromRGB(190, 30, 30), bg = Color3.fromRGB(32, 18, 22)},
    {name = "💚 GREEN", main = Color3.fromRGB(50, 210, 80), accent = Color3.fromRGB(40, 170, 60), bg = Color3.fromRGB(20, 32, 20)},
    {name = "💜 PURPLE", main = Color3.fromRGB(160, 60, 230), accent = Color3.fromRGB(130, 40, 190), bg = Color3.fromRGB(28, 18, 36)},
    {name = "🧡 ORANGE", main = Color3.fromRGB(255, 140, 30), accent = Color3.fromRGB(210, 110, 20), bg = Color3.fromRGB(36, 28, 18)},
    {name = "⚪ WHITE", main = Color3.fromRGB(200, 200, 220), accent = Color3.fromRGB(160, 160, 180), bg = Color3.fromRGB(28, 28, 34)}
}

for i, theme in ipairs(themes) do
    local btn = Instance.new("TextButton")
    btn.Text = theme.name
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Size = UDim2.new(1, -30, 0, 46)
    btn.Position = UDim2.new(0, 15, 0, 10 + (i-1) * 56)
    btn.BackgroundColor3 = theme.main
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = themeContent
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 10)
    btnCorner.Parent = btn
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = theme.accent}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = theme.main}):Play()
    end)
    btn.MouseButton1Click:Connect(function()
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {BackgroundColor3 = theme.bg}):Play()
        TweenService:Create(MainStroke, TweenInfo.new(0.3), {Color = theme.main}):Play()
        TweenService:Create(TitleBar, TweenInfo.new(0.3), {BackgroundColor3 = theme.main}):Play()
        for _, sf in pairs(scrollingFrames) do
            sf.sf.ScrollBarImageColor3 = theme.main
        end
        for _, btn in pairs(tabButtons) do
            if btn.BackgroundColor3 ~= theme.main then
                btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
            end
        end
        tabButtons[currentTab].BackgroundColor3 = theme.main
        settings.theme = theme.name
        save("Theme", theme.name)
    end)
end

-- =========== BUTTON ACTIONS ==========
MinimizeBtn.MouseButton1Click:Connect(function()
    MainContainer:TweenSize(UDim2.new(0, 520, 0, 48), "Out", "Quad", 0.25)
    task.wait(0.25)
    MainContainer.Size = UDim2.new(0, 520, 0, 580)
end)
CloseBtn.MouseButton1Click:Connect(function()
    TweenService:Create(MainContainer, TweenInfo.new(0.2), {Size = UDim2.new(0, 0, 0, 0)}):Play()
    task.wait(0.2)
    ScreenGui:Destroy()
end)

-- =========== INITIALIZE FEATURES ==========
updateAutoWalk()
if state.noclip then toggleNoclip(true) end
if state.fly then toggleFly(true) end
if state.infiniteJump then toggleInfiniteJump(true) end
if state.speedHack then applySpeed(true) end
if state.esp then updateESP() end

-- =========== RESPAWN HANDLER ==========
player.CharacterAdded:Connect(function(newChar)
    task.wait(0.2)
    character = newChar
    humanoid = newChar:FindFirstChild("Humanoid")
    camera = Workspace.CurrentCamera
    if humanoid then
        humanoid.WalkSpeed = state.speedHack and state.speedValue or settings.walkSpeed
        humanoid.JumpPower = state.infiniteJump and state.jumpValue or settings.jumpPower
    end
    if camera then camera.FieldOfView = settings.fov end
    if state.fly then toggleFly(true) end
    if state.noclip then toggleNoclip(true) end
    if state.infiniteJump then toggleInfiniteJump(true) end
    for _, obj in pairs(espObjects) do pcall(function() obj:Destroy() end) end
    espObjects = {}
end)

print("═══════════════════════════════════════════")
print("⚡ TWKS SYNAPSE UI v7 FULLY LOADED ⚡")
print("📌 RightAlt - Скрыть/Показать меню")
print("📌 Fly: W/A/S/D + E(вверх)/Q(вниз)")
print("✅ SpeedHack | Noclip | Fly | Infinite Jump | ESP")
print("═══════════════════════════════════════════")
