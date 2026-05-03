--[[
    Mobile Roblox Executor - Floating Mini Menu
    Сенсорное управление, копирование позиции в буфер
    Совместимость: Hydrogen, Arceus X, Fluxus Android, Delta Executor
--]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Конфигурация меню
local MenuConfig = {
    Position = UDim2.new(0.85, 0, 0.15, 0),  -- Правая сторона, 15% сверху
    Size = UDim2.new(0, 140, 0, 180),
    Color = Color3.fromRGB(25, 25, 35),
    TextColor = Color3.fromRGB(255, 255, 255),
    AccentColor = Color3.fromRGB(66, 135, 245)
}

-- Создание GUI
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

-- Скругление углов
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

-- Тень (легкий эффект глубины)
local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 1
UIStroke.Color = Color3.fromRGB(100, 100, 120)
UIStroke.Transparency = 0.7
UIStroke.Parent = MainFrame

-- Заголовок
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
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
TitleLabel.Text = "📍 PosGetter"
TitleLabel.TextColor3 = MenuConfig.TextColor
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Кнопка закрытия (X)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = TitleBar
CloseBtn.Size = UDim2.new(0, 30, 1, 0)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = MenuConfig.TextColor
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.GothamBold

-- Кнопка "Получить позицию"
local GetPosBtn = Instance.new("TextButton")
GetPosBtn.Parent = MainFrame
GetPosBtn.Size = UDim2.new(0.85, 0, 0, 40)
GetPosBtn.Position = UDim2.new(0.075, 0, 0, 45)
GetPosBtn.BackgroundColor3 = MenuConfig.AccentColor
GetPosBtn.BackgroundTransparency = 0.2
GetPosBtn.Text = "📌 Получить позицию"
GetPosBtn.TextColor3 = MenuConfig.TextColor
GetPosBtn.TextSize = 13
GetPosBtn.Font = Enum.Font.GothamSemibold

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 8)
BtnCorner.Parent = GetPosBtn

-- Поле вывода координат
local PosDisplay = Instance.new("TextBox")
PosDisplay.Parent = MainFrame
PosDisplay.Size = UDim2.new(0.85, 0, 0, 35)
PosDisplay.Position = UDim2.new(0.075, 0, 0, 95)
PosDisplay.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
PosDisplay.BackgroundTransparency = 0.3
PosDisplay.Text = "X: 0, Y: 0, Z: 0"
PosDisplay.TextColor3 = MenuConfig.TextColor
PosDisplay.TextSize = 11
PosDisplay.Font = Enum.Font.Code
PosDisplay.TextXAlignment = Enum.TextXAlignment.Center
PosDisplay.ClearTextOnFocus = false

local DisplayCorner = Instance.new("UICorner")
DisplayCorner.CornerRadius = UDim.new(0, 6)
DisplayCorner.Parent = PosDisplay

-- Кнопка копирования
local CopyBtn = Instance.new("TextButton")
CopyBtn.Parent = MainFrame
CopyBtn.Size = UDim2.new(0.85, 0, 0, 35)
CopyBtn.Position = UDim2.new(0.075, 0, 0, 140)
CopyBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
CopyBtn.Text = "📋 Копировать в буфер"
CopyBtn.TextColor3 = MenuConfig.TextColor
CopyBtn.TextSize = 12
CopyBtn.Font = Enum.Font.Gotham

local CopyCorner = Instance.new("UICorner")
CopyCorner.CornerRadius = UDim.new(0, 6)
CopyCorner.Parent = CopyBtn

-- Индикатор статуса
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Parent = MainFrame
StatusLabel.Size = UDim2.new(0.85, 0, 0, 18)
StatusLabel.Position = UDim2.new(0.075, 0, 1, -22)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Готов"
StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
StatusLabel.TextSize = 9
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextXAlignment = Enum.TextXAlignment.Center

-- Анимация нажатия
local function AnimateButton(btn)
    local originalSize = btn.Size
    local tween = TweenService:Create(btn, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
        {Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset, originalSize.Y.Scale, originalSize.Y.Offset - 2)})
    tween:Play()
    tween.Completed:Connect(function()
        local tween2 = TweenService:Create(btn, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
            {Size = originalSize})
        tween2:Play()
    end)
end

