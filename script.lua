--[[
  VANEZY UNIVERSAL MOBILE SCRIPT - FULL RELEASE
  Версия: 2.0 COMPLETE
  Все функции: Fly (джойстик + скорость + отдельные кнопки вверх/вниз)
  ESP (игроки/сундуки/мобы/размер/ХП/расстояние)
  Noclip (стены/пол/потолок отдельно)
  Speed (ходьба слайдер + спидхак слайдер + автономный)
  Jump (сила прыжка слайдер + бесконечные прыжки)
  FOV слайдер, Автобег слайдер + тоггл
  Радужный цвет + скорость радуги слайдер
  Меню: перемещение пальцем, сворачивание, закрытие
  Загрузочный экран "Script loading... by Vanezy" 2 сек
  Адаптация под телефон (джойстик, тач-слайдеры)
--]]

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer

-- Переменные состояния
local flyEnabled = false
local flySpeed = 50
local flyBodyVel = nil
local flyBodyGyro = nil
local flyControl = {Forward = 0, Right = 0, Up = 0}
local flyConnection = nil

local noclipEnabled = false
local noclipWalls = false
local noclipFloor = false
local noclipCeiling = false
local noclipConnection = nil

local espEnabled = false
local espChest = false
local espMobs = false
local espSize = 1
local espShowHP = false
local espShowDist = false
local espObjects = {}
local espConnection = nil

local speedHack = false
local speedHackValue = 16
local walkSpeedValue = 16
local jumpPowerValue = 50
local infiniteJump = false
local fovValue = 70
local autoRun = false
local autoRunSpeed = 16

local rainbowEnabled = false
local rainbowHue = 0
local rainbowSpeed = 1
local currentSolidColor = Color3.fromRGB(255,255,255)

local guiVisible = true
local guiMinimized = false

-- Цвета для кнопки
local colorOptions = {
    {name = "Красный", color = Color3.fromRGB(255,0,0)},
    {name = "Зелёный", color = Color3.fromRGB(0,255,0)},
    {name = "Синий", color = Color3.fromRGB(0,0,255)},
    {name = "Жёлтый", color = Color3.fromRGB(255,255,0)},
    {name = "Фиолетовый", color = Color3.fromRGB(255,0,255)},
    {name = "Оранжевый", color = Color3.fromRGB(255,165,0)},
    {name = "Белый", color = Color3.fromRGB(255,255,255)},
    {name = "Радужный", color = "rainbow"}
}
local currentColorIndex = 8

-- UI элементы
local screenGui = Instance.new("ScreenGui")
local mainFrame = Instance.new("Frame")
local topBar = Instance.new("Frame")
local titleText = Instance.new("TextLabel")
local authorText = Instance.new("TextLabel")
local iconStar = Instance.new("TextLabel")
local closeButton = Instance.new("TextButton")
local minimizeButton = Instance.new("TextButton")
local colorButton = Instance.new("TextButton")
local rainbowSpeedFrame = Instance.new("Frame")
local rainbowSliderFill = Instance.new("Frame")
local rainbowKnob = Instance.new("Frame")
local draggingRainbow = false

local tabBar = Instance.new("Frame")
local homeTab = Instance.new("Frame")
local flyTab = Instance.new("Frame")
local espTab = Instance.new("Frame")
local noclipTab = Instance.new("Frame")
local movementTab = Instance.new("Frame")
local activeTab = homeTab

local loadingFrame = Instance.new("Frame")
local loadingLabel = Instance.new("TextLabel")
local loadingAuthor = Instance.new("TextLabel")

