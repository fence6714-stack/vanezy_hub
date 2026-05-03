--[[
    Mobile Roblox Executor - PosGetter+ PRO (Noclip Toggle + Speed Slider)
    - Копирование ТОЛЬКО координат (X, Y, Z) через запятую или пробел
    - Ползунок регулировки скорости
    - Кнопка Noclip (вкл/выкл)
    - Сенсорное управление
--]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Конфигурация
local MenuConfig = {
    Position = UDim2.new(0.85, 0, 0.12, 0),
    Size = UDim2.new(0, 180, 0, 310),
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

local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 1
UIStroke.Color = Color3.fromRGB(100, 100, 130)
UIStroke.Transparency = 0.6
UIStroke.Parent = MainFrame

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

-- === БЛОК ПОЗИЦИИ ===
local PosSection = Instance.new("Frame")
PosSection.Parent = MainFrame
PosSection.Size = UDim2.new(0.9, 0, 0, 90)
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
GetPosBtn.Size = UDim2.new(1, 0, 0, 30)
GetPosBtn.Position = UDim2.new(0, 0, 0, 20)
GetPosBtn.BackgroundColor3 = MenuConfig.AccentColor
GetPosBtn.BackgroundTransparency = 0.25
GetPosBtn.Text = "📌 Получить позицию"
GetPosBtn.TextColor3 = MenuConfig.TextColor
GetPosBtn.TextSize = 12
GetPosBtn.Font = Enum.Font.GothamSemibold

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 8)
BtnCorner.Parent = GetPosBtn

local PosDisplay = Instance.new("TextBox")
PosDisplay.Parent = PosSection
PosDisplay.Size = UDim2.new(0.7, 0, 0, 28)
PosDisplay.Position = UDim2.new(0, 0, 0, 55)
PosDisplay.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
PosDisplay.BackgroundTransparency = 0.4
PosDisplay.Text = "0.00, 0.00, 0.00"
PosDisplay.TextColor3 = MenuConfig.TextColor
PosDisplay.TextSize = 10
PosDisplay.Font = Enum.Font.Code
PosDisplay.TextXAlignment = Enum.TextXAlignment.Center
PosDisplay.ClearTextOnFocus = false

local DisplayCorner = Instance.new("UICorner")
DisplayCorner.CornerRadius = UDim.new(0, 6)
DisplayCorner.Parent = PosDisplay

local CopyBtn = Instance.new("TextButton")
CopyBtn.Parent = PosSection
CopyBtn.Size = UDim2.new(0.25, 0, 0, 28)
CopyBtn.Position = UDim2.new(0.73, 0, 0, 55)
CopyBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
CopyBtn.Text = "📋 Копировать"
CopyBtn.TextColor3 = MenuConfig.TextColor
CopyBtn.TextSize = 10
CopyBtn.Font = Enum.Font.Gotham

local CopyCorner = Instance.new("UICorner")
CopyCorner.CornerRadius = UDim.new(0, 6)
CopyCorner.Parent = CopyBtn

-- === БЛОК NOCLIP ===
local NoclipSection = Instance.new("Frame")
NoclipSection.Parent = MainFrame
NoclipSection.Size = UDim2.new(0.9, 0, 0, 60)
NoclipSection.Position = UDim2.new(0.05, 0, 0, 142)
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

-- === БЛОК SPEED С ПОЛЗУНКОМ ===
local SpeedSection = Instance.new("Frame")
SpeedSection.Parent = MainFrame
SpeedSection.Size = UDim2.new(0.9, 0, 0, 85)
SpeedSection.Position = UDim2.new(0.05, 0, 0, 210)
SpeedSection.BackgroundTransparency = 1

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Parent = SpeedSection
SpeedLabel.Size = UDim2.new(1, 0, 0, 18)
SpeedLabel.Position = UDim2.new(0, 0, 0, 0)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "⚡ БЫСТРЫЙ ХАК (СПИЗДЗАК)"
SpeedLabel.TextColor3 = Color3.fromRGB(180, 180, 220)
SpeedLabel.TextSize = 10
SpeedLabel.Font = Enum.Font.GothamBold
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Кнопка вкл/выкл скорости
local SpeedToggleBtn = Instance.new("TextButton")
SpeedToggleBtn.Parent = SpeedSection
SpeedToggleBtn.Size = UDim2.new(0.48, 0, 0, 34)
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

-- Ползунок скорости
local SpeedSliderFrame = Instance.new("Frame")
SpeedSliderFrame.Parent = SpeedSection
SpeedSliderFrame.Size = UDim2.new(0.48, 0, 0, 34)
SpeedSliderFrame.Position = UDim2.new(0.52, 0, 0, 22)
SpeedSliderFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
SpeedSliderFrame.BackgroundTransparency = 0.3

local SliderCorner = Instance.new("UICorner")
SliderCorner.CornerRadius = UDim.new(0, 8)
SliderCorner.Parent = SpeedSliderFrame

-- Фон ползунка (трек)
local SliderTrack = Instance.new("Frame")
SliderTrack.Parent = SpeedSliderFrame
SliderTrack.Size = UDim2.new(0.85, 0, 0, 4)
SliderTrack.Position = UDim2.new(0.075, 0, 0.5, -2)
SliderTrack.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
SliderTrack.BorderSizePixel = 0

local TrackCorner = Instance.new("UICorner")
TrackCorner.CornerRadius = UDim.new(0, 2)
TrackCorner.Parent = SliderTrack

-- Заполненная часть ползунка
local SliderFill = Instance.new("Frame")
SliderFill.Parent = SliderTrack
SliderFill.Size = UDim2.new(0.5, 0, 1, 0)
SliderFill.BackgroundColor3 = MenuConfig.SpeedColor
SliderFill.BorderSizePixel = 0

local FillCorner = Instance.new("UICorner")
FillCorner.CornerRadius = UDim.new(0, 2)
FillCorner.Parent = SliderFill

-- Круглый бегунок
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

-- Значение скорости текстом
local SpeedValueLabel = Instance.new("TextLabel")
SpeedValueLabel.Parent = SpeedSection
SpeedValueLabel.Size = UDim2.new(0.48, 0, 0, 18)
SpeedValueLabel.Position = UDim2.new(0.52, 0, 0, 60)
SpeedValueLabel.BackgroundTransparency = 1
SpeedValueLabel.Text = "50"
SpeedValueLabel.TextColor3 = MenuConfig.SpeedColor
SpeedValueLabel.TextSize = 12
SpeedValueLabel.Font = Enum.Font.GothamBold

-- Статус
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Parent = MainFrame
StatusLabel.Size = UDim2.new(0.9, 0, 0, 16)
StatusLabel.Position = UDim2.new(0.05, 0, 1, -22)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Готов"
StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
StatusLabel.TextSize = 9
StatusLabel.Font = Enum.Font.Gotham

-- === ЯДЕРНЫЕ ФУНКЦИИ ===
local function UpdateCharacterReferences()
    Character = LocalPlayer.Character
    if Character then
        Humanoid = Character:FindFirstChild("Humanoid")
        if Humanoid and not SpeedEnabled then
            OriginalWalkspeed = Humanoid.WalkSpeed
        end
    end
end

-- Noclip
local noclipConnection = nil
local function StartNoclipLoop()
    if noclipConnection then noclipConnection:Disconnect() end
    noclipConnection = RunService.Stepped:Connect(function()
        if not NoclipEnabled then return end
        UpdateCharacterReferences()
        if Character then
            for _, part in pairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

local function ToggleNoclip()
    NoclipEnabled = not NoclipEnabled
    UpdateCharacterReferences()
    
    if NoclipEnabled then
        if Character then
            for _, part in pairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
        StartNoclipLoop()
        NoclipBtn.Text = "✅ NOCLIP: ВКЛ"
        NoclipBtn.BackgroundColor3 = MenuConfig.DangerOnColor
        NoclipBtn.BackgroundTransparency = 0
        StatusLabel.Text = "✓ Noclip активирован"
    else
        if Character then
            for _, part in pairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
        if noclipConnection then noclipConnection:Disconnect() end
        NoclipBtn.Text = "❌ NOCLIP: ВЫКЛ"
        NoclipBtn.BackgroundColor3 = MenuConfig.DangerColor
        NoclipBtn.BackgroundTransparency = 0.3
        StatusLabel.Text = "✗ Noclip деактивирован"
    end
    StatusLabel.TextColor3 = NoclipEnabled and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 150, 150)
    task.wait(1.2)
    StatusLabel.Text = "Готов"
    StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
end

-- Speed
local function SetSpeed(value)
    value = math.clamp(value, 16, 250)
    CurrentSpeed = value
    UpdateCharacterReferences()
    if Humanoid and SpeedEnabled then
        Humanoid.WalkSpeed = value
    end
    SpeedValueLabel.Text = tostring(math.floor(value))
    
    -- Обновление ползунка UI
    local percent = (value - 16) / (250 - 16)
    local trackWidth = SliderTrack.AbsoluteSize.X
    if trackWidth > 0 then
        local knobPosX = percent * trackWidth
        SliderFill.Size = UDim2.new(percent, 0, 1, 0)
        SliderKnob.Position = UDim2.new(percent, -9, 0.5, -9)
    end
end

local function ToggleSpeed()
    SpeedEnabled = not SpeedEnabled
    UpdateCharacterReferences()
    
    if SpeedEnabled then
        if Humanoid then
            OriginalWalkspeed = Humanoid.WalkSpeed
            Humanoid.WalkSpeed = CurrentSpeed
        end
        SpeedToggleBtn.Text = "⚡ ВКЛ"
        SpeedToggleBtn.BackgroundColor3 = MenuConfig.SpeedColor
        SpeedToggleBtn.BackgroundTransparency = 0
        StatusLabel.Text = "✓ Скорость: " .. CurrentSpeed
    else
        if Humanoid then
            Humanoid.WalkSpeed = OriginalWalkspeed
        end
        SpeedToggleBtn.Text = "⚡ ВЫКЛ"
        SpeedToggleBtn.BackgroundTransparency = 0.3
        StatusLabel.Text = "✗ Скорость сброшена"
    end
    StatusLabel.TextColor3 = SpeedEnabled and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 150, 150)
    task.wait(1.2)
    StatusLabel.Text = "Готов"
    StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
