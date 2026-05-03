--[[
    TWEAKOS EXECUTOR v3.0 - ПОЛНЫЙ ФИКС
    Все кнопки работают через Touch событие
    Noclip: Реальный обход коллизий через физический движок
    Позиция: Прямое чтение CFrame + экспорт в буфер
    Скорость: Прямая модификация Humanoid.WalkSpeed
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

-- Очистка старых GUI
for _, gui in ipairs(LocalPlayer.PlayerGui:GetChildren()) do
    if gui.Name == "TWEAKOS_Core" then
        gui:Destroy()
    end
end

-- ============================================
-- СОСТОЯНИЯ
-- ============================================
local noclipEnabled = false
local speedValue = 16
local noclipConnection = nil
local lastPosition = Vector3.zero

-- ============================================
-- СОЗДАНИЕ GUI
-- ============================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TWEAKOS_Core"
ScreenGui.Parent = LocalPlayer.PlayerGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 280)
MainFrame.Position = UDim2.new(0.5, -150, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.Text = "TWEAKOS v3.0"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = MainFrame

-- ============================================
-- 1. NOCLIP (ПРОХОД СКВОЗЬ СТЕНЫ)
-- ============================================
local NoclipFrame = Instance.new("Frame")
NoclipFrame.Size = UDim2.new(1, -20, 0, 45)
NoclipFrame.Position = UDim2.new(0, 10, 0, 45)
NoclipFrame.BackgroundTransparency = 1
NoclipFrame.Parent = MainFrame

local NoclipLabel = Instance.new("TextLabel")
NoclipLabel.Size = UDim2.new(0.55, 0, 1, 0)
NoclipLabel.BackgroundTransparency = 1
NoclipLabel.Text = "ПРОХОД СКВОЗЬ СТЕНЫ"
NoclipLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
NoclipLabel.Font = Enum.Font.Gotham
NoclipLabel.TextSize = 14
NoclipLabel.TextXAlignment = Enum.TextXAlignment.Left
NoclipLabel.Parent = NoclipFrame

local NoclipButton = Instance.new("TextButton")
NoclipButton.Size = UDim2.new(0, 60, 0, 30)
NoclipButton.Position = UDim2.new(1, -65, 0.5, -15)
NoclipButton.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
NoclipButton.Text = "ВЫКЛ"
NoclipButton.TextColor3 = Color3.fromRGB(255, 255, 255)
NoclipButton.Font = Enum.Font.GothamBold
NoclipButton.TextSize = 12
NoclipButton.AutoButtonColor = false
NoclipButton.Parent = NoclipFrame

local NoclipCorner = Instance.new("UICorner")
NoclipCorner.CornerRadius = UDim.new(0, 8)
NoclipCorner.Parent = NoclipButton

-- ФУНКЦИЯ NOCLIP (РЕАЛЬНАЯ)
local function EnableNoclip()
    if noclipConnection then noclipConnection:Disconnect() end
    
    noclipConnection = RunService.Stepped:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        
        -- Отключаем коллизию для ВСЕХ частей тела и аксессуаров
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") and v.CanCollide == true then
                v.CanCollide = false
            end
        end
    end)
end

local function DisableNoclip()
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    
    local char = LocalPlayer.Character
    if char then
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = true
            end
        end
    end
end

-- Обработчик кнопки Noclip (ИСПРАВЛЕНО)
local function OnNoclipClick()
    noclipEnabled = not noclipEnabled
    
    if noclipEnabled then
        EnableNoclip()
        NoclipButton.BackgroundColor3 = Color3.fromRGB(40, 180, 40)
        NoclipButton.Text = "ВКЛ"
    else
        DisableNoclip()
        NoclipButton.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
        NoclipButton.Text = "ВЫКЛ"
    end
end

NoclipButton.Activated:Connect(OnNoclipClick)
NoclipButton.MouseButton1Click:Connect(OnNoclipClick)

-- ============================================
-- 2. СКОРОСТЬ (ПОЛЗУНОК)
-- ============================================
local SpeedFrame = Instance.new("Frame")
SpeedFrame.Size = UDim2.new(1, -20, 0, 60)
SpeedFrame.Position = UDim2.new(0, 10, 0, 100)
SpeedFrame.BackgroundTransparency = 1
SpeedFrame.Parent = MainFrame

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(1, 0, 0, 20)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "СКОРОСТЬ: 16"
SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedLabel.Font = Enum.Font.Gotham
SpeedLabel.TextSize = 14
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedLabel.Parent = SpeedFrame

-- Трек ползунка
local SliderTrack = Instance.new("TextButton")
SliderTrack.Size = UDim2.new(1, 0, 0, 12)
SliderTrack.Position = UDim2.new(0, 0, 0, 26)
SliderTrack.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SliderTrack.BorderSizePixel = 0
SliderTrack.Text = ""
SliderTrack.AutoButtonColor = false
SliderTrack.Parent = SpeedFrame

local TrackCorner = Instance.new("UICorner")
TrackCorner.CornerRadius = UDim.new(0, 6)
TrackCorner.Parent = SliderTrack

-- Заполнение
local SliderFill = Instance.new("Frame")
SliderFill.Size = UDim2.new(0.09, 0, 1, 0)
SliderFill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
SliderFill.BorderSizePixel = 0
SliderFill.Parent = SliderTrack

local FillCorner = Instance.new("UICorner")
FillCorner.CornerRadius = UDim.new(0, 6)
FillCorner.Parent = SliderFill

-- Круглый ползунок
local SliderKnob = Instance.new("TextButton")
SliderKnob.Size = UDim2.new(0, 30, 0, 30)
SliderKnob.Position = UDim2.new(0.09, -15, 0.5, -15)
SliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SliderKnob.BorderSizePixel = 0
SliderKnob.Text = ""
SliderKnob.AutoButtonColor = false
SliderKnob.Parent = SliderTrack

local KnobCorner = Instance.new("UICorner")
KnobCorner.CornerRadius = UDim.new(1, 0)
KnobCorner.Parent = SliderKnob

-- Логика ползунка
local isDragging = false

local function UpdateSpeedFromPosition(inputPosition)
    local trackStart = SliderTrack.AbsolutePosition.X
    local trackWidth = SliderTrack.AbsoluteSize.X
    local relativeX = math.clamp((inputPosition.X - trackStart) / trackWidth, 0, 1)
    
    speedValue = math.floor(8 + (relativeX * 92) + 0.5) -- 8-100
    speedValue = math.clamp(speedValue, 8, 100)
    
    SliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
    SliderKnob.Position = UDim2.new(relativeX, -15, 0.5, -15)
    SpeedLabel.Text = "СКОРОСТЬ: " .. speedValue
    
    -- Применяем скорость
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            hum.WalkSpeed = speedValue
        end
    end
end

SliderKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or 
       input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = true
    end
end)

