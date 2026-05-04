--[[
    STRONGEST SIMULATOR - АВТО-ШТАНГА v6
    Алгоритм: Телепорт → пауза 0.5с → зажать 1с → клики раз в 0.7с (бесконечно)
    Повтор только при перезапуске (выкл/вкл тоггла)
    GUI: 300x200
--]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    HumanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
    Humanoid = newChar:WaitForChild("Humanoid")
    if AutoFarmEnabled then
        -- При респавне запускаем только клики, без повтора инициализации
        task.spawn(clickLoopOnly)
    end
end)

-- ==================== ДАННЫЕ ====================
local TrainingPosition = Vector3.new(2284.360, 49.147, 5903.271)
local AutoFarmEnabled = false
local freezeConnection = nil
local initializationDone = false -- Флаг: была ли инициализация

-- ==================== УТИЛИТЫ ====================
local function teleportTo(pos)
    if Character and HumanoidRootPart then
        HumanoidRootPart.CFrame = CFrame.new(pos)
    end
end

-- Заморозка в воздухе
local function freezeCharacter()
    if not Character or not HumanoidRootPart then return end
    if freezeConnection then freezeConnection:Disconnect() end
    
    local frozenCFrame = HumanoidRootPart.CFrame
    
    freezeConnection = RunService.RenderStepped:Connect(function()
        if Character and HumanoidRootPart and Humanoid then
            HumanoidRootPart.CFrame = frozenCFrame
            HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
            Humanoid.PlatformStand = true
        end
    end)
end

-- Разморозка
local function unfreezeCharacter()
    if freezeConnection then
        freezeConnection:Disconnect()
        freezeConnection = nil
    end
    if Character and Humanoid then
        Humanoid.PlatformStand = false
    end
end

-- Зажать кнопку мыши
local function holdMouse()
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
end

-- Отпустить кнопку мыши
local function releaseMouse()
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
end

-- Одиночный клик
local function clickOnce()
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
end

-- ==================== ЦИКЛ ТОЛЬКО КЛИКОВ (после инициализации) ====================
local function clickLoopOnly()
    while AutoFarmEnabled do
        if not Character or not HumanoidRootPart then
            Character = LocalPlayer.Character
            if Character then
                HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
                Humanoid = Character:WaitForChild("Humanoid")
                -- При респавне заново зависаем
                freezeCharacter()
            end
        end
        
        if Character and HumanoidRootPart and AutoFarmEnabled then
            clickOnce()
            task.wait(0.7)
        else
            task.wait(0.1)
        end
    end
    unfreezeCharacter()
end

-- ==================== ПОЛНЫЙ ЦИКЛ С ИНИЦИАЛИЗАЦИЕЙ ====================
local function autoFarmFullCycle()
    -- Сбрасываем флаг инициализации
    initializationDone = false
    
    -- Ждём персонажа
    if not Character or not HumanoidRootPart then
        Character = LocalPlayer.Character
        if Character then
            HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
            Humanoid = Character:WaitForChild("Humanoid")
        end
    end
    
    if not Character or not HumanoidRootPart then
        unfreezeCharacter()
        return
    end
    
    -- Шаг 1: Телепорт к штанге
    teleportTo(TrainingPosition)
    
    -- Шаг 2: Заморозка в воздухе
    freezeCharacter()
    
    -- Шаг 3: Пауза 0.5 секунды
    task.wait(0.5)
    
    -- Шаг 4: Зажать на 1 секунду
    holdMouse()
    task.wait(1.0)
    releaseMouse()
    
    -- Шаг 5: Инициализация завершена, запускаем цикл кликов
    initializationDone = true
    
    -- Запускаем бесконечный цикл кликов раз в 0.7 сек
    clickLoopOnly()
end

-- ==================== GUI 300x200 ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TWEAK_SHTANGA"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 200)
MainFrame.Position = UDim2.new(1, -320, 0.5, -100)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- Хедер
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 35)
Header.BackgroundColor3 = Color3.fromRGB(140, 100, 255)
Header.BorderSizePixel = 0
Header.Parent = MainFrame
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 10)

