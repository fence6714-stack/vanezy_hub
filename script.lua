--[[
    Mobile Roblox Executor - PosGetter+ PRO FIXED
    ИСПРАВЛЕНИЯ:
    - Позиция работает (прямой доступ к Character)
    - Все кнопки нажимаются (фикс сенсорных событий)
    - Noclip и Speed работают стабильно
    - Ползунок регулирует скорость в реальном времени
    - Копирование ТОЛЬКО координат (X,Y,Z)
--]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Конфигурация
local MenuConfig = {
    Position = UDim2.new(0.85, 0, 0.12, 0),
    Size = UDim2.new(0, 190, 0, 330),
    Color = Color3.fromRGB(20, 20, 30),
    TextColor = Color3.fromRGB(240, 240, 255),
    AccentColor = Color3.fromRGB(80, 100, 255),
    DangerColor = Color3.fromRGB(220, 50, 50),
    DangerOnColor = Color3.fromRGB(255, 60, 60),
    SpeedColor = Color3.fromRGB(50, 200, 150),
    SliderColor = Color3.fromRGB(100, 100, 140)
}

-- Состояния
local NoclipEnabled = false
local SpeedEnabled = false
local CurrentSpeed = 50
local OriginalWalkspeed = 16
local Character = nil
local Humanoid = nil
local noclipConnection = nil

-- Функция получения персонажа (ПРЯМАЯ, БЕЗ ЗАДЕРЖЕК)
local function GetCharacter()
    local char = LocalPlayer.Character
    if char and char.Parent and char:FindFirstChild("HumanoidRootPart") then
        return char
    end
    return nil
end

local function UpdateCharacter()
    Character = GetCharacter()
    if Character then
        Humanoid = Character:FindFirstChild("Humanoid")
        if Humanoid and not SpeedEnabled then
            OriginalWalkspeed = Humanoid.WalkSpeed
        end
    end
end

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PosGetterPro"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

-- Главная панель
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = MenuConfig.Color
MainFrame.BackgroundTransparency = 0.05
MainFrame.BorderSizePixel = 0
MainFrame.Position = MenuConfig.Position
MainFrame.Size = MenuConfig.Size
MainFrame.Active = true
MainFrame.Draggable = true

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 14)
UICorner.Parent = MainFrame