end

-- === ПОЗИЦИЯ (КОПИРУЕТ ТОЛЬКО ЦИФРЫ) ===
local function GetPlayerPosition()
    UpdateCharacterReferences()
    if not Character or not Character.Parent then
        return nil
    end
    local rootPart = Character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        return rootPart.Position
    end
    local primary = Character.PrimaryPart
    if primary then
        return primary.Position
    end
    return nil
end

-- Форматирование ТОЛЬКО координат (без Vector3, без лишнего)
local function FormatPositionRaw(pos)
    if not pos then return "0, 0, 0" end
    return string.format("%.2f, %.2f, %.2f", pos.X, pos.Y, pos.Z)
end

local function FormatPositionSpaced(pos)
    if not pos then return "0 0 0" end
    return string.format("%.2f %.2f %.2f", pos.X, pos.Y, pos.Z)
end

local function UpdateDisplayAndCopy(mode)
    local pos = GetPlayerPosition()
    if pos then
        local copyText = (mode == "spaced") and FormatPositionSpaced(pos) or FormatPositionRaw(pos)
        PosDisplay.Text = FormatPositionRaw(pos)
        
        -- Копирование в буфер
        local success = false
        if setclipboard then setclipboard(copyText); success = true
        elseif toclipboard then toclipboard(copyText); success = true
        elseif writeclipboard then writeclipboard(copyText); success = true
        elseif syn and syn.set_clipboard then syn.set_clipboard(copyText); success = true
        elseif mobile and mobile.copy then mobile.copy(copyText); success = true
        end
        
        if success then
            StatusLabel.Text = "✓ Скопировано: " .. copyText
            StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            StatusLabel.Text = "⚠ Позиция: " .. copyText .. " (не скопировано)"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
        end
        task.wait(1.5)
        StatusLabel.Text = "Готов"
        StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
        return pos
    else
        PosDisplay.Text = "Ошибка"
        StatusLabel.Text = "✗ Персонаж не найден"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        task.wait(1.2)
        StatusLabel.Text = "Готов"
        return nil
    end