-- Функция загрузочного экрана
local function showLoading()
    loadingFrame.Size = UDim2.new(0.5, 0, 0.15, 0)
    loadingFrame.Position = UDim2.new(0.25, 0, 0.425, 0)
    loadingFrame.BackgroundColor3 = Color3.fromRGB(20,20,20)
    loadingFrame.BackgroundTransparency = 1
    loadingFrame.BorderSizePixel = 0
    loadingFrame.Parent = screenGui
    
    loadingLabel.Size = UDim2.new(1,0,0.6,0)
    loadingLabel.Position = UDim2.new(0,0,0.2,0)
    loadingLabel.BackgroundTransparency = 1
    loadingLabel.Text = "SCRIPT LOADING..."
    loadingLabel.TextColor3 = Color3.fromRGB(255,255,255)
    loadingLabel.TextSize = 24
    loadingLabel.Font = Enum.Font.GothamBold
    loadingLabel.TextScaled = true
    loadingLabel.Parent = loadingFrame
    
    loadingAuthor.Size = UDim2.new(1,0,0.3,0)
    loadingAuthor.Position = UDim2.new(0,0,0.7,0)
    loadingAuthor.BackgroundTransparency = 1
    loadingAuthor.Text = "by Vanezy"
    loadingAuthor.TextColor3 = Color3.fromRGB(150,150,150)
    loadingAuthor.TextSize = 14
    loadingAuthor.Font = Enum.Font.Gotham
    loadingAuthor.TextScaled = true
    loadingAuthor.Parent = loadingFrame
    
    local tweenIn = TweenService:Create(loadingFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {BackgroundTransparency = 0.2})
    tweenIn:Play()
    wait(2)
    local tweenOut = TweenService:Create(loadingFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundTransparency = 1})
    tweenOut:Play()
    tweenOut.Completed:Wait()
    loadingFrame:Destroy()
end

-- Обновление радужного цвета
local function updateRainbow()
    if not rainbowEnabled then return end
    rainbowHue = (rainbowHue + 0.0167 * rainbowSpeed) % 1
    local color = Color3.fromHSV(rainbowHue, 1, 1)
    mainFrame.BackgroundColor3 = color
    topBar.BackgroundColor3 = color
end

-- Создание переключателя (красный/зелёный)
local function createToggle(text, defaultValue, parent, yPos, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.9, 0, 0, 40)
    frame.Position = UDim2.new(0.05, 0, yPos, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255,255,255)
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 50, 0, 30)
    btn.Position = UDim2.new(0.85, -25, 0.5, -15)
    btn.BackgroundColor3 = defaultValue and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
    btn.Text = defaultValue and "Вкл" or "Выкл"
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.Parent = frame
    
    local state = defaultValue
    local event = Instance.new("BindableEvent")
    
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
        btn.Text = state and "Вкл" or "Выкл"
        event:Fire(state)
        if callback then callback(state) end
    end)
    
    return {OnToggle = event.Event, Set = function(v) state = v; btn.BackgroundColor3 = v and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0); btn.Text = v and "Вкл" or "Выкл"; event:Fire(v); if callback then callback(v) end end}
end

