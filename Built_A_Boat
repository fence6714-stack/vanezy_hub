-- VFF Hub - Blox Fruits Fruit Farmer
-- Version: 2.0.0
-- Совместим с большинством экзекуторов (Synapse X, Krnl, Fluxus, Scriptware и др.)

-- ============================================================================
-- БИБЛИОТЕКИ И УТИЛИТЫ
-- ============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- ============================================================================
-- НАСТРОЙКИ И СОХРАНЕНИЕ
-- ============================================================================

local Settings = {
    FarmFruit = false,
    AntiAFK = false,
    AutoRejoin = false
}

local SaveFileName = "VFF_Hub_Settings"
local SaveData = {}

-- Функция сохранения настроек
local function SaveSettings()
    local success, encoded = pcall(function()
        return HttpService:JSONEncode({
            FarmFruit = Settings.FarmFruit,
            AntiAFK = Settings.AntiAFK,
            AutoRejoin = Settings.AutoRejoin
        })
    end)
    
    if success then
        writefile(SaveFileName .. ".txt", encoded)
        print("[VFF Hub] Настройки сохранены")
        return true
    end
    return false
end

-- Функция загрузки настроек
local function LoadSettings()
    local success, data = pcall(function()
        return readfile(SaveFileName .. ".txt")
    end)
    
    if success and data then
        local decoded = HttpService:JSONDecode(data)
        Settings.FarmFruit = decoded.FarmFruit or false
        Settings.AntiAFK = decoded.AntiAFK or false
        Settings.AutoRejoin = decoded.AutoRejoin or false
        print("[VFF Hub] Настройки загружены")
        return true
    end
    return false
end

-- ============================================================================
-- ФУНКЦИЯ ДЛЯ ФАРМА ФРУКТОВ
-- ============================================================================

local FruitsList = {
    "Bomb-Bomb Fruit",
    "Spike-Spike Fruit",
    "Chop-Chop Fruit",
    "Spring-Spring Fruit",
    "Kilo-Kilo Fruit",
    "Spin-Spin Fruit",
    "Love-Love Fruit",
    "Ice-Ice Fruit",
    "Sand-Sand Fruit",
    "Dark-Dark Fruit",
    "Revive-Revive Fruit",
    "Diamond-Diamond Fruit",
    "Light-Light Fruit",
    "Rubber-Rubber Fruit",
    "Barrier-Barrier Fruit",
    "Magma-Magma Fruit",
    "Quake-Quake Fruit",
    "Buddha-Buddha Fruit",
    "Flame-Flame Fruit",
    "Spider-Spider Fruit",
    "Rumble-Rumble Fruit",
    "Portal-Portal Fruit",
    "Phoenix-Phoenix Fruit",
    "Dough-Dough Fruit",
    "Shadow-Shadow Fruit",
    "Venom-Venom Fruit",
    "Control-Control Fruit",
    "Spirit-Spirit Fruit",
    "Dragon-Dragon Fruit",
    "Leopard-Leopard Fruit"
}

local FarmRunning = false
local LastFruitPosition = nil
local FruitCheckInterval = 2
local MaxDistance = 500
local RejoinAttempts = 0

-- Телепортация к позиции
local function TeleportTo(position)
    if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        Player.Character.HumanoidRootPart.CFrame = CFrame.new(position)
    end
end

-- Сбор фрукта
local function CollectFruit(fruit)
    if fruit and fruit.Parent then
        local fruitPos = fruit.Position
        TeleportTo(fruitPos)
        wait(0.2)
        
        if fruit.Parent then
            fireclickdetector(fruit.ClickDetector)
            wait(0.3)
            return true
        end
    end
    return false
end

-- Поиск фруктов на карте
local function FindFruits()
    local fruits = {}
    local workspaceItems = workspace:GetDescendants()
    
    for _, item in ipairs(workspaceItems) do
        if item:IsA("Model") and item.Name == "Fruit" then
            local fruitPart = item:FindFirstChild("Handle")
            if fruitPart and fruitPart:IsA("BasePart") then
                table.insert(fruits, fruitPart)
            end
        elseif item:IsA("BasePart") and item.Name == "Fruit" then
            table.insert(fruits, item)
        end
    end
    
    return fruits
