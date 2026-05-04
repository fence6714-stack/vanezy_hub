--[[
    STRONGEST SIMULATOR - v14
    Предметы: ТП к предметам → 3 клика за 0.9с → ТП на новый финиш → стоит 0.3с → повтор
    Финиш: 2205.485, 66.495, 6968.355
--]]

repeat task.wait(0.1) until game:IsLoaded()
local plr = game:GetService("Players").LocalPlayer
repeat task.wait(0.1) until plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")

local char = plr.Character
local hrp = char.HumanoidRootPart
local hum = char.Humanoid

local TrainingPos = Vector3.new(2284.36, 49.147, 5903.271)
local ItemPos = Vector3.new(2554.064, 13.71, 5502.688)
local FinishPos = Vector3.new(2205.485, 66.495, 6968.355)  -- НОВЫЙ ФИНИШ

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

-- Клик по кнопке (ищем кнопку "Взять"/"Grab"/"Lift")
local function clickGrab()
    -- Ищем кнопку в GUI
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("TextButton") then
            local name = obj.Name:lower()
            local text = obj.Text:lower()
            if name:find("grab") or name:find("lift") or name:find("взять") or name:find("поднять") or
               text:find("grab") or text:find("lift") or text:find("взять") or text:find("поднять") then
                -- Клик по координатам кнопки
                local x = obj.AbsolutePosition.X + obj.AbsoluteSize.X / 2
                local y = obj.AbsolutePosition.Y + obj.AbsoluteSize.Y / 2
                game:GetService("VirtualInputManager"):SendMouseButtonEvent(x, y, 0, true, game, 1)
                game:GetService("VirtualInputManager"):SendMouseButtonEvent(x, y, 0, false, game, 1)
                return
            end
        end
    end
    -- Если кнопка не найдена - клик в центр экрана
    game:GetService("VirtualInputManager"):SendMouseButtonEvent(0, 0, 0, true, game, 1)
    game:GetService("VirtualInputManager"):SendMouseButtonEvent(0, 0, 0, false, game, 1)
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
        -- 1. Телепорт к предметам
        tp(ItemPos)
        
        -- 2. Стоим 0.9 сек, кликаем кнопку Взять каждые 0.3 сек
        clickGrab()
        task.wait(0.3)
        clickGrab()
        task.wait(0.3)
        clickGrab()
        task.wait(0.3)
        
        -- 3. Телепорт на финиш
        tp(FinishPos)
        
        -- 4. Стоим на финише 0.3 сек
        click()  -- клик "сдать"
        task.wait(0.3)
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
title.Text = "TWEAK v14"
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

print("v14 loaded")
print("Финиш: 2205.485, 66.495, 6968.355")
print("Предметы: 3 клика по кнопке Grab за 0.9с -> ТП финиш 0.3с -> повтор")