-- Получение позиции персонажа
local function GetPlayerPosition()
    local char = LocalPlayer.Character
    if not char or not char.Parent then
        return nil
    end
    
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if rootPart then
        return rootPart.Position
    end
    
    local primary = char.PrimaryPart
    if primary then
        return primary.Position
    end
    
    return nil
end

-- Форматирование позиции
local function FormatPosition(pos)
    if not pos then return "Персонаж не найден" end
    return string.format("X: %.1f, Y: %.1f, Z: %.1f", pos.X, pos.Y, pos.Z)
end

local function FormatVector3Lua(pos)
    if not pos then return "nil" end
    return string.format("Vector3.new(%.2f, %.2f, %.2f)", pos.X, pos.Y, pos.Z)
end

-- Обновление дисплея
local function UpdateDisplay()
    local pos = GetPlayerPosition()
    if pos then
        PosDisplay.Text = FormatPosition(pos)
        StatusLabel.Text = "✓ Позиция обновлена"
        StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        task.wait(1.5)
        StatusLabel.Text = "Готов"
        StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        return pos
    else
        PosDisplay.Text = "Ошибка: персонаж не найден"
        StatusLabel.Text = "✗ Ошибка"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        task.wait(1.5)
        StatusLabel.Text = "Готов"
        StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        return nil
    end
end

-- Копирование в буфер (мобильные экзекюторы)
local function CopyToClipboard(text)
    -- Поддержка разных экзекюторов
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
        StatusLabel.Text = "✓ Скопировано!"
        StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        task.wait(1)
        StatusLabel.Text = "Готов"
        StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    else
        StatusLabel.Text = "✗ Буфер недоступен"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        task.wait(1.5)
        StatusLabel.Text = "Готов"
    end
end

-- Обработчики кнопок
GetPosBtn.MouseButton1Click:Connect(function()
    AnimateButton(GetPosBtn)
    local pos = UpdateDisplay()
    if pos then
        -- Сохраняем в глобальную переменную для других скриптов
        _G.LastPlayerPosition = pos
        _G.LastPositionString = FormatVector3Lua(pos)
    end
end)

CopyBtn.MouseButton1Click:Connect(function()
    AnimateButton(CopyBtn)
    local currentText = PosDisplay.Text
    if currentText and currentText ~= "Ошибка: персонаж не найден" and currentText ~= "Персонаж не найден" then
        -- Получаем точную позицию для копирования
        local pos = GetPlayerPosition()
        if pos then
            local copyText = FormatVector3Lua(pos)
            CopyToClipboard(copyText)
            
            -- Визуальный фидбек на кнопке копирования
            local originalText = CopyBtn.Text
            CopyBtn.Text = "✓ Скопировано!"
            task.wait(0.8)
            CopyBtn.Text = originalText
        else
            CopyToClipboard(currentText)
        end
    else
        StatusLabel.Text = "✗ Нет позиции для копирования"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        task.wait(1)
        StatusLabel.Text = "Готов"
    end
end)

-- Закрытие меню
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Сенсорная поддержка для кнопок
local function SetupTouch(button)
    button.TouchTap:Connect(function()
        if button == GetPosBtn then
            AnimateButton(GetPosBtn)
            UpdateDisplay()
        elseif button == CopyBtn then
            AnimateButton(CopyBtn)
            local pos = GetPlayerPosition()
            if pos then
                CopyToClipboard(FormatVector3Lua(pos))
                local originalText = CopyBtn.Text
                CopyBtn.Text = "✓ Скопировано!"
                task.wait(0.8)
                CopyBtn.Text = originalText
            end
        elseif button == CloseBtn then
            ScreenGui:Destroy()
        end
    end)
end

SetupTouch(GetPosBtn)
SetupTouch(CopyBtn)
SetupTouch(CloseBtn)

-- Глобальные функции для других скриптов
_G.GetPosition = GetPlayerPosition
_G.GetPositionString = function()
    local pos = GetPlayerPosition()
    return pos and FormatVector3Lua(pos) or nil
end
_G.LastPlayerPosition = nil

-- Анимация появления меню (плавный fade-in)
MainFrame.BackgroundTransparency = 1
for i = 1, 10 do
    MainFrame.BackgroundTransparency = 1 - (i * 0.09)
    task.wait(0.02)
end

print("=== Mobile PosGetter Menu Loaded ===")
print("Сенсорное меню активно! Нажмите на кнопки для получения и копирования позиции")
print("Доступ из других скриптов: _G.GetPosition() и _G.LastPlayerPosition")