end

-- Основной цикл фарма фруктов
local function FarmFruits()
    while FarmRunning and Settings.FarmFruit and Player and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") do
        local fruits = FindFruits()
        
        if #fruits > 0 then
            -- Сортируем фрукты по расстоянию
            local characterPos = Player.Character.HumanoidRootPart.Position
            table.sort(fruits, function(a, b)
                return (a.Position - characterPos).Magnitude < (b.Position - characterPos).Magnitude
            end)
            
            -- Собираем ближайший фрукт
            for _, fruit in ipairs(fruits) do
                if FarmRunning and Settings.FarmFruit then
                    local distance = (fruit.Position - characterPos).Magnitude
                    if distance <= MaxDistance then
                        CollectFruit(fruit)
                        wait(0.5)
                        break
                    else
                        TeleportTo(fruit.Position)
                        wait(0.3)
                        CollectFruit(fruit)
                        wait(0.5)
                    end
                end
            end
        else
            -- Если фруктов нет, проверяем настройку AutoRejoin
            if Settings.AutoRejoin and not game:GetService("CoreGui"):FindFirstChild("TeleportPrompt") then
                RejoinAttempts = RejoinAttempts + 1
                print("[VFF Hub] Фруктов не найдено, перезаход через " .. (RejoinAttempts * 2) .. " сек")
                wait(RejoinAttempts * 2)
                
                if not FindFruits() or #FindFruits() == 0 then
                    if Settings.AutoRejoin then
                        TeleportService:Teleport(game.PlaceId)
                        wait(5)
                    end
                end
            else
                wait(FruitCheckInterval)
            end
        end
        
        wait(0.5)
    end
end

-- Запуск фарма
local function StartFarm()
    if FarmRunning then return end
    FarmRunning = true
    spawn(function()
        FarmFruits()
    end)
end

-- Остановка фарма
local function StopFarm()
    FarmRunning = false
end

-- ============================================================================
-- ФУНКЦИИ АНТИ-АФК
-- ============================================================================

local AntiAFKRunning = false

local function AntiAFK()
    while AntiAFKRunning and Settings.AntiAFK do
        if Player.Character and Player.Character:FindFirstChild("Humanoid") then
            local humanoid = Player.Character.Humanoid
            if humanoid.Sit then
                humanoid.Sit = false
            end
            
            -- Имитация движения камеры
            local ts = game:GetService("TweenService")
            local camera = workspace.CurrentCamera
            local originalCF = camera.CFrame
            local newCF = originalCF * CFrame.Angles(0, math.rad(1), 0)
            
            ts:Create(camera, TweenInfo.new(0.5), {CFrame = newCF}):Play()
            wait(0.5)
            ts:Create(camera, TweenInfo.new(0.5), {CFrame = originalCF}):Play()
        end
        
        -- Эмуляция движения мыши
        if UserInputService and VirtualUser then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton1(Vector2.new(0, 0))
            end)
        end
        
        wait(60) -- Каждую минуту
    end
end

local function StartAntiAFK()
    if AntiAFKRunning then return end
    AntiAFKRunning = true
    spawn(function()
        AntiAFK()
    end)
end

local function StopAntiAFK()
    AntiAFKRunning = false
end

-- ============================================================================
-- ФУНКЦИИ АВТО-ПЕРЕЗАХОДА
-- ============================================================================

local AutoRejoinRunning = false
local PlaceId = game.PlaceId

local function AutoRejoinLoop()
    while AutoRejoinRunning and Settings.AutoRejoin do
        -- Проверяем наличие фруктов
        local fruits = FindFruits()
        
        if #fruits == 0 then
            print("[VFF Hub] Нет фруктов, перезаход через 5 секунд...")
            wait(5)
            
            if #FindFruits() == 0 then
                TeleportService:Teleport(PlaceId)
                wait(10)
            end
        end
        
        -- Проверка на отключение
        local success, err = pcall(function()
            return Players.LocalPlayer and Players.LocalPlayer.Character
        end)
        
        if not success then
            wait(3)
            TeleportService:Teleport(PlaceId)
            wait(10)
        end
        
        wait(30)
    end
