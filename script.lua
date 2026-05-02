--[[
    TWKS FRUIT v10 - BLOX FRUITS STYLE MENU
    Mobile optimized | 360x500 | Full categories
    NO functions stolen, only design inspiration
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
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
    -- Combat
    autoFarm = load("AutoFarm", false),
    autoSkillZ = load("AutoSkillZ", false),
    autoSkillX = load("AutoSkillX", false),
    autoSkillC = load("AutoSkillC", false),
    autoSkillV = load("AutoSkillV", false),
    autoSkillF = load("AutoSkillF", false),
    autoChest = load("AutoChest", false),
    autoCollect = load("AutoCollect", false),
    
    -- Movement
    speedHack = load("SpeedHack", false),
    noclip = load("Noclip", false),
    fly = load("Fly", false),
    infiniteJump = load("InfiniteJump", false),
    speedValue = load("SpeedValue", 50),
    jumpValue = load("JumpValue", 80),
    
    -- Visual
    esp = load("ESP", false),
    espColorR = load("ESPColorR", 255),
    espColorG = load("ESPColorG", 100),
    espColorB = load("ESPColorB", 0),
    
    -- Teleport
    teleportToIsland = load("TeleportIsland", ""),
    
    -- Misc
    autoWalk = load("AutoWalk", false),
    fov = load("FOV", 70)
}

-- =========== STATE ==========
local state = {}
for k, v in pairs(settings) do state[k] = v end

-- =========== VARIABLES ==========
local character, humanoid, camera
local flyVel, flyGyro, flyConn, noclipConn, autoWalkConn, infJumpConn, farmConn
local keysPressed = {}
local espObjects = {}
local menuVisible = true
local lastESPUpdate = 0

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
                else humanoid.WalkSpeed = 16 end
                if state.infiniteJump then humanoid.JumpPower = state.jumpValue
                else humanoid.JumpPower = 50 end
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

-- =========== COMBAT FUNCTIONS ==========
local function getNearestMob()
    local nearest = nil
    local minDist = 50
    local char = player.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj ~= char then
            local objHrp = obj:FindFirstChild("HumanoidRootPart")
            if objHrp then
                local dist = (objHrp.Position - hrp.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    nearest = obj
                end
            end
        end
    end
    return nearest
end

local function useSkill(skillKey)
    pcall(function()
        local char = player.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        -- Поиск навыка в панели инструментов
        local backpack = player:FindFirstChild("Backpack")
        local tool = nil
        
        if skillKey == "Z" then tool = char:FindFirstChildWhichIsA("Tool") or (backpack and backpack:FindFirstChildWhichIsA("Tool"))
        elseif skillKey == "X" then tool = char:FindFirstChildWhichIsA("Tool") or (backpack and backpack:FindFirstChildWhichIsA("Tool"))
        elseif skillKey == "C" then tool = char:FindFirstChildWhichIsA("Tool") or (backpack and backpack:FindFirstChildWhichIsA("Tool"))
        elseif skillKey == "V" then tool = char:FindFirstChildWhichIsA("Tool") or (backpack and backpack:FindFirstChildWhichIsA("Tool"))
        elseif skillKey == "F" then tool = char:FindFirstChildWhichIsA("Tool") or (backpack and backpack:FindFirstChildWhichIsA("Tool"))
        end
        
        if tool then
            local skill = tool:FindFirstChild(skillKey)
            if skill and skill:IsA("RemoteEvent") then
                skill:FireServer()
            end
        end
    end)
end

local function autoFarmLoop()
    if not state.autoFarm then return end
    
    local mob = getNearestMob()
    if mob then
        local hrp = mob:FindFirstChild("HumanoidRootPart")
        local char = player.Character
        if char and hrp then
            local charHrp = char:FindFirstChild("HumanoidRootPart")
            if charHrp then
                -- Move to mob
                charHrp.CFrame = CFrame.new(charHrp.Position, hrp.Position)
                
                -- Auto attack
                if state.autoSkillZ then useSkill("Z") end
                if state.autoSkillX then useSkill("X") end
                if state.autoSkillC then useSkill("C") end
                if state.autoSkillV then useSkill("V") end
                if state.autoSkillF then useSkill("F") end
                
                -- Auto click
                local hum = mob:FindFirstChild("Humanoid")
                if hum and hum.Health > 0 then
                    local tool = char:FindFirstChildWhichIsA("Tool")
                    if tool then
                        pcall(function() tool:Activate() end)
                    end
                end
            end
        end
    end
end

local function chestFarmLoop()
    if not state.autoChest then return end
    
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    for _, chest in pairs(Workspace:GetDescendants()) do
        if chest:IsA("Model") and (chest.Name:lower():find("chest") or chest.Name:lower():find("crate")) then
            local chestPos = chest:FindFirstChild("HumanoidRootPart") or chest:FindFirstChild("Head") or chest:FindFirstChild("Part")
            if chestPos then
                local dist = (chestPos.Position - hrp.Position).Magnitude
                if dist < 20 then
                    -- Симуляция удара по сундуку
                    local tool = char:FindFirstChildWhichIsA("Tool")
                    if tool then
                        pcall(function() tool:Activate() end)
                    end
                elseif dist < 100 then
                    hrp.CFrame = CFrame.new(hrp.Position, chestPos.Position)
                end
            end
        end
    end
end

-- =========== FARM LOOP ==========
RunService.Heartbeat:Connect(function()
    if state.autoFarm then autoFarmLoop() end
    if state.autoChest then chestFarmLoop() end
end)

-- =========== MOVEMENT ==========
local function applySpeed(state)
    pcall(function()
        local char = player.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then hum.WalkSpeed = state and state.speedValue or 16 end
        end
    end)
end

local function toggleNoclip(state)
    if noclipConn then noclipConn:Disconnect() noclipConn = nil end
    if state then
        noclipConn = RunService.Stepped:Connect(function()
            if not state.noclip then return end
            local char = player.Character
            if not char then return end
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    pcall(function() part.CanCollide = false end)
                end
            end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp and hrp.Position.Y < -10 then
                hrp.Position = Vector3.new(hrp.Position.X, 5, hrp.Position.Z)
            end
        end)
    end
end

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

-- =========== ESP ==========
local function updateESP()
    if not state.esp then
        for _, obj in pairs(espObjects) do pcall(function() obj:Destroy() end) end
        espObjects = {}
        return
    end
    
    local espColor = Color3.fromRGB(state.espColorR, state.espColorG, state.espColorB)
    
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player then
            local char = plr.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                if not espObjects[plr.UserId] then
                    local bill = Instance.new("BillboardGui")
                    bill.Size = UDim2.new(0, 180, 0, 40)
                    bill.StudsOffset = Vector3.new(0, 2.5, 0)
                    bill.AlwaysOnTop = true
                    bill.Parent = root
                    
                    local nameLabel = Instance.new("TextLabel")
                    nameLabel.Font = Enum.Font.GothamBold
                    nameLabel.TextSize = 14
                    nameLabel.TextColor3 = espColor
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
                    data.label.TextColor3 = espColor
                end
            elseif espObjects[plr.UserId] then
                pcall(function() 
                    if espObjects[plr.UserId].bill then espObjects[plr.UserId].bill:Destroy() end
                end)
                espObjects[plr.UserId] = nil
            end
        end
    end
    
    -- ESP for mobs/chests
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj ~= character then
            local root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Head")
            if root and not espObjects[obj.Name .. tostring(obj)] then
                local bill = Instance.new("BillboardGui")
                bill.Size = UDim2.new(0, 150, 0, 35)
                bill.StudsOffset = Vector3.new(0, 2, 0)
                bill.AlwaysOnTop = true
                bill.Parent = root
                
                local nameLabel = Instance.new("TextLabel")
                nameLabel.Font = Enum.Font.Gotham
                nameLabel.TextSize = 12
                nameLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
                nameLabel.BackgroundTransparency = 1
                nameLabel.Size = UDim2.new(1, 0, 1, 0)
                nameLabel.Text = "🗡️ MOB"
                nameLabel.Parent = bill
                
                espObjects[obj.Name .. tostring(obj)] = bill
            end
        elseif obj:IsA("Model") and (obj.Name:lower():find("chest") or obj.Name:lower():find("crate")) then
            local root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Part")
            if root and not espObjects["chest_" .. tostring(obj)] then
                local bill = Instance.new("BillboardGui")
                bill.Size = UDim2.new(0, 120, 0, 35)
                bill.StudsOffset = Vector3.new(0, 1, 0)
                bill.AlwaysOnTop = true
                bill.Parent = root
                
                local nameLabel = Instance.new("TextLabel")
                nameLabel.Font = Enum.Font.Gotham
                nameLabel.TextSize = 12
                nameLabel.TextColor3 = Color3.fromRGB(100, 255, 200)
                nameLabel.BackgroundTransparency = 1
                nameLabel.Size = UDim2.new(1, 0, 1, 0)
                nameLabel.Text = "📦 CHEST"
                nameLabel.Parent = bill
                
                espObjects["chest_" .. tostring(obj)] = bill
            end
        end
    end
end

RunService.Heartbeat:Connect(function(dt)
    lastESPUpdate = lastESPUpdate + dt
    if lastESPUpdate >= 0.3 then
        lastESPUpdate = 0
        updateESP()
    end
end)

-- =========== TELEPORT ==========
local islands = {
    "Marine Start",
    "Jungle",
    "Desert",
    "Snow",
    "Volcano",
    "Sky Islands",
    "Great Tree"
}

-- =========== CREATE GUI ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TWKS_Fruit"
ScreenGui.ResetOnSpawn = false
ScreenGui.Enabled = true

local guiParent = nil
pcall(function() guiParent = player:WaitForChild("PlayerGui", 2) end)
if not guiParent then pcall(function() guiParent = game:GetService("CoreGui") end) end
if not guiParent then pcall(function() guiParent = game:GetService("StarterGui") end) end
if guiParent then pcall(function() ScreenGui.Parent = guiParent end) end

-- =========== MAIN MENU - BLOX FRUITS STYLE ==========
local MENU_WIDTH = 360
local MENU_HEIGHT = 500

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, MENU_WIDTH, 0, MENU_HEIGHT)
MainFrame.Position = UDim2.new(0.5, -MENU_WIDTH/2, 0.5, -MENU_HEIGHT/2)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
MainFrame.BackgroundTransparency = 0.05
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(255, 170, 0)
MainStroke.Thickness = 1.5
MainStroke.Transparency = 0.4
MainStroke.Parent = MainFrame

-- =========== HEADER ==========
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 52)
Header.BackgroundColor3 = Color3.fromRGB(30, 25, 40)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 12)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.Text = "⚡ TWKS FRUIT MENU ⚡"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextColor3 = Color3.fromRGB(255, 170, 0)
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, -80, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local SubTitle = Instance.new("TextLabel")
SubTitle.Text = "Auto Farm | Teleport | ESP"
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextSize = 10
SubTitle.TextColor3 = Color3.fromRGB(180, 180, 200)
SubTitle.BackgroundTransparency = 1
SubTitle.Size = UDim2.new(1, -80, 0, 16)
SubTitle.Position = UDim2.new(0, 12, 0, 30)
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.Parent = Header

