-- // УНИВЕРСАЛЬНЫЙ ХАК ДЛЯ ROBLOX (Mobile/PC)
-- // FLY | ESP | AUTO WALK | SPEED | JUMP | LEVITATION

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

-- // НАСТРОЙКИ
local settings = {
    speed = 16,
    jumpPower = 50,
    fly = false,
    levitation = false,
    espEnabled = true,
    autoWalk = false,
    menuColor = Color3.fromRGB(0, 150, 255),
    rainbow = false
}

-- // СОЗДАНИЕ GUI (МИНИ-МЕНЮ)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "NebulaHub"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = CoreGui

-- // АНИМАЦИЯ ЗАГРУЗКИ (LOADING...)
local loadingFrame = Instance.new("Frame")
loadingFrame.Size = UDim2.new(0, 160, 0, 40)
loadingFrame.Position = UDim2.new(0.5, -80, 0.5, -20)
loadingFrame.BackgroundColor3 = Color3.fromRGB(20, 25, 45)
loadingFrame.BackgroundTransparency = 1
loadingFrame.BorderSizePixel = 0
loadingFrame.ClipsDescendants = true
loadingFrame.Parent = screenGui

local loadingText = Instance.new("TextLabel")
loadingText.Size = UDim2.new(1, 0, 1, 0)
loadingText.BackgroundTransparency = 1
loadingText.Text = "loading..."
loadingText.TextColor3 = Color3.fromRGB(0, 200, 255)
loadingText.TextScaled = true
loadingText.Font = Enum.Font.GothamBold
loadingText.TextStrokeTransparency = 0.2
loadingText.Parent = loadingFrame

local neonGlow = Instance.new("Frame")
neonGlow.Size = UDim2.new(1, 0, 0, 2)
neonGlow.Position = UDim2.new(0, 0, 1, -2)
neonGlow.BackgroundColor3 = settings.menuColor
neonGlow.BorderSizePixel = 0
neonGlow.Parent = loadingFrame

-- Плавное появление
local loadTweenIn = TweenService:Create(loadingFrame, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.85})
local glowTween = TweenService:Create(neonGlow, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {BackgroundColor3 = Color3.fromRGB(0, 255, 200)})
loadTweenIn:Play()
glowTween:Play()
task.wait(2)

-- Плавное исчезновение загрузки и рост меню
local loadTweenOut = TweenService:Create(loadingFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1})
loadTweenOut:Play()
task.wait(0.5)
loadingFrame:Destroy()

-- // ОСНОВНОЕ МЕНЮ (теперь оно "вырастает")
local menuFrame = Instance.new("Frame")
menuFrame.Size = UDim2.new(0, 220, 0, 280)
menuFrame.Position = UDim2.new(0.5, -110, 0.6, -140)
menuFrame.BackgroundColor3 = Color3.fromRGB(18, 22, 40)
menuFrame.BackgroundTransparency = 0.1
menuFrame.BorderSizePixel = 0
menuFrame.ClipsDescendants = true
menuFrame.Parent = screenGui

-- Анимация роста
menuFrame.Size = UDim2.new(0, 0, 0, 0)
local growTween = TweenService:Create(menuFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 220, 0, 280)})
growTween:Play()

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = menuFrame

local outline = Instance.new("UIStroke")
outline.Color = settings.menuColor
outline.Thickness = 1.5
outline.Transparency = 0.3
outline.Parent = menuFrame

-- // ЦВЕТНАЯ ПОЛОСА (для радуги)
local colorBar = Instance.new("Frame")
colorBar.Size = UDim2.new(1, 0, 0, 3)
colorBar.Position = UDim2.new(0, 0, 0, 0)
colorBar.BackgroundColor3 = settings.menuColor
colorBar.BorderSizePixel = 0
colorBar.Parent = menuFrame

-- // ЗАГОЛОВОК ДЛЯ ПЕРЕТАСКИВАНИЯ (Mobile Drag)
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundTransparency = 1
titleBar.Parent = menuFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 1, 0)
title.BackgroundTransparency = 1
title.Text = "✨ NEBULA ✨"
title.TextColor3 = settings.menuColor
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = titleBar

