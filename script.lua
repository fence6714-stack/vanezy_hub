--[[
  Vanezy Universal Mobile Script
  Версия: 1.0 FULL
  Платформа: Roblox (для телефона с поддержкой джойстика)
  Все функции полностью реализованы
--]]

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Глобальные переменные
local flyEnabled = false
local flySpeed = 50
local bodyVelocity = nil
local bodyGyro = nil
local noclipEnabled = false
local noclipWalls = false
local noclipFloor = false
local noclipCeiling = false
local espEnabled = false
local espChestEnabled = false
local espMobEnabled = false
local espSize = 1
local espHP = false
local espDistance = false
local speedHack = false
local speedValue = 16
local jumpPower = 50
local infiniteJump = false
local fovValue = 70
local autoRun = false
local autoRunSpeed = 16
local walkSpeedValue = 16
local flyControl = {Forward = 0, Right = 0, Up = 0}
local rainbowHue = 0
local rainbowSpeed = 1
local currentColor = Color3.fromRGB(255,255,255)
local scriptVisible = true
local minimized = false
local espObjects = {}
local flyConnection = nil
local noclipConnection = nil
local espConnection = nil
local rainbowConnection = nil

-- Цвета
local colors = {
    {Name = "Красный", Color = Color3.fromRGB(255,0,0)},
    {Name = "Зелёный", Color = Color3.fromRGB(0,255,0)},
    {Name = "Синий", Color = Color3.fromRGB(0,0,255)},
    {Name = "Жёлтый", Color = Color3.fromRGB(255,255,0)},
    {Name = "Фиолетовый", Color = Color3.fromRGB(255,0,255)},
    {Name = "Оранжевый", Color = Color3.fromRGB(255,165,0)},
    {Name = "Белый", Color = Color3.fromRGB(255,255,255)},
    {Name = "Радужный", Color = "rainbow"}
}

-- UI элементы
local screenGui = Instance.new("ScreenGui")
local mainFrame = Instance.new("Frame")
local topBar = Instance.new("Frame")
local titleLabel = Instance.new("TextLabel")
local authorLabel = Instance.new("TextLabel")
local iconLabel = Instance.new("TextLabel")
local closeBtn = Instance.new("TextButton")
local minimizeBtn = Instance.new("TextButton")
local colorBtn = Instance.new("TextButton")
local rainbowSpeedSlider = Instance.new("Frame")
local rainbowSliderFill = Instance.new("Frame")
local rainbowKnob = Instance.new("Frame")
local tabContainer = Instance.new("Frame")
local homeTab = Instance.new("Frame")
local flyTab = Instance.new("Frame")
local espTab = Instance.new("Frame")
local noclipTab = Instance.new("Frame")
local movementTab = Instance.new("Frame")
local currentTab = homeTab
local draggingRainbow = false

-- Загрузочный экран
local loadingFrame = Instance.new("Frame")
local loadingLabel = Instance.new("TextLabel")
local loadingAuthor = Instance.new("TextLabel")

function createLoadingScreen()
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
    
    local appear = TweenService:Create(loadingFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {BackgroundTransparency = 0.2})
    appear:Play()
    wait(2)
    local disappear = TweenService:Create(loadingFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundTransparency = 1})
    disappear:Play()
    disappear.Completed:Wait()
    loadingFrame:Destroy()
    
    local mainAppear = TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {BackgroundTransparency = 0.05})
    mainAppear:Play()
end

function updateRainbow()
    if currentColor == "rainbow" then
        rainbowHue = (rainbowHue + 0.0167 * rainbowSpeed) % 1
        local color = Color3.fromHSV(rainbowHue, 1, 1)
        mainFrame.BackgroundColor3 = color
        topBar.BackgroundColor3 = color
    end
end