-- Заголовок
local TitleBar = Instance.new("Frame")
TitleBar.Parent = MainFrame
TitleBar.BackgroundColor3 = MenuConfig.AccentColor
TitleBar.BackgroundTransparency = 0.2
TitleBar.Size = UDim2.new(1, 0, 0, 34)
TitleBar.Position = UDim2.new(0, 0, 0, 0)

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 14)
TitleCorner.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Parent = TitleBar
TitleLabel.BackgroundTransparency = 1
TitleLabel.Size = UDim2.new(1, -35, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.Text = "🔧 PosGetter+ PRO"
TitleLabel.TextColor3 = MenuConfig.TextColor
TitleLabel.TextSize = 13
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = TitleBar
CloseBtn.Size = UDim2.new(0, 35, 1, 0)
CloseBtn.Position = UDim2.new(1, -35, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = MenuConfig.TextColor
CloseBtn.TextSize = 18
CloseBtn.Font = Enum.Font.GothamBold

-- ПОЗИЦИЯ
local PosSection = Instance.new("Frame")
PosSection.Parent = MainFrame
PosSection.Size = UDim2.new(0.9, 0, 0, 95)
PosSection.Position = UDim2.new(0.05, 0, 0, 44)
PosSection.BackgroundTransparency = 1

local SectionLabel = Instance.new("TextLabel")
SectionLabel.Parent = PosSection
SectionLabel.Size = UDim2.new(1, 0, 0, 18)
SectionLabel.Position = UDim2.new(0, 0, 0, 0)
SectionLabel.BackgroundTransparency = 1
SectionLabel.Text = "📍 ПОЗИЦИЯ"
SectionLabel.TextColor3 = Color3.fromRGB(180, 180, 220)
SectionLabel.TextSize = 10
SectionLabel.Font = Enum.Font.GothamBold
SectionLabel.TextXAlignment = Enum.TextXAlignment.Left

local GetPosBtn = Instance.new("TextButton")
GetPosBtn.Parent = PosSection
GetPosBtn.Size = UDim2.new(1, 0, 0, 34)
GetPosBtn.Position = UDim2.new(0, 0, 0, 20)
GetPosBtn.BackgroundColor3 = MenuConfig.AccentColor
GetPosBtn.BackgroundTransparency = 0.25
GetPosBtn.Text = "📌 Получить и скопировать позицию"
GetPosBtn.TextColor3 = MenuConfig.TextColor
GetPosBtn.TextSize = 11
GetPosBtn.Font = Enum.Font.GothamSemibold

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 8)
BtnCorner.Parent = GetPosBtn

local PosDisplay = Instance.new("TextBox")
PosDisplay.Parent = PosSection
PosDisplay.Size = UDim2.new(1, 0, 0, 30)
PosDisplay.Position = UDim2.new(0, 0, 0, 60)
PosDisplay.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
PosDisplay.BackgroundTransparency = 0.4
PosDisplay.Text = "Нажмите кнопку"
PosDisplay.TextColor3 = MenuConfig.TextColor
PosDisplay.TextSize = 10
PosDisplay.Font = Enum.Font.Code
PosDisplay.TextXAlignment = Enum.TextXAlignment.Center
PosDisplay.ClearTextOnFocus = false

local DisplayCorner = Instance.new("UICorner")
DisplayCorner.CornerRadius = UDim.new(0, 6)
DisplayCorner.Parent = PosDisplay

-- NOCLIP
local NoclipSection = Instance.new("Frame")
NoclipSection.Parent = MainFrame
NoclipSection.Size = UDim2.new(0.9, 0, 0, 60)
NoclipSection.Position = UDim2.new(0.05, 0, 0, 148)
NoclipSection.BackgroundTransparency = 1

local NoclipLabel = Instance.new("TextLabel")
NoclipLabel.Parent = NoclipSection
NoclipLabel.Size = UDim2.new(1, 0, 0, 18)
NoclipLabel.Position = UDim2.new(0, 0, 0, 0)
NoclipLabel.BackgroundTransparency = 1
NoclipLabel.Text = "🚪 ПРОХОД СКВОЗЬ СТЕНЫ"
NoclipLabel.TextColor3 = Color3.fromRGB(180, 180, 220)
NoclipLabel.TextSize = 10
NoclipLabel.Font = Enum.Font.GothamBold
NoclipLabel.TextXAlignment = Enum.TextXAlignment.Left

local NoclipBtn = Instance.new("TextButton")
NoclipBtn.Parent = NoclipSection
NoclipBtn.Size = UDim2.new(1, 0, 0, 34)
NoclipBtn.Position = UDim2.new(0, 0, 0, 22)
NoclipBtn.BackgroundColor3 = MenuConfig.DangerColor
NoclipBtn.BackgroundTransparency = 0.3
NoclipBtn.Text = "❌ NOCLIP: ВЫКЛ"
NoclipBtn.TextColor3 = MenuConfig.TextColor
NoclipBtn.TextSize = 12
NoclipBtn.Font = Enum.Font.GothamBold

local NoclipCorner = Instance.new("UICorner")
NoclipCorner.CornerRadius = UDim.new(0, 8)
NoclipCorner.Parent = NoclipBtn

-- SPEED
local SpeedSection = Instance.new("Frame")
SpeedSection.Parent = MainFrame
SpeedSection.Size = UDim2.new(0.9, 0, 0, 90)
SpeedSection.Position = UDim2.new(0.05, 0, 0, 218)
SpeedSection.BackgroundTransparency = 1

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Parent = SpeedSection
SpeedLabel.Size = UDim2.new(1, 0, 0, 18)
SpeedLabel.Position = UDim2.new(0, 0, 0, 0)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "⚡ СПИДХАК (ползунок + вкл/выкл)"
SpeedLabel.TextColor3 = Color3.fromRGB(180, 180, 220)
SpeedLabel.TextSize = 10
SpeedLabel.Font = Enum.Font.GothamBold
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left

local SpeedToggleBtn = Instance.new("TextButton")
SpeedToggleBtn.Parent = SpeedSection
SpeedToggleBtn.Size = UDim2.new(0.45, 0, 0, 34)
SpeedToggleBtn.Position = UDim2.new(0, 0, 0, 22)
SpeedToggleBtn.BackgroundColor3 = MenuConfig.SpeedColor
SpeedToggleBtn.BackgroundTransparency = 0.3
SpeedToggleBtn.Text = "⚡ ВЫКЛ"
SpeedToggleBtn.TextColor3 = MenuConfig.TextColor
SpeedToggleBtn.TextSize = 11
SpeedToggleBtn.Font = Enum.Font.GothamBold

local SpeedToggleCorner = Instance.new("UICorner")
SpeedToggleCorner.CornerRadius = UDim.new(0, 8)
SpeedToggleCorner.Parent = SpeedToggleBtn

local SpeedSliderFrame = Instance.new("Frame")
SpeedSliderFrame.Parent = SpeedSection
SpeedSliderFrame.Size = UDim2.new(0.5, 0, 0, 34)
SpeedSliderFrame.Position = UDim2.new(0.48, 0, 0, 22)
SpeedSliderFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
SpeedSliderFrame.BackgroundTransparency = 0.3

local SliderCorner = Instance.new("UICorner")
SliderCorner.CornerRadius = UDim.new(0, 8)
SliderCorner.Parent = SpeedSliderFrame

local SliderTrack = Instance.new("Frame")
SliderTrack.Parent = SpeedSliderFrame
SliderTrack.Size = UDim2.new(0.8, 0, 0, 4)
SliderTrack.Position = UDim2.new(0.1, 0, 0.5, -2)
SliderTrack.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
SliderTrack.BorderSizePixel = 0

local TrackCorner = Instance.new("UICorner")
TrackCorner.CornerRadius = UDim.new(0, 2)
TrackCorner.Parent = SliderTrack

local SliderFill = Instance.new("Frame")
SliderFill.Parent = SliderTrack
SliderFill.Size = UDim2.new(0.5, 0, 1, 0)
SliderFill.BackgroundColor3 = MenuConfig.SpeedColor
SliderFill.BorderSizePixel = 0

local SliderKnob = Instance.new("TextButton")
SliderKnob.Parent = SpeedSliderFrame
SliderKnob.Size = UDim2.new(0, 18, 0, 18)
SliderKnob.Position = UDim2.new(0.5, -9, 0.5, -9)
SliderKnob.BackgroundColor3 = MenuConfig.SpeedColor
SliderKnob.Text = ""
SliderKnob.AutoButtonColor = false

local KnobCorner = Instance.new("UICorner")
KnobCorner.CornerRadius = UDim.new(1, 0)
KnobCorner.Parent = SliderKnob

local SpeedValueLabel = Instance.new("TextLabel")
SpeedValueLabel.Parent = SpeedSection
SpeedValueLabel.Size = UDim2.new(0.5, 0, 0, 20)
SpeedValueLabel.Position = UDim2.new(0.48, 0, 0, 60)
SpeedValueLabel.BackgroundTransparency = 1
SpeedValueLabel.Text = "50"
SpeedValueLabel.TextColor3 = MenuConfig.SpeedColor
SpeedValueLabel.TextSize = 12
SpeedValueLabel.Font = Enum.Font.GothamBold

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Parent = MainFrame
StatusLabel.Size = UDim2.new(0.9, 0, 0, 16)
StatusLabel.Position = UDim2.new(0.05, 0, 1, -24)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Готов"
StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
StatusLabel.TextSize = 9
StatusLabel.Font = Enum.Font.Gotham

-- ========== ФУНКЦИИ ==========

-- ПОЛУЧЕНИЕ ПОЗИЦИИ (РАБОЧАЯ)
local function GetPlayerPosition()
    local char = LocalPlayer.Character
    if not char then return nil end
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if rootPart then
        return rootPart.Position
    end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then return hrp.Position end
    return nil
end

-- ФОРМАТ ТОЛЬКО КООРДИНАТЫ
local function FormatRawPosition(pos)
    if not pos then return nil end
    return string.format("%.2f, %.2f, %.2f", pos.X, pos.Y, pos.Z)
end

-- КОПИРОВАНИЕ В БУФЕР (УНИВЕРСАЛЬНОЕ)
local function CopyToClipboard(text)
    local success = false
    if syn and syn.set_clipboard then syn.set_clipboard(text); success = true
    elseif setclipboard then setclipboard(text); success = true
    elseif toclipboard then toclipboard(text); success = true
    elseif writeclipboard then writeclipboard(text); success = true
    elseif clipbrd then clipbrd(text); success = true
    elseif mobile and mobile.copy then mobile.copy(text); success = true
    end
    return success
end

-- ПОЛУЧИТЬ И СКОПИРОВАТЬ ПОЗИЦИЮ
local function GetAndCopyPosition()
    local pos = GetPlayerPosition()
    if pos then
        local posStr = FormatRawPosition(pos)
        PosDisplay.Text = posStr
        local copied = CopyToClipboard(posStr)
        if copied then
            StatusLabel.Text = "✓ Скопировано: " .. posStr
            StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            StatusLabel.Text = "⚠ Позиция: " .. posStr .. " (буфер не доступен)"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
        end
        return true
    else
        PosDisplay.Text = "Ошибка: персонаж не найден"
        StatusLabel.Text = "✗ Не удалось получить позицию"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        return false
    end
end

-- NOCLIP
local function ApplyNoclip(state)
    local char = LocalPlayer.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = not state
            end
        end
    end
end

local function StartNoclipLoop()
    if noclipConnection then noclipConnection:Disconnect() end
    noclipConnection = RunService.Stepped:Connect(function()
        if NoclipEnabled then
            local char = LocalPlayer.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide == true then
                        part.CanCollide = false
                    end
                end
            end
        end
    end)
end

local function ToggleNoclip()
    NoclipEnabled = not NoclipEnabled
    if NoclipEnabled then
        ApplyNoclip(true)
        StartNoclipLoop()
        NoclipBtn.Text = "✅ NOCLIP: ВКЛ"
        NoclipBtn.BackgroundColor3 = MenuConfig.DangerOnColor
        NoclipBtn.BackgroundTransparency = 0
        StatusLabel.Text = "✓ Noclip включен"
    else
        ApplyNoclip(false)
        if noclipConnection then noclipConnection:Disconnect() end
        NoclipBtn.Text = "❌ NOCLIP: ВЫКЛ"
        NoclipBtn.BackgroundColor3 = MenuConfig.DangerColor
        NoclipBtn.BackgroundTransparency = 0.3
        StatusLabel.Text = "✗ Noclip выключен"
    end
    StatusLabel.TextColor3 = NoclipEnabled and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 150, 150)
    task.wait(1.2)
    StatusLabel.Text = "Готов"
    StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