-- Кнопки управления
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 32, 0, 28)
MinimizeBtn.Position = UDim2.new(1, -70, 0.5, -14)
MinimizeBtn.Text = "−"
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 20
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 35, 50)
MinimizeBtn.BorderSizePixel = 0
MinimizeBtn.Parent = Header
local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 8)
minCorner.Parent = MinimizeBtn

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 28)
CloseBtn.Position = UDim2.new(1, -36, 0.5, -14)
CloseBtn.Text = "✕"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = Header
local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = CloseBtn

-- =========== CATEGORY TABS (БЛОКИ КАК НА КАРТИНКЕ) ==========
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, 0, 0, 44)
TabContainer.Position = UDim2.new(0, 0, 0, 52)
TabContainer.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
TabContainer.BackgroundTransparency = 0.8
TabContainer.BorderSizePixel = 0
TabContainer.Parent = MainFrame

-- Категории в стиле "General, Auto Main Farm, Settings Mastery"
local categories = {
    {name = "⚔️ COMBAT", icon = "⚔️"},
    {name = "🏃 MOVEMENT", icon = "🏃"},
    {name = "👁️ VISUAL", icon = "👁️"},
    {name = "✨ MISC", icon = "✨"}
}

local currentCategory = "⚔️ COMBAT"
local catButtons = {}
local catFrames = {}

