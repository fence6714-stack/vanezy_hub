--[[
    TWKS MOBILE v9 - RAINBOW EDITION
    Компактное меню: 340x440
    РАДУЖНАЯ АНИМАЦИЯ на всём меню (фон, градиент, кнопки, ползунки)
    Исправленные ползунки, рабочий Noclip (с Anti-Fall), ESP с настройками
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

if not player then player = Players.PlayerAdded:Wait() end

-- =========== RAINBOW CYCLE ==========
local rainbowHue = 0
local rainbowSpeed = 0.5 -- секунды на полный цикл
local rainbowEnabled = true

local function getRainbowColor()
    return Color3.fromHSV(rainbowHue, 1, 1)
end

local function getRainbowGradient()
    return ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromHSV(rainbowHue, 1, 1)),
        ColorSequenceKeypoint.new(0.5, Color3.fromHSV((rainbowHue + 0.5) % 1, 1, 1)),
        ColorSequenceKeypoint.new(1, Color3.fromHSV((rainbowHue + 1) % 1, 1, 1))
    })
end

-- Rainbow update loop
RunService.RenderStepped:Connect(function(dt)
    if rainbowEnabled then
        rainbowHue = (rainbowHue + dt / rainbowSpeed) % 1
    end
end)

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
    espSize = load("ESPSize", 18),
    rainbow = load("Rainbow", true)
}

local state = {
    autoWalk = settings.autoWalk,
    esp = settings.esp,
    speedHack = settings.speedHack,
    noclip = settings.noclip,
    fly = settings.fly,
    infiniteJump = settings.infiniteJump,
    speedValue = settings.speedValue,
    jumpValue = settings.jumpValue,
    espColor = Color3.fromRGB(settings.espColorR, settings.espColorG, settings.espColorB),
    espSize = settings.espSize,
    rainbow = settings.rainbow
}

rainbowEnabled = state.rainbow

-- =========== VARIABLES ==========
local character, humanoid, camera
local flyVel, flyGyro, flyConn, noclipConn, autoWalkConn, infJumpConn
local keysPressed = {}
local espObjects = {}
local menuVisible = true
local lastESPUpdate = 0

-- Все UI элементы для радужного обновления
local uiElements = {
    gradients = {},
    buttons = {},
    sliders = {},
    frames = {}
}

-- =========== COMPACT MENU SIZE ==========
local MENU_WIDTH = 340
local MENU_HEIGHT = 440

-- =========== KEYBOARD ==========
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    keysPressed[input.KeyCode.Name] = true
    if input.KeyCode == Enum.KeyCode.RightAlt or input.KeyCode == Enum.KeyCode.VolumeUp then
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

-- =========== NOCLIP С ЗАЩИТОЙ ОТ ПАДЕНИЯ ==========
local function toggleNoclip(state)
    if noclipConn then noclipConn:Disconnect() noclipConn = nil end
    if state then
        noclipConn = RunService.Stepped:Connect(function()
            if not state.noclip then return end
            local char = player.Character
            if not char then return end
            
            -- Основной ноклип
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    pcall(function() part.CanCollide = false end)
                end
            end
            
            -- ЗАЩИТА ОТ ПАДЕНИЯ: не даём провалиться под карту
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp and hrp.Position.Y < -10 then
                hrp.Position = Vector3.new(hrp.Position.X, 5, hrp.Position.Z)
                local hum = char:FindFirstChild("Humanoid")
                if hum then hum:ChangeState(Enum.HumanoidStateType.Landing) end
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
                    bill.Size = UDim2.new(0, 200, 0, 50)
                    bill.StudsOffset = Vector3.new(0, 2.5, 0)
                    bill.AlwaysOnTop = true
                    bill.Parent = root
                    
                    local nameLabel = Instance.new("TextLabel")
                    nameLabel.Font = Enum.Font.GothamBold
                    nameLabel.TextSize = state.espSize
                    nameLabel.TextColor3 = state.espColor
                    nameLabel.BackgroundTransparency = 1
                    nameLabel.Size = UDim2.new(1, 0, 1, 0)
                    nameLabel.TextStrokeTransparency = 0.3
                    nameLabel.Parent = bill
                    
                    espObjects[plr.UserId] = {bill = bill, label = nameLabel}
                end
                
                local data = espObjects[plr.UserId]
                if data.bill and data.bill.Parent ~= root then data.bill.Parent = root end
                if data.label then
                    data.label.Text = plr.Name
                    data.label.TextSize = state.espSize
                    data.label.TextColor3 = state.espColor
                end
            elseif espObjects[plr.UserId] then
                pcall(function() 
                    if espObjects[plr.UserId].bill then espObjects[plr.UserId].bill:Destroy() end
                end)
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
ScreenGui.Name = "TWKS_Mobile"
ScreenGui.ResetOnSpawn = false
ScreenGui.Enabled = true

local guiParent = nil
pcall(function() guiParent = player:WaitForChild("PlayerGui", 2) end)
if not guiParent then pcall(function() guiParent = game:GetService("CoreGui") end) end
if not guiParent then pcall(function() guiParent = game:GetService("StarterGui") end) end
if guiParent then pcall(function() ScreenGui.Parent = guiParent end) end

-- =========== КОМПАКТНОЕ МЕНЮ ==========
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, MENU_WIDTH, 0, MENU_HEIGHT)
MainFrame.Position = UDim2.new(0.5, -MENU_WIDTH/2, 0.5, -MENU_HEIGHT/2)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 16)
MainCorner.Parent = MainFrame
table.insert(uiElements.frames, MainFrame)