end

-- SPEED
local function SetSpeed(value)
    value = math.clamp(value, 16, 250)
    CurrentSpeed = value
    SpeedValueLabel.Text = tostring(math.floor(value))
    
    local percent = (value - 16) / (250 - 16)
    SliderFill.Size = UDim2.new(percent, 0, 1, 0)
    SliderKnob.Position = UDim2.new(percent, -9, 0.5, -9)
    
    if SpeedEnabled then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then
                hum.WalkSpeed = CurrentSpeed
            end
        end
    end
end

local function ToggleSpeed()
    SpeedEnabled = not SpeedEnabled
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChild("Humanoid")
    
    if SpeedEnabled then
        if hum then
            OriginalWalkspeed = hum.WalkSpeed
            hum.WalkSpeed = CurrentSpeed
        end
        SpeedToggleBtn.Text = "⚡ ВКЛ"
        SpeedToggleBtn.BackgroundTransparency = 0
        StatusLabel.Text = "✓ Спидхак: " .. CurrentSpeed
    else
        if hum then
            hum.WalkSpeed = OriginalWalkspeed
        end
        SpeedToggleBtn.Text = "⚡ ВЫКЛ"
        SpeedToggleBtn.BackgroundTransparency = 0.3
        StatusLabel.Text = "✗ Спидхак выключен"
    end
    StatusLabel.TextColor3 = SpeedEnabled and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 150, 150)
    task.wait(1.2)
    StatusLabel.Text = "Готов"
    StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