for i, cat in ipairs(categories) do
    local btn = Instance.new("TextButton")
    btn.Text = cat.icon .. " " .. cat.name
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.Size = UDim2.new(0.25, -2, 1, -4)
    btn.Position = UDim2.new((i-1) * 0.25, 1, 0, 2)
    btn.BackgroundColor3 = i == 1 and Color3.fromRGB(255, 170, 0) or Color3.fromRGB(30, 30, 45)
    btn.TextColor3 = i == 1 and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(200, 200, 200)
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = TabContainer
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn
    
    local sf = Instance.new("ScrollingFrame")
    sf.Size = UDim2.new(1, -10, 1, -100)
    sf.Position = UDim2.new(0, 5, 0, 100)
    sf.BackgroundTransparency = 1
    sf.CanvasSize = UDim2.new(0, 0, 0, 600)
    sf.ScrollBarThickness = 3
    sf.ScrollBarImageColor3 = Color3.fromRGB(255, 170, 0)
    sf.Visible = i == 1
    sf.Parent = MainFrame
    
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 0, 600)
    content.BackgroundTransparency = 1
    content.Parent = sf
    
    catButtons[cat.name] = btn
    catFrames[cat.name] = {sf = sf, content = content}
    
    btn.MouseButton1Click:Connect(function()
        for name, tb in pairs(catButtons) do
            tb.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
            tb.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
        btn.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
        btn.TextColor3 = Color3.fromRGB(0, 0, 0)
        for name, sfData in pairs(catFrames) do
            sfData.sf.Visible = false
        end
        catFrames[cat.name].sf.Visible = true
        currentCategory = cat.name
    end)
