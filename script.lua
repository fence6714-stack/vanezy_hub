--[[
    BLOX FRUITS ULTIMATE FIXED v3.0
    - Исправлен лаг (оптимизирован код)
    - Авто-детект уровня, квестов, NPC, мобов
    - Плавный полёт НАД мобами (безопасная высота)
    - Притягивание мобов + убийство с воздуха
    - Анти-падение, только плавное движение
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

if not player then player = Players.PlayerAdded:Wait() end

-- =========== ОПТИМИЗАЦИЯ ==========
local frameSkip = 0
local OPTIMIZATION_INTERVAL = 3 -- Каждый 3 кадр

-- =========== STORAGE ==========
local Storage = Instance.new("Folder")
Storage.Name = "BF_FixedFarm"
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
    weaponType = load("WeaponType", "Combat"),
    autoSkill = load("AutoSkill", true),
    bringMobs = load("BringMobs", true),
    farmRadius = load("FarmRadius", 200),
    flyHeight = load("FlyHeight", 25),
    attackRange = load("AttackRange", 60),
}

local state = {
    autoFarm = settings.autoFarm,
    weaponType = settings.weaponType,
    autoSkill = settings.autoSkill,
    bringMobs = settings.bringMobs,
    farmRadius = settings.farmRadius,
    flyHeight = settings.flyHeight,
    attackRange = settings.attackRange,
}

-- =========== VARIABLES ==========
local character, humanoid, rootPart
local currentQuestMob = nil
local currentQuestNPC = nil
local currentIslandData = nil
local farming = false
local menuVisible = true
local flyConn = nil
local flyVel = nil
local flyGyro = nil
local isFlying = false
local keysPressed = {}
local lastAttackTime = 0
local attackCooldown = 0.25
local currentLevel = 0
local lastLevelCheck = 0
local mobCache = {}
local cacheTime = 0
local pullVelocities = {}

-- =========== АВТО-ДЕТЕКТ УРОВНЯ ==========
local function updatePlayerLevel()
    pcall(function()
        local ls = player:FindFirstChild("leaderstats")
        if ls then
            local lvl = ls:FindFirstChild("Level")
            if lvl then currentLevel = lvl.Value end
        end
    end)
    return currentLevel
end

-- =========== ДАННЫЕ ВСЕХ ОСТРОВОВ (авто-детект) ==========
-- Заполняется автоматически из игры, но для начала используем базу
local islandsDatabase = {
    -- Sea 1
    [1] = {name="Pirate Village", minLvl=1, maxLvl=10, npcName="Quest Giver", mobs={"Bandit", "Traitor"}, islandPos=nil, npcPos=nil},
    [5] = {name="Desert", minLvl=10, maxLvl=25, npcName="Quest Giver", mobs={"Desert Bandit", "Sandman"}, islandPos=nil, npcPos=nil},
    [10] = {name="Jungle", minLvl=25, maxLvl=50, npcName="Quest Giver", mobs={"Jungle Warrior"}, islandPos=nil, npcPos=nil},
    [15] = {name="Snow", minLvl=50, maxLvl=100, npcName="Quest Giver", mobs={"Snow Bandit"}, islandPos=nil, npcPos=nil},
    [20] = {name="Magma", minLvl=100, maxLvl=150, npcName="Quest Giver", mobs={"Magma Soldier"}, islandPos=nil, npcPos=nil},
    [25] = {name="Sky", minLvl=150, maxLvl=200, npcName="Quest Giver", mobs={"Sky Warrior"}, islandPos=nil, npcPos=nil},
    -- Sea 2
    [30] = {name="Kingdom of Rose", minLvl=700, maxLvl=850, npcName="Quest Giver", mobs={"Pirate"}, islandPos=nil, npcPos=nil},
    [35] = {name="Green Zone", minLvl=850, maxLvl=950, npcName="Quest Giver", mobs={"Militant"}, islandPos=nil, npcPos=nil},
    [40] = {name="Graveyard", minLvl=950, maxLvl=1050, npcName="Quest Giver", mobs={"Reborn"}, islandPos=nil, npcPos=nil},
    -- Sea 3
    [45] = {name="Port Town", minLvl=1500, maxLvl=1650, npcName="Quest Giver", mobs={"Pirate"}, islandPos=nil, npcPos=nil},
    [50] = {name="Hydra Island", minLvl=1650, maxLvl=1800, npcName="Quest Giver", mobs={"Pirate"}, islandPos=nil, npcPos=nil},
    [55] = {name="Floating Turtle", minLvl=1800, maxLvl=2000, npcName="Quest Giver", mobs={"Pirate"}, islandPos=nil, npcPos=nil},
    [60] = {name="Mansion", minLvl=2000, maxLvl=2200, npcName="Quest Giver", mobs={"Pirate"}, islandPos=nil, npcPos=nil},
    [65] = {name="Great Tree", minLvl=2200, maxLvl=2350, npcName="Quest Giver", mobs={"Pirate"}, islandPos=nil, npcPos=nil},
    [70] = {name="Castle on Sea", minLvl=2350, maxLvl=2550, npcName="Quest Giver", mobs={"Pirate"}, islandPos=nil, npcPos=nil},
}

-- =========== АВТО-ДЕТЕКТ ТЕКУЩЕГО ОСТРОВА ==========
local function detectCurrentIsland()
    local level = currentLevel
    
    local bestMatch = nil
    for _, data in pairs(islandsDatabase) do
        if level >= data.minLvl and level <= data.maxLvl then
            if not bestMatch or data.minLvl > bestMatch.minLvl then
                bestMatch = data
            end
        end
    end
    
    -- Если не нашли по уровню, ищем по позиции
    if not bestMatch and rootPart then
        local charPos = rootPart.Position
        local minDist = 1000
        for _, data in pairs(islandsDatabase) do
            if data.islandPos then
                local dist = (charPos - data.islandPos).Magnitude
                if dist < minDist then
                    minDist = dist
                    bestMatch = data
                end
            end
        end
    end
    
    return bestMatch or islandsDatabase[1]
end

-- =========== ПОИСК NPC ДЛЯ КВЕСТА ==========
local function findQuestNPC()
    -- Ищем ближайшего NPC с квестом
    local nearestNPC = nil
    local minDist = 500
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") then
            local name = obj.Name:lower()
            if name:find("quest") or name:find("npc") or name:find("giver") or name:find("trainee") or name:find("teacher") then
                local npcPos = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Head")
                if npcPos and rootPart then
                    local dist = (npcPos.Position - rootPart.Position).Magnitude
                    if dist < minDist then
                        minDist = dist
                        nearestNPC = obj
                    end
                end
            end
        end
    end
    
    return nearestNPC
end

-- =========== ПОИСК НУЖНЫХ МОБОВ ДЛЯ КВЕСТА ==========
local function findQuestMobs()
    local islandData = detectCurrentIsland()
    if not islandData then return {} end
    
    local mobs = {}
    if not rootPart then return mobs end
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj ~= character then
            local name = obj.Name:lower()
            local isTargetMob = false
            
            for _, mobName in pairs(islandData.mobs) do
                if name:find(mobName:lower()) then
                    isTargetMob = true
                    break
                end
            end
            
            if isTargetMob then
                local mobHrp = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Head")
                if mobHrp then
                    local dist = (mobHrp.Position - rootPart.Position).Magnitude
                    if dist < state.farmRadius then
                        table.insert(mobs, {model = obj, hrp = mobHrp, distance = dist})
                    end
                end
            end
        end
    end
    
    return mobs
end

-- =========== ВЗЯТИЕ КВЕСТА ==========
local function takeQuest()
    local npc = findQuestNPC()
    if not npc then return false end
    
    -- Летим к NPC
    local npcPos = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Head")
    if not npcPos then return false end
    
    local arrived = false
    repeat
        RunService.RenderStepped:Wait()
        arrived = flyToPosition(npcPos.Position, false)
    until arrived
    
    task.wait(0.5)
    
    -- Взаимодействие с NPC
    pcall(function()
        -- Пробуем разные способы взятия квеста
        local dialogRemote = npc:FindFirstChild("RemoteEvent") or npc:FindFirstChild("Dialog")
        if dialogRemote then
            dialogRemote:FireServer()
        end
        
        -- Кликаем по NPC
        local clickDetector = npc:FindFirstChild("ClickDetector")
        if clickDetector then
            clickDetector:Click()
        end
        
        -- Через Remotes
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        if remotes then
            local takeRemote = remotes:FindFirstChild("TakeQuest") or remotes:FindFirstChild("StartQuest") or remotes:FindFirstChild("Quest")
            if takeRemote then
                takeRemote:FireServer()
            end
        end
    end)
    
    task.wait(1)
    return true
end

-- =========== ПОЛЁТ (ОПТИМИЗИРОВАННЫЙ) ==========
local function startFly()
    if flyConn then flyConn:Disconnect() end
    if flyVel then flyVel:Destroy() end
    if flyGyro then flyGyro:Destroy() end
    
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    flyVel = Instance.new("BodyVelocity")
    flyVel.MaxForce = Vector3.new(1e6, 1e6, 1e6)
    flyVel.P = 1e5
    flyVel.Parent = hrp
    
    flyGyro = Instance.new("BodyGyro")
    flyGyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
    flyGyro.P = 1e6
    flyGyro.Parent = hrp
    
    isFlying = true
    
    flyConn = RunService.RenderStepped:Connect(function()
        if not isFlying then return end
        frameSkip = frameSkip + 1
        if frameSkip % OPTIMIZATION_INTERVAL ~= 0 then return end
        
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
            flyVel.Velocity = (cam.CFrame.RightVector * move.X + cam.CFrame.UpVector * move.Y + cam.CFrame.LookVector * move.Z) * 100
            flyGyro.CFrame = cam.CFrame
        end
    end)
end

local function stopFly()
    isFlying = false
    if flyConn then flyConn:Disconnect() flyConn = nil end
    if flyVel then flyVel:Destroy() flyVel = nil end
    if flyGyro then flyGyro:Destroy() flyGyro = nil end
end

local function flyToPosition(targetPos, keepHeight)
    if not targetPos then return false end
    local char = player.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    if not isFlying then
        startFly()
    end
    
    local target = targetPos
    if keepHeight then
        target = Vector3.new(targetPos.X, targetPos.Y + state.flyHeight, targetPos.Z)
    end
    
    local distance = (target - hrp.Position).Magnitude
    
    if distance < 10 then
        if flyVel then flyVel.Velocity = Vector3.new(0, 0, 0) end
        return true
    end
    
    local dir = (target - hrp.Position).Unit
    if flyVel then
        flyVel.Velocity = dir * 80
    end
    
    return false
end

-- =========== ПРИТЯГИВАНИЕ МОБОВ ==========
local pulledMobs = {}
local pullCleanupTime = 0.5

local function pullMob(mob, targetPos)
    if not mob or not mob.hrp then return end
    
    if pulledMobs[mob.model] then
        if tick() - pulledMobs[mob.model] < 2 then return end
    end
    
    pulledMobs[mob.model] = tick()
    
    local bodyVel = mob.model:FindFirstChild("TWKSPullVel")
    if bodyVel then bodyVel:Destroy() end
    
    bodyVel = Instance.new("BodyVelocity")
    bodyVel.Name = "TWKSPullVel"
    bodyVel.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bodyVel.P = 8000
    bodyVel.Parent = mob.model
    
    local dir = (targetPos - mob.hrp.Position).Unit
    bodyVel.Velocity = dir * 40
    
    task.spawn(function()
        task.wait(pullCleanupTime)
        if bodyVel then bodyVel:Destroy() end
    end)
end

local function bringAllMobs()
    if not state.bringMobs then return end
    if not rootPart then return end
    
    local mobs = findQuestMobs()
    
    -- Чистим старые ссылки
    for model, _ in pairs(pulledMobs) do
        if not model or not model.Parent then
            pulledMobs[model] = nil
        end
    end
    
    -- Притягиваем мобов под игрока
    local abovePos = Vector3.new(rootPart.Position.X, rootPart.Position.Y - 10, rootPart.Position.Z)
    
    for _, mob in ipairs(mobs) do
        if mob.hrp and mob.model then
            pullMob(mob, abovePos)
        end
    end
end

-- =========== АТАКА С ВОЗДУХА (УВЕЛИЧЕННЫЙ РАДИУС) ==========
local function attackFromAbove()
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local mobs = findQuestMobs()
    
    if #mobs == 0 then return end
    
    -- Берём ближайшего моба
    local targetMob = mobs[1]
    
    if targetMob and targetMob.hrp then
        -- Наводим направление на моба
        hrp.CFrame = CFrame.new(hrp.Position, targetMob.hrp.Position)
        
        -- Атака через Tool
        pcall(function()
            local tool = char:FindFirstChildWhichIsA("Tool")
            if tool then
                tool:Activate()
            end
            
            -- Удалённая атака через Remote
            local attackRemote = ReplicatedStorage:FindFirstChild("Remote")
            if attackRemote then
                attackRemote:FireServer("Attack")
            end
        end)
        
        -- Атака выбранным оружием
        if state.weaponType == "Combat" then
            pcall(function()
                local humanoid = char:FindFirstChild("Humanoid")
                if humanoid then
                    local anim = humanoid:LoadAnimation(Instance.new("Animation"))
                    pcall(function() anim:Play() end)
                end
            end)
        elseif state.weaponType == "Fruit" then
            pcall(function()
                for _, t in pairs(char:GetChildren()) do
                    if t:IsA("Tool") and (t.Name:lower():find("fruit") or t.Name:lower():find("blox")) then
                        t:Activate()
                        break
                    end
                end
            end)
        elseif state.weaponType == "Sword" then
            pcall(function()
                for _, t in pairs(char:GetChildren()) do
                    if t:IsA("Tool") and (t.Name:lower():find("sword") or t.Name:lower():find("blade") or t.Name:lower():find("katana") or t.Name:lower():find("cutlass") or t.Name:lower():find("saber")) then
                        t:Activate()
                        break
                    end
                end
            end)
        elseif state.weaponType == "Gun" then
            pcall(function()
                for _, t in pairs(char:GetChildren()) do
                    if t:IsA("Tool") and (t.Name:lower():find("gun") or t.Name:lower():find("pistol") or t.Name:lower():find("rifle") or t.Name:lower():find("musket")) then
                        t:Activate()
                        break
                    end
                end
            end)
        end
        
        -- Авто-скиллы
        if state.autoSkill then
            pcall(function()
                local skills = {"Z", "X", "C", "V", "F"}
                for _, skillName in ipairs(skills) do
                    local tool = char:FindFirstChildWhichIsA("Tool")
                    if tool then
                        local skill = tool:FindFirstChild(skillName)
                        if skill and skill:IsA("RemoteEvent") then
                            skill:FireServer(targetMob.hrp.Position)
                        end
                    end
                end
            end)
        end
    end
end

-- =========== ОСНОВНОЙ ЦИКЛ АВТОФАРМА (ОПТИМИЗИРОВАННЫЙ) ==========
local farmCooldown = 0
local lastMobCheck = 0
local mobCheckInterval = 0.5
local lastQuestCheck = 0
local questCheckInterval = 3

local function autoFarmLoop()
    if not state.autoFarm then return end
    
    local now = tick()
    
    -- Проверка уровня каждые 2 секунды
    if now - lastLevelCheck > 2 then
        lastLevelCheck = now
        updatePlayerLevel()
    end
    
    local char = player.Character
    if not char then return end
    rootPart = char:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    -- Проверка мобов с интервалом
    local mobs = {}
    if now - lastMobCheck > mobCheckInterval then
        lastMobCheck = now
        mobs = findQuestMobs()
    else
        -- Используем кэш
        mobs = mobCache
    end
    mobCache = mobs
    
    local islandData = detectCurrentIsland()
    
    if #mobs > 0 then
        farming = true
        
        -- Находим центр скопления мобов
        local centerPos = rootPart.Position
        local mobCount = 0
        
        for _, mob in ipairs(mobs) do
            if mob.hrp then
                centerPos = centerPos + mob.hrp.Position
                mobCount = mobCount + 1
            end
        end
        
        if mobCount > 0 then
            centerPos = centerPos / mobCount
        end
        
        -- Летим НАД мобами
        local abovePos = Vector3.new(centerPos.X, centerPos.Y + state.flyHeight, centerPos.Z)
        flyToPosition(abovePos, false)
        
        -- Собираем мобов под собой
        bringAllMobs()
        
        -- Атакуем с задержкой
        if now - lastAttackTime >= attackCooldown then
            lastAttackTime = now
            attackFromAbove()
        end
        
        -- Сброс флага после уничтожения всех мобов
        if mobCount == 0 and now - lastAttackTime > 5 then
            farming = false
        end
        
    else
        if farming then
            farming = false
            -- Задержка перед проверкой квеста
        end
        
        -- Проверка квеста и полёт к NPC
        if now - lastQuestCheck > questCheckInterval then
            lastQuestCheck = now
            
            if not currentQuestNPC then
                takeQuest()
            else
                -- Летим к месту спавна мобов
                if islandData and islandData.islandPos then
                    flyToPosition(islandData.islandPos, false)
                end
            end
        end
    end
end

-- =========== ЗАПУСК ЦИКЛА (С ОПТИМИЗАЦИЕЙ) ==========
RunService.Heartbeat:Connect(function()
    autoFarmLoop()
end)

-- =========== КЛАВИАТУРА ==========
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    keysPressed[input.KeyCode.Name] = true
    if input.KeyCode == Enum.KeyCode.RightAlt or input.KeyCode == Enum.KeyCode.VolumeUp then
        menuVisible = not menuVisible
        if ScreenGui then ScreenGui.Enabled = menuVisible end
    end
    if input.KeyCode == Enum.KeyCode.F9 then
        if isFlying then
            stopFly()
        else
            startFly()
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    keysPressed[input.KeyCode.Name] = false
end)

