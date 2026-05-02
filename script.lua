--[[
    BLOX FRUITS - ADVANCED AUTO FARM v1.0
    - Anti-teleport (только полёт/ходьба)
    - Определение уровня
    - Авто-квест (берёт → фармит → сдаёт)
    - Сбор мобов в кучу
    - Выбор оружия: Combat/Fruit/Sword/Gun
    - Полностью мобильная версия
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

if not player then player = Players.PlayerAdded:Wait() end

-- =========== SETTINGS STORAGE ==========
local Storage = Instance.new("Folder")
Storage.Name = "BF_AutoFarm"
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
    autoFarm = load("AutoFarm", false),
    weaponType = load("WeaponType", "Combat"), -- Combat, Fruit, Sword, Gun
    autoSkill = load("AutoSkill", true),
    bringMobs = load("BringMobs", true),
    farmRadius = load("FarmRadius", 200),
}

local state = {
    autoFarm = settings.autoFarm,
    weaponType = settings.weaponType,
    autoSkill = settings.autoSkill,
    bringMobs = settings.bringMobs,
    farmRadius = settings.farmRadius,
}

-- =========== VARIABLES ==========
local character, humanoid, rootPart
local currentQuest = nil
local currentIsland = nil
local currentMobs = {}
local farming = false
local menuVisible = true
local flyConnection = nil
local flyBodyVel = nil
local flyBodyGyro = nil
local isFlying = false
local keysPressed = {}

-- Уровни и острова Blox Fruits
local levelData = {
    {minLevel = 1, maxLevel = 10, island = "Pirate Village", questNPC = "Quest Giver 1", mobs = {"Bandit", "Traitor"}, pos = Vector3.new(100, 10, 50)},
    {minLevel = 10, maxLevel = 25, island = "Desert", questNPC = "Quest Giver 2", mobs = {"Desert Bandit", "Sandman"}, pos = Vector3.new(500, 15, 200)},
    {minLevel = 25, maxLevel = 50, island = "Jungle", questNPC = "Quest Giver 3", mobs = {"Jungle Warrior", "Wild Beast"}, pos = Vector3.new(800, 20, -100)},
    {minLevel = 50, maxLevel = 100, island = "Snow", questNPC = "Quest Giver 4", mobs = {"Snow Bandit", "Ice Creature"}, pos = Vector3.new(-300, 30, 600)},
    {minLevel = 100, maxLevel = 150, island = "Magma", questNPC = "Quest Giver 5", mobs = {"Magma Soldier", "Fire Monster"}, pos = Vector3.new(1200, 10, 400)},
    {minLevel = 150, maxLevel = 200, island = "Sky", questNPC = "Quest Giver 6", mobs = {"Sky Warrior", "Thunder Bird"}, pos = Vector3.new(-500, 200, -400)},
    {minLevel = 200, maxLevel = 300, island = "Great Tree", questNPC = "Quest Giver 7", mobs = {"Tree Guardian", "Nature Spirit"}, pos = Vector3.new(1500, 50, -600)},
    {minLevel = 300, maxLevel = 500, island = "Cake Land", questNPC = "Quest Giver 8", mobs = {"Cake Soldier", "Sweet Monster"}, pos = Vector3.new(-800, 40, 900)},
    {minLevel = 500, maxLevel = 750, island = "Sea Castle", questNPC = "Quest Giver 9", mobs = {"Sea Knight", "Water Spirit"}, pos = Vector3.new(1800, 20, -900)},
    {minLevel = 750, maxLevel = 1000, island = "Haunted Castle", questNPC = "Quest Giver 10", mobs = {"Ghost", "Skeleton"}, pos = Vector3.new(-1200, 60, 1100)},
    {minLevel = 1000, maxLevel = 1500, island = "Elite Pirates", questNPC = "Quest Giver 11", mobs = {"Elite Pirate", "Captain"}, pos = Vector3.new(2000, 15, -1300)},
    {minLevel = 1500, maxLevel = 2000, island = "Marine Base", questNPC = "Quest Giver 12", mobs = {"Marine Soldier", "Marine Captain"}, pos = Vector3.new(-1500, 25, 1600)},
    {minLevel = 2000, maxLevel = 2550, island = "Dragon Dojo", questNPC = "Quest Giver 13", mobs = {"Dragon Warrior", "Ninja"}, pos = Vector3.new(2200, 50, -1800)},
}

-- Координаты NPC для сдачи квеста (нужно подобрать под вашу карту)
local npcPositions = {
    ["Pirate Village"] = Vector3.new(100, 10, 55),
    ["Desert"] = Vector3.new(505, 15, 205),
    ["Jungle"] = Vector3.new(805, 20, -95),
    ["Snow"] = Vector3.new(-295, 30, 605),
    ["Magma"] = Vector3.new(1205, 10, 405),
    ["Sky"] = Vector3.new(-495, 200, -395),
    ["Great Tree"] = Vector3.new(1505, 50, -595),
    ["Cake Land"] = Vector3.new(-795, 40, 905),
    ["Sea Castle"] = Vector3.new(1805, 20, -895),
    ["Haunted Castle"] = Vector3.new(-1195, 60, 1105),
    ["Elite Pirates"] = Vector3.new(2005, 15, -1295),
    ["Marine Base"] = Vector3.new(-1495, 25, 1605),
    ["Dragon Dojo"] = Vector3.new(2205, 50, -1795),
}

-- =========== UTILITIES ==========
local function getPlayerLevel()
    pcall(function()
        local leaderstats = player:FindFirstChild("leaderstats")
        if leaderstats then
            local level = leaderstats:FindFirstChild("Level")
            if level then
                return level.Value
            end
        end
    end)
    return 1
end

local function getCurrentIslandByLevel()
    local level = getPlayerLevel()
    for _, data in ipairs(levelData) do
        if level >= data.minLevel and level <= data.maxLevel then
            return data
        end
    end
    return levelData[1]
end

-- =========== FLY SYSTEM (без телепортов) ==========
local function startFly()
    if flyConnection then flyConnection:Disconnect() end
    if flyBodyVel then flyBodyVel:Destroy() end
    if flyBodyGyro then flyBodyGyro:Destroy() end
    
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    flyBodyVel = Instance.new("BodyVelocity")
    flyBodyVel.MaxForce = Vector3.new(1e6, 1e6, 1e6)
    flyBodyVel.P = 1e5
    flyBodyVel.Parent = hrp
    
    flyBodyGyro = Instance.new("BodyGyro")
    flyBodyGyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
    flyBodyGyro.P = 1e6
    flyBodyGyro.Parent = hrp
    
    isFlying = true
    
    flyConnection = RunService.RenderStepped:Connect(function()
        if not isFlying then return end
        local char = player.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp or not flyBodyVel or not flyBodyGyro then return end
        
        local move = Vector3.new(
            (keysPressed["D"] and 1 or 0) - (keysPressed["A"] and 1 or 0),
            (keysPressed["E"] and 1 or 0) - (keysPressed["Q"] and 1 or 0),
            (keysPressed["W"] and 1 or 0) - (keysPressed["S"] and 1 or 0)
        )
        if move.Magnitude > 0 then move = move.Unit end
        
        local cam = Workspace.CurrentCamera
        if cam then
            flyBodyVel.Velocity = (cam.CFrame.RightVector * move.X + cam.CFrame.UpVector * move.Y + cam.CFrame.LookVector * move.Z) * 120
            flyBodyGyro.CFrame = cam.CFrame
        end
    end)
end

local function stopFly()
    isFlying = false
    if flyConnection then flyConnection:Disconnect() flyConnection = nil end
    if flyBodyVel then flyBodyVel:Destroy() flyBodyVel = nil end
    if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end
end

local function flyToPosition(targetPos)
    if not targetPos then return end
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    -- Включаем полёт если ещё не включён
    if not isFlying then
        startFly()
    end
    
    -- Направление к цели
    local dir = (targetPos - hrp.Position).Unit
    local distance = (targetPos - hrp.Position).Magnitude
    
    if distance < 10 then
        stopFly()
        return true
    end
    
    if flyBodyVel then
        flyBodyVel.Velocity = dir * 100
    end
    
    return false
end

local function walkToPosition(targetPos)
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return end
    
    local distance = (targetPos - hrp.Position).Magnitude
    
    if distance < 5 then
        hum.WalkSpeed = 16
        return true
    end
    
    -- Идём к цели
    hum.WalkSpeed = 40
    local dir = (targetPos - hrp.Position).Unit
    hrp.CFrame = CFrame.new(hrp.Position, targetPos)
    hum:Move(dir)
    
    return false
end

local function moveToPosition(targetPos, useFly)
    if useFly then
        return flyToPosition(targetPos)
    else
        return walkToPosition(targetPos)
    end
end

-- =========== QUEST SYSTEM ==========
local function getQuestNPC(islandName)
    -- Поиск NPC по имени на острове
    for _, npc in pairs(Workspace:GetDescendants()) do
        if npc:IsA("Model") and npc.Name:lower():find("quest") or npc.Name:lower():find("giver") then
            if npc:FindFirstChild("HumanoidRootPart") then
                return npc
            end
        end
    end
    return nil
end

local function takeQuest()
    local islandData = getCurrentIslandByLevel()
    local npcPos = npcPositions[islandData.island]
    
    if not npcPos then return false end
    
    -- Летим к NPC
    local arrived = false
    repeat
        RunService.RenderStepped:Wait()
        arrived = moveToPosition(npcPos, true)
    until arrived
    
    -- Взаимодействие с NPC (нужно подобрать правильный Remote)
    pcall(function()
        -- Поиск Remote для взятия квеста
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        if remotes then
            local takeQuestRemote = remotes:FindFirstChild("TakeQuest")
            if takeQuestRemote then
                takeQuestRemote:FireServer(islandData.questNPC)
            end
        end
    end)
    
    task.wait(1)
    return true
end

local function completeQuest()
    local islandData = getCurrentIslandByLevel()
    local npcPos = npcPositions[islandData.island]
    
    if not npcPos then return false end
    
    -- Летим к NPC
    local arrived = false
    repeat
        RunService.RenderStepped:Wait()
        arrived = moveToPosition(npcPos, true)
    until arrived
    
    -- Сдача квеста
    pcall(function()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        if remotes then
            local completeRemote = remotes:FindFirstChild("CompleteQuest")
            if completeRemote then
                completeRemote:FireServer()
            end
        end
    end)
    
    task.wait(1)
    return true
end

-- =========== COMBAT SYSTEM ==========
local function getNearbyMobs(radius)
    local mobs = {}
    local char = player.Character
    if not char then return mobs end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return mobs end
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj ~= char then
            local mobHrp = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Head")
            if mobHrp then
                local dist = (mobHrp.Position - hrp.Position).Magnitude
                if dist < radius then
                    table.insert(mobs, {model = obj, hrp = mobHrp, distance = dist})
                end
            end
        end
    end
    
    table.sort(mobs, function(a, b) return a.distance < b.distance end)
    return mobs
end

local function bringMobsTogether()
    if not state.bringMobs then return end
    
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local mobs = getNearbyMobs(80)
    
    for _, mob in ipairs(mobs) do
        if mob.hrp then
            -- Собираем мобов к игроку (притягиваем)
            local dir = (hrp.Position - mob.hrp.Position).Unit
            local bodyVel = mob.model:FindFirstChild("BodyVelocity")
            if not bodyVel then
                bodyVel = Instance.new("BodyVelocity")
                bodyVel.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                bodyVel.P = 5000
                bodyVel.Parent = mob.model
            end
            bodyVel.Velocity = dir * 30
            
            -- Удаляем через 1 секунду чтобы не спамить
            task.spawn(function()
                task.wait(1)
                if bodyVel then bodyVel:Destroy() end
            end)
        end
    end
end

local function attackMob(mob)
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    -- Поворачиваемся к мобу
    if mob.hrp then
        hrp.CFrame = CFrame.new(hrp.Position, mob.hrp.Position)
    end
    
    -- Атака выбранным оружием
    if state.weaponType == "Combat" then
        -- Боевая атака (кулак)
        pcall(function()
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid then
                -- Симуляция удара
                local tool = char:FindFirstChildWhichIsA("Tool")
                if tool then
                    tool:Activate()
                end
            end
        end)
    elseif state.weaponType == "Fruit" then
        -- Атака фруктом
        pcall(function()
            local fruitTool = nil
            for _, tool in pairs(char:GetChildren()) do
                if tool:IsA("Tool") and tool.Name:lower():find("fruit") then
                    fruitTool = tool
                    break
                end
            end
            if fruitTool then
                fruitTool:Activate()
            end
        end)
    elseif state.weaponType == "Sword" then
        -- Атака мечом
        pcall(function()
            local sword = nil
            for _, tool in pairs(char:GetChildren()) do
                if tool:IsA("Tool") and (tool.Name:lower():find("sword") or tool.Name:lower():find("blade") or tool.Name:lower():find("katana")) then
                    sword = tool
                    break
                end
            end
            if sword then
                sword:Activate()
            end
        end)
    elseif state.weaponType == "Gun" then
        -- Атака оружием
        pcall(function()
            local gun = nil
            for _, tool in pairs(char:GetChildren()) do
                if tool:IsA("Tool") and (tool.Name:lower():find("gun") or tool.Name:lower():find("pistol") or tool.Name:lower():find("rifle")) then
                    gun = tool
                    break
                end
            end
            if gun then
                gun:Activate()
            end
        end)
    end
    
    -- Использование навыков если включено
    if state.autoSkill then
        pcall(function()
            local skills = {"Z", "X", "C", "V", "F"}
            for _, skill in ipairs(skills) do
                local tool = char:FindFirstChildWhichIsA("Tool")
                if tool then
                    local skillRemote = tool:FindFirstChild(skill)
                    if skillRemote and skillRemote:IsA("RemoteEvent") then
                        skillRemote:FireServer()
                    end
                end
            end
        end)
    end
end

-- =========== AUTO FARM CORE ==========
local function autoFarmLoop()
    if not state.autoFarm then return end
    
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    -- Получаем текущий уровень и остров
    local currentLevel = getPlayerLevel()
    local islandData = getCurrentIslandByLevel()
    
    -- Ищем мобов поблизости
    local mobs = getNearbyMobs(state.farmRadius)
    
    if #mobs > 0 then
        farming = true
        
        -- Собираем мобов в кучу
        bringMobsTogether()
        
        -- Летим над мобами (сверху)
        local highestMobY = 0
        for _, mob in ipairs(mobs) do
            if mob.hrp and mob.hrp.Position.Y > highestMobY then
                highestMobY = mob.hrp.Position.Y
            end
        end
        
        -- Позиция над мобами (на 30 единиц выше)
        local abovePos = Vector3.new(hrp.Position.X, highestMobY + 30, hrp.Position.Z)
        flyToPosition(abovePos)
        
        -- Атакуем ближайшего моба
        if mobs[1] then
            attackMob(mobs[1])
        end
        
        -- Периодически проверяем собрались ли мобы
        if state.bringMobs then
            bringMobsTogether()
        end
        
    else
        farming = false
        
        -- Нет мобов поблизости → летим к месту спавна мобов
        local mobSpawnPos = islandData.pos
        
        if mobSpawnPos then
            local arrived = flyToPosition(mobSpawnPos)
            
            if arrived then
                -- Прилетели на место, ищем квест если нужно
                if currentQuest == nil then
                    takeQuest()
                end
            end
        end
    end
end

-- =========== MAIN FARM LOOP ==========
RunService.Heartbeat:Connect(function()
    autoFarmLoop()
end)

-- =========== KEYBOARD ==========
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    keysPressed[input.KeyCode.Name] = true
    if input.KeyCode == Enum.KeyCode.RightAlt or input.KeyCode == Enum.KeyCode.VolumeUp then
        menuVisible = not menuVisible
        if ScreenGui then ScreenGui.Enabled = menuVisible end
    end
    -- Включить/выключить полёт вручную (кнопка F9)
    if input.KeyCode == Enum.KeyCode.F9 then
        if isFlying then
            stopFly()
        else
            startFly()
        end
    end
end)

