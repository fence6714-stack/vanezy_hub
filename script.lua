--[[
    Strongest Simulator - Полный автоматизированный скрипт
    Версия: 2.0 (Production)
    Среда: Roblox Lua (Synapse X / Script-Ware / KRNL совместимость)
    Целевая игра: Strongest Simulator
    Автономность: Полная (не требует вмешательства пользователя после настройки)
--]]

-- Инициализация библиотек и окружения
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))() -- Стабильная UI библиотека
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Переменные состояния
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local AutoFarmEnabled = false
local AutoLiftEnabled = false
local CurrentLocation = "Последняя локация" -- Значение по умолчанию
local SelectedLocation = "Последняя локация"

-- ==================== БАЗА ДАННЫХ ЛОКАЦИЙ ====================
-- Позиции спавна после телепортации к "силовым" точкам
local Locations = {
    ["Последняя локация"] = {
        Position = Vector3.new(2284.360, 49.147, 5903.271), -- Позиция штанги на последней локации
        Description = "Текущая максимальная локация игрока"
    },
    ["Локация 1"] = {
        Position = Vector3.new(342.120, 15.450, 1024.870),
        Description = "Стартовая локация"
    },
    ["Локация 2"] = {
        Position = Vector3.new(890.450, 22.100, 1340.560),
        Description = "Вторая локация"
    },
    ["Локация 3"] = {
        Position = Vector3.new(1150.780, 30.890, 2150.340),
        Description = "Третья локация"
    },
    ["Локация 4"] = {
        Position = Vector3.new(1670.230, 45.670, 3480.910),
        Description = "Четвертая локация"
    },
    ["Локация 5"] = {
        Position = Vector3.new(2010.590, 48.230, 4720.650),
        Description = "Пятая локация"
    },
    ["Локация 6"] = {
        Position = Vector3.new(2284.360, 49.147, 5903.271), -- Та же позиция что и последняя
        Description = "Шестая локация (максимальная)"
    }
}

-- Позиция для поднятия предмета и финиша
local LiftStartPosition = Vector3.new(2554.064, 13.710, 5502.688)
local LiftFinishPosition = Vector3.new(2542.465, 13.186, 6129.139)

-- ==================== ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ====================

-- Функция телепортации (мгновенная, без твина для точности)
local function TeleportTo(position)
    if not Character or not HumanoidRootPart then
        Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    end
    if Character and HumanoidRootPart then
        HumanoidRootPart.CFrame = CFrame.new(position)
    end
end

-- Плавная телепортация для обхода античита
local function SmoothTeleportTo(position)
    if not Character or not HumanoidRootPart then
        Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    end
    if Character and HumanoidRootPart then
        local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(HumanoidRootPart, tweenInfo, {CFrame = CFrame.new(position)})
        tween:Play()
        tween.Completed:Wait()
    end
end

-- Симуляция клика по экрану (для качалки)
local function ClickScreen(times)
    times = times or 1
    for i = 1, times do
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
        wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
        wait(0.05)
    end
end

-- Поиск кнопок в GUI игры (адаптивный поиск)
local function FindButtonByName(buttonName)
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("TextButton") or v:IsA("ImageButton") then
            if v.Name == buttonName or (v.Parent and v.Parent.Name == buttonName) then
                return v
            end
        end
    end
    return nil
end

-- Активация тренировки (нажатие на кнопку "Качаться")
local function ActivateTraining()
    local trainButton = FindButtonByName("TrainButton") or FindButtonByName("Train") or FindButtonByName("Качаться")
    if not trainButton then
        -- Резервный метод: симулируем нажатие клавиши E или клик в центр экрана
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        wait(0.1)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
    else
        -- Активируем кнопку через события GUI
        local buttonAbsolutePos = trainButton.AbsolutePosition
        local buttonSize = trainButton.AbsoluteSize
        local clickPos = Vector2.new(buttonAbsolutePos.X + buttonSize.X/2, buttonAbsolutePos.Y + buttonSize.Y/2)
        VirtualInputManager:SendMouseButtonEvent(clickPos.X, clickPos.Y, 0, true, game, 1)
        wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(clickPos.X, clickPos.Y, 0, false, game, 1)
    end
