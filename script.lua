--[[
    Mobile Roblox Executor - Floating Mini Menu + Noclip + Speed
    Сенсорное управление, копирование позиции, проход через стены, ускорение
    Совместимость: Hydrogen, Arceus X, Fluxus Android, Delta Executor
--]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Конфигурация
local MenuConfig = {
    Position = UDim2.new(0.85, 0, 0.15, 0),
    Size = UDim2.new(0, 160, 0, 260),
    Color = Color3.fromRGB(25, 25, 35),
    TextColor = Color3.fromRGB(255, 255, 255),
    AccentColor = Color3.fromRGB(66, 135, 245),
    DangerColor = Color3.fromRGB(220, 50, 50),
    SpeedColor = Color3.fromRGB(50, 220, 150)
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
ScreenGui.Name = "PosGetterMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

-- Главная панель
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = MenuConfig.Color
MainFrame.BackgroundTransparency = 0.08
MainFrame.BorderSizePixel = 0
MainFrame.Position = MenuConfig.Position
MainFrame.Size = MenuConfig.Size
MainFrame.Active = true
MainFrame.Draggable = true

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 1
UIStroke.Color = Color3.fromRGB(100, 100, 120)
UIStroke.Transparency = 0.7
UIStroke.Parent = MainFrame

-- Заголовок
local TitleBar = Instance.new("Frame")
TitleBar.Parent = MainFrame
TitleBar.BackgroundColor3 = MenuConfig.AccentColor
TitleBar.BackgroundTransparency = 0.15
TitleBar.Size = UDim2.new(1, 0, 0, 32)
TitleBar.Position = UDim2.new(0, 0, 0, 0)

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Parent = TitleBar
TitleLabel.BackgroundTransparency = 1
TitleLabel.Size = UDim2.new(1, -30, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.Text = "🔧 PosGetter+"
TitleLabel.TextColor3 = MenuConfig.TextColor
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = TitleBar
CloseBtn.Size = UDim2.new(0, 30, 1, 0)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = MenuConfig.TextColor
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.GothamBold

-- Кнопка позиции
local GetPosBtn = Instance.new("TextButton")
GetPosBtn.Parent = MainFrame
GetPosBtn.Size = UDim2.new(0.85, 0, 0, 38)
GetPosBtn.Position = UDim2.new(0.075, 0, 0, 42)
GetPosBtn.BackgroundColor3 = MenuConfig.AccentColor
GetPosBtn.BackgroundTransparency = 0.2
GetPosBtn.Text = "📍 Получить позицию"
GetPosBtn.TextColor3 = MenuConfig.TextColor
GetPosBtn.TextSize = 12
GetPosBtn.Font = Enum.Font.GothamSemibold

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 8)
BtnCorner.Parent = GetPosBtn

-- Поле вывода
local PosDisplay = Instance.new("TextBox")
PosDisplay.Parent = MainFrame
PosDisplay.Size = UDim2.new(0.85, 0, 0, 32)
PosDisplay.Position = UDim2.new(0.075, 0, 0, 88)
PosDisplay.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
PosDisplay.BackgroundTransparency = 0.3
PosDisplay.Text = "X: 0, Y: 0, Z: 0"
PosDisplay.TextColor3 = MenuConfig.TextColor
PosDisplay.TextSize = 10
PosDisplay.Font = Enum.Font.Code
PosDisplay.TextXAlignment = Enum.TextXAlignment.Center
PosDisplay.ClearTextOnFocus = false

local DisplayCorner = Instance.new("UICorner")
DisplayCorner.CornerRadius = UDim.new(0, 6)
DisplayCorner.Parent = PosDisplay

-- Кнопка копирования
local CopyBtn = Instance.new("TextButton")
CopyBtn.Parent = MainFrame
CopyBtn.Size = UDim2.new(0.85, 0, 0, 32)
CopyBtn.Position = UDim2.new(0.075, 0, 0, 128)
CopyBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
CopyBtn.Text = "📋 Копировать"
CopyBtn.TextColor3 = MenuConfig.TextColor
CopyBtn.TextSize = 11
CopyBtn.Font = Enum.Font.Gotham

local CopyCorner = Instance.new("UICorner")
CopyCorner.CornerRadius = UDim.new(0, 6)
CopyCorner.Parent = CopyBtn

-- Разделитель
local Divider = Instance.new("Frame")
Divider.Parent = MainFrame
Divider.Size = UDim2.new(0.85, 0, 0, 1)
Divider.Position = UDim2.new(0.075, 0, 0, 170)
Divider.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
Divider.BackgroundTransparency = 0.5

-- Кнопка Noclip
local NoclipBtn = Instance.new("TextButton")
NoclipBtn.Parent = MainFrame
NoclipBtn.Size = UDim2.new(0.85, 0, 0, 36)
NoclipBtn.Position = UDim2.new(0.075, 0, 0, 182)
NoclipBtn.BackgroundColor3 = MenuConfig.DangerColor
NoclipBtn.BackgroundTransparency = 0.3
NoclipBtn.Text = "🚪 NOCLIP: ВЫКЛ"
NoclipBtn.TextColor3 = MenuConfig.TextColor
NoclipBtn.TextSize = 12
NoclipBtn.Font = Enum.Font.GothamBold

local NoclipCorner = Instance.new("UICorner")
NoclipCorner.CornerRadius = UDim.new(0, 8)
NoclipCorner.Parent = NoclipBtn

-- Кнопка Speed
local SpeedBtn = Instance.new("TextButton")
SpeedBtn.Parent = MainFrame
SpeedBtn.Size = UDim2.new(0.85, 0, 0, 36)
SpeedBtn.Position = UDim2.new(0.075, 0, 0, 226)
SpeedBtn.BackgroundColor3 = MenuConfig.SpeedColor
SpeedBtn.BackgroundTransparency = 0.3
SpeedBtn.Text = "⚡ SPEED: ВЫКЛ (50)"
SpeedBtn.TextColor3 = MenuConfig.TextColor
SpeedBtn.TextSize = 11
SpeedBtn.Font = Enum.Font.GothamBold

local SpeedCorner = Instance.new("UICorner")
SpeedCorner.CornerRadius = UDim.new(0, 8)
SpeedCorner.Parent = SpeedBtn

-- Статус
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Parent = MainFrame
StatusLabel.Size = UDim2.new(0.85, 0, 0, 16)
StatusLabel.Position = UDim2.new(0.075, 0, 1, -20)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Готов"
StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
StatusLabel.TextSize = 9
StatusLabel.Font = Enum.Font.Gotham

-- === ФУНКЦИИ NOCLIP ===
local function UpdateCharacterReferences()
    Character = LocalPlayer.Character
    if Character then
        Humanoid = Character:FindFirstChild("Humanoid")
    end
end

local function StartNoclip()
    if not NoclipEnabled then return end
    RunService.Stepped:Connect(function()
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
    if NoclipEnabled then
        UpdateCharacterReferences()
        if Character then
            for _, part in pairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
        NoclipBtn.Text = "🚪 NOCLIP: ВКЛ"
        NoclipBtn.BackgroundColor3 = MenuConfig.DangerColor
        NoclipBtn.BackgroundTransparency = 0
        StatusLabel.Text = "✓ Noclip активирован"
        StartNoclip()
    else
        UpdateCharacterReferences()
        if Character then
            for _, part in pairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
        NoclipBtn.Text = "🚪 NOCLIP: ВЫКЛ"
        NoclipBtn.BackgroundTransparency = 0.3
        StatusLabel.Text = "✗ Noclip деактивирован"
    end
    StatusLabel.TextColor3 = NoclipEnabled and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
    task.wait(1.5)
    StatusLabel.Text = "Готов"
    StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
end

-- === ФУНКЦИИ SPEED ===
local function SetSpeed(value)
    UpdateCharacterReferences()
    if Humanoid then
        OriginalWalkspeed = Humanoid.WalkSpeed
        Humanoid.WalkSpeed = value
    end
end

local function ResetSpeed()
    UpdateCharacterReferences()
    if Humanoid then
        Humanoid.WalkSpeed = OriginalWalkspeed
    end
end

local function ToggleSpeed()
    SpeedEnabled = not SpeedEnabled
    if SpeedEnabled then
        SetSpeed(CurrentSpeed)
        SpeedBtn.Text = "⚡ SPEED: ВКЛ (" .. CurrentSpeed .. ")"
        SpeedBtn.BackgroundTransparency = 0
        StatusLabel.Text = "✓ Скорость: " .. CurrentSpeed
    else
        ResetSpeed()
        SpeedBtn.Text = "⚡ SPEED: ВЫКЛ (" .. CurrentSpeed .. ")"
        SpeedBtn.BackgroundTransparency = 0.3
        StatusLabel.Text = "✗ Скорость сброшена"
    end
    StatusLabel.TextColor3 = SpeedEnabled and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
    task.wait(1.5)
    StatusLabel.Text = "Готов"
    StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
end

-- Изменение скорости (зажимание для увеличения)
local SpeedAdjustActive = false
local SpeedAdjustThread = nil

local function StartSpeedAdjust(increase)
    SpeedAdjustActive = true
    SpeedAdjustThread = task.spawn(function()
        while SpeedAdjustActive do
            if increase then
                CurrentSpeed = math.min(CurrentSpeed + 5, 250)
            else
                CurrentSpeed = math.max(CurrentSpeed - 5, 16)
            end
            if SpeedEnabled then
                SetSpeed(CurrentSpeed)
            end
            SpeedBtn.Text = (SpeedEnabled and "⚡ SPEED: ВКЛ (" or "⚡ SPEED: ВЫКЛ (") .. CurrentSpeed .. ")"
            StatusLabel.Text = "⚡ Скорость: " .. CurrentSpeed
            task.wait(0.15)
        end
    end)
end

local function StopSpeedAdjust()
    SpeedAdjustActive = false
    if SpeedAdjustThread then
        task.cancel(SpeedAdjustThread)
    end
    StatusLabel.Text = "Готов"
    task.wait(1)
    StatusLabel.Text = "Готов"
end

-- === ОСТАЛЬНЫЕ ФУНКЦИИ ===
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

local function FormatPosition(pos)
    if not pos then return "Персонаж не найден" end
    return string.format("X: %.1f, Y: %.1f, Z: %.1f", pos.X, pos.Y, pos.Z)
end

local function FormatVector3Lua(pos)
    if not pos then return "nil" end
    return string.format("Vector3.new(%.2f, %.2f, %.2f)", pos.X, pos.Y, pos.Z)
end

local function UpdateDisplay()
    local pos = GetPlayerPosition()
    if pos then
        PosDisplay.Text = FormatPosition(pos)
        StatusLabel.Text = "✓ Позиция обновлена"
        StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        task.wait(1.2)
        StatusLabel.Text = "Готов"
        StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        return pos
    else
        PosDisplay.Text = "Ошибка: персонаж не найден"
        StatusLabel.Text = "✗ Ошибка"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        task.wait(1.2)
        StatusLabel.Text = "Готов"
        return nil
    end
end

local function CopyToClipboard(text)
    local success = false
    if setclipboard then
        setclipboard(text)
        success = true
    elseif toclipboard then
        toclipboard(text)
        success = true
    elseif writeclipboard then
        writeclipboard(text)
        success = true
    elseif syn and syn.set_clipboard then
        syn.set_clipboard(text)
        success = true
    elseif mobile and mobile.copy then
        mobile.copy(text)
        success = true
    end
    
    if success then
        StatusLabel.Text = "✓ Скопировано: " .. text
        StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        task.wait(1)
    else
        StatusLabel.Text = "✗ Буфер недоступен"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        task.wait(1.2)
    end
    StatusLabel.Text = "Готов"
    StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
end

local function AnimateButton(btn)
    local originalSize = btn.Size
    local tween = TweenService:Create(btn, TweenInfo.new(0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
        {Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset, originalSize.Y.Scale, originalSize.Y.Offset - 2)})
    tween:Play()
    tween.Completed:Connect(function()
        local tween2 = TweenService:Create(btn, TweenInfo.new(0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
            {Size = originalSize})
        tween2:Play()
    end)
end

-- === ОБРАБОТЧИКИ ===
GetPosBtn.MouseButton1Click:Connect(function()
    AnimateButton(GetPosBtn)
    UpdateDisplay()
end)

CopyBtn.MouseButton1Click:Connect(function()
    AnimateButton(CopyBtn)
    local pos = GetPlayerPosition()
    if pos then
        CopyToClipboard(FormatVector3Lua(pos))
    else
        CopyToClipboard(PosDisplay.Text)
    end
end)

NoclipBtn.MouseButton1Click:Connect(function()
    AnimateButton(NoclipBtn)
    ToggleNoclip()
end)

-- Долгое нажатие для сброса noclip (FULL RESET)
local NoclipHoldThread = nil
NoclipBtn.MouseButton1Down:Connect(function()
    NoclipHoldThread = task.spawn(function()
        task.wait(1.5)
        if NoclipEnabled then
            ToggleNoclip()
            ToggleNoclip()
            StatusLabel.Text = "🔄 Noclip перезагружен"
        end
    end)
end)
NoclipBtn.MouseButton1Up:Connect(function()
    if NoclipHoldThread then task.cancel(NoclipHoldThread) end
end)

-- Speed кнопка: короткое нажатие = вкл/выкл, долгое = регулировка
local SpeedHoldThread = nil
local SpeedHoldActive = false

SpeedBtn.MouseButton1Down:Connect(function()
    SpeedHoldThread = task.spawn(function()
        task.wait(0.5)
        SpeedHoldActive = true
        StartSpeedAdjust(true)
    end)
end)

SpeedBtn.MouseButton1Up:Connect(function()
    if SpeedHoldThread then 
        task.cancel(SpeedHoldThread)
        SpeedHoldThread = nil
    end
    if SpeedHoldActive then
        StopSpeedAdjust()
        SpeedHoldActive = false
    else
        ToggleSpeed()
    end
end)

-- Нажатие правой кнопкой/двумя пальцами = уменьшение скорости
local function OnRightClick()
    StartSpeedAdjust(false)
    task.wait(1)
    StopSpeedAdjust()
end

SpeedBtn.MouseButton2Click:Connect(OnRightClick)

CloseBtn.MouseButton1Click:Connect(function()
    if NoclipEnabled then ToggleNoclip() end
    if SpeedEnabled then ToggleSpeed() end
    ScreenGui:Destroy()
end)

-- Сенсорная поддержка
local function SetupTouch(button, isSpeed)
    button.TouchTap:Connect(function()
        if button == GetPosBtn then
            AnimateButton(GetPosBtn)
            UpdateDisplay()
        elseif button == CopyBtn then
            AnimateButton(CopyBtn)
            local pos = GetPlayerPosition()
            if pos then
                CopyToClipboard(FormatVector3Lua(pos))
            end
        elseif button == NoclipBtn then
            AnimateButton(NoclipBtn)
            ToggleNoclip()
        elseif button == SpeedBtn then
            ToggleSpeed()
        elseif button == CloseBtn then
            if NoclipEnabled then ToggleNoclip() end
            if SpeedEnabled then ToggleSpeed() end
            ScreenGui:Destroy()
        end
    end)
    
    if isSpeed then
        button.TouchLongPress:Connect(function()
            StartSpeedAdjust(true)
            task.wait(2)
            StopSpeedAdjust()
        end)
    end
end

SetupTouch(GetPosBtn, false)
SetupTouch(CopyBtn, false)
SetupTouch(NoclipBtn, false)
SetupTouch(SpeedBtn, true)
SetupTouch(CloseBtn, false)

-- Глобальные экспорты
_G.GetPosition = GetPlayerPosition
_G.GetPositionString = function() local pos = GetPlayerPosition() return pos and FormatVector3Lua(pos) or nil end
_G.LastPlayerPosition = nil
_G.ToggleNoclip = ToggleNoclip
_G.ToggleSpeed = ToggleSpeed
_G.SetSpeedValue = function(val) CurrentSpeed = math.clamp(val, 16, 250) if SpeedEnabled then SetSpeed(CurrentSpeed) end SpeedBtn.Text = (SpeedEnabled and "⚡ SPEED: ВКЛ (" or "⚡ SPEED: ВЫКЛ (") .. CurrentSpeed .. ")" end

-- Отслеживание респавна
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = newChar:FindFirstChild("Humanoid")
    task.wait(0.5)
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
end)

-- Анимация появления
MainFrame.BackgroundTransparency = 1
for i = 1, 10 do
    MainFrame.BackgroundTransparency = 1 - (i * 0.09)
    task.wait(0.02)
end

print("=== Mobile PosGetter+ Noclip/Speed Loaded ===")
print("Noclip: нажмите кнопку для прохода сквозь стены")
print("Speed: короткое нажатие - вкл/выкл, долгое нажатие - увеличение, правая кнопка/долгий тап - уменьшение")
print("Доступ: _G.ToggleNoclip(), _G.ToggleSpeed(), _G.SetSpeedValue(число)")