end

-- =========== UI HELPER FUNCTIONS ==========
local function addSectionHeader(parent, title, y)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -16, 0, 32)
    frame.Position = UDim2.new(0, 8, 0, y)
    frame.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
    frame.BackgroundTransparency = 0.85
    frame.BorderSizePixel = 0
    frame.Parent = parent
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 6)
    frameCorner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Text = "▸ " .. title .. " ◂"
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.TextColor3 = Color3.fromRGB(255, 170, 0)
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 1, 0)
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.Parent = frame
    
    return frame
end

local function addToggle(parent, text, y, defaultValue, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -16, 0, 38)
    frame.Position = UDim2.new(0, 8, 0, y)
    frame.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
    frame.BackgroundTransparency = 0.4
    frame.BorderSizePixel = 0
    frame.Parent = parent
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 8)
    frameCorner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Text = text
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextColor3 = Color3.fromRGB(220, 220, 230)
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 52, 0, 26)
    btn.Position = UDim2.new(1, -60, 0.5, -13)
    btn.Text = defaultValue and "ON" or "OFF"
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundColor3 = defaultValue and Color3.fromRGB(0, 170, 90) or Color3.fromRGB(55, 55, 68)
    btn.BorderSizePixel = 0
    btn.Parent = frame
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
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

local function addSlider(parent, text, y, minVal, maxVal, defaultVal, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -16, 0, 62)
    frame.Position = UDim2.new(0, 8, 0, y)
    frame.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
    frame.BackgroundTransparency = 0.4
    frame.BorderSizePixel = 0
    frame.Parent = parent
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 8)
    frameCorner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Text = text .. " [" .. tostring(defaultVal) .. "]"
    label.Font = Enum.Font.Gotham
    label.TextSize = 11
    label.TextColor3 = Color3.fromRGB(200, 200, 210)
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, -16, 0, 22)
    label.Position = UDim2.new(0, 8, 0, 6)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -24, 0, 4)
    bar.Position = UDim2.new(0, 12, 0, 40)
    bar.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    bar.BorderSizePixel = 0
    bar.Parent = frame
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(1, 0)
    barCorner.Parent = bar
    
    local ratio = (defaultVal - minVal) / (maxVal - minVal)
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(ratio, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
    fill.BorderSizePixel = 0
    fill.Parent = bar
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill
    
    local currentVal = defaultVal
    local dragging = false
    
    local function update(input)
        local barPos = bar.AbsolutePosition
        local barSize = bar.AbsoluteSize
        if not barPos or not barSize or barSize.X == 0 then return end
        local percent = math.clamp((input.Position.X - barPos.X) / barSize.X, 0, 1)
        local val = math.floor((minVal + (maxVal - minVal) * percent) * 10 + 0.5) / 10
        fill.Size = UDim2.new(percent, 0, 1, 0)
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
        label.Text = text .. " [" .. tostring(v) .. "]"
        if callback then callback(v) end
    end}
