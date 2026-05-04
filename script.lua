--[[
    STRONGEST SIMULATOR - v11 FINAL
    Штанга: как раньше
    Предметы: стоит возле предметов -> клик Взять -> ТЕЛЕПОРТ ПРЕДМЕТА К ФИНИШУ (чел остаётся на месте)
    Либо: чел стоит 0.9с у предметов, каждые 0.3с клик Взять + ТП на финиш + ТП обратно
--]]

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

-- Телепорт
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

-- Телепорт предмета который в руках (чел остается на месте)
local function tpToolToFinish()
    if not char then return end
    -- Ищем Tool в персонаже
    for _, obj in pairs(char:GetChildren()) do
        if obj:IsA("Tool") then
            -- Телепортируем Handle предмета на финиш
            local handle = obj:FindFirstChild("Handle")
            if handle then
                handle.CFrame = CFrame.new(FinishPos)
            end
        end
    end
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

-- Цикл предметов (НОВЫЙ: персонаж стоит у предметов, предмет телепортируется на финиш)
function liftLoop()
    -- Телепорт к предметам ОДИН РАЗ
    tp(ItemPos)
    
    while AutoLift and char and hrp do
        -- Клик "Взять"
        click()
        task.wait(0.1)
        
        -- Телепорт ПРЕДМЕТА на финиш (персонаж остается на месте)
        tpToolToFinish()
        task.wait(0.1)
        
        -- Клик "Сдать" (если нужно)
        click()
        
        -- Ждем 0.3 сек до следующего цикла
        task.wait(0.3)
    end
end

-- Альтернативный цикл: чел стоит 0.9с, телепорт туда-сюда
function liftLoopV2()
    while AutoLift and char and hrp do
        -- Стоим у предметов 0.9 сек и кликаем каждые 0.3
        tp(ItemPos)
        
        for i = 1, 3 do  -- 3 клика за 0.9 сек (каждые 0.3)
            if not AutoLift then break end
            click()
            task.wait(0.3)
        end
        
        -- Телепорт на финиш
        tp(FinishPos)
        click()
        task.wait(0.2)
        
        -- Обратно к предметам
        tp(ItemPos)
        task.wait(0.1)
    end
end

-- GUI
local gui = Instance.new("ScreenGui", game:GetService("CoreGui"))
gui.Name = "TWEAK"

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 300, 0, 200)
main.Position = UDim2.new(0.5, -150, 0.5, -100)
main.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
main.BorderSizePixel = 0
main.Draggable = true
main.Active = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(140, 100, 255)
title.Text = "TWEAK v11"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.BorderSizePixel = 0
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

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

local status = Instance.new("TextLabel", main)
status.Size = UDim2.new(1, -20, 0, 20)
status.Position = UDim2.new(0, 10, 0, 130)
status.BackgroundTransparency = 1
status.Text = "Готов"
status.TextColor3 = Color3.fromRGB(150, 150, 150)
status.Font = Enum.Font.GothamMedium
status.TextSize = 10
status.TextXAlignment = Enum.TextXAlignment.Left

local modeBtn = Instance.new("TextButton", main)
modeBtn.Size = UDim2.new(1, -20, 0, 25)
modeBtn.Position = UDim2.new(0, 10, 0, 152)
modeBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 140)
modeBtn.Text = "Режим: Телепорт предмета"
modeBtn.TextColor3 = Color3.new(1, 1, 1)
modeBtn.Font = Enum.Font.GothamMedium
modeBtn.TextSize = 10
modeBtn.BorderSizePixel = 0
Instance.new("UICorner", modeBtn).CornerRadius = UDim.new(0, 4)

local stop = Instance.new("TextButton", main)
stop.Size = UDim2.new(1, -20, 0, 25)
stop.Position = UDim2.new(0, 10, 0, 180)
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
local mode = 1  -- 1 = телепорт предмета, 2 = телепорт туда-сюда

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
        if mode == 1 then
            task.spawn(liftLoop)
        else
            task.spawn(liftLoopV2)
        end
    else
        b2.BackgroundColor3 = Color3.fromRGB(200, 70, 70)
        c2.Position = UDim2.new(0, 3, 0.5, -7)
        status.Text = "Предметы OFF"
    end
end)

modeBtn.MouseButton1Click:Connect(function()
    if mode == 1 then
        mode = 2
        modeBtn.Text = "Режим: ТП туда-сюда (0.9с)"
        if AutoLift then
            AutoLift = false
            task.wait(0.1)
            AutoLift = true
            task.spawn(liftLoopV2)
        end
    else
        mode = 1
        modeBtn.Text = "Режим: Телепорт предмета"
        if AutoLift then
            AutoLift = false
            task.wait(0.1)
            AutoLift = true
            task.spawn(liftLoop)
        end
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

print("TWEAK v11 LOADED")
print("Режим 1: Перс стоит у предметов -> предмет ТП на финиш")
print("Режим 2: Перс 0.9с у предметов -> ТП на финиш -> обратно")