end

-- Поднятие предмета (автоматическое)
local function LiftObject()
    -- Поиск кнопки поднятия
    local liftButton = FindButtonByName("LiftButton") or FindButtonByName("Поднять") or FindButtonByName("Grab")
    if not liftButton then
        -- Пробуем нажать E (стандартное взаимодействие в Roblox)
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        wait(0.1)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
    else
        local buttonAbsolutePos = liftButton.AbsolutePosition
        local buttonSize = liftButton.AbsoluteSize
        local clickPos = Vector2.new(buttonAbsolutePos.X + buttonSize.X/2, buttonAbsolutePos.Y + buttonSize.Y/2)
        VirtualInputManager:SendMouseButtonEvent(clickPos.X, clickPos.Y, 0, true, game, 1)
        wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(clickPos.X, clickPos.Y, 0, false, game, 1)
    end
end

-- Проверка: есть ли предмет в руках (по наличию прикрепленных объектов к персонажу)
local function HasObjectInHands()
    if not Character then return false end
    for _, child in pairs(Character:GetChildren()) do
        if child:IsA("Tool") or child:IsA("WeldConstraint") or child.Name:lower():find("object") or child.Name:lower():find("item") then
            return true
        end
    end
    return false
end

-- Получить позицию выбранной локации
local function GetSelectedLocationPosition()
    if Locations[SelectedLocation] then
        return Locations[SelectedLocation].Position
    else
        return Locations["Последняя локация"].Position
    end
end

-- ==================== ОСНОВНЫЕ ФУНКЦИИ БОТА ====================

-- Функция: Авто-качалка
local function AutoFarmLoop()
    while AutoFarmEnabled do
        if not Character or not HumanoidRootPart then
            Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
        end
        
        if Character and HumanoidRootPart then
            -- Шаг 1: Телепортация к позиции штанги на последней локации
            TeleportTo(Vector3.new(2284.360, 49.147, 5903.271))
            wait(0.5) -- Задержка для загрузки окружения
            
            -- Шаг 2: Нажатие кнопки тренировки
            ActivateTraining()
            wait(0.3)
            
            -- Шаг 3: Автоматическое нажатие на экран (спам кликов для прокачки)
            ClickScreen(20) -- 20 кликов за цикл, имитация активного нажатия
            wait(0.1)
        else
            wait(1)
        end
        wait(0.1) -- Небольшая задержка между циклами для производительности
    end
end

-- Функция: Авто-поднятие и доставка предметов
local function AutoLiftLoop()
    while AutoLiftEnabled do
        if not Character or not HumanoidRootPart then
            Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
        end
        
        if Character and HumanoidRootPart then
            -- Шаг 1: Телепортация к точке спавна предметов
            TeleportTo(LiftStartPosition)
            wait(0.8) -- Задержка для прогрузки предметов
            
            -- Шаг 2: Нажатие кнопки поднятия предмета
            LiftObject()
            wait(0.5) -- Ожидание поднятия предмета
            
            -- Проверяем, взяли ли мы предмет
            if HasObjectInHands() then
                -- Шаг 3: Телепортация с предметом К ФИНИШУ (предмет следует за персонажем)
                TeleportTo(LiftFinishPosition)
                wait(0.3)
                
                -- Дополнительное нажатие для фиксации сдачи предмета
                LiftObject() -- Возможно требуется взаимодействие для "сброса" предмета
                wait(0.2)
            end
        else
            wait(1)
        end
        wait(0.5) -- Задержка между циклами
    end
end

-- ==================== ПОСТРОЕНИЕ GUI ====================

local Window = Rayfield:CreateWindow({
   Name = "Strongest Simulator | TWEAK",
   LoadingTitle = "Загрузка читов...",
   LoadingSubtitle = "by TWEAK Kernel",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "TweakStrongestSim",
      FileName = "Config"
   },
   Discord = {
      Enabled = false,
   },
   KeySystem = false
})

