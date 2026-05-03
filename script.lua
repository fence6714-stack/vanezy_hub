--[[
    TWEAKOS EXECUTOR v5.0 - МИНИМАЛЬНАЯ ВЕРСИЯ БЕЗ ОШИБОК
    Убраны все потенциальные проблемы совместимости
    Noclip через BodyVelocity + CanCollide
    Скорость 8-300
    Позиция с копированием
--]]

-- Защита от повторов
if getgenv().TWEAKOS_LOADED then
    return
end
getgenv().TWEAKOS_LOADED = true

-- Сервисы
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Очистка старых GUI
pcall(function()
    for _, v in ipairs(LocalPlayer.PlayerGui:GetChildren()) do
        if v.Name == "TWEAKOS_Core" then
            v:Destroy()
        end
    end
end)

-- Переменные
local noclipEnabled = false
local speedValue = 16
local noclipBv = nil
local noclipConn = nil
local lastPosition = Vector3.zero

-- Создание GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TWEAKOS_Core"
ScreenGui.Parent = LocalPlayer.PlayerGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 300, 0, 250)
Main.Position = UDim2.new(0.5, -150, 0.3, 0)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.Text = "TWEAKOS v5.0"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = Main

-- ============================================
-- NOCLIP
-- ============================================
local NoclipFrame = Instance.new("Frame")
NoclipFrame.Size = UDim2.new(1, -20, 0, 50)
NoclipFrame.Position = UDim2.new(0, 10, 0, 45)
NoclipFrame.BackgroundTransparency = 1
NoclipFrame.Parent = Main

local NoclipLabel = Instance.new("TextLabel")
NoclipLabel.Size = UDim2.new(0, 180, 0, 50)
NoclipLabel.BackgroundTransparency = 1
NoclipLabel.Text = "ПРОХОД СКВОЗЬ СТЕНЫ"
NoclipLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
NoclipLabel.Font = Enum.Font.Gotham
NoclipLabel.TextSize = 14
NoclipLabel.TextXAlignment = Enum.TextXAlignment.Left
NoclipLabel.Parent = NoclipFrame

local NoclipBtn = Instance.new("TextButton")
NoclipBtn.Size = UDim2.new(0, 70, 0, 35)
NoclipBtn.Position = UDim2.new(1, -75, 0, 8)
NoclipBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
NoclipBtn.Text = "ВЫКЛ"
NoclipBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
NoclipBtn.Font = Enum.Font.GothamBold
NoclipBtn.TextSize = 13
NoclipBtn.AutoButtonColor = false
NoclipBtn.Parent = NoclipFrame

Instance.new("UICorner", NoclipBtn).CornerRadius = UDim.new(0, 8)

-- Функция Noclip
local function EnableNoclip()
    local char = LocalPlayer.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    -- Удаляем старый BodyVelocity
    if noclipBv then
        pcall(function() noclipBv:Destroy() end)
    end
    
    -- Создаём новый
    noclipBv = Instance.new("BodyVelocity")
    noclipBv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    noclipBv.Velocity = Vector3.zero
    noclipBv.P = 100000
    noclipBv.Parent = hrp
    
    -- Отключаем коллизию
    for _, v in ipairs(char:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CanCollide = false
        end
    end
    
    -- Цикл движения
    noclipConn = RunService.Stepped:Connect(function()
        if not noclipEnabled then return end
        
        local c = LocalPlayer.Character
        if not c then return end
        
        local h = c:FindFirstChild("Humanoid")
        local r = c:FindFirstChild("HumanoidRootPart")
        if not h or not r then return end
        
        -- Поддержание коллизии выключенной
        for _, v in ipairs(c:GetDescendants()) do
            if v:IsA("BasePart") and v.CanCollide == true then
                v.CanCollide = false
            end
        end
        
        -- Движение через BodyVelocity
        if noclipBv and noclipBv.Parent == r then
            local md = h.MoveDirection
            if md.Magnitude > 0 then
                noclipBv.Velocity = md * speedValue
            else
                noclipBv.Velocity = Vector3.zero
            end
        end
    end)
end

local function DisableNoclip()
    noclipEnabled = false
    
    if noclipConn then
        pcall(function() noclipConn:Disconnect() end)
        noclipConn = nil
    end
    
    if noclipBv then
        pcall(function() noclipBv:Destroy() end)
        noclipBv = nil
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

local function ToggleNoclip()
    noclipEnabled = not noclipEnabled
    
    if noclipEnabled then
        EnableNoclip()
        NoclipBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 40)
        NoclipBtn.Text = "ВКЛ"
    else
        DisableNoclip()
        NoclipBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
        NoclipBtn.Text = "ВЫКЛ"
    end
end

NoclipBtn.Activated:Connect(ToggleNoclip)
NoclipBtn.MouseButton1Down:Connect(ToggleNoclip)

-- ============================================
-- СКОРОСТЬ
-- ============================================
local SpeedFrame = Instance.new("Frame")
SpeedFrame.Size = UDim2.new(1, -20, 0, 60)
SpeedFrame.Position = UDim2.new(0, 10, 0, 105)
SpeedFrame.BackgroundTransparency = 1
SpeedFrame.Parent = Main

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(1, 0, 0, 22)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "СКОРОСТЬ: 16"
SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedLabel.Font = Enum.Font.Gotham
SpeedLabel.TextSize = 14
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedLabel.Parent = SpeedFrame