end

local function JustCopy()
    local pos = GetPlayerPosition()
    if pos then
        local copyText = FormatPositionRaw(pos)
        if setclipboard then setclipboard(copyText)
        elseif toclipboard then toclipboard(copyText)
        elseif writeclipboard then writeclipboard(copyText)
        elseif syn and syn.set_clipboard then syn.set_clipboard(copyText)
        elseif mobile and mobile.copy then mobile.copy(copyText)
        end
        StatusLabel.Text = "✓ " .. copyText
        StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        task.wait(1)
        StatusLabel.Text = "Готов"
    else
        StatusLabel.Text = "✗ Нет позиции"
    end
end

local function UpdateDisplayOnly()
    local pos = GetPlayerPosition()
    if pos then
        PosDisplay.Text = FormatPositionRaw(pos)
    else
        PosDisplay.Text = "Ошибка"
    end
end

-- === ПОЛЗУНОК (СЕНСОРНЫЙ/МЫШЬ) ===
local dragging = false
local function UpdateSliderFromInput(inputPos)
    local trackAbsPos = SliderTrack.AbsolutePosition
    local trackWidth = SliderTrack.AbsoluteSize.X
    if trackWidth <= 0 then return end
    
    local relativeX = math.clamp(inputPos.X - trackAbsPos.X, 0, trackWidth)
    local percent = relativeX / trackWidth
    local newSpeed = 16 + percent * (250 - 16)
    newSpeed = math.clamp(newSpeed, 16, 250)
    SetSpeed(newSpeed)
    if SpeedEnabled then
        UpdateCharacterReferences()
        if Humanoid then Humanoid.WalkSpeed = CurrentSpeed end
    end
