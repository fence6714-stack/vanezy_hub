--[[
    redz Hub: Blox Fruits GUI Recreation - ИСПРАВЛЕННАЯ ВЕРСИЯ
    Убраны rbxassetid, PremiumOnly, добавлена проверка PlaceId
    Библиотека: Orion UI (raw GitHub, без внешних ассетов)
--]]

-- Проверка игры Blox Fruits
local AllowedPlaces = {
    2753915549, -- First Sea
    4442272183, -- Second Sea
    7449423635  -- Third Sea
}
if not table.find(AllowedPlaces, game.PlaceId) then
    local player = game.Players.LocalPlayer
    if player then
        player:Kick("redz Hub: Запустите скрипт ТОЛЬКО в Blox Fruits!")
    end
    return
end

-- Загрузка Orion UI
local success, OrionLib = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Qanuir/orion-ui/main/source"))()
end)

if not success then
    warn("Ошибка загрузки Orion UI: " .. tostring(OrionLib))
    -- Фолбэк: пробуем альтернативную ссылку
    success, OrionLib = pcall(function()
        return loadstring(game:HttpGet("https://pastebin.com/raw/8QXKsdNX"))()
    end)
    if not success then
        error("Не удалось загрузить Orion UI. Проверьте интернет или используйте другой инжектор.")
    end
end

-- Создание окна (без rbxassetid, без PremiumOnly)
local Window = OrionLib:MakeWindow({
    Name = "redz Hub: Blox Fruits",
    SubTitle = "by real redz | VanezyScripts",
    SaveConfig = true,
    ConfigFolder = "RedzHub_Config",
    IntroEnabled = false, -- Убрано интро для ускорения запуска
    IntroText = ""
})

-- Создание вкладок (иконки заменены на текстовые маркеры)
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
-- Tab Local Player
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

-- ===================================================================
-- Tab Setting Farm
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

-- ===================================================================
-- Tab Farming (ГЛАВНАЯ ВКЛАДКА СО СКРИНШОТА)
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
        while getgenv().FarmMaterialActive do
            task.wait(1)
        end
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
        if player and player.Character then
            player.Character:MoveTo(Vector3.new(0, 20, 0))
        end
    end
})

-- ===================================================================
-- Tab Upgrade Race
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
-- Tab Get
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
        if player and player.Character then
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
    Callback = function(Value) getgenv().NPCESP = Value end
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
    Callback = function(Value) getgenv().NoStun = Value end
})

TabPVP:AddToggle({
    Name = "Infinity Combo",
    Default = false,
    Callback = function(Value) getgenv().InfinityCombo = Value end
})

-- ===================================================================
-- ФИНАЛИЗАЦИЯ
-- ===================================================================
OrionLib:Init()

-- Уведомление
task.wait(0.5)
pcall(function()
    OrionLib:MakeNotification({
        Name = "redz Hub",
        Content = "GUI загружен! PlaceId: " .. game.PlaceId,
        Time = 5
    })
end)

print("redz Hub Recreation загружен успешно.")