end

local function addDropdown(parent, text, y, options, defaultVal, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -16, 0, 44)
    frame.Position = UDim2.new(0, 8, 0, y)
    frame.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
    frame.BackgroundTransparency = 0.4
    frame.BorderSizePixel = 0
    frame.Parent = parent
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 8)
    frameCorner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Text = text
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextColor3 = Color3.fromRGB(220, 220, 230)
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(0.35, 0, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local dropdown = Instance.new("TextButton")
    dropdown.Size = UDim2.new(0.55, -10, 0, 30)
    dropdown.Position = UDim2.new(0.42, 0, 0.5, -15)
    dropdown.Text = defaultVal or options[1]
    dropdown.Font = Enum.Font.Gotham
    dropdown.TextSize = 11
    dropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
    dropdown.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    dropdown.BorderSizePixel = 0
    dropdown.Parent = frame
    local dropCorner = Instance.new("UICorner")
    dropCorner.CornerRadius = UDim.new(0, 6)
    dropCorner.Parent = dropdown
    
    local selected = defaultVal or options[1]
    dropdown.MouseButton1Click:Connect(function()
        -- Просто цикл по опциям при нажатии
        local idx = 1
        for i, opt in ipairs(options) do
            if opt == selected then idx = i end
        end
        local nextIdx = idx % #options + 1
        selected = options[nextIdx]
        dropdown.Text = selected
        if callback then callback(selected) end
    end)
    
    return dropdown
end

-- =========== COMBAT CATEGORY ==========
local combatContent = catFrames["⚔️ COMBAT"].content
local y = 5

addSectionHeader(combatContent, "AUTO FARM", y)
y = y + 40
addToggle(combatContent, "Auto Farm Level", y, state.autoFarm, function(val)
    state.autoFarm = val
    save("AutoFarm", val)
end)
y = y + 46
addSectionHeader(combatContent, "AUTO SKILL", y)
y = y + 40
addToggle(combatContent, "Auto Use Skill Z", y, state.autoSkillZ, function(val)
    state.autoSkillZ = val
    save("AutoSkillZ", val)
end)
y = y + 46
addToggle(combatContent, "Auto Use Skill X", y, state.autoSkillX, function(val)
    state.autoSkillX = val
    save("AutoSkillX", val)
end)
y = y + 46
addToggle(combatContent, "Auto Use Skill C", y, state.autoSkillC, function(val)
    state.autoSkillC = val
    save("AutoSkillC", val)
end)
y = y + 46
addToggle(combatContent, "Auto Use Skill V", y, state.autoSkillV, function(val)
    state.autoSkillV = val
    save("AutoSkillV", val)
end)
y = y + 46
addToggle(combatContent, "Auto Use Skill F", y, state.autoSkillF, function(val)
    state.autoSkillF = val
    save("AutoSkillF", val)
end)
y = y + 50
addSectionHeader(combatContent, "LOOT & CHEST", y)
y = y + 40
addToggle(combatContent, "Auto Chest Farm", y, state.autoChest, function(val)
    state.autoChest = val
    save("AutoChest", val)
end)
y = y + 46
addToggle(combatContent, "Auto Collect Berry", y, state.autoCollect, function(val)
    state.autoCollect = val
    save("AutoCollect", val)
end)

-- =========== MOVEMENT CATEGORY ==========
local movementContent = catFrames["🏃 MOVEMENT"].content
y = 5

addSectionHeader(movementContent, "MOVEMENT HACKS", y)
y = y + 40
addToggle(movementContent, "Speed Hack", y, state.speedHack, function(val)
    state.speedHack = val
    save("SpeedHack", val)
    applySpeed(val)
end)
y = y + 46
addSlider(movementContent, "Speed Value", y, 20, 250, state.speedValue, function(val)
    state.speedValue = val
    save("SpeedValue", val)
    if state.speedHack then applySpeed(true) end
end)
y = y + 70
addToggle(movementContent, "Noclip (No Fall)", y, state.noclip, function(val)
    state.noclip = val
    save("Noclip", val)
    toggleNoclip(val)
end)
y = y + 46
addToggle(movementContent, "Fly Mode (WASD+E/Q)", y, state.fly, function(val)
    state.fly = val
    save("Fly", val)
    toggleFly(val)
end)
y = y + 46
addToggle(movementContent, "Infinite Jump", y, state.infiniteJump, function(val)
    state.infiniteJump = val
    save("InfiniteJump", val)
    toggleInfiniteJump(val)
end)
y = y + 46
addSlider(movementContent, "Jump Power", y, 30, 200, state.jumpValue, function(val)
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
y = y + 70
addSectionHeader(movementContent, "AUTO WALK", y)
y = y + 40
addToggle(movementContent, "Auto Walk", y, state.autoWalk, function(val)
    state.autoWalk = val
    save("AutoWalk", val)
    updateAutoWalk()
end)

-- =========== VISUAL CATEGORY ==========
local visualContent = catFrames["👁️ VISUAL"].content
y = 5

addSectionHeader(visualContent, "PLAYER ESP", y)
y = y + 40
addToggle(visualContent, "ESP Players & Mobs", y, state.esp, function(val)
    state.esp = val
    save("ESP", val)
    updateESP()
end)
y = y + 50
addSlider(visualContent, "🔴 ESP Red", y, 0, 255, state.espColorR, function(val)
    state.espColorR = val
    save("ESPColorR", val)
    updateESP()
end)
y = y + 70
addSlider(visualContent, "🟢 ESP Green", y, 0, 255, state.espColorG, function(val)
    state.espColorG = val
    save("ESPColorG", val)
    updateESP()
end)
y = y + 70
addSlider(visualContent, "🔵 ESP Blue", y, 0, 255, state.espColorB, function(val)
    state.espColorB = val
    save("ESPColorB", val)
    updateESP()
end)
y = y + 70
addSectionHeader(visualContent, "CAMERA", y)
y = y + 40
addSlider(visualContent, "Field of View (FOV)", y, 30, 120, settings.fov, function(val)
    settings.fov = val
    save("FOV", val)
    if camera then camera.FieldOfView = val end
end)

-- =========== MISC CATEGORY ==========
local miscContent = catFrames["✨ MISC"].content
y = 5

addSectionHeader(miscContent, "TELEPORT", y)
y = y + 40
addDropdown(miscContent, "Teleport To:", y, islands, settings.teleportToIsland, function(val)
    settings.teleportToIsland = val
    save("TeleportIsland", val)
    -- Teleport logic
    pcall(function()
        local char = player.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                -- Поиск позиции острова (заглушка, нужно подставить реальные координаты)
                local islandPositions = {
                    ["Marine Start"] = Vector3.new(-100, 10, 0),
                    ["Jungle"] = Vector3.new(500, 20, 300),
                    ["Desert"] = Vector3.new(800, 15, -200)
                }
                local pos = islandPositions[val]
                if pos then
                    hrp.CFrame = CFrame.new(pos)
                end
            end
        end
    end)
end)
y = y + 52
addSectionHeader(miscContent, "PVP & UTILS", y)
y = y + 40
-- Кнопка для сброса камеры
local resetCamBtn = Instance.new("TextButton")
resetCamBtn.Size = UDim2.new(1, -16, 0, 38)
resetCamBtn.Position = UDim2.new(0, 8, 0, y)
resetCamBtn.Text = "📷 Reset Camera"
resetCamBtn.Font = Enum.Font.GothamBold
resetCamBtn.TextSize = 12
resetCamBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
resetCamBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
resetCamBtn.BorderSizePixel = 0
resetCamBtn.Parent = miscContent
local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 8)
btnCorner.Parent = resetCamBtn
resetCamBtn.MouseButton1Click:Connect(function()
    pcall(function()
        if camera then
            camera.FieldOfView = 70
            settings.fov = 70
            save("FOV", 70)
        end
    end)
end)

y = y + 46
local resetBtn = Instance.new("TextButton")
resetBtn.Size = UDim2.new(1, -16, 0, 38)
resetBtn.Position = UDim2.new(0, 8, 0, y)
resetBtn.Text = "🔄 Reset All Settings"
resetBtn.Font = Enum.Font.GothamBold
resetBtn.TextSize = 12
resetBtn.TextColor3 = Color3.fromRGB(255, 200, 200)
resetBtn.BackgroundColor3 = Color3.fromRGB(80, 40, 40)
resetBtn.BorderSizePixel = 0
resetBtn.Parent = miscContent
local resetCorner = Instance.new("UICorner")
resetCorner.CornerRadius = UDim.new(0, 8)
resetCorner.Parent = resetBtn
resetBtn.MouseButton1Click:Connect(function()
    -- Reset all to defaults
    state.autoFarm = false save("AutoFarm", false)
    state.autoSkillZ = false save("AutoSkillZ", false)
    state.autoSkillX = false save("AutoSkillX", false)
    state.autoSkillC = false save("AutoSkillC", false)
    state.autoSkillV = false save("AutoSkillV", false)
    state.autoSkillF = false save("AutoSkillF", false)
    state.autoChest = false save("AutoChest", false)
    state.speedHack = false save("SpeedHack", false)
    state.noclip = false save("Noclip", false)
    state.fly = false save("Fly", false)
    state.infiniteJump = false save("InfiniteJump", false)
    state.esp = false save("ESP", false)
    state.autoWalk = false save("AutoWalk", false)
    settings.fov = 70 save("FOV", 70)
    if camera then camera.FieldOfView = 70 end
    
    -- Refresh UI would require restart, but at least state is reset
    print("Settings reset! Please re-run script to refresh UI")
end)

-- =========== DRAG ==========
local dragActive = false
local dragStart, frameStart
Header.InputBegan:Connect(function(input)
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

-- =========== MINIMIZE / CLOSE ==========
local minimized = false
local originalHeight = MENU_HEIGHT

MinimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        MainFrame:TweenSize(UDim2.new(0, MENU_WIDTH, 0, 52), "Out", "Quad", 0.2)
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
        humanoid.WalkSpeed = state.speedHack and state.speedValue or 16
        humanoid.JumpPower = state.infiniteJump and state.jumpValue or 50
    end
    if camera then camera.FieldOfView = settings.fov end
    if state.fly then toggleFly(true) end
    if state.noclip then toggleNoclip(true) end
    if state.infiniteJump then toggleInfiniteJump(true) end
    for _, obj in pairs(espObjects) do 
        pcall(function() 
            if obj and obj.bill then obj.bill:Destroy() elseif obj then obj:Destroy() end
        end)
    end
    espObjects = {}
end)

print("═══════════════════════════════════════════")
print("🍎 TWKS FRUIT v10 - BLOX FRUITS STYLE")
print("📌 Размер: 360x500 | Оранжевая тема")
print("📌 4 категории: COMBAT | MOVEMENT | VISUAL | MISC")
print("✅ Auto Farm | Auto Skill | ESP | Teleport")
print("═══════════════════════════════════════════")