end

local function StartAutoRejoin()
    if AutoRejoinRunning then return end
    AutoRejoinRunning = true
    spawn(function()
        AutoRejoinLoop()
    end)
end

local function StopAutoRejoin()
    AutoRejoinRunning = false
end

-- ============================================================================
-- СОЗДАНИЕ GUI
-- ============================================================================

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TitleLabel = Instance.new("TextLabel")
local SubtitleLabel = Instance.new("TextLabel")
local FarmButton = Instance.new("TextButton")
local FarmToggle = Instance.new("TextButton")
local AntiAFKButton = Instance.new("TextButton")
local AntiAFKToggle = Instance.new("TextButton")
local AutoRejoinButton = Instance.new("TextButton")
local AutoRejoinToggle = Instance.new("TextButton")
local SaveButton = Instance.new("TextButton")
local CloseButton = Instance.new("TextButton")
local DragBar = Instance.new("Frame")

-- Настройка GUI
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.Name = "VFFHub"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- MainFrame
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BackgroundTransparency = 0.05
MainFrame.BorderColor3 = Color3.fromRGB(100, 50, 200)
MainFrame.BorderSizePixel = 2
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
MainFrame.Size = UDim2.new(0, 400, 0, 350)
MainFrame.ClipsDescendants = true
MainFrame.Active = true
MainFrame.Draggable = true

-- Анимация появления
MainFrame.BackgroundTransparency = 1
TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {BackgroundTransparency = 0.05}):Play()

-- DragBar (для перетаскивания)
DragBar.Parent = MainFrame
DragBar.BackgroundColor3 = Color3.fromRGB(100, 50, 200)
DragBar.BackgroundTransparency = 0.5
DragBar.Position = UDim2.new(0, 0, 0, 0)
DragBar.Size = UDim2.new(1, 0, 0, 30)
DragBar.Active = true
DragBar.Draggable = true

-- Title
TitleLabel.Parent = MainFrame
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0, 0, 0, 5)
TitleLabel.Size = UDim2.new(1, 0, 0, 30)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "VFF HUB"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 24
TitleLabel.TextScaled = false

-- Subtitle
SubtitleLabel.Parent = MainFrame
SubtitleLabel.BackgroundTransparency = 1
SubtitleLabel.Position = UDim2.new(0, 0, 0, 35)
SubtitleLabel.Size = UDim2.new(1, 0, 0, 20)
SubtitleLabel.Font = Enum.Font.Gotham
SubtitleLabel.Text = "vanezy fruit farm"
SubtitleLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
SubtitleLabel.TextSize = 14

-- Close Button
CloseButton.Parent = MainFrame
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.Size = UDim2.new(0, 30, 0, 25)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "✕"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 16
CloseButton.BorderSizePixel = 0

-- Farm Fruit Section
local FarmSection = Instance.new("TextLabel")
FarmSection.Parent = MainFrame
FarmSection.BackgroundTransparency = 1
FarmSection.Position = UDim2.new(0, 20, 0, 70)
FarmSection.Size = UDim2.new(1, -40, 0, 30)
FarmSection.Font = Enum.Font.GothamBold
FarmSection.Text = "🍎 FARM FRUIT"
FarmSection.TextColor3 = Color3.fromRGB(255, 255, 255)
FarmSection.TextSize = 16
FarmSection.TextXAlignment = Enum.TextXAlignment.Left

-- Farm Toggle (полукруглый ползунок)
FarmToggle.Parent = MainFrame
FarmToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
FarmToggle.Position = UDim2.new(1, -80, 0, 70)
FarmToggle.Size = UDim2.new(0, 60, 0, 30)
FarmToggle.BorderSizePixel = 0
FarmToggle.Text = "OFF"
FarmToggle.TextColor3 = Color3.fromRGB(200, 200, 200)
FarmToggle.TextSize = 14