local HeaderText = Instance.new("TextLabel")
HeaderText.Size = UDim2.new(1, -20, 1, 0)
HeaderText.Position = UDim2.new(0, 15, 0, 0)
HeaderText.BackgroundTransparency = 1
HeaderText.Text = "TWEAK | Авто-штанга v6"
HeaderText.TextColor3 = Color3.fromRGB(255, 255, 255)
HeaderText.Font = Enum.Font.GothamBold
HeaderText.TextSize = 14
HeaderText.TextXAlignment = Enum.TextXAlignment.Left
HeaderText.Parent = Header

-- Контент
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -20, 1, -35)
Content.Position = UDim2.new(0, 10, 0, 35)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.Parent = MainFrame

-- Заголовок
local SectionLabel = Instance.new("TextLabel")
SectionLabel.Size = UDim2.new(1, 0, 0, 20)
SectionLabel.Position = UDim2.new(0, 0, 0, 10)
SectionLabel.BackgroundTransparency = 1
SectionLabel.Text = "Управление"
SectionLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SectionLabel.Font = Enum.Font.GothamBold
SectionLabel.TextSize = 12
SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
SectionLabel.Parent = Content

-- Тоггл
local ToggleFrame = Instance.new("Frame")
ToggleFrame.Size = UDim2.new(1, 0, 0, 40)
ToggleFrame.Position = UDim2.new(0, 0, 0, 35)
ToggleFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
ToggleFrame.BorderSizePixel = 0
ToggleFrame.Parent = Content
Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 8)

local ToggleLabel = Instance.new("TextLabel")
ToggleLabel.Size = UDim2.new(0.6, 0, 1, 0)
ToggleLabel.Position = UDim2.new(0, 10, 0, 0)
ToggleLabel.BackgroundTransparency = 1
ToggleLabel.Text = "Авто-штанга"
ToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleLabel.Font = Enum.Font.GothamMedium
ToggleLabel.TextSize = 13
ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
ToggleLabel.Parent = ToggleFrame

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 50, 0, 24)
ToggleBtn.Position = UDim2.new(1, -60, 0.5, -12)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 70, 70)
ToggleBtn.Text = ""
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Parent = ToggleFrame
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 12)

local ToggleCircle = Instance.new("Frame")
ToggleCircle.Size = UDim2.new(0, 18, 0, 18)
ToggleCircle.Position = UDim2.new(0, 3, 0.5, -9)
ToggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ToggleCircle.BorderSizePixel = 0
ToggleCircle.Parent = ToggleBtn
Instance.new("UICorner", ToggleCircle).CornerRadius = UDim.new(0, 9)

-- Статус
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.Position = UDim2.new(0, 0, 0, 85)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Статус: Выключено"
StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
StatusLabel.Font = Enum.Font.GothamMedium
StatusLabel.TextSize = 11
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = Content

-- Инфо
local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(1, 0, 0, 40)
InfoLabel.Position = UDim2.new(0, 0, 0, 115)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text = "Поз: 2284, 49, 5903\nИнит: один раз → клики бесконечно"
InfoLabel.TextColor3 = Color3.fromRGB(140, 140, 150)
InfoLabel.Font = Enum.Font.GothamMedium
InfoLabel.TextSize = 10
InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
InfoLabel.Parent = Content

-- Логика тоггла
local isEnabled = false

local function updateToggleVisual()
    if isEnabled then
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(80, 200, 120)
        ToggleCircle.Position = UDim2.new(1, -21, 0.5, -9)
        StatusLabel.Text = "Статус: Клики раз в 0.7с"
    else
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 70, 70)
        ToggleCircle.Position = UDim2.new(0, 3, 0.5, -9)
        StatusLabel.Text = "Статус: Выключено"
    end
end

ToggleBtn.MouseButton1Click:Connect(function()
    isEnabled = not isEnabled
    AutoFarmEnabled = isEnabled
    updateToggleVisual()
    
    if isEnabled then
        -- Запускаем полный цикл с инициализацией
        task.spawn(autoFarmFullCycle)
    else
        -- Выключаем, размораживаем
        unfreezeCharacter()
    end
end)

updateToggleVisual()

print("=== TWEAK АВТО-ШТАНГА v6 ЗАГРУЖЕН ===")
print("Инициализация: ОДИН РАЗ при вкл (телепорт → 0.5с → зажать 1с)")
print("Далее: клики раз в 0.7с бесконечно")
print("Перезапуск инициализации: выкл/вкл тоггл")