end

-- ПОЛЗУНОК (ДРАГ)
local dragging = false
local function UpdateSliderFromPosition(inputPos)
    local track = SliderTrack
    local trackPos = track.AbsolutePosition
    local trackSize = track.AbsoluteSize.X
    if trackSize <= 0 then return end
    local relativeX = math.clamp(inputPos.X - trackPos.X, 0, trackSize)
    local percent = relativeX / trackSize
    local newSpeed = 16 + percent * (250 - 16)
    SetSpeed(newSpeed)
end

SliderKnob.MouseButton1Down:Connect(function()
    dragging = true
end)

SliderKnob.TouchTap:Connect(function() end)
SliderKnob.TouchMoved:Connect(function(touch)
    UpdateSliderFromPosition(touch.Position)
end)

SliderTrack.MouseButton1Down:Connect(function(x, y)
    UpdateSliderFromPosition(UserInputService:GetMouseLocation())
end)

SliderTrack.TouchTap:Connect(function(touch)
    UpdateSliderFromPosition(touch.Position)
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or 
       input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or 
                     input.UserInputType == Enum.UserInputType.Touch) then
        UpdateSliderFromPosition(input.Position)
    end
end)

-- ========== ОБРАБОТЧИКИ КНОПОК ==========
local function AnimateButton(btn)
    local orig = btn.Size
    local tween = TweenService:Create(btn, TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Size = UDim2.new(orig.X.Scale, orig.X.Offset, orig.Y.Scale, orig.Y.Offset - 2)})
    tween:Play()
    tween.Completed:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size = orig}):Play()
    end)