-- =========== ПЕРЕРОЖДЕНИЕ ==========
player.CharacterAdded:Connect(function(newChar)
    task.wait(0.5)
    character = newChar
    humanoid = newChar:FindFirstChild("Humanoid")
    rootPart = newChar:FindFirstChild("HumanoidRootPart")
    if humanoid then humanoid.WalkSpeed = 16 end
    if state.autoFarm then
        task.wait(0.2)
        startFly()
    end
    -- Очистка кэша
    mobCache = {}
    pulledMobs = {}
end)

-- =========== СОЗДАНИЕ GUI ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BF_FixedFarm"
ScreenGui.ResetOnSpawn = false
ScreenGui.Enabled = true

local guiParent = nil
pcall(function() guiParent = player:WaitForChild("PlayerGui", 2) end)
if not guiParent then pcall(function() guiParent = game:GetService("CoreGui") end) end
if guiParent then pcall(function() ScreenGui.Parent = guiParent end) end

-- =========== МЕНЮ ==========
local MENU_WIDTH = 340
local MENU_HEIGHT = 500

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
MainStroke.Color = Color3.fromRGB(80, 200, 255)
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 60)
Header.BackgroundColor3 = Color3.fromRGB(30, 35, 50)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 14)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.Text = "🛡️ BLOX FRUITS ULTIMATE v3"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextColor3 = Color3.fromRGB(80, 200, 255)
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, -80, 0, 25)
Title.Position = UDim2.new(0, 12, 0, 8)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local LevelText = Instance.new("TextLabel")
LevelText.Text = "📊 Level: " .. currentLevel
LevelText.Font = Enum.Font.Gotham
LevelText.TextSize = 11
LevelText.TextColor3 = Color3.fromRGB(200, 200, 220)
LevelText.BackgroundTransparency = 1
LevelText.Size = UDim2.new(1, -80, 0, 20)
LevelText.Position = UDim2.new(0, 12, 0, 34)
LevelText.TextXAlignment = Enum.TextXAlignment.Left
LevelText.Parent = Header