SliderTrack.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or 
       input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = true
        UpdateSpeedFromPosition(input.Position)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isDragging and (input.UserInputType == Enum.UserInputType.Touch or 
                      input.UserInputType == Enum.UserInputType.MouseMovement) then
        UpdateSpeedFromPosition(input.Position)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or 
       input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = false
    end
end)

-- ============================================
-- 3. ПОЗИЦИЯ (УЗНАВАНИЕ)
-- ============================================
local PositionFrame = Instance.new("Frame")
PositionFrame.Size = UDim2.new(1, -20, 0, 60)
PositionFrame.Position = UDim2.new(0, 10, 0, 170)
PositionFrame.BackgroundTransparency = 1
PositionFrame.Parent = MainFrame

local PositionLabel = Instance.new("TextLabel")
PositionLabel.Size = UDim2.new(1, 0, 0, 20)
PositionLabel.BackgroundTransparency = 1
PositionLabel.Text = "ПОЗИЦИЯ: 0, 0, 0"
PositionLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
PositionLabel.Font = Enum.Font.Code
PositionLabel.TextSize = 11
PositionLabel.TextXAlignment = Enum.TextXAlignment.Left
PositionLabel.Parent = PositionFrame

local CopyPosButton = Instance.new("TextButton")
CopyPosButton.Size = UDim2.new(1, 0, 0, 30)
CopyPosButton.Position = UDim2.new(0, 0, 0, 25)
CopyPosButton.BackgroundColor3 = Color3.fromRGB(50, 50, 180)
CopyPosButton.Text = "КОПИРОВАТЬ ПОЗИЦИЮ"
CopyPosButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyPosButton.Font = Enum.Font.GothamBold
CopyPosButton.TextSize = 12
CopyPosButton.AutoButtonColor = false
CopyPosButton.Parent = PositionFrame

local CopyCorner = Instance.new("UICorner")
CopyCorner.CornerRadius = UDim.new(0, 6)
CopyCorner.Parent = CopyPosButton

-- Обновление позиции
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            lastPosition = hrp.Position
            PositionLabel.Text = string.format(
                "X: %.3f | Y: %.3f | Z: %.3f",
                lastPosition.X, lastPosition.Y, lastPosition.Z
            )
            -- Глобальный экспорт
            getgenv().PlayerPosition = lastPosition
        end
    end
end)

-- Копирование в буфер
local function CopyPosition()
    local pos = lastPosition
    local posString = string.format("Vector3.new(%.3f, %.3f, %.3f)", pos.X, pos.Y, pos.Z)
    
    pcall(function()
        setclipboard(posString)
    end)
    
    -- Визуальный фидбек
    CopyPosButton.BackgroundColor3 = Color3.fromRGB(60, 180, 60)
    CopyPosButton.Text = "СКОПИРОВАНО!"
    
    task.wait(0.7)
    CopyPosButton.BackgroundColor3 = Color3.fromRGB(50, 50, 180)
    CopyPosButton.Text = "КОПИРОВАТЬ ПОЗИЦИЮ"
end

CopyPosButton.Activated:Connect(CopyPosition)
CopyPosButton.MouseButton1Click:Connect(CopyPosition)

-- ============================================
-- ПОДДЕРЖКА NOCLIP ПРИ РЕСПАВНЕ
-- ============================================
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.1)
    if noclipEnabled then
        EnableNoclip()
    end
    local hum = char:WaitForChild("Humanoid")
    hum.WalkSpeed = speedValue
end)

-- ============================================
-- ИНИЦИАЛИЗАЦИЯ
-- ============================================
if LocalPlayer.Character then
    local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
    if hum then hum.WalkSpeed = speedValue end
end

print("TWEAKOS v3.0 - Все системы активны")