-- РАДУЖНАЯ ОБВОДКА
local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 2
MainStroke.Transparency = 0.3
MainStroke.Parent = MainFrame
table.insert(uiElements.frames, MainStroke)

-- =========== РАДУЖНЫЙ ТИТЛ БАР ==========
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 42)
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 16)
TitleCorner.Parent = TitleBar

local TitleGradient = Instance.new("UIGradient")
TitleGradient.Rotation = 45
TitleGradient.Parent = TitleBar
table.insert(uiElements.gradients, TitleGradient)

local TitleText = Instance.new("TextLabel")
TitleText.Text = "🌈 TWKS RAINBOW v9"
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 16
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.BackgroundTransparency = 1
TitleText.Size = UDim2.new(1, -70, 1, 0)
TitleText.Position = UDim2.new(0, 12, 0, 0)
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

-- Кнопки
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 32, 0, 28)
MinimizeBtn.Position = UDim2.new(1, -70, 0.5, -14)
MinimizeBtn.Text = "−"
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 20
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MinimizeBtn.BackgroundTransparency = 0.5
MinimizeBtn.BorderSizePixel = 0
MinimizeBtn.Parent = TitleBar
local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 8)
minCorner.Parent = MinimizeBtn
table.insert(uiElements.buttons, MinimizeBtn)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 28)
CloseBtn.Position = UDim2.new(1, -36, 0.5, -14)
CloseBtn.Text = "✕"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
CloseBtn.BackgroundTransparency = 0.5
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TitleBar
local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = CloseBtn
table.insert(uiElements.buttons, CloseBtn)

-- =========== DRAG ==========
local dragActive = false
local dragStart, frameStart
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragActive = true
        dragStart = input.Position
        frameStart = MainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragActive and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(frameStart.X.Scale, frameStart.X.Offset + delta.X, frameStart.Y.Scale, frameStart.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragActive = false
    end
end)

-- =========== TABS (КОМПАКТ) ==========
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, 0, 0, 38)
TabContainer.Position = UDim2.new(0, 0, 0, 42)
TabContainer.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
TabContainer.BackgroundTransparency = 0.5
TabContainer.BorderSizePixel = 0
TabContainer.Parent = MainFrame

local tabs = {"⚡", "🎮", "👁️", "🌈"}
local tabNames = {"MAIN", "COMBAT", "VISUAL", "RAINBOW"}
local currentTab = "MAIN"
local tabButtons = {}
local tabFrames = {}

