--[[
    STRONGEST SIMULATOR - v10 ULTRA MINIMAL
    Абсолютный минимум, гарантированный запуск
    Телепорт через Character:MoveTo
    Клики через mouse1click
--]]

-- Ждём всё
repeat task.wait(0.1) until game:IsLoaded() and game:GetService("Players").LocalPlayer
local plr = game:GetService("Players").LocalPlayer
repeat task.wait(0.1) until plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
local char = plr.Character
local hrp = char.HumanoidRootPart
local hum = char.Humanoid

local TrainingPos = Vector3.new(2284.36, 49.147, 5903.271)
local ItemPos = Vector3.new(2554.064, 13.71, 5502.688)
local FinishPos = Vector3.new(2542.465, 13.186, 6129.139)

local AutoFarm = false
local AutoLift = false
local frozen = nil

plr.CharacterAdded:Connect(function(c)
    char = c
    hrp = c:WaitForChild("HumanoidRootPart")
    hum = c:WaitForChild("Humanoid")
    if AutoFarm then task.spawn(farmLoop) end
    if AutoLift then task.spawn(liftLoop) end
end)

-- Телепорт через MoveTo
local function tp(pos)
    if char and hrp then
        hrp.CFrame = CFrame.new(pos)
    end
end

-- Заморозка
local function freeze()
    if frozen then frozen:Disconnect() end
    local pos = hrp.Position
    frozen = game:GetService("RunService").RenderStepped:Connect(function()
        if hrp then
            hrp.CFrame = CFrame.new(pos)
            hrp.Velocity = Vector3.zero
        end
        if hum then hum.PlatformStand = true end
    end)
end

local function unfreeze()
    if frozen then frozen:Disconnect(); frozen = nil end
    if hum then hum.PlatformStand = false end
end

-- Клик мышью
local function click()
    game:GetService("VirtualInputManager"):SendMouseButtonEvent(0, 0, 0, true, game, 1)
    game:GetService("VirtualInputManager"):SendMouseButtonEvent(0, 0, 0, false, game, 1)
end

-- Зажать
local function hold(t)
    game:GetService("VirtualInputManager"):SendMouseButtonEvent(0, 0, 0, true, game, 1)
    task.wait(t)
    game:GetService("VirtualInputManager"):SendMouseButtonEvent(0, 0, 0, false, game, 1)
end

-- Цикл штанги
function farmLoop()
    tp(TrainingPos)
    freeze()
    task.wait(0.5)
    hold(1.0)
    while AutoFarm and char and hrp do
        click()
        task.wait(0.7)
    end
    unfreeze()
end

-- Цикл предметов
function liftLoop()
    while AutoLift and char and hrp do
        tp(ItemPos)
        click()
        tp(FinishPos)
        task.wait(0.5)
    end
end

-- GUI
local gui = Instance.new("ScreenGui", game:GetService("CoreGui"))
gui.Name = "TWEAK"

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 300, 0, 180)
main.Position = UDim2.new(0.5, -150, 0.5, -90)
main.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
main.BorderSizePixel = 0
main.Draggable = true
main.Active = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(140, 100, 255)
title.Text = "TWEAK v10"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.BorderSizePixel = 0
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

-- Тоггл 1
local tf1 = Instance.new("Frame", main)
tf1.Size = UDim2.new(1, -20, 0, 35)
tf1.Position = UDim2.new(0, 10, 0, 40)
tf1.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
tf1.BorderSizePixel = 0
Instance.new("UICorner", tf1).CornerRadius = UDim.new(0, 5)

local l1 = Instance.new("TextLabel", tf1)
l1.Size = UDim2.new(0.5, 0, 1, 0)
l1.Position = UDim2.new(0, 8, 0, 0)
l1.BackgroundTransparency = 1
l1.Text = "Авто-штанга"
l1.TextColor3 = Color3.new(1, 1, 1)
l1.Font = Enum.Font.GothamMedium
l1.TextSize = 12
l1.TextXAlignment = Enum.TextXAlignment.Left

local b1 = Instance.new("TextButton", tf1)
b1.Size = UDim2.new(0, 40, 0, 20)
b1.Position = UDim2.new(1, -48, 0.5, -10)
b1.BackgroundColor3 = Color3.fromRGB(200, 70, 70)
b1.Text = ""
b1.BorderSizePixel = 0
Instance.new("UICorner", b1).CornerRadius = UDim.new(0, 10)

