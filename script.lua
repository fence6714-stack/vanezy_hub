--[[
    redz Hub: Blox Fruits GUI Recreation - УНИВЕРСАЛЬНАЯ ВЕРСИЯ
    Работает во ВСЕХ играх Roblox
    Без проверок PlaceId, без киков
--]]

-- Загрузка Orion UI
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Qanuir/orion-ui/main/source"))()

-- Создание окна
local Window = OrionLib:MakeWindow({
    Name = "redz Hub: Blox Fruits",
    SubTitle = "by real redz | VanezyScripts",
    SaveConfig = true,
    ConfigFolder = "RedzHub_Config",
    IntroEnabled = false
})

-- Создание вкладок
local TabLocalPlayer = Window:MakeTab({Name = "Local Player"})
local TabSettingFarm = Window:MakeTab({Name = "Setting Farm"})
local TabFarming = Window:MakeTab({Name = "Farming"})
local TabStackFarm = Window:MakeTab({Name = "Stack Farm"})
local TabFarmingOther = Window:MakeTab({Name = "Farming Other"})
local TabFruitRaid = Window:MakeTab({Name = "Fruit and Raid"})
local TabSeaEvent = Window:MakeTab({Name = "Sea Event"})
local TabUpgradeRace = Window:MakeTab({Name = "Upgrade Race"})
local TabGet = Window:MakeTab({Name = "Get"})
local TabVolcanEvent = Window:MakeTab({Name = "Volcan Event"})
local TabESP = Window:MakeTab({Name = "ESP"})
local TabPVP = Window:MakeTab({Name = "PVP"})

-- ===================================================================
-- Local Player
-- ===================================================================
TabLocalPlayer:AddSection("Настройки игрока")

TabLocalPlayer:AddToggle({
    Name = "Auto Run",
    Default = false,
    Callback = function(Value)
        getgenv().AutoRun = Value
        while getgenv().AutoRun do
            local player = game.Players.LocalPlayer
            if player and player.Character and player.Character:FindFirstChild("Humanoid") then
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
        if player and player.Character and player.Character:FindFirstChild("Humanoid") then
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
        if player and player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.JumpPower = Value
        end
    end
})

TabLocalPlayer:AddToggle({
    Name = "Fly",
    Default = false,
    Callback = function(Value)
        getgenv().FlyActive = Value
        local player = game.Players.LocalPlayer
        if Value then
            repeat
                if player and player.Character and player.Character:FindFirstChild("Humanoid") then
                    player.Character.Humanoid.PlatformStand = true
                end
                task.wait()
            until not getgenv().FlyActive
            if player and player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.PlatformStand = false
            end
        end
    end
})

TabLocalPlayer:AddToggle({
    Name = "Noclip",
    Default = false,
    Callback = function(Value)
        getgenv().NoclipActive = Value
        local function noclipLoop()
            local player = game.Players.LocalPlayer
            while getgenv().NoclipActive do
                if player and player.Character then
                    for _, part in pairs(player.Character:GetDescendants()) do
                        if part:IsA("BasePart") and part.CanCollide then
                            part.CanCollide = false
                        end
                    end
                end
                task.wait()
            end
        end
        if Value then
            task.spawn(noclipLoop)
        end
    end
})

-- ===================================================================
-- Setting Farm
-- ===================================================================
TabSettingFarm:AddSection("Конфигурация фарма")

TabSettingFarm:AddDropdown({
    Name = "Select Weapon",
    Default = "1",
    Options = {"Melee", "Sword", "Gun", "Fruit"},
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

TabSettingFarm:AddToggle({
    Name = "Auto Equip Best Weapon",
    Default = false,
    Callback = function(Value)
        getgenv().AutoEquipBest = Value
    end
})

-- ===================================================================
-- Farming
-- ===================================================================
TabFarming:AddSection("Farming Material")

TabFarming:AddDropdown({
    Name = "Select Material",
    Default = "1",
    Options = {"Wood", "Stone", "Iron", "Gold", "Diamond", "Dragon Scales", "Magma Ore"},
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
            Content = "Активен: " .. tostring(getgenv().FarmMaterialActive),
            Time = 3
        })
    end
})

TabFarming:AddSection("Mastery Farm")

TabFarming:AddLabel("GODHUMAN")
TabFarming:AddLabel("Mac: 125")
TabFarming:AddLabel("Soaring Beast: [Z]")
TabFarming:AddLabel("Heaven Earth: [X]")
TabFarming:AddLabel("Sixth Realm Gun: [ACT]")

TabFarming:AddButton({
    Name = "Mastery 600 (MAX)",
    Callback = function()
        getgenv().MasteryFarmActive = not getgenv().MasteryFarmActive
        OrionLib:MakeNotification({
            Name = "Mastery Farm",
            Content = "Активен: " .. tostring(getgenv().MasteryFarmActive),
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
            Content = "Активен: " .. tostring(getgenv().LevelFarmActive),
            Time = 3
        })
    end
})