-- Drag logic (для мобилы и ПК)
local dragging = false
local dragStart, startPos

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = menuFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        menuFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- // ФУНКЦИЯ СОЗДАНИЯ СЛАЙДЕРА
local function createSlider(parent, text, minVal, maxVal, defaultVal, callback, step)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.9, 0, 0, 45)
    frame.Position = UDim2.new(0.05, 0, 0, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 18)
    label.Text = text .. ": " .. defaultVal
    label.TextColor3 = Color3.fromRGB(200, 210, 255)
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.Parent = frame

    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, 0, 0, 4)
    sliderFrame.Position = UDim2.new(0, 0, 0, 22)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(40, 45, 70)
    sliderFrame.BorderSizePixel = 0
    sliderFrame.Parent = frame

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((defaultVal - minVal)/(maxVal - minVal), 0, 1, 0)
    fill.BackgroundColor3 = settings.menuColor
    fill.BorderSizePixel = 0
    fill.Parent = sliderFrame

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.Position = UDim2.new((defaultVal - minVal)/(maxVal - minVal), -6, 0.5, -6)
    knob.BackgroundColor3 = settings.menuColor
    knob.BorderSizePixel = 0
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob
    knob.Parent = sliderFrame

    local function updateSlider(value)
        local clamped = math.clamp(value, minVal, maxVal)
        local percent = (clamped - minVal)/(maxVal - minVal)
        fill.Size = UDim2.new(percent, 0, 1, 0)
        knob.Position = UDim2.new(percent, -6, 0.5, -6)
        label.Text = text .. ": " .. string.format("%.1f", clamped)
        callback(clamped)
    end

    local sliderInput
    sliderInput = sliderFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            local x = (input.Position.X - sliderFrame.AbsolutePosition.X) / sliderFrame.AbsoluteSize.X
            local value = minVal + x * (maxVal - minVal)
            if step then value = math.floor(value/step)*step end
            updateSlider(value)
            
            local moveConn
            moveConn = UserInputService.InputChanged:Connect(function(move)
                if move.UserInputType == Enum.UserInputType.Touch or move.UserInputType == Enum.UserInputType.MouseMovement then
                    local x2 = (move.Position.X - sliderFrame.AbsolutePosition.X) / sliderFrame.AbsoluteSize.X
                    local val = minVal + x2 * (maxVal - minVal)
                    if step then val = math.floor(val/step)*step end
                    updateSlider(val)
                end
            end)
            
            local endConn
            endConn = UserInputService.InputEnded:Connect(function(endInput)
                if endInput.UserInputType == Enum.UserInputType.Touch or endInput.UserInputType == Enum.UserInputType.MouseButton1 then
                    moveConn:Disconnect()
                    endConn:Disconnect()
                end
            end)
        end
    end)
    
    return updateSlider
end

-- // ТОГГЛЫ
local function createToggle(parent, text, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.9, 0, 0, 30)
    frame.Position = UDim2.new(0.05, 0, 0, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Text = text
    label.TextColor3 = Color3.fromRGB(200, 210, 255)
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.Parent = frame

    local toggleBtn = Instance.new("Frame")
    toggleBtn.Size = UDim2.new(0, 36, 0, 20)
    toggleBtn.Position = UDim2.new(0.85, 0, 0.5, -10)
    toggleBtn.BackgroundColor3 = default and Color3.fromRGB(0, 200, 150) or Color3.fromRGB(80, 80, 100)
    toggleBtn.BorderSizePixel = 0
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggleBtn
    toggleBtn.Parent = frame

    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 16, 0, 16)
    circle.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(1, 0)
    circleCorner.Parent = circle
    circle.Parent = toggleBtn

    local active = default
    toggleBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            active = not active
            toggleBtn.BackgroundColor3 = active and Color3.fromRGB(0, 200, 150) or Color3.fromRGB(80, 80, 100)
            local tween = TweenService:Create(circle, TweenInfo.new(0.2), {Position = active and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)})
            tween:Play()
            callback(active)
        end
    end)
    callback(default)
end