for i, tabIcon in ipairs(tabs) do
    local btn = Instance.new("TextButton")
    btn.Text = tabIcon
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 18
    btn.Size = UDim2.new(0.25, -2, 1, -4)
    btn.Position = UDim2.new((i-1) * 0.25, 1, 0, 2)
    btn.BackgroundColor3 = i == 1 and Color3.fromRGB(50, 50, 70) or Color3.fromRGB(30, 30, 45)
    btn.TextColor3 = Color3.fromRGB(220, 220, 220)
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = TabContainer
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn
    table.insert(uiElements.buttons, btn)
    
    local sf = Instance.new("ScrollingFrame")
    sf.Size = UDim2.new(1, -10, 1, -50)
    sf.Position = UDim2.new(0, 5, 0, 85)
    sf.BackgroundTransparency = 1
    sf.CanvasSize = UDim2.new(0, 0, 0, 500)
    sf.ScrollBarThickness = 3
    sf.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 150)
    sf.Visible = i == 1
    sf.Parent = MainFrame
    
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 0, 500)
    content.BackgroundTransparency = 1
    content.Parent = sf
    
    tabButtons[tabNames[i]] = btn
    tabFrames[tabNames[i]] = {sf = sf, content = content}
    
    btn.MouseButton1Click:Connect(function()
        for name, tb in pairs(tabButtons) do
            tb.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
            tb.TextColor3 = Color3.fromRGB(180, 180, 180)
        end
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        for name, sfData in pairs(tabFrames) do
            sfData.sf.Visible = false
        end
        tabFrames[currentTab].sf.Visible = false
        tabFrames[tabNames[i]].sf.Visible = true
        currentTab = tabNames[i]
    end)
end

-- =========== HELPER FUNCTIONS ==========
local function addToggle(parentContent, text, y, defaultValue, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -16, 0, 44)
    frame.Position = UDim2.new(0, 8, 0, y)
    frame.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
    frame.BackgroundTransparency = 0.4
    frame.BorderSizePixel = 0
    frame.Parent = parentContent
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 10)
    frameCorner.Parent = frame
    table.insert(uiElements.frames, frame)
    
    local label = Instance.new("TextLabel")
    label.Text = text
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextColor3 = Color3.fromRGB(220, 220, 230)
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(0.55, 0, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 60, 0, 30)
    btn.Position = UDim2.new(1, -68, 0.5, -15)
    btn.Text = defaultValue and "ON" or "OFF"
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundColor3 = defaultValue and Color3.fromRGB(0, 170, 90) or Color3.fromRGB(55, 55, 68)
    btn.BorderSizePixel = 0
    btn.Parent = frame
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn
    table.insert(uiElements.buttons, btn)
    
    local val = defaultValue
    btn.MouseButton1Click:Connect(function()
        val = not val
        btn.Text = val and "ON" or "OFF"
        if callback then callback(val) end
    end)
    if callback and defaultValue then task.spawn(function() callback(defaultValue) end) end
    return btn
end

local function addSlider(parentContent, text, y, minVal, maxVal, defaultVal, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -16, 0, 68)
    frame.Position = UDim2.new(0, 8, 0, y)
    frame.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
    frame.BackgroundTransparency = 0.4
    frame.BorderSizePixel = 0
    frame.Parent = parentContent
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 10)
    frameCorner.Parent = frame
    table.insert(uiElements.frames, frame)
    
    local label = Instance.new("TextLabel")
    label.Text = text .. " [" .. tostring(defaultVal) .. "]"
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextColor3 = Color3.fromRGB(200, 200, 210)
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, -16, 0, 24)
    label.Position = UDim2.new(0, 8, 0, 6)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -24, 0, 5)
    bar.Position = UDim2.new(0, 12, 0, 44)
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
    table.insert(uiElements.sliders, fill)
    
    local valueBtn = Instance.new("TextButton")
    valueBtn.Size = UDim2.new(0, 42, 0, 22)
    valueBtn.Position = UDim2.new(ratio, -21, 0.5, -11)
    valueBtn.Text = tostring(defaultVal)
    valueBtn.Font = Enum.Font.GothamBold
    valueBtn.TextSize = 11
    valueBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    valueBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
    valueBtn.BorderSizePixel = 0
    valueBtn.Parent = frame
    local valCorner = Instance.new("UICorner")
    valCorner.CornerRadius = UDim.new(0, 6)
    valCorner.Parent = valueBtn
    table.insert(uiElements.buttons, valueBtn)
    
    local currentVal = defaultVal
    local dragging = false
    
    local function update(input)
        local barPos = bar.AbsolutePosition
        local barSize = bar.AbsoluteSize
        if not barPos or not barSize or barSize.X == 0 then return end
        local percent = math.clamp((input.Position.X - barPos.X) / barSize.X, 0, 1)
        local val = math.floor((minVal + (maxVal - minVal) * percent) * 10 + 0.5) / 10
        fill.Size = UDim2.new(percent, 0, 1, 0)
        valueBtn.Position = UDim2.new(percent, -21, 0.5, -11)
        valueBtn.Text = tostring(val)
        label.Text = text .. " [" .. tostring(val) .. "]"
        currentVal = val
        if callback then callback(val) end
    end
    
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input)
        end
    end)
    valueBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    if callback then callback(defaultVal) end
    return {setValue = function(v) 
        local r = math.clamp((v - minVal) / (maxVal - minVal), 0, 1)
        fill.Size = UDim2.new(r, 0, 1, 0)
        valueBtn.Position = UDim2.new(r, -21, 0.5, -11)
        valueBtn.Text = tostring(v)
        label.Text = text .. " [" .. tostring(v) .. "]"
        if callback then callback(v) end
    end}