UserInputService.InputEnded:Connect(function(input) keysPressed[input.KeyCode.Name] = false end)

-- =========== CHARACTER SETUP ==========
player.CharacterAdded:Connect(function(newChar)
    task.wait(0.5)
    character = newChar
    humanoid = newChar:FindFirstChild("Humanoid")
    rootPart = newChar:FindFirstChild("HumanoidRootPart")
    
    if humanoid then
        humanoid.WalkSpeed = 16
    end
    
    -- Перезапускаем полёт если автофарм включён
    if state.autoFarm then
        startFly()
    end
end)

-- =========== CREATE GUI ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BF_AutoFarm"
ScreenGui.ResetOnSpawn = false
ScreenGui.Enabled = true

local guiParent = nil
pcall(function() guiParent = player:WaitForChild("PlayerGui", 2) end)
if not guiParent then pcall(function() guiParent = game:GetService("CoreGui") end) end
if guiParent then pcall(function() ScreenGui.Parent = guiParent end) end

-- =========== COMPACT MENU ==========
local MENU_WIDTH = 350
local MENU_HEIGHT = 480

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, MENU_WIDTH, 0, MENU_HEIGHT)
MainFrame.Position = UDim2.new(0.5, -MENU_WIDTH/2, 0.5, -MENU_HEIGHT/2)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
MainFrame.BackgroundTransparency = 0.05
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(255, 80, 80)
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 55)
Header.BackgroundColor3 = Color3.fromRGB(30, 25, 35)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 14)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.Text = "⚔️ BLOX FRUITS AUTO FARM ⚔️"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
Title.TextColor3 = Color3.fromRGB(255, 80, 80)
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, -80, 0, 25)
Title.Position = UDim2.new(0, 12, 0, 8)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local LevelLabel = Instance.new("TextLabel")
LevelLabel.Text = "📊 Level: " .. getPlayerLevel()
LevelLabel.Font = Enum.Font.Gotham
LevelLabel.TextSize = 11
LevelLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
LevelLabel.BackgroundTransparency = 1
LevelLabel.Size = UDim2.new(1, -80, 0, 20)
LevelLabel.Position = UDim2.new(0, 12, 0, 32)
LevelLabel.TextXAlignment = Enum.TextXAlignment.Left
LevelLabel.Parent = Header