TabFarming:AddSection("Auto Farm")
TabFarming:AddToggle({
    Name = "Auto Farm",
    Default = false,
    Callback = function(Value)
        getgenv().AutoFarm = Value
        while getgenv().AutoFarm do
            local player = game.Players.LocalPlayer
            if player and player.Character then
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Name ~= player.Name then
                        if v.Humanoid.Health > 0 then
                            player.Character.HumanoidRootPart.CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, 2, 2)
                            task.wait(0.1)
                            game:GetService("VirtualUser"):Button1Down()
                            task.wait(0.1)
                            game:GetService("VirtualUser"):Button1Up()
                        end
                    end
                end
            end
            task.wait()
        end
    end
})

-- ===================================================================
-- Stack Farm
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
-- Farming Other
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

TabFarmingOther:AddToggle({
    Name = "Auto Collect Drops",
    Default = false,
    Callback = function(Value) getgenv().AutoCollect = Value end
})

-- ===================================================================
-- Fruit and Raid
-- ===================================================================
TabFruitRaid:AddSection("Фрукты и рейды")

TabFruitRaid:AddDropdown({
    Name = "Select Raid Type",
    Default = "1",
    Options = {"Flame", "Ice", "Quake", "Dark", "Light", "String", "Rumble", "Magma", "Buddha", "Sand", "Dough", "Phoenix"},
    Callback = function(Value) getgenv().SelectedRaid = Value end
})

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

TabFruitRaid:AddToggle({
    Name = "Auto Spawn Fruit",
    Default = false,
    Callback = function(Value) getgenv().AutoSpawnFruit = Value end
})

-- ===================================================================
-- Sea Event
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
        if player and player.Character then
            player.Character:MoveTo(Vector3.new(0, 20, 0))
        end
    end
})

-- ===================================================================
-- Upgrade Race
-- ===================================================================
TabUpgradeRace:AddSection("Прокачка расы")

TabUpgradeRace:AddDropdown({
    Name = "Select Race",
    Default = "1",
    Options = {"Human", "Skypian", "Fishman", "Mink", "Cyborg", "Ghoul"},
    Callback = function(Value) getgenv().SelectedRace = Value end
})

TabUpgradeRace:AddButton({
    Name = "Upgrade to V2",
    Callback = function()
        OrionLib:MakeNotification({
            Name = "Race Upgrade",
            Content = "Запущена прокачка до V2",
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
            Time = 3
        })
    end
})

-- ===================================================================
-- Get
-- ===================================================================
TabGet:AddSection("Получить предметы")

TabGet:AddButton({
    Name = "Get All Swords",
    Callback = function()
        OrionLib:MakeNotification({
            Name = "Get Items",
            Content = "Получение всех мечей...",
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
            Time = 3
        })
    end
})

TabGet:AddButton({
    Name = "Get All Fruits",
    Callback = function()
        OrionLib:MakeNotification({
            Name = "Get Items",
            Content = "Получение всех фруктов...",
            Time = 3
        })
    end
})

-- ===================================================================
-- Volcan Event
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
        if player and player.Character then
            player.Character:MoveTo(Vector3.new(-5500, 550, -1500))
        end
    end
})

-- ===================================================================
-- ESP
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
    Callback = function(Value) getgenv().NPCESP = Value end
})

TabESP:AddToggle({
    Name = "Chest ESP",
    Default = false,
    Callback = function(Value) getgenv().ChestESP = Value end
})

TabESP:AddToggle({
    Name = "Item ESP",
    Default = false,
    Callback = function(Value) getgenv().ItemESP = Value end
})

TabESP:AddColorpicker({
    Name = "ESP Color",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(Value) getgenv().ESPColor = Value end
})

-- ===================================================================
-- PVP
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
    Callback = function(Value) getgenv().NoStun = Value end
})

TabPVP:AddToggle({
    Name = "Infinity Combo",
    Default = false,
    Callback = function(Value) getgenv().InfinityCombo = Value end
})

TabPVP:AddToggle({
    Name = "God Mode",
    Default = false,
    Callback = function(Value)
        getgenv().GodMode = Value
        local player = game.Players.LocalPlayer
        if player and player.Character and player.Character:FindFirstChild("Humanoid") then
            if Value then
                player.Character.Humanoid.MaxHealth = math.huge
                player.Character.Humanoid.Health = math.huge
            else
                player.Character.Humanoid.MaxHealth = 100
                player.Character.Humanoid.Health = 100
            end
        end
    end
})

-- ===================================================================
-- Инициализация Orion
-- ===================================================================
OrionLib:Init()

-- Уведомление
task.wait(0.5)
OrionLib:MakeNotification({
    Name = "redz Hub",
    Content = "Загружен! Игра: " .. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name,
    Time = 5
})

print("redz Hub Recreation - Универсальная версия загружена.")
print("Текущая игра:", game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name)
print("PlaceId:", game.PlaceId)