end

SliderKnob.MouseButton1Down:Connect(function()
    dragging = true
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
        UpdateSliderFromInput(input.Position)
    end
end)

-- Сенсор для ползунка
SliderKnob.TouchTap:Connect(function() end)
SliderKnob.TouchMoved:Connect(function(touch)
    UpdateSliderFromInput(touch.Position)
end)

SliderTrack.MouseButton1Down:Connect(function(x, y)
    UpdateSliderFromInput(UserInputService:GetMouseLocation())
end)

SliderTrack.TouchTap:Connect(function(touch)
    UpdateSliderFromInput(touch.Position)
end)

-- === ОБРАБОТЧИКИ КНОПОК ===
local function AnimateButton(btn)
    local origSize = btn.Size
    local tween = TweenService:Create(btn, TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Size = UDim2.new(origSize.X.Scale, origSize.X.Offset, origSize.Y.Scale, origSize.Y.Offset - 2)})
    tween:Play()
    tween.Completed:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size = origSize}):Play()
    end)
end

GetPosBtn.MouseButton1Click:Connect(function()
    AnimateButton(GetPosBtn)
    UpdateDisplayAndCopy("raw")
end)

CopyBtn.MouseButton1Click:Connect(function()
    AnimateButton(CopyBtn)
    JustCopy()
end)

NoclipBtn.MouseButton1Click:Connect(function()
    AnimateButton(NoclipBtn)
    ToggleNoclip()
end)

SpeedToggleBtn.MouseButton1Click:Connect(function()
    AnimateButton(SpeedToggleBtn)
    ToggleSpeed()
end)

CloseBtn.MouseButton1Click:Connect(function()
    if NoclipEnabled then ToggleNoclip() end
    if SpeedEnabled then ToggleSpeed() end
    ScreenGui:Destroy()
end)

-- Сенсорные прикосновения
GetPosBtn.TouchTap:Connect(function() AnimateButton(GetPosBtn); UpdateDisplayAndCopy("raw") end)
CopyBtn.TouchTap:Connect(function() AnimateButton(CopyBtn); JustCopy() end)
NoclipBtn.TouchTap:Connect(function() AnimateButton(NoclipBtn); ToggleNoclip() end)
SpeedToggleBtn.TouchTap:Connect(function() AnimateButton(SpeedToggleBtn); ToggleSpeed() end)
CloseBtn.TouchTap:Connect(function() 
    if NoclipEnabled then ToggleNoclip() end
    if SpeedEnabled then ToggleSpeed() end
    ScreenGui:Destroy() 
end)

-- Сброс Noclip при респавне
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = newChar:FindFirstChild("Humanoid")
    task.wait(0.3)
    if NoclipEnabled then
        for _, part in pairs(newChar:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
    if SpeedEnabled and Humanoid then
        Humanoid.WalkSpeed = CurrentSpeed
    end
    UpdateDisplayOnly()
end)

-- Инициализация ползунка
SetSpeed(50)

-- Глобальные экспорты
_G.GetPosition = GetPlayerPosition
_G.GetPositionRaw = function() local p = GetPlayerPosition() return p and string.format("%.2f,%.2f,%.2f", p.X, p.Y, p.Z) end
_G.ToggleNoclip = ToggleNoclip
_G.ToggleSpeed = ToggleSpeed
_G.SetSpeed = SetSpeed
_G.NoclipEnabled = false
_G.SpeedEnabled = false

-- Анимация появления
MainFrame.BackgroundTransparency = 1
for i = 1, 10 do
    MainFrame.BackgroundTransparency = 1 - (i * 0.09)
    task.wait(0.015)
end

print("=== PosGetter+ PRO Loading ===")
print("Копирует ТОЛЬКО: X, Y, Z")
print("Noclip: кнопка вкл/выкл")
print("Speed: ползунок регулировки + кнопка вкл/выкл")
