--[[
    redz Hub: Blox Fruits GUI Recreation
    На основе скриншота: вкладки Local Player, Farming, Stack Farm, Farming Other,
    Fruit and Raid, Sea Event, Upgrade Race, Get, Volcan Event, ESP, PVP
    + блоки Farming Material, Mastery Farm (GODHUMAN), Level Farm
    Библиотека: Orion UI (тёмная тема, максимальное сходство)
--]]

-- Инициализация Orion UI
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Qanuir/orion-ui/main/source"))()
local Window = OrionLib:MakeWindow({
    Name = "redz Hub: Blox Fruits by real redz",
    SubTitle = "VanezyScripts",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "RedzHub_Config",
    IntroEnabled = true,
    IntroText = "redz Hub"
})

-- Основные вкладки согласно скриншоту
local TabLocalPlayer = Window:MakeTab({Name = "Local Player", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local TabSettingFarm = Window:MakeTab({Name = "Setting Farm", Icon = "rbxassetid://7733960280", PremiumOnly = false})
local TabFarming = Window:MakeTab({Name = "Farming", Icon = "rbxassetid://7734055157", PremiumOnly = false})
local TabStackFarm = Window:MakeTab({Name = "Stack Farm", Icon = "rbxassetid://7733967659", PremiumOnly = false})
local TabFarmingOther = Window:MakeTab({Name = "Farming Other", Icon = "rbxassetid://7733957924", PremiumOnly = false})
local TabFruitRaid = Window:MakeTab({Name = "Fruit and Raid", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local TabSeaEvent = Window:MakeTab({Name = "Sea Event", Icon = "rbxassetid://7733978196", PremiumOnly = false})
local TabUpgradeRace = Window:MakeTab({Name = "Upgrade Race", Icon = "rbxassetid://7733994645", PremiumOnly = false})
local TabGet = Window:MakeTab({Name = "Get", Icon = "rbxassetid://4335482701", PremiumOnly = false})
local TabVolcanEvent = Window:MakeTab({Name = "Volcan Event", Icon = "rbxassetid://7734054769", PremiumOnly = false})
local TabESP = Window:MakeTab({Name = "ESP", Icon = "rbxassetid://7733967659", PremiumOnly = false})
local TabPVP = Window:MakeTab({Name = "PVP", Icon = "rbxassetid://7733960280", PremiumOnly = false})

-- ===================================================================
-- Tab Local Player (базовые функции игрока)
-- ===================================================================
TabLocalPlayer:AddSection("Настройки игрока")

TabLocalPlayer:AddToggle({
    Name = "Auto Run",
    Default = false,
    Callback = function(Value)
        getgenv().AutoRun = Value
        while getgenv().AutoRun do
            -- Эмуляция бега
            local player = game.Players.LocalPlayer
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid:Move(Vector3.new(0, 0, -1), true)
            end
            task.wait()
        end
    end
})

TabLocalPlayer:AddSlider({
    Name = "Walk Speed",
    Min = 16,
    Max = 350,
    Default = 16,
    Color = Color3.fromRGB(255, 100, 100),
    Increment = 1,
    ValueName = "studs/s",
    Callback = function(Value)
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = Value
        end
    end
})

TabLocalPlayer:AddSlider({
    Name = "Jump Power",
    Min = 50,
    Max = 500,
    Default = 50,
    Color = Color3.fromRGB(100, 255, 100),
    Increment = 1,
    ValueName = "power",
    Callback = function(Value)
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.JumpPower = Value
        end
    end
})

-- ===================================================================
-- Tab Setting Farm
-- ===================================================================
TabSettingFarm:AddSection("Конфигурация фарма")

local WeaponList = {"Melee", "Sword", "Gun", "Fruit"}
TabSettingFarm:AddDropdown({
    Name = "Select Weapon",
    Default = "Melee",
    Options = WeaponList,
    Callback = function(Value)
        getgenv().SelectedWeapon = Value
    end
})

TabSettingFarm:AddToggle({
    Name = "Safe Mode",
    Default = true,
    Callback = function(Value)
        getgenv().SafeMode = Value
    end
})

-- ===================================================================
-- Tab Farming
-- ===================================================================
TabFarming:AddSection("Farming Material")

local MaterialList = {"Wood", "Stone", "Iron", "Gold", "Diamond", "Dragon Scales", "Magma Ore"}
TabFarming:AddDropdown({
    Name = "Select Material",
    Default = "Wood",
    Options = MaterialList,
    Callback = function(Value)
        getgenv().SelectedMaterial = Value
    end
})

TabFarming:AddButton({
    Name = "Farm Material",
    Callback = function()
        getgenv().FarmMaterialActive = not getgenv().FarmMaterialActive
        OrionLib:MakeNotification({
            Name = "Farming Material",
            Content = "Статус: " .. tostring(getgenv().FarmMaterialActive),
            Image = "rbxassetid://4483345998",
            Time = 3
        })
        while getgenv().FarmMaterialActive do
            -- Здесь была бы логика фарма материалов (зависит от игры)
            task.wait(1)
        end
    end
})

TabFarming:AddSection("Mastery Farm")

-- Прогресс GODHUMAN (как на скриншоте)
TabFarming:AddLabel("GODHUMAN")
TabFarming:AddLabel("Mac: 125")
TabFarming:AddLabel("Soaring Beast: [Z]")
TabFarming:AddLabel("Heaven Earth: [X]")
TabFarming:AddLabel("Sixth Realm Gun: [ACT]")

TabFarming:AddButton({
    Name = "Mastery 600 (MAX) - 1,802,046/1,892,346",
    Callback = function()
        getgenv().MasteryFarmActive = not getgenv().MasteryFarmActive
        OrionLib:MakeNotification({
            Name = "Mastery Farm",
            Content = "Статус: " .. tostring(getgenv().MasteryFarmActive),
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end
})

TabFarming:AddSection("Level Farm")
TabFarming:AddButton({
    Name = "Level Farm",
    Callback = function()
        getgenv().LevelFarmActive = not getgenv().LevelFarmActive
        OrionLib:MakeNotification({
            Name = "Level Farm",
            Content = "Статус: " .. tostring(getgenv().LevelFarmActive),
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end
})

-- ===================================================================
-- Tab Stack Farm
-- ===================================================================
TabStackFarm:AddSection("Авто-стак фарм")

TabStackFarm:AddToggle({
    Name = "Auto Stack NPC",
    Default = false,
    Callback = function(Value)
        getgenv().AutoStackNPC = Value
    end
})

TabStackFarm:AddSlider({
    Name = "Stack Distance",
    Min = 5,
    Max = 50,
    Default = 15,
    Color = Color3.fromRGB(255, 200, 100),
    Increment = 1,
    ValueName = "studs",
    Callback = function(Value)
        getgenv().StackDistance = Value
    end
})

-- ===================================================================
-- Tab Farming Other
-- ===================================================================
TabFarmingOther:AddSection("Прочие фармы")

TabFarmingOther:AddToggle({
    Name = "Auto Bone",
    Default = false,
    Callback = function(Value) getgenv().AutoBone = Value end
})

TabFarmingOther:AddToggle({
    Name = "Auto Ectoplasm",
    Default = false,
    Callback = function(Value) getgenv().AutoEctoplasm = Value end
})

TabFarmingOther:AddToggle({
    Name = "Auto Dark Fragment",
    Default = false,
    Callback = function(Value) getgenv().AutoDarkFragment = Value end
})

-- ===================================================================
-- Tab Fruit and Raid
-- ===================================================================
TabFruitRaid:AddSection("Фрукты и рейды")

TabFruitRaid:AddToggle({
    Name = "Auto Raid",
    Default = false,
    Callback = function(Value) getgenv().AutoRaid = Value end
})

TabFruitRaid:AddToggle({
    Name = "Auto Store Fruit",
    Default = false,
    Callback = function(Value) getgenv().AutoStoreFruit = Value end
})

TabFruitRaid:AddDropdown({
    Name = "Select Raid Type",
    Default = "Flame",
    Options = {"Flame", "Ice", "Quake", "Dark", "Light", "String", "Rumble", "Magma", "Human: Buddha", "Sand", "Dough", "Phoenix"},
    Callback = function(Value) getgenv().SelectedRaid = Value end
})

-- ===================================================================
-- Tab Sea Event
-- ===================================================================
TabSeaEvent:AddSection("Морские ивенты")

TabSeaEvent:AddToggle({
    Name = "Auto Sea Beast",
    Default = false,
    Callback = function(Value) getgenv().AutoSeaBeast = Value end
})

TabSeaEvent:AddToggle({
    Name = "Auto Ship Farm",
    Default = false,
    Callback = function(Value) getgenv().AutoShipFarm = Value end
})

TabSeaEvent:AddButton({
    Name = "Teleport to Sea",
    Callback = function()
        local player = game.Players.LocalPlayer
        if player.Character then
            player.Character:MoveTo(Vector3.new(0, 20, 0)) -- Плейсхолдер координат
        end
    end
})

-- ===================================================================
-- Tab Upgrade Race
-- ===================================================================
TabUpgradeRace:AddSection("Прокачка расы")

local RaceList = {"Human", "Skypian", "Fishman", "Mink", "Cyborg", "Ghoul"}
TabUpgradeRace:AddDropdown({
    Name = "Select Race",
    Default = "Human",
    Options = RaceList,
    Callback = function(Value) getgenv().SelectedRace = Value end
})

TabUpgradeRace:AddButton({
    Name = "Upgrade to V2",
    Callback = function()
        OrionLib:MakeNotification({
            Name = "Race Upgrade",
            Content = "Запущена прокачка до V2",
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end
})

TabUpgradeRace:AddButton({
    Name = "Upgrade to V3",
    Callback = function()
        OrionLib:MakeNotification({
            Name = "Race Upgrade",
            Content = "Запущена прокачка до V3",
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end
})

TabUpgradeRace:AddButton({
    Name = "Upgrade to V4",
    Callback = function()
        OrionLib:MakeNotification({
            Name = "Race Upgrade",
            Content = "Запущена прокачка до V4",
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end
})

-- ===================================================================
-- Tab Get
-- ===================================================================
TabGet:AddSection("Получить предметы")

TabGet:AddButton({
    Name = "Get All Swords",
    Callback = function()
        OrionLib:MakeNotification({
            Name = "Get Items",
            Content = "Получение всех мечей...",
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end
})

TabGet:AddButton({
    Name = "Get All Guns",
    Callback = function()
        OrionLib:MakeNotification({
            Name = "Get Items",
            Content = "Получение всего оружия...",
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end
})

TabGet:AddButton({
    Name = "Get All Accessories",
    Callback = function()
        OrionLib:MakeNotification({
            Name = "Get Items",
            Content = "Получение аксессуаров...",
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end
})

-- ===================================================================
-- Tab Volcan Event
-- ===================================================================
TabVolcanEvent:AddSection("Вулканический ивент")

TabVolcanEvent:AddToggle({
    Name = "Auto Volcano",
    Default = false,
    Callback = function(Value) getgenv().AutoVolcano = Value end
})

TabVolcanEvent:AddButton({
    Name = "Teleport to Volcano",
    Callback = function()
        local player = game.Players.LocalPlayer
        if player.Character then
            player.Character:MoveTo(Vector3.new(-5500, 550, -1500))
        end
    end
})

-- ===================================================================
-- Tab ESP
-- ===================================================================
TabESP:AddSection("ESP Настройки")

TabESP:AddToggle({
    Name = "Player ESP",
    Default = false,
    Callback = function(Value) getgenv().PlayerESP = Value end
})

TabESP:AddToggle({
    Name = "Fruit ESP",
    Default = false,
    Callback = function(Value) getgenv().FruitESP = Value end
})

TabESP:AddToggle({
    Name = "NPC ESP",
    Default = false,
    Callback = function(Value) getgenv().NPCCESP = Value end
})

TabESP:AddToggle({
    Name = "Chest ESP",
    Default = false,
    Callback = function(Value) getgenv().ChestESP = Value end
})

TabESP:AddColorpicker({
    Name = "ESP Color",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(Value) getgenv().ESPColor = Value end
})

-- ===================================================================
-- Tab PVP
-- ===================================================================
TabPVP:AddSection("PVP функции")

TabPVP:AddToggle({
    Name = "Kill Aura",
    Default = false,
    Callback = function(Value) getgenv().KillAura = Value end
})

TabPVP:AddSlider({
    Name = "Kill Aura Range",
    Min = 5,
    Max = 100,
    Default = 15,
    Color = Color3.fromRGB(255, 100, 100),
    Increment = 1,
    ValueName = "studs",
    Callback = function(Value) getgenv().KillAuraRange = Value end
})

TabPVP:AddToggle({
    Name = "Aim Assist",
    Default = false,
    Callback = function(Value) getgenv().AimAssist = Value end
})

TabPVP:AddToggle({
    Name = "No Stun",
    Default = false,
    Callback = function(Value)
        getgenv().NoStun = Value
        local player = game.Players.LocalPlayer
        if Value and player.Character then
            -- No Stun реализация
        end
    end
})

TabPVP:AddToggle({
    Name = "Infinity Combo",
    Default = false,
    Callback = function(Value) getgenv().InfinityCombo = Value end
})

-- ===================================================================
-- Закрытие / финализация Orion UI
-- ===================================================================
OrionLib:Init()

-- Автоматическое уведомление о загрузке
OrionLib:MakeNotification({
    Name = "redz Hub",
    Content = "Загружена реплика GUI. 11 вкладок активированы.",
    Image = "rbxassetid://4483345998",
    Time = 5
})