local FarmToggleCircle = Instance.new("Frame")
FarmToggleCircle.Parent = FarmToggle
FarmToggleCircle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
FarmToggleCircle.Position = UDim2.new(0, 5, 0, 5)
FarmToggleCircle.Size = UDim2.new(0, 20, 0, 20)
FarmToggleCircle.BorderSizePixel = 0

-- Anti AFK Section
local AntiAFKSection = Instance.new("TextLabel")
AntiAFKSection.Parent = MainFrame
AntiAFKSection.BackgroundTransparency = 1
AntiAFKSection.Position = UDim2.new(0, 20, 0, 110)
AntiAFKSection.Size = UDim2.new(1, -40, 0, 30)
AntiAFKSection.Font = Enum.Font.GothamBold
AntiAFKSection.Text = "🛡️ ANTI AFK"
AntiAFKSection.TextColor3 = Color3.fromRGB(255, 255, 255)
AntiAFKSection.TextSize = 16
AntiAFKSection.TextXAlignment = Enum.TextXAlignment.Left

-- Anti AFK Toggle
AntiAFKToggle.Parent = MainFrame
AntiAFKToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
AntiAFKToggle.Position = UDim2.new(1, -80, 0, 110)
AntiAFKToggle.Size = UDim2.new(0, 60, 0, 30)
AntiAFKToggle.BorderSizePixel = 0
AntiAFKToggle.Text = "OFF"
AntiAFKToggle.TextColor3 = Color3.fromRGB(200, 200, 200)
AntiAFKToggle.TextSize = 14

local AntiAFKToggleCircle = Instance.new("Frame")
AntiAFKToggleCircle.Parent = AntiAFKToggle
AntiAFKToggleCircle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
AntiAFKToggleCircle.Position = UDim2.new(0, 5, 0, 5)
AntiAFKToggleCircle.Size = UDim2.new(0, 20, 0, 20)
AntiAFKToggleCircle.BorderSizePixel = 0

-- Auto Rejoin Section
local AutoRejoinSection = Instance.new("TextLabel")
AutoRejoinSection.Parent = MainFrame
AutoRejoinSection.BackgroundTransparency = 1
AutoRejoinSection.Position = UDim2.new(0, 20, 0, 150)
AutoRejoinSection.Size = UDim2.new(1, -40, 0, 30)
AutoRejoinSection.Font = Enum.Font.GothamBold
AutoRejoinSection.Text = "🔄 AUTO REJOIN"
AutoRejoinSection.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoRejoinSection.TextSize = 16
AutoRejoinSection.TextXAlignment = Enum.TextXAlignment.Left

-- Auto Rejoin Toggle
AutoRejoinToggle.Parent = MainFrame
AutoRejoinToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
AutoRejoinToggle.Position = UDim2.new(1, -80, 0, 150)
AutoRejoinToggle.Size = UDim2.new(0, 60, 0, 30)
AutoRejoinToggle.BorderSizePixel = 0
AutoRejoinToggle.Text = "OFF"
AutoRejoinToggle.TextColor3 = Color3.fromRGB(200, 200, 200)
AutoRejoinToggle.TextSize = 14

local AutoRejoinToggleCircle = Instance.new("Frame")
AutoRejoinToggleCircle.Parent = AutoRejoinToggle
AutoRejoinToggleCircle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
AutoRejoinToggleCircle.Position = UDim2.new(0, 5, 0, 5)
AutoRejoinToggleCircle.Size = UDim2.new(0, 20, 0, 20)
AutoRejoinToggleCircle.BorderSizePixel = 0

-- Save Button
SaveButton.Parent = MainFrame
SaveButton.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
SaveButton.Position = UDim2.new(0.5, -80, 1, -60)
SaveButton.Size = UDim2.new(0, 160, 0, 40)
SaveButton.Font = Enum.Font.GothamBold
SaveButton.Text = "💾 СОХРАНИТЬ"
SaveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveButton.TextSize = 16
SaveButton.BorderSizePixel = 0