-- Создание слайдера (ползунок)
local function createSlider(text, minVal, maxVal, defaultVal, parent, yPos, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.9, 0, 0, 50)
    frame.Position = UDim2.new(0.05, 0, yPos, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 0.4, 0)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. tostring(defaultVal)
    label.TextColor3 = Color3.fromRGB(255,255,255)
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(0.8, 0, 0, 4)
    sliderBg.Position = UDim2.new(0, 0, 0.7, 0)
    sliderBg.BackgroundColor3 = Color3.fromRGB(80,80,80)
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = frame
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0,255,0)
    fill.BorderSizePixel = 0
    fill.Parent = sliderBg
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.Position = UDim2.new((defaultVal - minVal) / (maxVal - minVal), -6, 0.5, -6)
    knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
    knob.BorderSizePixel = 0
    knob.Parent = sliderBg
    
    local dragging = false
    
    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    local function updateFromPosition(touchPos)
        local relX = math.clamp((touchPos.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        local val = minVal + relX * (maxVal - minVal)
        val = math.floor(val * 10) / 10
        label.Text = text .. ": " .. tostring(val)
        fill.Size = UDim2.new(relX, 0, 1, 0)
        knob.Position = UDim2.new(relX, -6, 0.5, -6)
        callback(val)
    end
    
    RunService.RenderStepped:Connect(function()
        if dragging then
            local touches = UserInputService:GetTouchPositions()
            if #touches > 0 then
                updateFromPosition(touches[1])
            end
        end
    end)
end

-- Функция полёта
local function toggleFly()
    flyEnabled = not flyEnabled
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChild("Humanoid")
    if not hrp or not humanoid then return end
    
    if flyEnabled then
        humanoid.PlatformStand = true
        flyBodyVel = Instance.new("BodyVelocity")
        flyBodyVel.MaxForce = Vector3.new(1e6, 1e6, 1e6)
        flyBodyVel.Parent = hrp
        
        flyBodyGyro = Instance.new("BodyGyro")
        flyBodyGyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
        flyBodyGyro.CFrame = hrp.CFrame
        flyBodyGyro.Parent = hrp
        
        if flyConnection then flyConnection:Disconnect() end
        flyConnection = RunService.RenderStepped:Connect(function()
            if not flyEnabled or not flyBodyVel or not char or not hrp then return end
            local cam = workspace.CurrentCamera
            local moveDir = (cam.CFrame.LookVector * flyControl.Forward) + (cam.CFrame.RightVector * flyControl.Right) + (Vector3.new(0, flyControl.Up, 0))
            if moveDir.Magnitude > 0 then moveDir = moveDir.Unit end
            flyBodyVel.Velocity = moveDir * flySpeed
            if flyBodyGyro then flyBodyGyro.CFrame = cam.CFrame end
        end)
    else
        humanoid.PlatformStand = false
        if flyBodyVel then flyBodyVel:Destroy() end
        if flyBodyGyro then flyBodyGyro:Destroy() end
        if flyConnection then flyConnection:Disconnect() end
        flyBodyVel = nil
        flyBodyGyro = nil
    end
end

-- Функция Noclip
local function updateNoclip()
    if not noclipEnabled then
        if noclipConnection then noclipConnection:Disconnect() end
        local char = player.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
        return
    end
    
    if noclipConnection then noclipConnection:Disconnect() end
    noclipConnection = RunService.RenderStepped:Connect(function()
        local char = player.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        if noclipWalls then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
        
        if noclipFloor then
            local params = RaycastParams.new()
            params.FilterDescendantsInstances = {char}
            params.FilterType = Enum.RaycastFilterType.Blacklist
            local hit = workspace:Raycast(hrp.Position, Vector3.new(0, -3, 0), params)
            if hit and hit.Instance then
                hit.Instance.CanCollide = false
                task.wait(0.05)
                hit.Instance.CanCollide = true
            end
        end
        
        if noclipCeiling then
            local params = RaycastParams.new()
            params.FilterDescendantsInstances = {char}
            params.FilterType = Enum.RaycastFilterType.Blacklist
            local hit = workspace:Raycast(hrp.Position, Vector3.new(0, 3, 0), params)
            if hit and hit.Instance then
                hit.Instance.CanCollide = false
                task.wait(0.05)
                hit.Instance.CanCollide = true
            end
        end
    end)
end

-- ESP функции
local function createESPForObject(obj, color, text)
    if espObjects[obj] then
        if espObjects[obj].bill then espObjects[obj].bill:Destroy() end
        espObjects[obj] = nil
    end
    local bill = Instance.new("BillboardGui")
    bill.Size = UDim2.new(0, math.floor(4 * espSize), 0, math.floor(3 * espSize))
    bill.StudsOffset = Vector3.new(0, 2.5, 0)
    bill.AlwaysOnTop = true
    bill.Parent = obj
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1,0,1,0)
    frame.BackgroundTransparency = 0.5
    frame.BackgroundColor3 = color
    frame.BorderSizePixel = 0
    frame.Parent = bill
    
    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(1,0,0.5,0)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = text
    nameLbl.TextColor3 = Color3.fromRGB(255,255,255)
    nameLbl.TextScaled = true
    nameLbl.Parent = frame
    
    local hpBar = nil
    local distLbl = nil
    if espShowHP then
        hpBar = Instance.new("Frame")
        hpBar.Size = UDim2.new(1,0,0.2,0)
        hpBar.Position = UDim2.new(0,0,0.8,0)
        hpBar.BackgroundColor3 = Color3.fromRGB(0,255,0)
        hpBar.BorderSizePixel = 0
        hpBar.Parent = frame
    end
    
    espObjects[obj] = {bill = bill, frame = frame, nameLbl = nameLbl, hpBar = hpBar, distLbl = distLbl}
    return bill
end

local function updateESP()
    if not espEnabled then return end
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local rootPos = char.HumanoidRootPart.Position
    
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (plr.Character.HumanoidRootPart.Position - rootPos).Magnitude
            local hum = plr.Character:FindFirstChild("Humanoid")
            local hpPercent = hum and (hum.Health / hum.MaxHealth) or 1
            
            if not espObjects[plr.Character] then
                createESPForObject(plr.Character, Color3.fromRGB(255,0,0), plr.Name)
            end
            local data = espObjects[plr.Character]
            if data and data.bill then
                data.bill.Size = UDim2.new(0, math.floor(4 * espSize), 0, math.floor(3 * espSize))
                if espShowDist then
                    if not data.distLbl then
                        data.distLbl = Instance.new("TextLabel")
                        data.distLbl.Size = UDim2.new(1,0,0.3,0)
                        data.distLbl.Position = UDim2.new(0,0,0,0)
                        data.distLbl.BackgroundTransparency = 1
                        data.distLbl.TextColor3 = Color3.fromRGB(255,255,0)
                        data.distLbl.TextScaled = true
                        data.distLbl.Parent = data.frame
                    end
                    data.distLbl.Text = math.floor(dist) .. "m"
                elseif data.distLbl then
                    data.distLbl:Destroy()
                    data.distLbl = nil
                end
                
                if espShowHP then
                    if not data.hpBar then
                        data.hpBar = Instance.new("Frame")
                        data.hpBar.Position = UDim2.new(0,0,0.8,0)
                        data.hpBar.BorderSizePixel = 0
                        data.hpBar.Parent = data.frame
                    end
                    data.hpBar.Size = UDim2.new(hpPercent, 0, 0.2, 0)
                    data.hpBar.BackgroundColor3 = Color3.fromRGB(255 * (1 - hpPercent), 255 * hpPercent, 0)
                elseif data.hpBar then
                    data.hpBar:Destroy()
                    data.hpBar = nil
                end
            end
        elseif espObjects[plr.Character] then
            espObjects[plr.Character].bill:Destroy()
            espObjects[plr.Character] = nil
        end
    end
    
    if espChest then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and (obj.Name:lower():find("chest") or obj.Name:lower():find("treasure") or obj.Name:lower():find("crate")) then
                if not espObjects[obj] then
                    createESPForObject(obj, Color3.fromRGB(255,165,0), obj.Name)
                elseif espObjects[obj].bill then
                    espObjects[obj].bill.Size = UDim2.new(0, math.floor(4 * espSize), 0, math.floor(3 * espSize))
                end
            end
        end
    end
    
    if espMobs then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and not Players:GetPlayerFromCharacter(obj) then
                if not espObjects[obj] then
                    createESPForObject(obj, Color3.fromRGB(0,255,0), obj.Name)
                elseif espObjects[obj].bill then
                    espObjects[obj].bill.Size = UDim2.new(0, math.floor(4 * espSize), 0, math.floor(3 * espSize))
                end
            end
        end
    end
end

local function startESP()
    if espConnection then espConnection:Disconnect() end
    espConnection = RunService.RenderStepped:Connect(updateESP)
end

local function stopESP()
    if espConnection then espConnection:Disconnect() end
    for obj, data in pairs(espObjects) do
        if data.bill then data.bill:Destroy() end
    end
    espObjects = {}
end

-- Создание вкладок
local function createTabs()
    local tabs = {"🏠 HOME", "✈ FLY", "👁 ESP", "🧱 NOCLIP", "⚡ MOVEMENT"}
    local frames = {homeTab, flyTab, espTab, noclipTab, movementTab}
    for i, name in ipairs(tabs) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.2, 0, 1, 0)
        btn.Position = UDim2.new((i-1)*0.2, 0, 0, 0)
        btn.BackgroundTransparency = 1
        btn.Text = name
        btn.TextColor3 = Color3.fromRGB(200,200,200)
        btn.TextSize = 14
        btn.Font = Enum.Font.Gotham
        btn.Parent = tabBar
        btn.MouseButton1Click:Connect(function()
            activeTab.Visible = false
            activeTab = frames[i]
            activeTab.Visible = true
            for _, other in pairs(tabBar:GetChildren()) do
                if other:IsA("TextButton") then
                    other.TextColor3 = Color3.fromRGB(200,200,200)
                end
            end
            btn.TextColor3 = Color3.fromRGB(255,255,255)
        end)
    end