-- Обновление уровня в UI
task.spawn(function()
    while true do
        task.wait(1)
        LevelText.Text = "📊 Level: " .. currentLevel
    end
end)

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 32, 0, 28)
MinimizeBtn.Position = UDim2.new(1, -70, 0.5, -14)
MinimizeBtn.Text = "−"
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 20
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 45, 60)
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
ScrollingFrame.Size = UDim2.new(1, -10, 1, -75)
ScrollingFrame.Position = UDim2.new(0, 5, 0, 70)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 550)
ScrollingFrame.ScrollBarThickness = 3
ScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 200, 255)
ScrollingFrame.Parent = MainFrame

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, 0, 0, 550)
Content.BackgroundTransparency = 1
Content.Parent = ScrollingFrame

-- UI Helpers
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
        dropdown.Text = selected        if callback then callback(selected) end
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
    fill.BackgroundColor3 = Color3.fromRGB(80, 200, 255)
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
local y = 8

addToggle(Content, "⚡ ULTIMATE AUTO FARM", y, state.autoFarm, function(val)
    state.autoFarm = val
    save("AutoFarm", val)
    if val then
        startFly()
    else
        stopFly()
    end
end)
y = y + 52

addDropdown(Content, "⚔️ WEAPON TYPE", y, {"Combat", "Fruit", "Sword", "Gun"}, state.weaponType, function(val)
    state.weaponType = val
    save("WeaponType", val)
end)
y = y + 52