end

GetPosBtn.MouseButton1Click:Connect(function()
    AnimateButton(GetPosBtn)
    GetAndCopyPosition()
end)

GetPosBtn.TouchTap:Connect(function()
    AnimateButton(GetPosBtn)
    GetAndCopyPosition()
end)

NoclipBtn.MouseButton1Click:Connect(function()
    AnimateButton(NoclipBtn)
    ToggleNoclip()
end)

NoclipBtn.TouchTap:Connect(function()
    AnimateButton(NoclipBtn)
    ToggleNoclip()
end)

SpeedToggleBtn.MouseButton1Click:Connect(function()
    AnimateButton(SpeedToggleBtn)
    ToggleSpeed()
end)

SpeedToggleBtn.TouchTap:Connect(function()
    AnimateButton(SpeedToggleBtn)
    ToggleSpeed()
end)

CloseBtn.MouseButton1Click:Connect(function()
    if NoclipEnabled then ToggleNoclip() end
    if SpeedEnabled then ToggleSpeed() end
    ScreenGui:Destroy()
end)

CloseBtn.TouchTap:Connect(function()
    if NoclipEnabled then ToggleNoclip() end
    if SpeedEnabled then ToggleSpeed() end
    ScreenGui:Destroy()
end)

-- ОТСЛЕЖИВАНИЕ ПЕРСОНАЖА
LocalPlayer.CharacterAdded:Connect(function(newChar)
    task.wait(0.5)
    if NoclipEnabled then
        for _, part in pairs(newChar:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
    if SpeedEnabled then
        local hum = newChar:FindFirstChild("Humanoid")
        if hum then
            hum.WalkSpeed = CurrentSpeed
        end
    end
    local pos = GetPlayerPosition()
    if pos then
        PosDisplay.Text = FormatRawPosition(pos)
    end
end)

-- Периодическое обновление отображения позиции (опционально)
task.spawn(function()
    while ScreenGui and ScreenGui.Parent do
        task.wait(2)
        local pos = GetPlayerPosition()
        if pos and PosDisplay.Text ~= FormatRawPosition(pos) then
            PosDisplay.Text = FormatRawPosition(pos)
        end
    end
end)

-- ИНИЦИАЛИЗАЦИЯ
SetSpeed(50)

-- Глобальные экспорты
_G.GetPosition = GetPlayerPosition
_G.CopyPosition = GetAndCopyPosition
_G.ToggleNoclip = ToggleNoclip
_G.ToggleSpeed = ToggleSpeed
_G.SetSpeed = SetSpeed

-- Анимация появления
MainFrame.BackgroundTransparency = 1
for i = 1, 10 do
    MainFrame.BackgroundTransparency = 1 - (i * 0.09)
    task.wait(0.015)
end

print("=== PosGetter+ PRO FIXED ===")
print("Позиция: кнопка 'Получить' -> копирует только X,Y,Z")
print("Noclip: кнопка вкл/выкл")
print("Спидхак: кнопка вкл/выкл + ползунок")