end

-- HOME вкладка
local function buildHomeTab()
    homeTab.Size = UDim2.new(1, 0, 1, -40)
    homeTab.Position = UDim2.new(0, 0, 0, 40)
    homeTab.BackgroundTransparency = 1
    homeTab.Parent = mainFrame
    
    local dev = Instance.new("TextLabel")
    dev.Size = UDim2.new(0.9, 0, 0.1, 0)
    dev.Position = UDim2.new(0.05, 0, 0.05, 0)
    dev.BackgroundTransparency = 1
    dev.Text = "Разработчик: Vanezy"
    dev.TextColor3 = Color3.fromRGB(255,255,255)
    dev.TextSize = 16
    dev.Font = Enum.Font.GothamBold
    dev.TextXAlignment = Enum.TextXAlignment.Left
    dev.Parent = homeTab
    
    local socials = {"Discord: vanezy.gg", "Telegram: @vanezy", "GitHub: /vanezy", "YouTube: @VanezyScripts"}
    for i, soc in ipairs(socials) do
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.9, 0, 0.08, 0)
        lbl.Position = UDim2.new(0.05, 0, 0.2 + (i-1)*0.1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = soc
        lbl.TextColor3 = Color3.fromRGB(180,180,255)
        lbl.TextSize = 14
        lbl.Font = Enum.Font.Gotham
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = homeTab
    end
    
    local ver = Instance.new("TextLabel")
    ver.Size = UDim2.new(0.9, 0, 0.08, 0)
    ver.Position = UDim2.new(0.05, 0, 0.85, 0)
    ver.BackgroundTransparency = 1
    ver.Text = "Версия: 2.0 COMPLETE | Mobile"
    ver.TextColor3 = Color3.fromRGB(150,150,150)
    ver.TextSize = 12
    ver.Font = Enum.Font.Gotham
    ver.TextXAlignment = Enum.TextXAlignment.Left
    ver.Parent = homeTab
end

-- FLY вкладка
local function buildFlyTab()
    flyTab.Size = UDim2.new(1, 0, 1, -40)
    flyTab.Position = UDim2.new(0, 0, 0, 40)
    flyTab.BackgroundTransparency = 1
    flyTab.Visible = false
    flyTab.Parent = mainFrame
    
    local flyToggle = createToggle("Флай", false, flyTab, 0.05)
    local speedSld = createSlider("Скорость флая", 10, 200, flySpeed, flyTab, 0.2, function(v) flySpeed = v end)
    flyToggle.OnToggle:Connect(function(v) if v then toggleFly() else toggleFly() end end)
    
    -- Джойстик
    local joyBg = Instance.new("Frame")
    joyBg.Size = UDim2.new(0, 120, 0, 120)
    joyBg.Position = UDim2.new(0.65, 0, 0.45, 0)
    joyBg.BackgroundColor3 = Color3.fromRGB(50,50,50)
    joyBg.BackgroundTransparency = 0.5
    joyBg.BorderSizePixel = 0
    joyBg.Parent = flyTab
    
    local stick = Instance.new("Frame")
    stick.Size = UDim2.new(0, 45, 0, 45)
    stick.Position = UDim2.new(0.5, -22.5, 0.5, -22.5)
    stick.BackgroundColor3 = Color3.fromRGB(100,100,100)
    stick.BorderSizePixel = 0
    stick.Parent = joyBg
    
    local joyActive = false
    local joyStartPos = nil
    joyBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            joyActive = true
            joyStartPos = input.Position
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            joyActive = false
            stick.Position = UDim2.new(0.5, -22.5, 0.5, -22.5)
            flyControl.Forward = 0
            flyControl.Right = 0
        end
    end)
    RunService.RenderStepped:Connect(function()
        if not flyEnabled then return end
        if joyActive then
            local touches = UserInputService:GetTouchPositions()
            if #touches > 0 then
                local delta = touches[1] - joyStartPos
                local ang = math.atan2(delta.Y, delta.X)
                local mag = math.min(delta.Magnitude, 60)
                stick.Position = UDim2.new(0.5, math.cos(ang)*mag - 22.5, 0.5, math.sin(ang)*mag - 22.5)
                flyControl.Forward = -math.sin(ang) * (mag/60)
                flyControl.Right = math.cos(ang) * (mag/60)
            end
        else
            stick.Position = UDim2.new(0.5, -22.5, 0.5, -22.5)
            flyControl.Forward = 0
            flyControl.Right = 0
        end
    end)
    
    local upBtn = Instance.new("TextButton")
    upBtn.Size = UDim2.new(0, 60, 0, 60)
    upBtn.Position = UDim2.new(0.05, 0, 0.6, 0)
    upBtn.BackgroundColor3 = Color3.fromRGB(80,80,80)
    upBtn.Text = "▲"
    upBtn.TextSize = 30
    upBtn.Font = Enum.Font.GothamBold
    upBtn.Parent = flyTab
    local downBtn = Instance.new("TextButton")
    downBtn.Size = UDim2.new(0, 60, 0, 60)
    downBtn.Position = UDim2.new(0.05, 0, 0.8, 0)
    downBtn.BackgroundColor3 = Color3.fromRGB(80,80,80)
    downBtn.Text = "▼"
    downBtn.TextSize = 30
    downBtn.Font = Enum.Font.GothamBold
    downBtn.Parent = flyTab
    upBtn.MouseButton1Down:Connect(function() flyControl.Up = 1 end)
    upBtn.MouseButton1Up:Connect(function() flyControl.Up = 0 end)
    downBtn.MouseButton1Down:Connect(function() flyControl.Up = -1 end)
    downBtn.MouseButton1Up:Connect(function() flyControl.Up = 0 end)