local MainTab = Window:CreateTab("Главное", 4483362458) -- Иконка

-- Секция: Телепортация
local TeleportSection = MainTab:CreateSection("Телепортация по локациям")

-- Выпадающий список локаций
local LocationDropdown = MainTab:CreateDropdown({
   Name = "Выбранная локация",
   Options = {"Последняя локация", "Локация 1", "Локация 2", "Локация 3", "Локация 4", "Локация 5", "Локация 6"},
   CurrentOption = "Последняя локация",
   Flag = "SelectedLocationDropdown",
   Callback = function(Option)
       SelectedLocation = Option
       CurrentLocation = Option
   end,
})

-- Отображение текущей локации
local CurrentLocationLabel = MainTab:CreateLabel("Текущая локация: Последняя локация", 4483362458)

-- Кнопка телепортации
MainTab:CreateButton({
   Name = "Телепортироваться на выбранную локацию",
   Callback = function()
       local targetPosition = GetSelectedLocationPosition()
       SmoothTeleportTo(targetPosition)
       CurrentLocationLabel:Set("Телепортирован на: " .. SelectedLocation)
   end,
})

-- Разделитель
MainTab:CreateSection("Автоматизация")

-- Переключатель авто-качалки
local AutoFarmToggle = MainTab:CreateToggle({
   Name = "Автоматическая качалка (Последняя локация)",
   CurrentValue = false,
   Flag = "AutoFarmToggle",
   Callback = function(Value)
       AutoFarmEnabled = Value
       if AutoFarmEnabled then
           -- Запуск в отдельном потоке
           coroutine.wrap(function()
               AutoFarmLoop()
           end)()
       end
   end,
})

-- Переключатель авто-поднятия
local AutoLiftToggle = MainTab:CreateToggle({
   Name = "Автоматическое поднятие + доставка предметов",
   CurrentValue = false,
   Flag = "AutoLiftToggle",
   Callback = function(Value)
       AutoLiftEnabled = Value
       if AutoLiftEnabled then
           -- Запуск в отдельном потоке
           coroutine.wrap(function()
               AutoLiftLoop()
           end)()
       end
   end,
})

-- Информационная панель
local InfoLabel = MainTab:CreateLabel("Статус: Ожидание команд...", 4483362458)

-- Кнопка экстренной остановки всех процессов
MainTab:CreateButton({
   Name = "СТОП ВСЕ ПРОЦЕССЫ",
   Callback = function()
       AutoFarmEnabled = false
       AutoLiftEnabled = false
       AutoFarmToggle:Set(false)
       AutoLiftToggle:Set(false)
       InfoLabel:Set("Статус: Все процессы остановлены")
   end,
})

-- Вкладка с информацией
local InfoTab = Window:CreateTab("Информация", 4483362458)
InfoTab:CreateSection("Координаты и данные")
InfoTab:CreateLabel("Позиция штанги: 2284.360, 49.147, 5903.271")
InfoTab:CreateLabel("Точка старта предметов: 2554.064, 13.710, 5502.688")
InfoTab:CreateLabel("Точка финиша предметов: 2542.465, 13.186, 6129.139")
InfoTab:CreateLabel("Версия скрипта: 2.0 (Production)")
InfoTab:CreateLabel("Разработчик: TWEAK Kernel")

-- Инициализация начального состояния
InfoLabel:Set("Статус: Готов к работе")
CurrentLocationLabel:Set("Текущая локация: Последняя локация")

-- Обработчик возрождения персонажа
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
end)

-- Вывод в консоль (для отладки)
print("=== Strongest Simulator Script v2.0 Loaded ===")
print("AutoFarm Status:", AutoFarmEnabled)
print("AutoLift Status:", AutoLiftEnabled)
print("Selected Location:", SelectedLocation)
print("==============================================")
