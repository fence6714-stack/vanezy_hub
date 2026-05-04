--[[
    STRONGEST SIMULATOR - v12 DEAD SIMPLE
    Абсолютно чистый код, ничего лишнего
--]]

repeat task.wait(0.1) until game:IsLoaded()
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

local function tp(pos)
    if hrp then hrp.CFrame = CFrame.new(pos) end
end

local function freeze()
    if frozen then frozen:Disconnect() end
    local pos = hrp.Position
    frozen = game:GetService("RunService").RenderStepped:Connect(function()
        if hrp then hrp.CFrame = CFrame.new(pos); hrp.Velocity = Vector3.zero end
        if hum then hum.PlatformStand = true end
    end)
end

local function unfreeze()
    if frozen then frozen:Disconnect(); frozen = nil end
    if hum then hum.PlatformStand = false end
end

local function click()
    game:GetService("VirtualInputManager"):SendMouseButtonEvent(0, 0, 0, true, game, 1)
    game:GetService("VirtualInputManager"):SendMouseButtonEvent(0, 0, 0, false, game, 1)
end

local function hold(t)
    game:GetService("VirtualInputManager"):SendMouseButtonEvent(0, 0, 0, true, game, 1)
    task.wait(t)
    game:GetService("VirtualInputManager"):SendMouseButtonEvent(0, 0, 0, false, game, 1)
end

function farmLoop()
    tp(TrainingPos)
    freeze()
    task.wait(0.5)
    hold(1.0)
    while AutoFarm do
        click()
        task.wait(0.7)
    end
    unfreeze()
end

function liftLoop()
    while AutoLift do
        tp(ItemPos)
        click()
        task.wait(0.05)
        tp(FinishPos)
        click()
        task.wait(0.5)
    end
end

--[[ GUI ]]--
local gui = Instance.new("ScreenGui")
gui.Parent = game:GetService("CoreGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 260, 0, 160)
main.Position = UDim2.new(0.5, -130, 0.5, -80)
main.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
main.BorderSizePixel = 0
main.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 28)
title.BackgroundColor3 = Color3.fromRGB(140, 100, 255)
title.Text = "TWEAK v12"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.BorderSizePixel = 0
title.Parent = main

local b1 = Instance.new("TextButton")
b1.Size = UDim2.new(1, -20, 0, 32)
b1.Position = UDim2.new(0, 10, 0, 35)
b1.BackgroundColor3 = Color3.fromRGB(200, 70, 70)
b1.Text = "Авто-штанга: OFF"
b1.TextColor3 = Color3.new(1, 1, 1)
b1.Font = Enum.Font.GothamBold
b1.TextSize = 12
b1.BorderSizePixel = 0
b1.Parent = main

local b2 = Instance.new("TextButton")
b2.Size = UDim2.new(1, -20, 0, 32)
b2.Position = UDim2.new(0, 10, 0, 72)
b2.BackgroundColor3 = Color3.fromRGB(200, 70, 70)
b2.Text = "Авто-предметы: OFF"
b2.TextColor3 = Color3.new(1, 1, 1)
b2.Font = Enum.Font.GothamBold
b2.TextSize = 12
b2.BorderSizePixel = 0
b2.Parent = main

local stop = Instance.new("TextButton")
stop.Size = UDim2.new(1, -20, 0, 30)
stop.Position = UDim2.new(0, 10, 0, 115)
stop.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
stop.Text = "СТОП"
stop.TextColor3 = Color3.new(1, 1, 1)
stop.Font = Enum.Font.GothamBold
stop.TextSize = 13
stop.BorderSizePixel = 0
stop.Parent = main

local f1 = false
local f2 = false

b1.MouseButton1Click:Connect(function()
    f1 = not f1
    AutoFarm = f1
    if f1 then
        b1.BackgroundColor3 = Color3.fromRGB(80, 200, 120)
        b1.Text = "Авто-штанга: ON"
        task.spawn(farmLoop)
    else
        b1.BackgroundColor3 = Color3.fromRGB(200, 70, 70)
        b1.Text = "Авто-штанга: OFF"
        unfreeze()
    end
end)

b2.MouseButton1Click:Connect(function()
    f2 = not f2
    AutoLift = f2
    if f2 then
        b2.BackgroundColor3 = Color3.fromRGB(80, 200, 120)
        b2.Text = "Авто-предметы: ON"
        task.spawn(liftLoop)
    else
        b2.BackgroundColor3 = Color3.fromRGB(200, 70, 70)
        b2.Text = "Авто-предметы: OFF"
    end
end)

stop.MouseButton1Click:Connect(function()
    f1 = false; f2 = false
    AutoFarm = false; AutoLift = false
    unfreeze()
    b1.BackgroundColor3 = Color3.fromRGB(200, 70, 70)
    b1.Text = "Авто-штанга: OFF"
    b2.BackgroundColor3 = Color3.fromRGB(200, 70, 70)
    b2.Text = "Авто-предметы: OFF"
end)

print("v12 loaded")