function createMainUI()
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
    
    titleLabel.Size = UDim2.new(0.5, 0, 1, 0)
    titleLabel.Position = UDim2.new(0.05, 0, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "VANEZY UNIVERSAL"
    titleLabel.TextColor3 = Color3.fromRGB(255,255,255)
    titleLabel.TextSize = 20
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = topBar
    
    authorLabel.Size = UDim2.new(0.4, 0, 0.5, 0)
    authorLabel.Position = UDim2.new(0.05, 0, 0.5, 0)
    authorLabel.BackgroundTransparency = 1
    authorLabel.Text = "Vanezy"
    authorLabel.TextColor3 = Color3.fromRGB(180,180,180)
    authorLabel.TextSize = 12
    authorLabel.Font = Enum.Font.Gotham
    authorLabel.TextXAlignment = Enum.TextXAlignment.Left
    authorLabel.Parent = topBar
    
    iconLabel.Size = UDim2.new(0, 40, 1, 0)
    iconLabel.Position = UDim2.new(1, -200, 0, 0)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = "🌙"
    iconLabel.TextColor3 = Color3.fromRGB(255,255,255)
    iconLabel.TextSize = 30
    iconLabel.Font = Enum.Font.GothamBold
    iconLabel.Parent = topBar
    
    closeBtn.Size = UDim2.new(0, 40, 1, 0)
    closeBtn.Position = UDim2.new(1, -40, 0, 0)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255,100,100)
    closeBtn.TextSize = 20
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = topBar
    
    minimizeBtn.Size = UDim2.new(0, 40, 1, 0)
    minimizeBtn.Position = UDim2.new(1, -80, 0, 0)
    minimizeBtn.BackgroundTransparency = 1
    minimizeBtn.Text = "−"
    minimizeBtn.TextColor3 = Color3.fromRGB(255,255,255)
    minimizeBtn.TextSize = 20
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.Parent = topBar
    
    colorBtn.Size = UDim2.new(0, 60, 0.6, 0)
    colorBtn.Position = UDim2.new(0.6, 0, 0.2, 0)
    colorBtn.BackgroundColor3 = Color3.fromRGB(80,80,80)
    colorBtn.Text = "Цвет"
    colorBtn.TextColor3 = Color3.fromRGB(255,255,255)
    colorBtn.TextSize = 14
    colorBtn.Parent = topBar
    
    rainbowSpeedSlider.Size = UDim2.new(0.3, 0, 0.05, 0)
    rainbowSpeedSlider.Position = UDim2.new(0.6, 0, 0.85, 0)
    rainbowSpeedSlider.BackgroundColor3 = Color3.fromRGB(50,50,50)
    rainbowSpeedSlider.Visible = false
    rainbowSpeedSlider.Parent = mainFrame
    
    rainbowSliderFill.Size = UDim2.new(0.5, 0, 1, 0)
    rainbowSliderFill.BackgroundColor3 = Color3.fromRGB(0,255,0)
    rainbowSliderFill.BorderSizePixel = 0
    rainbowSliderFill.Parent = rainbowSpeedSlider
    
    rainbowKnob.Size = UDim2.new(0, 10, 0, 20)
    rainbowKnob.Position = UDim2.new(0.5, -5, 0.5, -10)
    rainbowKnob.BackgroundColor3 = Color3.fromRGB(255,255,255)
    rainbowKnob.BorderSizePixel = 0
    rainbowKnob.Parent = rainbowSpeedSlider
    
    tabContainer.Size = UDim2.new(1, 0, 0, 40)
    tabContainer.Position = UDim2.new(0, 0, 0, 50)
    tabContainer.BackgroundColor3 = Color3.fromRGB(35,35,35)
    tabContainer.BorderSizePixel = 0
    tabContainer.Parent = mainFrame
    
    createTabButtons()
    createHomeTab()
    createFlyTab()
    createEspTab()
    createNoclipTab()
    createMovementTab()
    
    homeTab.Visible = true
    
    local dragStart, dragStartPos
    topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragStart = input.Position
            dragStartPos = mainFrame.Position
        end
    end)
    
    topBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch and dragStart then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(dragStartPos.X.Scale, dragStartPos.X.Offset + delta.X, dragStartPos.Y.Scale, dragStartPos.Y.Offset + delta.Y)
        end
    end)
    
    topBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragStart = nil
        end
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        if flyEnabled then toggleFly() end
        if noclipEnabled then toggleNoclip() end
        if espEnabled then stopESP() end
        if rainbowConnection then rainbowConnection:Disconnect() end
    end)
    
    minimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            mainFrame.Size = UDim2.new(0, 350, 0, 50)
            tabContainer.Visible = false
            minimizeBtn.Text = "□"
        else
            mainFrame.Size = UDim2.new(0, 350, 0, 500)
            tabContainer.Visible = true
            minimizeBtn.Text = "−"
        end
    end)
    
    colorBtn.MouseButton1Click:Connect(function()
        local currentIndex = 1
        for i, col in ipairs(colors) do
            if col.Color == currentColor or (type(currentColor)=="string" and col.Name=="Радужный") then
                currentIndex = i % #colors + 1
                break
            end
        end
        local newColor = colors[currentIndex]
        if newColor.Color == "rainbow" then
            currentColor = "rainbow"
            rainbowSpeedSlider.Visible = true
            if rainbowConnection then rainbowConnection:Disconnect() end
            rainbowConnection = RunService.RenderStepped:Connect(updateRainbow)
        else
            currentColor = newColor.Color
            rainbowSpeedSlider.Visible = false
            if rainbowConnection then rainbowConnection:Disconnect() end
            mainFrame.BackgroundColor3 = currentColor
            topBar.BackgroundColor3 = currentColor
        end
    end)
    
    rainbowKnob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            draggingRainbow = true
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            draggingRainbow = false
        end
    end)
    
    RunService.RenderStepped:Connect(function()
        if draggingRainbow and rainbowSpeedSlider.Visible then
            local touchPos = UserInputService:GetTouchPositions()[1]
            if touchPos then
                local relX = math.clamp((touchPos.X - rainbowSpeedSlider.AbsolutePosition.X) / rainbowSpeedSlider.AbsoluteSize.X, 0, 1)
                rainbowSpeed = 0.5 + relX * 4.5
                rainbowSliderFill.Size = UDim2.new(relX, 0, 1, 0)
                rainbowKnob.Position = UDim2.new(relX, -5, 0.5, -10)
            end
        end
    end)