-- ============================================================================
-- ФУНКЦИИ УПРАВЛЕНИЯ GUI И ТОГГЛАМИ
-- ============================================================================

-- Функция обновления внешнего вида ползунка
local function UpdateToggle(toggle, circle, state)
    if state then
        toggle.BackgroundColor3 = Color3.fromRGB(50, 150, 100)
        toggle.Text = "ON"
        toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
        circle.BackgroundColor3 = Color3.fromRGB(100, 255, 150)
        circle.Position = UDim2.new(0, 35, 0, 5)
    else
        toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        toggle.Text = "OFF"
        toggle.TextColor3 = Color3.fromRGB(200, 200, 200)
        circle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        circle.Position = UDim2.new(0, 5, 0, 5)
    end
end

-- Функция обновления состояния фарма
local function SetFarmState(state)
    Settings.FarmFruit = state
    UpdateToggle(FarmToggle, FarmToggleCircle, state)
    
    if state then
        StartFarm()
    else
        StopFarm()
    end
end

-- Функция обновления состояния анти-афк
local function SetAntiAFKState(state)
    Settings.AntiAFK = state
    UpdateToggle(AntiAFKToggle, AntiAFKToggleCircle, state)
    
    if state then
        StartAntiAFK()
    else
        StopAntiAFK()
    end
end

-- Функция обновления состояния авто-перезахода
local function SetAutoRejoinState(state)
    Settings.AutoRejoin = state
    UpdateToggle(AutoRejoinToggle, AutoRejoinToggleCircle, state)
    
    if state then
        StartAutoRejoin()
    else
        StopAutoRejoin()
    end
end

-- Обработчики кнопок
FarmToggle.MouseButton1Click:Connect(function()
    SetFarmState(not Settings.FarmFruit)
end)

AntiAFKToggle.MouseButton1Click:Connect(function()
    SetAntiAFKState(not Settings.AntiAFK)
end)

AutoRejoinToggle.MouseButton1Click:Connect(function()
    SetAutoRejoinState(not Settings.AutoRejoin)
end)

-- Сохранение настроек
SaveButton.MouseButton1Click:Connect(function()
    SaveSettings()
    
    -- Анимация кнопки
    local originalColor = SaveButton.BackgroundColor3
    SaveButton.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
    wait(0.2)
    SaveButton.BackgroundColor3 = originalColor
    
    print("[VFF Hub] Настройки сохранены!")
end)

-- Закрытие GUI
CloseButton.MouseButton1Click:Connect(function()
    -- Останавливаем все процессы
    SetFarmState(false)
    SetAntiAFKState(false)
    SetAutoRejoinState(false)
    
    -- Анимация закрытия
    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundTransparency = 1}):Play()
    wait(0.3)
    ScreenGui:Destroy()
end)

-- ============================================================================
-- ИНИЦИАЛИЗАЦИЯ
-- ============================================================================

print("[VFF Hub] VFF Hub загружен!")
print("[VFF Hub] vanezy fruit farm")

-- Загрузка сохраненных настроек
LoadSettings()

-- Применение загруженных настроек
SetFarmState(Settings.FarmFruit)
SetAntiAFKState(Settings.AntiAFK)
SetAutoRejoinState(Settings.AutoRejoin)

-- Анимация появления GUI
TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Size = UDim2.new(0, 400, 0, 350)}):Play()

-- Изменяемый размер окна (опционально)
local dragging = false
local dragStartPos = nil
local dragStartFramePos = nil

DragBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStartPos = input.Position
        dragStartFramePos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStartPos
        MainFrBackgroundTransparencyew(
            dragStartFramePos.X.Scale,
            dragStartFramePos.X.Offset + delta.X,
            dragStartFramePos.Y.Scale,
            dragStartFramePos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

print("[VFF Hub] Интерфейс загружен. Используйте кнопку Save для сохранения настроек!")