-- // КНОПКА ВЫБОРА ЦВЕТА
local colorBtn = Instance.new("TextButton")
colorBtn.Size = UDim2.new(0.42, 0, 0, 30)
colorBtn.Position = UDim2.new(0.05, 0, 0, 0)
colorBtn.BackgroundColor3 = settings.menuColor
colorBtn.Text = "🌈 COLOR"
colorBtn.TextColor3 = Color3.new(1,1,1)
colorBtn.TextSize = 12
colorBtn.Font = Enum.Font.GothamBold
local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 6)
btnCorner.Parent = colorBtn
colorBtn.Parent = menuFrame

local rainbowBtn = Instance.new("TextButton")
rainbowBtn.Size = UDim2.new(0.42, 0, 0, 30)
rainbowBtn.Position = UDim2.new(0.53, 0, 0, 0)
rainbowBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 150)
rainbowBtn.Text = "✨ RAINBOW"
rainbowBtn.TextColor3 = Color3.new(1,1,1)
rainbowBtn.TextSize = 12
rainbowBtn.Font = Enum.Font.GothamBold
local btnCorner2 = Instance.new("UICorner")
btnCorner2.CornerRadius = UDim.new(0, 6)
btnCorner2.Parent = rainbowBtn
rainbowBtn.Parent = menuFrame

-- Логика радуги
local rainbowHue = 0
local rainbowTask
local function startRainbow()
    if rainbowTask then return end
    rainbowTask = RunService.RenderStepped:Connect(function()
        if settings.rainbow then
            rainbowHue = (rainbowHue + 0.005) % 1
            local col = Color3.fromHSV(rainbowHue, 1, 1)
            settings.menuColor = col
            outline.Color = col
            colorBar.BackgroundColor3 = col
            for _, child in pairs(menuFrame:GetDescendants()) do
                if child:IsA("Frame") and (child.Name == "fill" or child.Name == "knob" or child.BackgroundColor3 == settings.menuColor) then
                    if child.Name ~= "colorBar" and child ~= colorBar then
                        pcall(function() child.BackgroundColor3 = col end)
                    end
                end
                if child:IsA("TextLabel") and child.Text:find("NEBULA") then
                    child.TextColor3 = col
                end
            end
            colorBar.BackgroundColor3 = col
        end
    end)
end

rainbowBtn.MouseButton1Click:Connect(function()
    settings.rainbow = not settings.rainbow
    if settings.rainbow then
        startRainbow()
        rainbowBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 200)
        rainbowBtn.Text = "🌈 RAINBOW ON"
    else
        if rainbowTask then rainbowTask:Disconnect() rainbowTask = nil end
        settings.menuColor = Color3.fromRGB(0, 150, 255)
        outline.Color = settings.menuColor
        colorBar.BackgroundColor3 = settings.menuColor
        rainbowBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 150)
        rainbowBtn.Text = "✨ RAINBOW"
    end
end)