local c1 = Instance.new("Frame", b1)
c1.Size = UDim2.new(0, 14, 0, 14)
c1.Position = UDim2.new(0, 3, 0.5, -7)
c1.BackgroundColor3 = Color3.new(1, 1, 1)
c1.BorderSizePixel = 0
Instance.new("UICorner", c1).CornerRadius = UDim.new(0, 7)

-- Тоггл 2
local tf2 = Instance.new("Frame", main)
tf2.Size = UDim2.new(1, -20, 0, 35)
tf2.Position = UDim2.new(0, 10, 0, 85)
tf2.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
tf2.BorderSizePixel = 0
Instance.new("UICorner", tf2).CornerRadius = UDim.new(0, 5)

local l2 = Instance.new("TextLabel", tf2)
l2.Size = UDim2.new(0.5, 0, 1, 0)
l2.Position = UDim2.new(0, 8, 0, 0)
l2.BackgroundTransparency = 1
l2.Text = "Авто-предметы"
l2.TextColor3 = Color3.new(1, 1, 1)
l2.Font = Enum.Font.GothamMedium
l2.TextSize = 12
l2.TextXAlignment = Enum.TextXAlignment.Left

local b2 = Instance.new("TextButton", tf2)
b2.Size = UDim2.new(0, 40, 0, 20)
b2.Position = UDim2.new(1, -48, 0.5, -10)
b2.BackgroundColor3 = Color3.fromRGB(200, 70, 70)
b2.Text = ""
b2.BorderSizePixel = 0
Instance.new("UICorner", b2).CornerRadius = UDim.new(0, 10)

local c2 = Instance.new("Frame", b2)
c2.Size = UDim2.new(0, 14, 0, 14)
c2.Position = UDim2.new(0, 3, 0.5, -7)
c2.BackgroundColor3 = Color3.new(1, 1, 1)
c2.BorderSizePixel = 0
Instance.new("UICorner", c2).CornerRadius = UDim.new(0, 7)

-- Статус
local status = Instance.new("TextLabel", main)
status.Size = UDim2.new(1, -20, 0, 20)
status.Position = UDim2.new(0, 10, 0, 130)
status.BackgroundTransparency = 1
status.Text = "Готов"
status.TextColor3 = Color3.fromRGB(150, 150, 150)
status.Font = Enum.Font.GothamMedium
status.TextSize = 10
status.TextXAlignment = Enum.TextXAlignment.Left

-- Кнопка стоп
local stop = Instance.new("TextButton", main)
stop.Size = UDim2.new(1, -20, 0, 25)
stop.Position = UDim2.new(0, 10, 0, 150)
stop.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
stop.Text = "СТОП"
stop.TextColor3 = Color3.new(1, 1, 1)
stop.Font = Enum.Font.GothamBold
stop.TextSize = 12
stop.BorderSizePixel = 0
Instance.new("UICorner", stop).CornerRadius = UDim.new(0, 4)

-- Логика
local f1 = false
local f2 = false

b1.MouseButton1Click:Connect(function()
    f1 = not f1
    AutoFarm = f1
    if f1 then
        b1.BackgroundColor3 = Color3.fromRGB(80, 200, 120)
        c1.Position = UDim2.new(1, -17, 0.5, -7)
        status.Text = "Штанга ON"
        task.spawn(farmLoop)
    else
        b1.BackgroundColor3 = Color3.fromRGB(200, 70, 70)
        c1.Position = UDim2.new(0, 3, 0.5, -7)
        status.Text = "Штанга OFF"
        unfreeze()
    end
end)

b2.MouseButton1Click:Connect(function()
    f2 = not f2
    AutoLift = f2
    if f2 then
        b2.BackgroundColor3 = Color3.fromRGB(80, 200, 120)
        c2.Position = UDim2.new(1, -17, 0.5, -7)
        status.Text = "Предметы ON"
        task.spawn(liftLoop)
    else
        b2.BackgroundColor3 = Color3.fromRGB(200, 70, 70)
        c2.Position = UDim2.new(0, 3, 0.5, -7)
        status.Text = "Предметы OFF"
    end
end)

stop.MouseButton1Click:Connect(function()
    f1 = false; f2 = false
    AutoFarm = false; AutoLift = false
    unfreeze()
    b1.BackgroundColor3 = Color3.fromRGB(200, 70, 70)
    c1.Position = UDim2.new(0, 3, 0.5, -7)
    b2.BackgroundColor3 = Color3.fromRGB(200, 70, 70)
    c2.Position = UDim2.new(0, 3, 0.5, -7)
    status.Text = "Всё стоп"
end)

print("TWEAK v10 LOADED - OK")