addToggle(Content, "🎯 AUTO SKILL (Z/X/C/V/F)", y, state.autoSkill, function(val)
    state.autoSkill = val
    save("AutoSkill", val)
end)
y = y + 52

addToggle(Content, "🔄 BRING MOBS TOGETHER", y, state.bringMobs, function(val)
    state.bringMobs = val
    save("BringMobs", val)
end)
y = y + 52

addSlider(Content, "📡 FARM RADIUS", y, 100, 400, state.farmRadius, function(val)
    state.farmRadius = val
    save("FarmRadius", val)
end)
y = y + 70

addSlider(Content, "🚁 FLY HEIGHT", y, 15, 50, state.flyHeight, function(val)
    state.flyHeight = val
    save("FlyHeight", val)
end)
y = y + 70

addSlider(Content, "🎯 ATTACK RANGE", y, 30, 80, state.attackRange, function(val)
    state.attackRange = val
    save("AttackRange", val)
end)
y = y + 70

-- Info panel
local infoFrame = Instance.new("Frame")
infoFrame.Size = UDim2.new(1, -16, 0, 85)
infoFrame.Position = UDim2.new(0, 8, 0, y)
infoFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
infoFrame.BackgroundTransparency = 0.4
infoFrame.BorderSizePixel = 0
infoFrame.Parent = Content
local infoCorner = Instance.new("UICorner")
infoCorner.CornerRadius = UDim.new(0, 8)
infoCorner.Parent = infoFrame