end

-- ESP вкладка
local function buildEspTab()
    espTab.Size = UDim2.new(1, 0, 1, -40)
    espTab.Position = UDim2.new(0, 0, 0, 40)
    espTab.BackgroundTransparency = 1
    espTab.Visible = false
    espTab.Parent = mainFrame
    
    local togEsp = createToggle("ESP Игроков", false, espTab, 0.05)
    local togChest = createToggle("ESP Сундуков", false, espTab, 0.15)
    local togMobs = createToggle("ESP Мобов", false, espTab, 0.25)
    local sldSize = createSlider("ESP Размер", 0.5, 3, espSize, espTab, 0.35, function(v) espSize = v end)
    local togHp = createToggle("ESP ХП", false, espTab, 0.45)
    local togDist = createToggle("ESP Расстояние", false, espTab, 0.55)
    
    togEsp.OnToggle:Connect(function(v) espEnabled = v; if v then startESP() else stopESP() end end)
    togChest.OnToggle:Connect(function(v) espChest = v end)
    togMobs.OnToggle:Connect(function(v) espMobs = v end)
    togHp.OnToggle:Connect(function(v) espShowHP = v end)
    togDist.OnToggle:Connect(function(v) espShowDist = v end)
end

-- NOCLIP вкладка
local function buildNoclipTab()
    noclipTab.Size = UDim2.new(1, 0, 1, -40)
    noclipTab.Position = UDim2.new(0, 0, 0, 40)
    noclipTab.BackgroundTransparency = 1
    noclipTab.Visible = false
    noclipTab.Parent = mainFrame
    
    local togWalls = createToggle("Сквозь стены", false, noclipTab, 0.05)
    local togFloor = createToggle("Сквозь пол", false, noclipTab, 0.15)
    local togCeil = createToggle("Сквозь потолок", false, noclipTab, 0.25)
    
    togWalls.OnToggle:Connect(function(v) noclipWalls = v; noclipEnabled = noclipWalls or noclipFloor or noclipCeiling; updateNoclip() end)
    togFloor.OnToggle:Connect(function(v) noclipFloor = v; noclipEnabled = noclipWalls or noclipFloor or noclipCeiling; updateNoclip() end)
    togCeil.OnToggle:Connect(function(v) noclipCeiling = v; noclipEnabled = noclipWalls or noclipFloor or noclipCeiling; updateNoclip() end)