colorBtn.MouseButton1Click:Connect(function()
    settings.rainbow = false
    if rainbowTask then rainbowTask:Disconnect() rainbowTask = nil end
    rainbowBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 150)
    rainbowBtn.Text = "✨ RAINBOW"
    -- Простой выбор предустановок
    local colors = {Color3.fromRGB(0,150,255), Color3.fromRGB(0,255,200), Color3.fromRGB(100,100,255), Color3.fromRGB(0,200,255)}
    local newCol = colors[(math.random(1,#colors))]
    settings.menuColor = newCol
    outline.Color = newCol
    colorBar.BackgroundColor3 = newCol
    for _, child in pairs(menuFrame:GetDescendants()) do
        if child:IsA("Frame") and (child.Name == "fill" or child.Name == "knob") then
            pcall(function() child.BackgroundColor3 = newCol end)
        end
        if child:IsA("TextLabel") and child.Text:find("NEBULA") then
            child.TextColor3 = newCol
        end
    end
end)

-- // СКРОЛЛИНГ ДЛЯ МЕНЮ
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, 0, 1, -40)
scroll.Position = UDim2.new(0, 0, 0, 35)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 3
scroll.ScrollBarImageColor3 = settings.menuColor
scroll.CanvasSize = UDim2.new(0, 0, 0, 280)
scroll.Parent = menuFrame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = scroll

-- Добавляем элементы
createSlider(scroll, "🔹 Speed", 16, 120, 16, function(v) settings.speed = v end)
createSlider(scroll, "🔸 Jump Power", 40, 200, 50, function(v) settings.jumpPower = v end)
createToggle(scroll, "🕊️ Fly Mode", false, function(v) settings.fly = v; if not v then settings.levitation = false end end)
createToggle(scroll, "🧘 Levitation", false, function(v) settings.levitation = v; if v then settings.fly = false end end)
createToggle(scroll, "🦿 Auto Walk", false, function(v) settings.autoWalk = v end)
createToggle(scroll, "👁️ ESP (Players)", true, function(v) settings.espEnabled = v end)

-- // ESP
local espFolder = Instance.new("Folder")
espFolder.Name = "NebulaESP"
espFolder.Parent = CoreGui

local function updateESP()
    for _, v in pairs(espFolder:GetChildren()) do if v:IsA("Highlight") then v:Destroy() end end
    if not settings.espEnabled then return end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local hl = Instance.new("Highlight")
            hl.Name = "ESP_"..plr.Name
            hl.Adornee = plr.Character
            hl.FillColor = settings.menuColor
            hl.FillTransparency = 0.7
            hl.OutlineColor = Color3.fromRGB(255,255,255)
            hl.Parent = espFolder
        end
    end
end

Players.PlayerAdded:Connect(updateESP)
Players.PlayerRemoving:Connect(updateESP)
updateESP()

-- // FLY/LEVITATION/SPEED/AUTOWALK
local flyVelocity = Vector3.new(0,0,0)
local flyBodyVel
local levBodyPos

RunService.RenderStepped:Connect(function(dt)
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChild("Humanoid")
    if not hrp or not humanoid then return end
    
    -- Speed
    humanoid.WalkSpeed = settings.speed
    humanoid.JumpPower = settings.jumpPower
    
    -- Auto Walk
    if settings.autoWalk then
        local moveDir = (camera.CFrame.LookVector * Vector3.new(1,0,1)).Unit
        humanoid:Move(moveDir, true)
    end
    
    -- Fly
    if settings.fly then
        if not flyBodyVel then
            flyBodyVel = Instance.new("BodyVelocity")
            flyBodyVel.MaxForce = Vector3.new(1e6,1e6,1e6)
            flyBodyVel.Parent = hrp
            humanoid.PlatformStand = true
        end
        local move = Vector3.new()
        local forward = camera.CFrame.LookVector
        local right = camera.CFrame.RightVector
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + forward end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - forward end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + right end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - right end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0,1,0) end
        if move.Magnitude > 0 then move = move.Unit * 50 end
        flyBodyVel.Velocity = move
    elseif flyBodyVel then
        flyBodyVel:Destroy() flyBodyVel = nil
        humanoid.PlatformStand = false
    end
    
    -- Levitation (удержание в воздухе)
    if settings.levitation and not settings.fly then
        if not levBodyPos then
            levBodyPos = Instance.new("BodyPosition")
            levBodyPos.MaxForce = Vector3.new(1e6,1e6,1e6)
            levBodyPos.P = 3000
            levBodyPos.Parent = hrp
            humanoid.PlatformStand = true
        end
        levBodyPos.Position = hrp.Position + Vector3.new(0, 2, 0)
    elseif levBodyPos then
        levBodyPos:Destroy() levBodyPos = nil
        humanoid.PlatformStand = false
    end
end)

-- Обновление ESP цвета при радуге
if rainbowTask then
    local oldFunc = rainbowTask
    rainbowTask = RunService.RenderStepped:Connect(function()
        if settings.rainbow then
            rainbowHue = (rainbowHue + 0.005) % 1
            settings.menuColor = Color3.fromHSV(rainbowHue, 1, 1)
            updateESP()
        end
    end)
end

-- Скрыть меню по кнопке (тап по заголовку или долгое нажатие)
local menuVisible = true
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch and input.UserInputState == Enum.UserInputState.Begin then
        task.wait(0.3)
        if UserInputService:GetFingerPositions()[1] then
            menuVisible = not menuVisible
            menuFrame.Visible = menuVisible
        end
    end
end)

print("✅ Скрипт загружен! Тап/клик по заголовку NEBULA - скрыть/показать меню.")