local SliderTrack = Instance.new("TextButton")
SliderTrack.Size = UDim2.new(1, 0, 0, 14)
SliderTrack.Position = UDim2.new(0, 0, 0, 28)
SliderTrack.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SliderTrack.BorderSizePixel = 0
SliderTrack.Text = ""
SliderTrack.AutoButtonColor = false
SliderTrack.Parent = SpeedFrame

Instance.new("UICorner", SliderTrack).CornerRadius = UDim.new(0, 7)

local SliderFill = Instance.new("Frame")
SliderFill.Size = UDim2.new(0.027, 0, 1, 0)
SliderFill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
SliderFill.BorderSizePixel = 0
SliderFill.Parent = SliderTrack

Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(0, 7)

local SliderKnob = Instance.new("TextButton")
SliderKnob.Size = UDim2.new(0, 32, 0, 32)
SliderKnob.Position = UDim2.new(0.027, -16, 0.5, -16)
SliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SliderKnob.BorderSizePixel = 0
SliderKnob.Text = ""
SliderKnob.AutoButtonColor = false
SliderKnob.Parent = SliderTrack

Instance.new("UICorner", SliderKnob).CornerRadius = UDim.new(1, 0)

-- Логика ползунка
local dragging = false

local function UpdateSpeed(inputPos)
    local trackStart = SliderTrack.AbsolutePosition.X
    local trackWidth = SliderTrack.AbsoluteSize.X
    local relativeX = math.clamp((inputPos.X - trackStart) / trackWidth, 0, 1)
    
    speedValue = math.floor(8 + (relativeX * 292) + 0.5)
    speedValue = math.clamp(speedValue, 8, 300)
    
    SliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
    SliderKnob.Position = UDim2.new(relativeX, -16, 0.5, -16)
    SpeedLabel.Text = "СКОРОСТЬ: " .. speedValue
    
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
        dragging = true
    end
end)

SliderTrack.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or 
       input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        UpdateSpeed(input.Position)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or 
                    input.UserInputType == Enum.UserInputType.MouseMovement) then
        UpdateSpeed(input.Position)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or 
       input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- ============================================
-- ПОЗИЦИЯ
-- ============================================
local PositionFrame = Instance.new("Frame")
PositionFrame.Size = UDim2.new(1, -20, 0, 55)
PositionFrame.Position = UDim2.new(0, 10, 0, 175)
PositionFrame.BackgroundTransparency = 1
PositionFrame.Parent = Main

local PositionLabel = Instance.new("TextLabel")
PositionLabel.Size = UDim2.new(1, 0, 0, 22)
PositionLabel.BackgroundTransparency = 1
PositionLabel.Text = "X: 0.000 | Y: 0.000 | Z: 0.000"
PositionLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
PositionLabel.Font = Enum.Font.Code
PositionLabel.TextSize = 11
PositionLabel.TextXAlignment = Enum.TextXAlignment.Left
PositionLabel.Parent = PositionFrame

local CopyBtn = Instance.new("TextButton")
CopyBtn.Size = UDim2.new(1, 0, 0, 30)
CopyBtn.Position = UDim2.new(0, 0, 0, 24)
CopyBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 180)
CopyBtn.Text = "КОПИРОВАТЬ ПОЗИЦИЮ"
CopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyBtn.Font = Enum.Font.GothamBold
CopyBtn.TextSize = 13
CopyBtn.AutoButtonColor = false
CopyBtn.Parent = PositionFrame

Instance.new("UICorner", CopyBtn).CornerRadius = UDim.new(0, 6)

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
            getgenv().PlayerPosition = lastPosition
        end
    end
end)

local function CopyPosition()
    local pos = lastPosition
    local posString = string.format("Vector3.new(%.3f, %.3f, %.3f)", pos.X, pos.Y, pos.Z)
    
    pcall(function()
        setclipboard(posString)
    end)
    
    CopyBtn.BackgroundColor3 = Color3.fromRGB(60, 180, 60)
    CopyBtn.Text = "СКОПИРОВАНО!"
    
    task.wait(0.7)
    CopyBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 180)
    CopyBtn.Text = "КОПИРОВАТЬ ПОЗИЦИЮ"
end

CopyBtn.Activated:Connect(CopyPosition)
CopyBtn.MouseButton1Down:Connect(CopyPosition)

-- ============================================
-- ВОССТАНОВЛЕНИЕ ПРИ РЕСПАВНЕ
-- ============================================
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.2)
    
    local hum = char:FindFirstChild("Humanoid")
    if hum then
        hum.WalkSpeed = speedValue
    end
    
    if noclipEnabled then
        EnableNoclip()
    end
end)

-- Инициализация
if LocalPlayer.Character then
    local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
    if hum then
        hum.WalkSpeed = speedValue
    end
end

print("TWEAKOS v5.0 - Loaded")