end

function createTabButtons()
    local tabs = {"🏠 Home", "✈ Fly", "👁 ESP", "🧱 Noclip", "⚡ Movement"}
    local tabFrames = {homeTab, flyTab, espTab, noclipTab, movementTab}
    
    for i, tabName in ipairs(tabs) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.2, 0, 1, 0)
        btn.Position = UDim2.new((i-1)*0.2, 0, 0, 0)
        btn.BackgroundTransparency = 1
        btn.Text = tabName
        btn.TextColor3 = Color3.fromRGB(200,200,200)
        btn.TextSize = 14
        btn.Font = Enum.Font.Gotham
        btn.Parent = tabContainer
        
        btn.MouseButton1Click:Connect(function()
            currentTab.Visible = false
            currentTab = tabFrames[i]
            currentTab.Visible = true
            for _, other in ipairs(tabContainer:GetChildren()) do
                if other:IsA("TextButton") then
                    other.TextColor3 = Color3.fromRGB(200,200,200)
                end
            end
            btn.TextColor3 = Color3.fromRGB(255,255,255)
        end)
    end
end

function createHomeTab()
    homeTab.Size = UDim2.new(1, 0, 1, -40)
    homeTab.Position = UDim2.new(0, 0, 0, 40)
    homeTab.BackgroundTransparency = 1
    homeTab.Parent = mainFrame
    
    local devLabel = Instance.new("TextLabel")
    devLabel.Size = UDim2.new(0.9, 0, 0.1, 0)
    devLabel.Position = UDim2.new(0.05, 0, 0.05, 0)
    devLabel.BackgroundTransparency = 1
    devLabel.Text = "Разработчик: Vanezy"
    devLabel.TextColor3 = Color3.fromRGB(255,255,255)
    devLabel.TextSize = 16
    devLabel.Font = Enum.Font.GothamBold
    devLabel.TextXAlignment = Enum.TextXAlignment.Left
    devLabel.Parent = homeTab
    
    local socials = {"Discord: vanezy.gg", "Telegram: @vanezy", "GitHub: /vanezy", "YouTube: @VanezyScripts"}
    for i, social in ipairs(socials) do
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.9, 0, 0.08, 0)
        lbl.Position = UDim2.new(0.05, 0, 0.2 + (i-1)*0.1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = social
        lbl.TextColor3 = Color3.fromRGB(180,180,255)
        lbl.TextSize = 14
        lbl.Font = Enum.Font.Gotham
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = homeTab
    end
    
    local versionLabel = Instance.new("TextLabel")
    versionLabel.Size = UDim2.new(0.9, 0, 0.08, 0)
    versionLabel.Position = UDim2.new(0.05, 0, 0.85, 0)
    versionLabel.BackgroundTransparency = 1
    versionLabel.Text = "Версия: 1.0 FULL | Mobile Optimized"
    versionLabel.TextColor3 = Color3.fromRGB(150,150,150)
    versionLabel.TextSize = 12
    versionLabel.Font = Enum.Font.Gotham
    versionLabel.TextXAlignment = Enum.TextXAlignment.Left
    versionLabel.Parent = homeTab
    
    local thanksLabel = Instance.new("TextLabel")
    thanksLabel.Size = UDim2.new(0.9, 0, 0.08, 0)
    thanksLabel.Position = UDim2.new(0.05, 0, 0.75, 0)
    thanksLabel.BackgroundTransparency = 1
    thanksLabel.Text = "Спасибо за использование!"
    thanksLabel.TextColor3 = Color3.fromRGB(100,255,100)
    thanksLabel.TextSize = 12
    thanksLabel.Font = Enum.Font.Gotham
    thanksLabel.TextXAlignment = Enum.TextXAlignment.Left
    thanksLabel.Parent = homeTab
end

function createFlyTab()
    flyTab.Size = UDim2.new(1, 0, 1, -40)
    flyTab.Position = UDim2.new(0, 0, 0, 40)
    flyTab.BackgroundTransparency = 1
    flyTab.Visible = false
    flyTab.Parent = mainFrame
    
    local flyToggle = createToggle("Флай", false, flyTab, 0.05)
    local speedSlider = createSlider("Скорость флая", 10, 200, flySpeed, flyTab, 0.2, function(v) flySpeed = v end)
    
    flyToggle.OnToggle:Connect(function(enabled)
        if enabled then 
            toggleFly() 
        else 
            toggleFly() 
        end
    end)
    
    local joyStickFrame = Instance.new("Frame")
    joyStickFrame.Size = UDim2.new(0, 120, 0, 120)
    joyStickFrame.Position = UDim2.new(0.65, 0, 0.45, 0)
    joyStickFrame.BackgroundColor3 = Color3.fromRGB(50,50,50)
    joyStickFrame.BackgroundTransparency = 0.5
    joyStickFrame.BorderSizePixel = 0
    joyStickFrame.Parent = flyTab
    
    local stick = Instance.new("Frame")
    stick.Size = UDim2.new(0, 45, 0, 45)
    stick.Position = UDim2.new(0.5, -22.5, 0.5, -22.5)
    stick.BackgroundColor3 = Color3.fromRGB(100,100,100)
    stick.BorderSizePixel = 0
    stick.Parent = joyStickFrame
    
    local joyActive = false
    local joyStart = nil
    
    joyStickFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            joyActive = true
            joyStart = input.Position
        end
    end)
    
    RunService.RenderStepped:Connect(function()
        if not flyEnabled then return end
        if joyActive and UserInputService:GetTouchPositions()[1] then
            local touchPos = UserInputService:GetTouchPositions()[1]
            local delta = touchPos - joyStart
            local angle = math.atan2(delta.Y, delta.X)
            local magnitude = math.min(delta.Magnitude, 60)
            stick.Position = UDim2.new(0.5, (math.cos(angle)*magnitude)-22.5, 0.5, (math.sin(angle)*magnitude)-22.5)
            flyControl.Forward = -math.sin(angle) * (magnitude/60)
            flyControl.Right = math.cos(angle) * (magnitude/60)
        else
            stick.Position = UDim2.new(0.5, -22.5, 0.5, -22.5)
            flyControl.Forward = 0
            flyControl.Right = 0
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            joyActive = false
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
    
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(0.5, 0, 0.08, 0)
    infoLabel.Position = UDim2.new(0.05, 0, 0.05, 0)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Text = "Джойстик - движение по X/Z"
    infoLabel.TextColor3 = Color3.fromRGB(200,200,200)
    infoLabel.TextSize = 12
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.TextXAlignment = Enum.TextXAlignment.Left
    infoLabel.Parent = flyTab
end

function createEspTab()
    espTab.Size = UDim2.new(1, 0, 1, -40)
    espTab.Position = UDim2.new(0, 0, 0, 40)
    espTab.BackgroundTransparency = 1
    espTab.Visible = false
    espTab.Parent = mainFrame
    
    local espToggle = createToggle("ESP Игроков", false, espTab, 0.05)
    local chestToggle = createToggle("ESP Сундуков", false, espTab, 0.15)
    local mobToggle = createToggle("ESP Мобов", false, espTab, 0.25)
    local sizeSlider = createSlider("ESP Размер", 0.5, 3, espSize, espTab, 0.35, function(v) espSize = v end)
    local hpToggle = createToggle("ESP ХП", false, espTab, 0.45)
    local distToggle = createToggle("ESP Расстояние", false, espTab, 0.55)
    
    espToggle.OnToggle:Connect(function(v) 
        espEnabled = v
        if v then 
            startESP() 
        else 
            stopESP() 
        end
    end)
    chestToggle.OnToggle:Connect(function(v) espChestEnabled = v end)
    mobToggle.OnToggle:Connect(function(v) espMobEnabled = v end)
    hpToggle.OnToggle:Connect(function(v) espHP = v end)
    distToggle.OnToggle:Connect(function(v) espDistance = v end)
end

function createNoclipTab()
    noclipTab.Size = UDim2.new(1, 0, 1, -40)
    noclipTab.Position = UDim2.new(0, 0, 0, 40)
    noclipTab.BackgroundTransparency = 1
    noclipTab.Visible = false
    noclipTab.Parent = mainFrame
    
    local noclipToggle = createToggle("Сквозь стены", false, noclipTab, 0.05)
    local floorToggle = createToggle("Сквозь пол", false, noclipTab, 0.15)
    local ceilingToggle = createToggle("Сквозь потолок", false, noclipTab, 0.25)
    
    noclipToggle.OnToggle:Connect(function(v) 
        noclipWalls = v
        noclipEnabled = noclipWalls or noclipFloor or noclipCeiling
        toggleNoclip()
    end)
    floorToggle.OnToggle:Connect(function(v) 
        noclipFloor = v
        noclipEnabled = noclipWalls or noclipFloor or noclipCeiling
        toggleNoclip()
    end)
    ceilingToggle.OnToggle:Connect(function(v) 
        noclipCeiling = v
        noclipEnabled = noclipWalls or noclipFloor or noclipCeiling
        toggleNoclip()
    end)
end

function createMovementTab()
    movementTab.Size = UDim2.new(1, 0, 1, -40)
    movementTab.Position = UDim2.new(0, 0, 0, 40)
    movementTab.BackgroundTransparency = 1
    movementTab.Visible = false
    movementTab.Parent = mainFrame
    
    local walkSlider = createSlider("Speed ходьбы", 16, 100, walkSpeedValue, movementTab, 0.05, function(v) 
        walkSpeedValue = v
        if not speedHack and not autoRun and player.Character and player.Character:FindFirstChild("Humanoid") then 
            player.Character.Humanoid.WalkSpeed = v 
        end
    end)
    local jumpSlider = createSlider("Прыжок", 50, 200, jumpPower, movementTab, 0.18, function(v) 
        jumpPower = v
        if player.Character and player.Character:FindFirstChild("Humanoid") then 
            player.Character.Humanoid.JumpPower = v 
        end
    end)
    local speedToggle = createToggle("Спидхак", false, movementTab, 0.31)
    local speedValueSlider = createSlider("Спидхак скорость", 16, 500, speedValue, movementTab, 0.41, function(v) 
        speedValue = v
        if speedHack and player.Character and player.Character:FindFirstChild("Humanoid") then 
            player.Character.Humanoid.WalkSpeed = v 
        end
    end)
    local infiniteToggle = createToggle("Бесконечные прыжки", false, movementTab, 0.54)
    local fovSlider = createSlider("FOV", 70, 120, fovValue, movementTab, 0.64, function(v) 
        fovValue = v
        game.Workspace.CurrentCamera.FieldOfView = v 
    end)
    local autoRunSpeedSlider = createSlider("Автобег скорость", 16, 100, autoRunSpeed, movementTab, 0.74, function(v) 
        autoRunSpeed = v
        if autoRun and player.Character and player.Character:FindFirstChild("Humanoid") then 
            player.Character.Humanoid.WalkSpeed = v 
        end
    end)
    local autoRunToggle = createToggle("Автобег", false, movementTab, 0.87)
    
    speedToggle.OnToggle:Connect(function(v) 
        speedHack = v
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            if v then 
                player.Character.Humanoid.WalkSpeed = speedValue 
            else 
                player.Character.Humanoid.WalkSpeed = walkSpeedValue 
            end
        end
    end)
    infiniteToggle.OnToggle:Connect(function(v) infiniteJump = v end)
    autoRunToggle.OnToggle:Connect(function(v) 
        autoRun = v
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            if v then 
                player.Character.Humanoid.WalkSpeed = autoRunSpeed
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local bodyVel = Instance.new("BodyVelocity")
                    bodyVel.MaxForce = Vector3.new(1e6, 0, 1e6)
                    bodyVel.Velocity = hrp.CFrame.LookVector * autoRunSpeed
                    bodyVel.Parent = hrp
                    task.wait(0.1)
                    bodyVel:Destroy()
                end
            else 
                player.Character.Humanoid.WalkSpeed = walkSpeedValue 
            end
        end
    end)
    
    UserInputService.JumpRequest:Connect(function()
        if infiniteJump and player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

function createToggle(text, defaultValue, parent, yPos, callback)
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
    
    local toggled = defaultValue
    local event = Instance.new("BindableEvent")
    
    btn.MouseButton1Click:Connect(function()
        toggled = not toggled
        btn.BackgroundColor3 = toggled and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
        btn.Text = toggled and "Вкл" or "Выкл"
        event:Fire(toggled)
        if callback then callback(toggled) end
    end)
    
    return {OnToggle = event.Event, SetValue = function(v) 
        toggled = v
        btn.BackgroundColor3 = v and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
        btn.Text = v and "Вкл" or "Выкл"
        event:Fire(v)
        if callback then callback(v) end
    end}
end

function createSlider(text, minVal, maxVal, defaultValue, parent, yPos, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.9, 0, 0, 50)
    frame.Position = UDim2.new(0.05, 0, yPos, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 0.4, 0)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. tostring(defaultValue)
    label.TextColor3 = Color3.fromRGB(255,255,255)
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(0.8, 0, 0, 4)
    slider.Position = UDim2.new(0, 0, 0.7, 0)
    slider.BackgroundColor3 = Color3.fromRGB(80,80,80)
    slider.BorderSizePixel = 0
    slider.Parent = frame
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((defaultValue-minVal)/(maxVal-minVal), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0,255,0)
    fill.BorderSizePixel = 0
    fill.Parent = slider
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.Position = UDim2.new((defaultValue-minVal)/(maxVal-minVal), -6, 0.5, -6)
    knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
    knob.BorderSizePixel = 0
    knob.Parent = slider
    
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
    
    local function update(pos)
        local relX = math.clamp((pos.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
        local val = minVal + relX * (maxVal - minVal)
        val = math.floor(val * 10) / 10
        label.Text = text .. ": " .. tostring(val)
        fill.Size = UDim2.new(relX, 0, 1, 0)
        knob.Position = UDim2.new(relX, -6, 0.5, -6)
        callback(val)
    end
    
    RunService.RenderStepped:Connect(function()
        if dragging then
            local touchPos = UserInputService:GetTouchPositions()[1]
            if touchPos then update(touchPos) end
        end
    end)
end

function toggleFly()
    flyEnabled = not flyEnabled
    local char = player.Character
    if not char then return end
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    if flyEnabled then
        humanoid.PlatformStand = true
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
        bodyVelocity.Parent = char:FindFirstChild("HumanoidRootPart")
        
        bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
        bodyGyro.CFrame = char:FindFirstChild("HumanoidRootPart").CFrame
        bodyGyro.Parent = char:FindFirstChild("HumanoidRootPart")
        
        if flyConnection then flyConnection:Disconnect() end
        flyConnection = RunService.RenderStepped:Connect(function()
            if not flyEnabled or not bodyVelocity or not char or not char:FindFirstChild("HumanoidRootPart") then return end
            local cam = workspace.CurrentCamera
            local cf = cam.CFrame
            local moveDir = (cf.LookVector * flyControl.Forward) + (cf.RightVector * flyControl.Right) + (Vector3.new(0, flyControl.Up, 0))
            if moveDir.Magnitude > 0 then moveDir = moveDir.Unit end
            bodyVelocity.Velocity = moveDir * flySpeed
            if bodyGyro then
                bodyGyro.CFrame = cam.CFrame
            end
        end)
    else
        humanoid.PlatformStand = false
        if bodyVelocity then bodyVelocity:Destroy() end
        if bodyGyro then bodyGyro:Destroy() end
        bodyVelocity = nil
        bodyGyro = nil
        if flyConnection then flyConnection:Disconnect() end
    end
end

function toggleNoclip()
    if noclipEnabled then
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
                local floorCheck = workspace:Raycast(hrp.Position, Vector3.new(0, -3, 0), params)
                if floorCheck and floorCheck.Instance then
                    floorCheck.Instance.CanCollide = false
                    task.wait(0.1)
                    floorCheck.Instance.CanCollide = true
                end
            end
            
            if noclipCeiling then
                local params = RaycastParams.new()
                params.FilterDescendantsInstances = {char}
                params.FilterType = Enum.RaycastFilterType.Blacklist
                local ceilCheck = workspace:Raycast(hrp.Position, Vector3.new(0, 3, 0), params)
                if ceilCheck and ceilCheck.Instance then
                    ceilCheck.Instance.CanCollide = false
                    task.wait(0.1)
                    ceilCheck.Instance.CanCollide = true
                end
            end
        end)
    else
        if noclipConnection then noclipConnection:Disconnect() end
        local char = player.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

function createESP(instance, color, text)
    if espObjects[instance] then 
        if espObjects[instance].bill then espObjects[instance].bill:Destroy() end
        espObjects[instance] = nil
    end
    
    local bill = Instance.new("BillboardGui")
    bill.Size = UDim2.new(0, math.floor(4 * espSize), 0, math.floor(3 * espSize))
    bill.StudsOffset = Vector3.new(0, 2.5, 0)
    bill.AlwaysOnTop = true
    bill.Parent = instance
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1,0,1,0)
    frame.BackgroundTransparency = 0.5
    frame.BackgroundColor3 = color
    frame.BorderSizePixel = 0
    frame.Parent = bill
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1,0,0.5,0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = text
    nameLabel.TextColor3 = Color3.fromRGB(255,255,255)
    nameLabel.TextScaled = true
    nameLabel.Parent = frame
    
    local hpBar = nil
    local distLabel = nil
    
    if espHP then
        hpBar = Instance.new("Frame")
        hpBar.Size = UDim2.new(1,0,0.2,0)
        hpBar.Position = UDim2.new(0,0,0.8,0)
        hpBar.BackgroundColor3 = Color3.fromRGB(0,255,0)
        hpBar.BorderSizePixel = 0
        hpBar.Parent = frame
    end
    
    espObjects[instance] = {bill = bill, hpBar = hpBar, distLabel = distLabel, frame = frame, nameLabel = nameLabel}
    return bill
end

function updateESP()
    if not espEnabled then return end
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local rootPos = char.HumanoidRootPart.Position
    
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (plr.Character.HumanoidRootPart.Position - rootPos).Magnitude
            local humanoid = plr.Character:FindFirstChild("Humanoid")
            local hpPercent = humanoid and (humanoid.Health / humanoid.MaxHealth) or 1
            
            if not espObjects[plr.Character] then
                createESP(plr.Character, Color3.fromRGB(255,0,0), plr.Name)
            else
                local data = espObjects[plr.Character]
                if data.bill then
                    data.bill.Size = UDim2.new(0, math.floor(4 * espSize), 0, math.floor(3 * espSize))
                end
                if espDistance and data.distLabel then
                    data.distLabel.Text = math.floor(dist) .. "m"
                elseif espDistance and not data.distLabel then
                    data.distLabel = Instance.new("TextLabel")
                    data.distLabel.Size = UDim2.new(1,0,0.3,0)
                    data.distLabel.Position = UDim2.new(0,0,0,0)
                    data.distLabel.BackgroundTransparency = 1
                    data.distLabel.Text = math.floor(dist) .. "m"
                    data.distLabel.TextColor3 = Color3.fromRGB(255,255,0)
                    data.distLabel.TextScaled = true
                    data.distLabel.Parent = data.frame
                elseif not espDistance and data.distLabel then
                    data.distLabel:Destroy()
                    data.distLabel = nil
                end
                
                if espHP and data.hpBar then
                    data.hpBar.Size = UDim2.new(hpPercent, 0, 0.2, 0)
                    data.hpBar.BackgroundColor3 = Color3.fromRGB(255 * (1 - hpPercent), 255 * hpPercent, 0)
                elseif espHP and not data.hpBar then
                    data.hpBar = Instance.new("Frame")
                    data.hpBar.Size = UDim2.new(hpPercent, 0, 0.2, 0)
                    data.hpBar.Position = UDim2.new(0,0,0.8,0)
                    data.hpBar.BackgroundColor3 = Color3.fromRGB(255 * (1 - hpPercent), 255 * hpPercent, 0)
                    data.hpBar.BorderSizePixel = 0
                    data.hpBar.Parent = data.frame
                elseif not espHP and data.hpBar then
                    data.hpBar:Destroy()
                    data.hpBar = nil
                end
            end
        elseif espObjects[plr.Character] then
            espObjects[plr.Character].bill:Destroy()
            espObjects[plr.Character] = nil
        end
    end
    
    if espChestEnabled then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and (obj.Name:lower():find("chest") or obj.Name:lower():find("treasure") or obj.Name:lower():find("crate") or obj.Name:lower():find("suitcase")) then
                if not espObjects[obj] then
                    createESP(obj, Color3.fromRGB(255,165,0), obj.Name)
                elseif espObjects[obj].bill then
                    espObjects[obj].bill.Size = UDim2.new(0, math.floor(4 * espSize), 0, math.floor(3 * espSize))
                end
            end
        end
    end
    
    if espMobEnabled then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and not Players:GetPlayerFromCharacter(obj) then
                if not espObjects[obj] then
                    createESP(obj, Color3.fromRGB(0,255,0), obj.Name)
                elseif espObjects[obj].bill then
                    espObjects[obj].bill.Size = UDim2.new(0, math.floor(4 * espSize), 0, math.floor(3 * espSize))
                end
            end
        end
    end
end

function startESP()
    if espConnection then espConnection:Disconnect() end
    espConnection = RunService.RenderStepped:Connect(updateESP)
end

function stopESP()
    if espConnection then espConnection:Disconnect() end
    for obj, data in pairs(espObjects) do
        if data.bill then data.bill:Destroy() end
    end
    espObjects = {}
end

screenGui.Parent = CoreGui
screenGui.Name = "VanezyScriptGUI"
createMainUI()
createLoadingScreen()

player.CharacterAdded:Connect(function()
    task.wait(0.5)
    if flyEnabled then toggleFly() end
    if noclipEnabled then toggleNoclip() end
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = autoRun and autoRunSpeed or (speedHack and speedValue or walkSpeedValue)
        player.Character.Humanoid.JumpPower = jumpPower
    end
end)

print("Vanezy Universal Script v1.0 FULL загружен")