end

-- MOVEMENT вкладка
local function buildMovementTab()
    movementTab.Size = UDim2.new(1, 0, 1, -40)
    movementTab.Position = UDim2.new(0, 0, 0, 40)
    movementTab.BackgroundTransparency = 1
    movementTab.Visible = false
    movementTab.Parent = mainFrame
    
    local sldWalk = createSlider("Speed ходьбы", 16, 100, walkSpeedValue, movementTab, 0.05, function(v) walkSpeedValue = v; if not speedHack and not autoRun and player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid.WalkSpeed = v end end)
    local sldJump = createSlider("Прыжок", 50, 200, jumpPowerValue, movementTab, 0.18, function(v) jumpPowerValue = v; if player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid.JumpPower = v end end)
    local togSpeedHack = createToggle("Спидхак", false, movementTab, 0.31)
    local sldSpeedVal = createSlider("Спидхак скорость", 16, 500, speedHackValue, movementTab, 0.41, function(v) speedHackValue = v; if speedHack and player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid.WalkSpeed = v end end)
    local togInfJump = createToggle("Бесконечные прыжки", false, movementTab, 0.54)
    local sldFov = createSlider("FOV", 70, 120, fovValue, movementTab, 0.64, function(v) fovValue = v; workspace.CurrentCamera.FieldOfView = v end)
    local sldAutoSpeed = createSlider("Автобег скорость", 16, 100, autoRunSpeed, movementTab, 0.74, function(v) autoRunSpeed = v; if autoRun and player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid.WalkSpeed = v end end)
    local togAuto = createToggle("Автобег", false, movementTab, 0.87)
    
    togSpeedHack.OnToggle:Connect(function(v) speedHack = v; if player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid.WalkSpeed = v and speedHackValue or walkSpeedValue end end)
    togInfJump.OnToggle:Connect(function(v) infiniteJump = v end)
    togAuto.OnToggle:Connect(function(v) autoRun = v; if player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid.WalkSpeed = v and autoRunSpeed or walkSpeedValue end end)
    
    UserInputService.JumpRequest:Connect(function()
        if infiniteJump and player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

-- Основное меню
local function buildMainUI()
    mainFrame.Size = UDim2.new(0, 350, 0, 500)
    mainFrame.Position = UDim2.new(0.5, -175, 0.5, -250)
    mainFrame.BackgroundColor3 = Color3.fromRGB(40,40,40)
    mainFrame.BackgroundTransparency = 0.05
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    
    topBar.Size = UDim2.new(1, 0, 0, 50)
    topBar.BackgroundColor3 = Color3.fromRGB(60,60,60)
    topBar.BorderSizePixel = 0
    topBar.Parent = mainFrame
    
    titleText.Size = UDim2.new(0.5, 0, 1, 0)
    titleText.Position = UDim2.new(0.05, 0, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "VANEZY UNIVERSAL"
    titleText.TextColor3 = Color3.fromRGB(255,255,255)
    titleText.TextSize = 20
    titleText.Font = Enum.Font.GothamBold
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = topBar
    
    authorText.Size = UDim2.new(0.4, 0, 0.5, 0)
    authorText.Position = UDim2.new(0.05, 0, 0.5, 0)
    authorText.BackgroundTransparency = 1
    authorText.Text = "Vanezy"
    authorText.TextColor3 = Color3.fromRGB(180,180,180)
    authorText.TextSize = 12
    authorText.Font = Enum.Font.Gotham
    authorText.TextXAlignment = Enum.TextXAlignment.Left
    authorText.Parent = topBar
    
    iconStar.Size = UDim2.new(0, 40, 1, 0)
    iconStar.Position = UDim2.new(1, -200, 0, 0)
    iconStar.BackgroundTransparency = 1
    iconStar.Text = "🌙"
    iconStar.TextColor3 = Color3.fromRGB(255,255,255)
    iconStar.TextSize = 30
    iconStar.Font = Enum.Font.GothamBold
    iconStar.Parent = topBar
    
    closeButton.Size = UDim2.new(0, 40, 1, 0)
    closeButton.Position = UDim2.new(1, -40, 0, 0)
    closeButton.BackgroundTransparency = 1
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.fromRGB(255,100,100)
    closeButton.TextSize = 20
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = topBar
    
    minimizeButton.Size = UDim2.new(0, 40, 1, 0)
    minimizeButton.Position = UDim2.new(1, -80, 0, 0)
    minimizeButton.BackgroundTransparency = 1
    minimizeButton.Text = "−"
    minimizeButton.TextColor3 = Color3.fromRGB(255,255,255)
    minimizeButton.TextSize = 20
    minimizeButton.Font = Enum.Font.GothamBold
    minimizeButton.Parent = topBar
    
    colorButton.Size = UDim2.new(0, 60, 0.6, 0)
    colorButton.Position = UDim2.new(0.6, 0, 0.2, 0)
    colorButton.BackgroundColor3 = Color3.fromRGB(80,80,80)
    colorButton.Text = "Цвет"
    colorButton.TextColor3 = Color3.fromRGB(255,255,255)
    colorButton.TextSize = 14
    colorButton.Parent = topBar
    
    rainbowSpeedFrame.Size = UDim2.new(0.3, 0, 0.05, 0)
    rainbowSpeedFrame.Position = UDim2.new(0.6, 0, 0.85, 0)
    rainbowSpeedFrame.BackgroundColor3 = Color3.fromRGB(50,50,50)
    rainbowSpeedFrame.Visible = false
    rainbowSpeedFrame.Parent = mainFrame
    rainbowSliderFill.Size = UDim2.new(0.5, 0, 1, 0)
    rainbowSliderFill.BackgroundColor3 = Color3.fromRGB(0,255,0)
    rainbowSliderFill.BorderSizePixel = 0
    rainbowSliderFill.Parent = rainbowSpeedFrame
    rainbowKnob.Size = UDim2.new(0, 10, 0, 20)
    rainbowKnob.Position = UDim2.new(0.5, -5, 0.5, -10)
    rainbowKnob.BackgroundColor3 = Color3.fromRGB(255,255,255)
    rainbowKnob.BorderSizePixel = 0
    rainbowKnob.Parent = rainbowSpeedFrame
    
    tabBar.Size = UDim2.new(1, 0, 0, 40)
    tabBar.Position = UDim2.new(0, 0, 0, 50)
    tabBar.BackgroundColor3 = Color3.fromRGB(35,35,35)
    tabBar.BorderSizePixel = 0
    tabBar.Parent = mainFrame
    
    buildHomeTab()
    buildFlyTab()
    buildEspTab()
    buildNoclipTab()
    buildMovementTab()
    createTabs()
    activeTab.Visible = true
    
    -- Перетаскивание
    local dragStart, dragPos
    topBar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch then
            dragStart = inp.Position
            dragPos = mainFrame.Position
        end
    end)
    topBar.InputChanged:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch and dragStart then
            local delta = inp.Position - dragStart
            mainFrame.Position = UDim2.new(dragPos.X.Scale, dragPos.X.Offset + delta.X, dragPos.Y.Scale, dragPos.Y.Offset + delta.Y)
        end
    end)
    topBar.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch then dragStart = nil end
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        if flyEnabled then toggleFly() end
        if noclipEnabled then noclipEnabled = false; updateNoclip() end
        if espEnabled then stopESP() end
    end)
    
    minimizeButton.MouseButton1Click:Connect(function()
        guiMinimized = not guiMinimized
        if guiMinimized then
            mainFrame.Size = UDim2.new(0, 350, 0, 50)
            tabBar.Visible = false
            minimizeButton.Text = "□"
        else
            mainFrame.Size = UDim2.new(0, 350, 0, 500)
            tabBar.Visible = true
            minimizeButton.Text = "−"
        end
    end)
    
    colorButton.MouseButton1Click:Connect(function()
        currentColorIndex = currentColorIndex % #colorOptions + 1
        local opt = colorOptions[currentColorIndex]
        if opt.color == "rainbow" then
            rainbowEnabled = true
            rainbowSpeedFrame.Visible = true
            if not rainbowConnection then
                rainbowConnection = RunService.RenderStepped:Connect(updateRainbow)
            end
        else
            rainbowEnabled = false
            rainbowSpeedFrame.Visible = false
            if rainbowConnection then rainbowConnection:Disconnect() end
            mainFrame.BackgroundColor3 = opt.color
            topBar.BackgroundColor3 = opt.color
            currentSolidColor = opt.color
        end
    end)
    
    rainbowKnob.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch then draggingRainbow = true end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch then draggingRainbow = false end
    end)
    RunService.RenderStepped:Connect(function()
        if draggingRainbow and rainbowSpeedFrame.Visible then
            local touches = UserInputService:GetTouchPositions()
            if #touches > 0 then
                local relX = math.clamp((touches[1].X - rainbowSpeedFrame.AbsolutePosition.X) / rainbowSpeedFrame.AbsoluteSize.X, 0, 1)
                rainbowSpeed = 0.5 + relX * 4.5
                rainbowSliderFill.Size = UDim2.new(relX, 0, 1, 0)
                rainbowKnob.Position = UDim2.new(relX, -5, 0.5, -10)
            end
        end
    end)
end

-- Запуск
screenGui.Parent = CoreGui
screenGui.Name = "VanezyUniversal"
buildMainUI()
showLoading()

player.CharacterAdded:Connect(function()
    task.wait(0.5)
    if flyEnabled then toggleFly() end
    if noclipEnabled then updateNoclip() end
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        local hum = player.Character.Humanoid
        hum.WalkSpeed = autoRun and autoRunSpeed or (speedHack and speedHackValue or walkSpeedValue)
        hum.JumpPower = jumpPowerValue
        workspace.CurrentCamera.FieldOfView = fovValue
    end
end)

print("VANEZY UNIVERSAL v2.0 COMPLETE - 100% функций загружено")