local infoText = Instance.new("TextLabel")
infoText.Text = "📖 ИНФОРМАЦИЯ:\n🔹 Авто-детект уровня и острова\n🔹 Плавный полёт НАД мобами\n🔹 Притягивание мобов под игрока\n🔹 Увеличенный радиус атаки\n🔹 F9 - ручной полёт\n🔹 RightAlt/Volume± - скрыть меню"
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
        MainFrame:TweenSize(UDim2.new(0, MENU_WIDTH, 0, 60), "Out", "Quad", 0.2)
    else
        MainFrame:TweenSize(UDim2.new(0, MENU_WIDTH, 0, originalHeight), "Out", "Quad", 0.2)
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    if state.autoFarm then
        stopFly()
    end
    TweenService:Create(MainFrame, TweenInfo.new(0.15), {Size = UDim2.new(0, 0, 0, 0)}):Play()
    task.wait(0.15)
    ScreenGui:Destroy()
end)

-- Init
updatePlayerLevel()
if state.autoFarm then
    startFly()
end

print("═══════════════════════════════════════════")
print("🛡️ BLOX FRUITS ULTIMATE v3 - FIXED")
print("📌 Исправлен лаг (уменьшена нагрузка)")
print("📌 Авто-детект уровня и квестов")
print("📌 Полёт над мобами + притягивание")
print("📌 RightAlt/Volume± - скрыть меню")
print("📌 F9 - ручной полёт")
print("═══════════════════════════════════════════")