end

-- =========== POPULATE TABS ==========
local mainContent = tabFrames["MAIN"].content
addToggle(mainContent, "🚶 Auto Walk", 8, state.autoWalk, function(val)
    state.autoWalk = val
    save("AutoWalk", val)
    updateAutoWalk()
end)
addSlider(mainContent, "🏃 Walk Speed", 62, 8, 100, settings.walkSpeed, function(val)
    settings.walkSpeed = val
    save("WalkSpeed", val)
    if not state.speedHack then
        local char = player.Character
        if char then local hum = char:FindFirstChild("Humanoid") if hum then hum.WalkSpeed = val end end
    end
end)
addSlider(mainContent, "🦘 Jump Power", 140, 10, 200, settings.jumpPower, function(val)
    settings.jumpPower = val
    save("JumpPower", val)
    if not state.infiniteJump then
        local char = player.Character
        if char then local hum = char:FindFirstChild("Humanoid") if hum then hum.JumpPower = val end end
    end
end)
addSlider(mainContent, "👁️ FOV", 218, 30, 120, settings.fov, function(val)
    settings.fov = val
    save("FOV", val)
    if camera then camera.FieldOfView = val end
end)

local combatContent = tabFrames["COMBAT"].content
addToggle(combatContent, "⚡ Speed Hack", 8, state.speedHack, function(val)
    state.speedHack = val
    save("SpeedHack", val)
    applySpeed(val)
end)
addSlider(combatContent, "📈 Speed Value", 62, 20, 250, state.speedValue, function(val)
    state.speedValue = val
    save("SpeedValue", val)
    if state.speedHack then applySpeed(true) end
end)
addToggle(combatContent, "🌀 Noclip", 140, state.noclip, function(val)
    state.noclip = val
    save("Noclip", val)
    toggleNoclip(val)
end)
addToggle(combatContent, "🕊️ Fly", 194, state.fly, function(val)
    state.fly = val
    save("Fly", val)
    toggleFly(val)
end)
addToggle(combatContent, "⭐ Infinite Jump", 248, state.infiniteJump, function(val)
    state.infiniteJump = val
    save("InfiniteJump", val)
    toggleInfiniteJump(val)
end)
addSlider(combatContent, "🦘 Jump Value", 302, 30, 200, state.jumpValue, function(val)
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

local visualContent = tabFrames["VISUAL"].content
addToggle(visualContent, "👁️ ESP", 8, state.esp, function(val)
    state.esp = val
    save("ESP", val)
    updateESP()
end)
addSlider(visualContent, "📏 ESP Size", 62, 10, 30, state.espSize, function(val)
    state.espSize = val
    save("ESPSize", val)
    updateESP()
end)
addSlider(visualContent, "🔴 Red", 140, 0, 255, settings.espColorR, function(val)
    settings.espColorR = val
    save("ESPColorR", val)
    state.espColor = Color3.fromRGB(val, settings.espColorG, settings.espColorB)
    updateESP()
end)
addSlider(visualContent, "🟢 Green", 218, 0, 255, settings.espColorG, function(val)
    settings.espColorG = val
    save("ESPColorG", val)
    state.espColor = Color3.fromRGB(settings.espColorR, val, settings.espColorB)
    updateESP()
end)
addSlider(visualContent, "🔵 Blue", 296, 0, 255, settings.espColorB, function(val)
    settings.espColorB = val
    save("ESPColorB", val)
    state.espColor = Color3.fromRGB(settings.espColorR, settings.espColorG, val)
    updateESP()
end)

local rainbowContent = tabFrames["RAINBOW"].content
addToggle(rainbowContent, "🌈 RAINBOW MODE", 8, state.rainbow, function(val)
    state.rainbow = val
    rainbowEnabled = val
    save("Rainbow", val)
end)

local speedLabel = Instance.new("TextLabel")
speedLabel.Text = "🌀 Скорость радуги: " .. string.format("%.1f", 1/rainbowSpeed) .. "x"
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 12
speedLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
speedLabel.BackgroundTransparency = 1
speedLabel.Size = UDim2.new(1, -16, 0, 25)
speedLabel.Position = UDim2.new(0, 8, 0, 62)
speedLabel.Parent = rainbowContent

local speedSlider = addSlider(rainbowContent, "🌀 Speed", 90, 0.2, 2, 1/rainbowSpeed, function(val)
    rainbowSpeed = 1 / val
    speedLabel.Text = "🌀 Скорость радуги: " .. string.format("%.1f", val) .. "x"
end)

-- =========== RAINBOW UPDATE LOOP ==========
RunService.RenderStepped:Connect(function()
    if not rainbowEnabled then return end
    
    local rainbowColor = getRainbowColor()
    local rainbowGrad = getRainbowGradient()
    
    -- Обновляем градиенты
    for _, grad in pairs(uiElements.gradients) do
        if grad and grad.Parent then
            grad.Color = rainbowGrad
        end
    end
    
    -- Обновляем обводку
    if MainStroke then
        MainStroke.Color = rainbowColor
    end
    
    -- Обновляем ползунки
    for _, sliderFill in pairs(uiElements.sliders) do
        if sliderFill and sliderFill.Parent then
            sliderFill.BackgroundColor3 = rainbowColor
        end
    end
    
    -- Обновляем активную вкладку
    if tabButtons[currentTab] then
        tabButtons[currentTab].BackgroundColor3 = rainbowColor
    end
end)

-- =========== BUTTON ACTIONS ==========
local minimized = false
local originalHeight = MENU_HEIGHT

MinimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        MainFrame:TweenSize(UDim2.new(0, MENU_WIDTH, 0, 42), "Out", "Quad", 0.2)
    else
        MainFrame:TweenSize(UDim2.new(0, MENU_WIDTH, 0, originalHeight), "Out", "Quad", 0.2)
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    TweenService:Create(MainFrame, TweenInfo.new(0.15), {Size = UDim2.new(0, 0, 0, 0)}):Play()
    task.wait(0.15)
    ScreenGui:Destroy()
end)

-- =========== INITIALIZE ==========
updateAutoWalk()
if state.noclip then toggleNoclip(true) end
if state.fly then toggleFly(true) end
if state.infiniteJump then toggleInfiniteJump(true) end
if state.speedHack then applySpeed(true) end
if state.esp then updateESP() end

-- =========== RESPAWN ==========
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
    for _, obj in pairs(espObjects) do 
        pcall(function() 
            if obj.bill then obj.bill:Destroy() end
        end)
    end
    espObjects = {}
end)

print("═══════════════════════════════════════════")
print("🌈 TWKS RAINBOW v9 - МОБИЛЬНАЯ ВЕРСИЯ")
print("📌 Размер меню: 340x440 (компактный)")
print("📌 RightAlt или Volume± - скрыть меню")
print("🌈 Включите RAINBOW MODE в 4-й вкладке")
print("✅ Noclip: защита от падения под карту")
print("═══════════════════════════════════════════")
