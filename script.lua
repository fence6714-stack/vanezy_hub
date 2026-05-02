--[[
    TWKS FARMCORE v5.0 COMPLETE
    Функции: AutoQuest, GroupMobbing, TargetedDamage, Flight, AntiBan
    Управление: МИНИ-МЕНЮ с плавной анимацией (сворачивание/удаление)
    Включение/отключение функций через кнопки в меню
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- === ТОГЛЫ ФУНКЦИЙ (управляются из меню) ===
local Toggles = {
    Farming = true,      -- Основной фарм-цикл
    AutoQuest = true,    -- Автовыполнение квестов
    GroupMobs = true,    -- Сбор мобов в кучу
    FlightEnabled = true,-- Полёт
    AntiBan = true       -- Анти-бан защита
}

-- === 1. Anti-Ban / Anti-Cheat Bypass ===
local AntiBan = {
    LastAction = tick(),
    Delays = {0.3, 0.7, 0.5, 0.9, 1.2},
    Movements = {Vector3.new(1,0,0), Vector3.new(-1,0,0), Vector3.new(0,0,1), Vector3.new(0,0,-1)}
}

local function RandomWait()
    if not Toggles.AntiBan then return end
    local rand = AntiBan.Delays[math.random(1, #AntiBan.Delays)]
    task.wait(rand + (math.random(-20, 20) / 100))
end

local function SimulateInput()
    if not Toggles.AntiBan then return end
    if tick() - AntiBan.LastAction > 8 then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton1(Vector2.new(math.random(100, 500), math.random(100, 500)))
        end)
        AntiBan.LastAction = tick()
    end
end

-- === 2. Система полёта ===
local Flight = {
    Active = false,
    BodyVel = nil,
    BodyGyro = nil,
    Speed = 85.0
}

local function StartFlight()
    if not Toggles.FlightEnabled then 
        if Flight.Active then
            if Flight.BodyVel then Flight.BodyVel:Destroy() end
            if Flight.BodyGyro then Flight.BodyGyro:Destroy() end
            Flight.Active = false
            Humanoid.PlatformStand = false
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
        end
        return 
    end
    
    if Flight.Active then return end
    Flight.Active = true
    
    pcall(function()
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        Humanoid.PlatformStand = true
        
        Flight.BodyVel = Instance.new("BodyVelocity")
        Flight.BodyVel.Velocity = Vector3.new(0,0,0)
        Flight.BodyVel.MaxForce = Vector3.new(1e6, 1e6, 1e6)
        Flight.BodyVel.Parent = RootPart
        
        Flight.BodyGyro = Instance.new("BodyGyro")
        Flight.BodyGyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
        Flight.BodyGyro.CFrame = RootPart.CFrame
        Flight.BodyGyro.Parent = RootPart
    end)
end

-- Управление полётом с клавиш
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if not Toggles.FlightEnabled or not Flight.Active then return end
    
    if input.KeyCode == Enum.KeyCode.Space then
        Flight.BodyVel.Velocity = Vector3.new(0, Flight.Speed, 0)
    elseif input.KeyCode == Enum.KeyCode.LeftControl then
        Flight.BodyVel.Velocity = Vector3.new(0, -Flight.Speed, 0)
    elseif input.KeyCode == Enum.KeyCode.W then
        Flight.BodyVel.Velocity = RootPart.CFrame.LookVector * Flight.Speed
    elseif input.KeyCode == Enum.KeyCode.S then
        Flight.BodyVel.Velocity = -RootPart.CFrame.LookVector * Flight.Speed
    elseif input.KeyCode == Enum.KeyCode.A then
        Flight.BodyVel.Velocity = -RootPart.CFrame.RightVector * Flight.Speed
    elseif input.KeyCode == Enum.KeyCode.D then
        Flight.BodyVel.Velocity = RootPart.CFrame.RightVector * Flight.Speed
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if not Toggles.FlightEnabled or not Flight.Active then return end
    if input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.LeftControl or
       input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.S or
       input.KeyCode == Enum.KeyCode.A or input.KeyCode == Enum.KeyCode.D then
        Flight.BodyVel.Velocity = Vector3.new(0,0,0)
    end
end)

-- === 3. Поиск мобов и сбор в кучу ===
local function GetAllMobs(radius)
    local center = RootPart.Position
    local region = Region3.new(
        center - Vector3.new(radius, radius, radius),
        center + Vector3.new(radius, radius, radius)
    )
    local parts = workspace:FindPartsInRegion3(region, Character, 100)
    local mobs = {}
    
    for _, part in pairs(parts) do
        local mobChar = part.Parent
        if mobChar and mobChar:FindFirstChild("Humanoid") and mobChar.Name ~= LocalPlayer.Name then
            if mobChar.Humanoid.Health > 0 and not table.find(mobs, mobChar) then
                table.insert(mobs, mobChar)
            end
        end
    end
    return mobs
end

local function GroupMobs(mobs)
    if not Toggles.GroupMobs then return end
    local centerPoint = RootPart.Position
    for _, mob in pairs(mobs) do
        local mobRoot = mob:FindFirstChild("HumanoidRootPart")
        if mobRoot then
            pcall(function()
                local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Linear)
                local tween = TweenService:Create(mobRoot, tweenInfo, {
                    CFrame = CFrame.new(centerPoint + Vector3.new(math.random(-3,3), 0, math.random(-3,3)))
                })
                tween:Play()
                mob.Humanoid:MoveTo(centerPoint)
            end)
        end
    end
end

-- === 4. Нанесение урона предметом ===
local DamageItem = {
    Name = "Dark Blade",
    Damage = 750.0,
    Range = 35.0
}

local function EquipItem()
    local backpack = LocalPlayer.Backpack
    for _, tool in pairs(backpack:GetChildren()) do
        if tool.Name == DamageItem.Name then
            tool.Parent = Character
            RandomWait()
            break
        end
    end
end

local function AttackMob(mob)
    local tool = Character:FindFirstChild(DamageItem.Name)
    if not tool then 
        EquipItem()
        tool = Character:FindFirstChild(DamageItem.Name)
    end
    
    if tool then
        pcall(function()
            if tool:FindFirstChild("RemoteEvent") then
                tool.RemoteEvent:FireServer(mob, DamageItem.Damage)
            elseif tool:FindFirstChild("Activate") then
                tool.Activate:InvokeServer(mob)
            else
                local ray = Ray.new(tool.Handle.Position, (mob.HumanoidRootPart.Position - tool.Handle.Position).Unit * DamageItem.Range)
                local hit = workspace:FindPartOnRay(ray, Character)
                if hit and hit.Parent == mob then
                    mob.Humanoid.Health = mob.Humanoid.Health - DamageItem.Damage
                end
            end
        end)
    end
end

-- === 5. Автовыполнение квестов ===
local function AutoCompleteQuest()
    if not Toggles.AutoQuest then return end
    for _, remote in pairs(game:GetDescendants()) do
        if remote:IsA("RemoteEvent") then
            local name = remote.Name:lower()
            if name:find("quest") or name:find("complete") or name:find("claim") then
                pcall(function() remote:FireServer() end)
                RandomWait()
            end
        elseif remote:IsA("RemoteFunction") then
            local name = remote.Name:lower()
            if name:find("quest") or name:find("complete") or name:find("claim") then
                pcall(function() remote:InvokeServer() end)
                RandomWait()
            end
        end
    end
end

-- === 6. Основной цикл фарма ===
local FarmLoopRunning = false

local function FarmLoop()
    FarmLoopRunning = true
    while FarmLoopRunning do
        if not Toggles.Farming then
            task.wait(1)
            continue
        end
        
        SimulateInput()
        
        if Toggles.FlightEnabled and not Flight.Active then
            StartFlight()
        elseif not Toggles.FlightEnabled and Flight.Active then
            StartFlight() -- Это выключит полёт (функция проверяет Toggles)
        end
        
        local mobs = GetAllMobs(300)
        if #mobs > 0 then
            GroupMobs(mobs)
            RandomWait()
            
            for _, mob in pairs(mobs) do
                if mob and mob.Humanoid and mob.Humanoid.Health > 0 then
                    AttackMob(mob)
                    RandomWait()
                end
            end
        else
            local randomMove = Vector3.new(math.random(-50, 50), 0, math.random(-50, 50))
            RootPart.CFrame = RootPart.CFrame + randomMove
        end
        
        if tick() % 30 < 0.5 then
            AutoCompleteQuest()
        end
        
        RandomWait()
        RunService.Heartbeat:Wait()
    end
end

-- === 7. МИНИ-МЕНЮ (плавное, сворачиваемое, удаляемое) ===
local Menu = {
    ScreenGui = nil,
    MainFrame = nil,
    Collapsed = false,
    OriginalHeight = 320,
    CollapsedHeight = 30,
    TweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
}

local function CreateMenu()
    Menu.ScreenGui = Instance.new("ScreenGui")
    Menu.ScreenGui.Name = "TWKS_FarmMenu"
    Menu.ScreenGui.IgnoreGuiInset = true
    Menu.ScreenGui.ResetOnSpawn = false
    Menu.ScreenGui.Parent = game:GetService("CoreGui")
    
    Menu.MainFrame = Instance.new("Frame")
    Menu.MainFrame.Size = UDim2.new(0, 280, 0, Menu.OriginalHeight)
    Menu.MainFrame.Position = UDim2.new(0, 20, 0, 50)
    Menu.MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    Menu.MainFrame.BackgroundTransparency = 0.05
    Menu.MainFrame.BorderSizePixel = 1
    Menu.MainFrame.BorderColor3 = Color3.fromRGB(0, 150, 255)
    Menu.MainFrame.ClipsDescendants = true
    Menu.MainFrame.Parent = Menu.ScreenGui
    
    -- Заголовок
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 30)
    TitleBar.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    TitleBar.BackgroundTransparency = 0.2
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = Menu.MainFrame
    
    local TitleText = Instance.new("TextLabel")
    TitleText.Size = UDim2.new(1, -70, 1, 0)
    TitleText.Position = UDim2.new(0, 10, 0, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.Text = "TWKS FARMCORE v5.0"
    TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleText.TextSize = 13
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.Font = Enum.Font.GothamBold
    TitleText.Parent = TitleBar
    
    -- Кнопка свернуть
    local CollapseBtn = Instance.new("TextButton")
    CollapseBtn.Size = UDim2.new(0, 30, 1, 0)
    CollapseBtn.Position = UDim2.new(1, -65, 0, 0)
    CollapseBtn.BackgroundTransparency = 1
    CollapseBtn.Text = "▼"
    CollapseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CollapseBtn.TextSize = 16
    CollapseBtn.Font = Enum.Font.GothamBold
    CollapseBtn.Parent = TitleBar
    
    -- Кнопка закрыть (полное удаление)
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 1, 0)
    CloseBtn.Position = UDim2.new(1, -35, 0, 0)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
    CloseBtn.TextSize = 16
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Parent = TitleBar
    
    -- Контейнер для кнопок функций
    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, 0, 1, -30)
    Content.Position = UDim2.new(0, 0, 0, 30)
    Content.BackgroundTransparency = 1
    Content.Parent = Menu.MainFrame
    
    -- Функция создания кнопки-переключателя
    local function CreateToggleButton(name, yPos, toggleKey)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 240, 0, 35)
        btn.Position = UDim2.new(0, 20, 0, yPos)
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        btn.BackgroundTransparency = 0.3
        btn.Text = "✅ " .. name
        btn.TextColor3 = Color3.fromRGB(0, 255, 0)
        btn.TextSize = 13
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Font = Enum.Font.Gotham
        btn.Parent = Content
        
        local state = Toggles[toggleKey]
        if state then
            btn.Text = "✅ " .. name
            btn.TextColor3 = Color3.fromRGB(0, 255, 0)
        else
            btn.Text = "❌ " .. name
            btn.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
        
        btn.MouseButton1Click:Connect(function()
            Toggles[toggleKey] = not Toggles[toggleKey]
            if Toggles[toggleKey] then
                btn.Text = "✅ " .. name
                btn.TextColor3 = Color3.fromRGB(0, 255, 0)
            else
                btn.Text = "❌ " .. name
                btn.TextColor3 = Color3.fromRGB(255, 100, 100)
            end
            
            -- Мгновенное применение для некоторых функций
            if toggleKey == "FlightEnabled" then
                if Toggles.FlightEnabled then
                    StartFlight()
                elseif Flight.Active then
                    StartFlight() -- вызовет отключение
                end
            end
        end)
        
        return btn
    end
    
    -- Создаём кнопки
    CreateToggleButton("ФАРМ (основной цикл)", 15, "Farming")
    CreateToggleButton("АВТОКВЕСТЫ", 60, "AutoQuest")
    CreateToggleButton("СБОР МОБОВ В КУЧУ", 105, "GroupMobs")
    CreateToggleButton("ПОЛЁТ (WASD+Space/Ctrl)", 150, "FlightEnabled")
    CreateToggleButton("ЗАЩИТА ОТ АНТИЧИТА", 195, "AntiBan")
    
    -- Текст статуса
    local StatusText = Instance.new("TextLabel")
    StatusText.Size = UDim2.new(0, 260, 0, 20)
    StatusText.Position = UDim2.new(0, 10, 0, 250)
    StatusText.BackgroundTransparency = 1
    StatusText.Text = "Статус: АКТИВЕН"
    StatusText.TextColor3 = Color3.fromRGB(100, 255, 100)
    StatusText.TextSize = 11
    StatusText.Font = Enum.Font.Gotham
    StatusText.TextXAlignment = Enum.TextXAlignment.Center
    StatusText.Parent = Content
    
    -- Обновление статуса в реальном времени
    task.spawn(function()
        while Menu.ScreenGui and Menu.ScreenGui.Parent do
            if Toggles.Farming then
                StatusText.Text = "Статус: ФАРМ АКТИВЕН ✅"
                StatusText.TextColor3 = Color3.fromRGB(100, 255, 100)
            else
                StatusText.Text = "Статус: ОСТАНОВЛЕН ❌"
                StatusText.TextColor3 = Color3.fromRGB(255, 100, 100)
            end
            task.wait(0.5)
        end
    end)
    
    -- Анимация сворачивания/разворачивания
    local function ToggleCollapse()
        Menu.Collapsed = not Menu.Collapsed
        local targetHeight = Menu.Collapsed and Menu.CollapsedHeight or Menu.OriginalHeight
        CollapseBtn.Text = Menu.Collapsed and "▶" or "▼"
        
        local tween = TweenService:Create(Menu.MainFrame, Menu.TweenInfo, {Size = UDim2.new(0, 280, 0, targetHeight)})
        tween:Play()
    end
    
    CollapseBtn.MouseButton1Click:Connect(ToggleCollapse)
    
    -- Полное удаление меню
    CloseBtn.MouseButton1Click:Connect(function()
        local fadeOut = TweenService:Create(Menu.MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {BackgroundTransparency = 1})
        fadeOut:Play()
        fadeOut.Completed:Connect(function()
            if Menu.ScreenGui then Menu.ScreenGui:Destroy() end
            Menu.MainFrame = nil
            Menu.ScreenGui = nil
        end)
    end)
    
    -- Перетаскивание окна
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Menu.MainFrame.Position
        end
    end)
    
    TitleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Menu.MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- === ЗАПУСК ВСЕГО ===
local function Initialize()
    -- Отключаем телеметрию
    pcall(function()
        setfflag("AbuseReportScreenshot", "False")
        setfflag("DebugPrintRemoteEvents", "False")
        setfflag("UserSecurityTelemetry", "False")
    end)
    
    CreateMenu()
    
    LocalPlayer.CharacterAdded:Connect(function(newChar)
        Character = newChar
        RootPart = Character:WaitForChild("HumanoidRootPart")
        Humanoid = Character:WaitForChild("Humanoid")
        task.wait(0.5)
        if Toggles.FlightEnabled then StartFlight() end
    end)
    
    if Character then
        if Toggles.FlightEnabled then StartFlight() end
    end
    
    task.spawn(FarmLoop)
end

Initialize()