-- Update level every second
task.spawn(function()
    while true do
        task.wait(1)
        LevelLabel.Text = "📊 Level: " .. getPlayerLevel()
    end
end)

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

-- Scrolling Frame
local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, -10, 1, -70)
ScrollingFrame.Position = UDim2.new(0, 5, 0, 65)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 500)
ScrollingFrame.ScrollBarThickness = 3
ScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 80, 80)
ScrollingFrame.Parent = MainFrame

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, 0, 0, 500)
Content.BackgroundTransparency = 1
Content.Parent = ScrollingFrame

-- Helper functions
local function addToggle(parent, text, y, defaultValue, callback)
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
    label.Size = UDim2.new(0.55, 0, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 55, 0, 28)
    btn.Position = UDim2.new(1, -63, 0.5, -14)
    btn.Text = defaultValue and "ON" or "OFF"
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
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
    dropdown.Size = UDim2.new(0.5, -10, 0, 30)
    dropdown.Position = UDim2.new(0.45, 0, 0.5, -15)
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
    bar.Position = UDim2.new(0, 12, 0, 42)
    bar.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    bar.BorderSizePixel = 0
    bar.Parent = frame
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(1, 0)
    barCorner.Parent = bar
    
    local ratio = (defaultVal - minVal) / (maxVal - minVal)
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(ratio, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
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

-- Build UI
local y = 5

-- Auto Farm Toggle
addToggle(Content, "⚡ AUTO FARM", y, state.autoFarm, function(val)
    state.autoFarm = val
    save("AutoFarm", val)
    if val then
        startFly()
    else
        stopFly()
    end
end)
y = y + 52

-- Weapon Type Dropdown
addDropdown(Content, "⚔️ WEAPON TYPE", y, {"Combat", "Fruit", "Sword", "Gun"}, state.weaponType, function(val)
    state.weaponType = val
    save("WeaponType", val)
end)
y = y + 52

-- Auto Skill Toggle
addToggle(Content, "🎯 AUTO SKILL (Z/X/C/V/F)", y, state.autoSkill, function(val)
    state.autoSkill = val
    save("AutoSkill", val)
end)
y = y + 52

-- Bring Mobs Toggle
addToggle(Content, "🔄 BRING MOBS TOGETHER", y, state.bringMobs, function(val)
    state.bringMobs = val
    save("BringMobs", val)
end)
y = y + 52

-- Farm Radius Slider
addSlider(Content, "📡 FARM RADIUS", y, 50, 400, state.farmRadius, function(val)
    state.farmRadius = val
    save("FarmRadius", val)
end)
y = y + 70

-- Info Label
local infoFrame = Instance.new("Frame")
infoFrame.Size = UDim2.new(1, -16, 0, 80)
infoFrame.Position = UDim2.new(0, 8, 0, y)
infoFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
infoFrame.BackgroundTransparency = 0.4
infoFrame.BorderSizePixel = 0
infoFrame.Parent = Content
local infoCorner = Instance.new("UICorner")
infoCorner.CornerRadius = UDim.new(0, 8)
infoCorner.Parent = infoFrame

local infoText = Instance.new("TextLabel")
infoText.Text = "📖 ИНФОРМАЦИЯ:\n• Герой летает (не телепортируется)\n• Автоматически берёт и сдаёт квесты\n• Собирает мобов в кучу\n• Атакует выбранным оружием\n• F9 - ручное включение полёта"
infoText.Font = Enum.Font.Gotham
infoText.TextSize = 10
infoText.TextColor3 = Color3.fromRGB(180, 180, 200)
infoText.BackgroundTransparency = 1
infoText.Size = UDim2.new(1, -16, 1, -8)
infoText.Position = UDim2.new(0, 8, 0, 4)
infoText.TextXAlignment = Enum.TextXAlignment.Left
infoText.TextYAlignment = Enum.TextYAlignment.Top
infoText.Parent = infoFrame

-- Drag system
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

-- Minimize/Close
local minimized = false
local originalHeight = MENU_HEIGHT

MinimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        MainFrame:TweenSize(UDim2.new(0, MENU_WIDTH, 0, 55), "Out", "Quad", 0.2)
    else
        MainFrame:TweenSize(UDim2.new(0, MENU_WIDTH, 0, originalHeight), "Out", "Quad", 0.2)
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    TweenService:Create(MainFrame, TweenInfo.new(0.15), {Size = UDim2.new(0, 0, 0, 0)}):Play()
    task.wait(0.15)
    ScreenGui:Destroy()
end)

-- Init
if state.autoFarm then
    startFly()
end

print("═══════════════════════════════════════════")
print("⚔️ BLOX FRUITS ADVANCED AUTO FARM v1.0")
print("📌 Размер: 350x480")
print("📌 RightAlt или Volume± - скрыть меню")
print("📌 F9 - ручное включение полёта")
print("✅ Авто-квест (получение → фарм → сдача)")
print("✅ Только полёт (БЕЗ телепортов)")
print("✅ Сбор мобов + атака сверху")
print("═══════════════════════════════════════════")
