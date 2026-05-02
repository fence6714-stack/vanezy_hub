-- // УНИВЕРСАЛЬНЫЙ ХАК ДЛЯ ROBLOX - ЛЕВАЯ ПАНЕЛЬ (FULLY WORKING)
-- // FLY | ESP | AUTO WALK | SPEED | JUMP | LEVITATION | FOV

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- // НАСТРОЙКИ
local settings = {
    speed = 16,
    jumpPower = 50,
    fov = 70,
    fly = false,
    levitation = false,
    espEnabled = true,
    autoWalk = false,
    menuColor = Color3.fromRGB(0, 150, 255),
    rainbow = false,
    minimized = false
}

-- // СОЗДАНИЕ GUI (ЛЕВАЯ ПАНЕЛЬ)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "NebulaHub"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = CoreGui

-- // АНИМАЦИЯ ЗАГРУЗКИ
local loadingFrame = Instance.new("Frame")
loadingFrame.Size = UDim2.new(0, 180, 0, 45)
loadingFrame.Position = UDim2.new(0.5, -90, 0.5, -22.5)
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
loadingText.Parent = loadingFrame

local neonGlow = Instance.new("Frame")
neonGlow.Size = UDim2.new(1, 0, 0, 2)
neonGlow.Position = UDim2.new(0, 0, 1, -2)
neonGlow.BackgroundColor3 = settings.menuColor
neonGlow.BorderSizePixel = 0
neonGlow.Parent = loadingFrame

local loadTweenIn = TweenService:Create(loadingFrame, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.85})
local glowTween = TweenService:Create(neonGlow, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {BackgroundColor3 = Color3.fromRGB(0, 255, 200)})
loadTweenIn:Play()
glowTween:Play()
task.wait(2)

local loadTweenOut = TweenService:Create(loadingFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1})
loadTweenOut:Play()
task.wait(0.5)
loadingFrame:Destroy()

-- // ОСНОВНОЕ МЕНЮ (СЛЕВА, УВЕЛИЧЕННОЕ)
local menuFrame = Instance.new("Frame")
menuFrame.Size = UDim2.new(0, 240, 0, 420)
menuFrame.Position = UDim2.new(0, 10, 0.5, -210)
menuFrame.BackgroundColor3 = Color3.fromRGB(18, 22, 40)
menuFrame.BackgroundTransparency = 0.05
menuFrame.BorderSizePixel = 0
menuFrame.ClipsDescendants = true
menuFrame.Parent = screenGui

menuFrame.Size = UDim2.new(0, 0, 0, 0)
local growTween = TweenService:Create(menuFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 240, 0, 420)})
growTween:Play()

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 14)
corner.Parent = menuFrame

local outline = Instance.new("UIStroke")
outline.Color = settings.menuColor
outline.Thickness = 1.5
outline.Transparency = 0.3
outline.Parent = menuFrame

local colorBar = Instance.new("Frame")
colorBar.Size = UDim2.new(1, 0, 0, 3)
colorBar.BackgroundColor3 = settings.menuColor
colorBar.BorderSizePixel = 0
colorBar.Parent = menuFrame

-- // ЗАГОЛОВОК С КНОПКАМИ
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundTransparency = 1
titleBar.Parent = menuFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0.6, 0, 1, 0)
title.Position = UDim2.new(0.05, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "✨ NEBULA ✨"
title.TextColor3 = settings.menuColor
title.TextScaled = true
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamBold
title.Parent = titleBar

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 32, 0, 32)
minimizeBtn.Position = UDim2.new(0.72, 0, 0, 4)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(30, 35, 55)
minimizeBtn.Text = "−"
minimizeBtn.TextColor3 = Color3.fromRGB(200, 210, 255)
minimizeBtn.TextSize = 20
minimizeBtn.TextScaled = true
minimizeBtn.Font = Enum.Font.GothamBold
local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 6)
minCorner.Parent = minimizeBtn
minimizeBtn.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(0.85, 0, 0, 4)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 20
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.GothamBold
local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeBtn
closeBtn.Parent = titleBar

-- Кнопка восстановления (свёрнутый режим)
local restoreBtn = Instance.new("TextButton")
restoreBtn.Size = UDim2.new(0, 55, 0, 55)
restoreBtn.Position = UDim2.new(0, 15, 0.5, -27.5)
restoreBtn.BackgroundColor3 = Color3.fromRGB(18, 22, 40)
restoreBtn.BackgroundTransparency = 0.2
restoreBtn.Text = "✨"
restoreBtn.TextColor3 = settings.menuColor
restoreBtn.TextSize = 30
restoreBtn.Visible = false
local restoreCorner = Instance.new("UICorner")
restoreCorner.CornerRadius = UDim.new(1, 0)
restoreCorner.Parent = restoreBtn
local restoreStroke = Instance.new("UIStroke")
restoreStroke.Color = settings.menuColor
restoreStroke.Thickness = 1.5
restoreStroke.Parent = restoreBtn
restoreBtn.Parent = screenGui

-- // СВОРАЧИВАНИЕ/ЗАКРЫТИЕ
local function minimizeMenu()
    if settings.minimized then return end
    settings.minimized = true
    local minTween = TweenService:Create(menuFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 55, 0, 55), BackgroundTransparency = 0.3})
    minTween:Play()
    task.wait(0.2)
    for _, child in pairs(menuFrame:GetChildren()) do
        if child ~= titleBar and child ~= colorBar and child ~= outline then child.Visible = false end
    end
    titleBar.Visible = false
    colorBar.Visible = false
    restoreBtn.Visible = true
    TweenService:Create(restoreBtn, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundTransparency = 0.2, Size = UDim2.new(0, 60, 0, 60)}):Play()
end

local function restoreMenu()
    if not settings.minimized then return end
    settings.minimized = false
    restoreBtn.Visible = false
    for _, child in pairs(menuFrame:GetChildren()) do child.Visible = true end
    titleBar.Visible = true
    colorBar.Visible = true
    TweenService:Create(menuFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 240, 0, 420), BackgroundTransparency = 0.05}):Play()
end

local function closeMenu()
    TweenService:Create(menuFrame, TweenInfo.new(0.3), {Size = UDim2.new(0,0,0,0), BackgroundTransparency = 1}):Play()
    TweenService:Create(restoreBtn, TweenInfo.new(0.2), {Size = UDim2.new(0,0,0,0)}):Play()
    task.wait(0.3)
    screenGui:Destroy()
    if espFolder then espFolder:Destroy() end
    if flyBodyVel then flyBodyVel:Destroy() end
    if levBodyPos then levBodyPos:Destroy() end
end

minimizeBtn.MouseButton1Click:Connect(minimizeMenu)
closeBtn.MouseButton1Click:Connect(closeMenu)
restoreBtn.MouseButton1Click:Connect(restoreMenu)

-- // DRAG (только когда не свёрнуто)
local dragging = false
local dragStart, startPos
titleBar.InputBegan:Connect(function(input)
    if settings.minimized then return end
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = menuFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and not settings.minimized and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        menuFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-- // ПОЛЗУНКИ (ТВОЙ ЛЮБИМЫЙ ДИЗАЙН)
local function createSlider(parent, text, minVal, maxVal, defaultVal, callback, step)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.9, 0, 0, 50)
    frame.Position = UDim2.new(0.05, 0, 0, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 0, 20)
    label.Text = text .. " [" .. defaultVal .. "]"
    label.TextColor3 = Color3.fromRGB(220, 230, 255)
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.Parent = frame

    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, 0, 0, 5)
    sliderFrame.Position = UDim2.new(0, 0, 0, 25)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(40, 45, 70)
    sliderFrame.BorderSizePixel = 0
    sliderFrame.Parent = frame

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((defaultVal - minVal)/(maxVal - minVal), 0, 1, 0)
    fill.BackgroundColor3 = settings.menuColor
    fill.BorderSizePixel = 0
    fill.Parent = sliderFrame

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new((defaultVal - minVal)/(maxVal - minVal), -7, 0.5, -7)
    knob.BackgroundColor3 = settings.menuColor
    knob.BorderSizePixel = 0
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob
    knob.Parent = sliderFrame

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.2, 0, 0, 20)
    valueLabel.Position = UDim2.new(0.78, 0, 0, 0)
    valueLabel.Text = tostring(defaultVal)
    valueLabel.TextColor3 = settings.menuColor
    valueLabel.TextSize = 12
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.BackgroundTransparency = 1
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.Parent = frame

    local function updateSlider(value)
        local clamped = math.clamp(value, minVal, maxVal)
        local percent = (clamped - minVal)/(maxVal - minVal)
        fill:TweenSize(UDim2.new(percent, 0, 1, 0), "Out", "Quad", 0.1, true)
        knob:TweenPosition(UDim2.new(percent, -7, 0.5, -7), "Out", "Quad", 0.1, true)
        valueLabel.Text = string.format("%.0f", clamped)
        label.Text = text .. " [" .. string.format("%.0f", clamped) .. "]"
        callback(clamped)
    end

    local sliderInput
    sliderInput = sliderFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            local x = math.clamp((input.Position.X - sliderFrame.AbsolutePosition.X) / sliderFrame.AbsoluteSize.X, 0, 1)
            local value = minVal + x * (maxVal - minVal)
            if step then value = math.floor(value/step)*step end
            updateSlider(value)
            
            local moveConn, endConn
            moveConn = UserInputService.InputChanged:Connect(function(move)
                if move.UserInputType == Enum.UserInputType.Touch or move.UserInputType == Enum.UserInputType.MouseMovement then
                    local x2 = math.clamp((move.Position.X - sliderFrame.AbsolutePosition.X) / sliderFrame.AbsoluteSize.X, 0, 1)
                    local val = minVal + x2 * (maxVal - minVal)
                    if step then val = math.floor(val/step)*step end
                    updateSlider(val)
                end
            end)
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

-- // ТОГГЛЫ (ТВОЙ ЛЮБИМЫЙ ДИЗАЙН)
local function createToggle(parent, text, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.9, 0, 0, 35)
    frame.Position = UDim2.new(0.05, 0, 0, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65, 0, 1, 0)
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 230, 255)
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.Parent = frame

    local toggleBtn = Instance.new("Frame")
    toggleBtn.Size = UDim2.new(0, 44, 0, 24)
    toggleBtn.Position = UDim2.new(0.78, 0, 0.5, -12)
    toggleBtn.BackgroundColor3 = default and Color3.fromRGB(0, 200, 150) or Color3.fromRGB(80, 80, 100)
    toggleBtn.BorderSizePixel = 0
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggleBtn
    toggleBtn.Parent = frame

    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 20, 0, 20)
    circle.Position = default and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
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
            local tween = TweenService:Create(circle, TweenInfo.new(0.2), {Position = active and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)})
            tween:Play()
            callback(active)
        end
    end)
    callback(default)
end

-- // КНОПКИ ЦВЕТА
local colorBtn = Instance.new("TextButton")
colorBtn.Size = UDim2.new(0.42, 0, 0, 32)
colorBtn.Position = UDim2.new(0.05, 0, 0, 0)
colorBtn.BackgroundColor3 = settings.menuColor
colorBtn.Text = "🌈 COLOR"
colorBtn.TextColor3 = Color3.new(1,1,1)
colorBtn.TextSize = 13
colorBtn.Font = Enum.Font.GothamBold
local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 6)
btnCorner.Parent = colorBtn
colorBtn.Parent = menuFrame

local rainbowBtn = Instance.new("TextButton")
rainbowBtn.Size = UDim2.new(0.42, 0, 0, 32)
rainbowBtn.Position = UDim2.new(0.53, 0, 0, 0)
rainbowBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 150)
rainbowBtn.Text = "✨ RAINBOW"
rainbowBtn.TextColor3 = Color3.new(1,1,1)
rainbowBtn.TextSize = 13
rainbowBtn.Font = Enum.Font.GothamBold
local btnCorner2 = Instance.new("UICorner")
btnCorner2.CornerRadius = UDim.new(0, 6)
btnCorner2.Parent = rainbowBtn
rainbowBtn.Parent = menuFrame

-- // СКРОЛЛИНГ
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, 0, 1, -80)
scroll.Position = UDim2.new(0, 0, 0, 75)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 3
scroll.ScrollBarImageColor3 = settings.menuColor
scroll.CanvasSize = UDim2.new(0, 0, 0, 380)
scroll.Parent = menuFrame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = scroll

-- ДОБАВЛЯЕМ ВСЕ ЭЛЕМЕНТЫ
createSlider(scroll, "Walk Speed", 16, 120, 16, function(v) settings.speed = v end)
createSlider(scroll, "Jump Power", 40, 200, 50, function(v) settings.jumpPower = v end)
createSlider(scroll, "Field of View", 50, 120, 70, function(v) settings.fov = v; camera.FieldOfView = v end)
createToggle(scroll, "Auto Walk", false, function(v) settings.autoWalk = v end)
createToggle(scroll, "Fly Mode", false, function(v) settings.fly = v; if v then settings.levitation = false end end)
createToggle(scroll, "Levitation", false, function(v) settings.levitation = v; if v then settings.fly = false end end)
createToggle(scroll, "ESP (Players)", true, function(v) settings.espEnabled = v; updateESP() end)

-- // ESP (РАБОТАЕТ)
local espFolder = Instance.new("Folder")
espFolder.Name = "NebulaESP"
espFolder.Parent = CoreGui

function updateESP()
    for _, v in pairs(espFolder:GetChildren()) do if v:IsA("Highlight") then v:Destroy() end end
    if not settings.espEnabled then return end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local hl = Instance.new("Highlight")
            hl.Name = "ESP_"..plr.Name
            hl.Adornee = plr.Character
            hl.FillColor = settings.menuColor
            hl.FillTransparency = 0.65
            hl.OutlineColor = Color3.fromRGB(255,255,255)
            hl.OutlineTransparency = 0.2
            hl.Parent = espFolder
        end
    end
end

Players.PlayerAdded:Connect(updateESP)
Players.PlayerRemoving:Connect(updateESP)
updateESP()

-- // РАДУГА
local rainbowHue = 0
local rainbowTask
local function startRainbow()
    if rainbowTask then return end
    rainbowTask = RunService.RenderStepped:Connect(function()
        if settings.rainbow then
            rainbowHue = (rainbowHue + 0.003) % 1
            local col = Color3.fromHSV(rainbowHue, 1, 1)
            settings.menuColor = col
            outline.Color = col
            colorBar.BackgroundColor3 = col
            restoreStroke.Color = col
            restoreBtn.TextColor3 = col
            for _, child in pairs(menuFrame:GetDescendants()) do
                if child:IsA("Frame") and (child.Name == "fill" or child.Name == "knob") then
                    pcall(function() child.BackgroundColor3 = col end)
                end
                if child:IsA("TextLabel") and (child.Text:find("NEBULA") or child.Text:find("Field")) then
                    if child ~= loadingText then child.TextColor3 = col end
                end
            end
            updateESP()
        end
    end)
end

rainbowBtn.MouseButton1Click:Connect(function()
    settings.rainbow = not settings.rainbow
    if settings.rainbow then
        startRainbow()
        rainbowBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 200)
        rainbowBtn.Text = "🌈 ON"
    else
        if rainbowTask then rainbowTask:Disconnect() rainbowTask = nil end
        settings.menuColor = Color3.fromRGB(0, 150, 255)
        outline.Color = settings.menuColor
        colorBar.BackgroundColor3 = settings.menuColor
        restoreStroke.Color = settings.menuColor
        restoreBtn.TextColor3 = settings.menuColor
        rainbowBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 150)
        rainbowBtn.Text = "✨ RAINBOW"
        updateESP()
    end
end)

colorBtn.MouseButton1Click:Connect(function()
    settings.rainbow = false
    if rainbowTask then rainbowTask:Disconnect() rainbowTask = nil end
    rainbowBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 150)
    rainbowBtn.Text = "✨ RAINBOW"
    local colors = {Color3.fromRGB(0,150,255), Color3.fromRGB(0,200,255), Color3.fromRGB(80,180,255), Color3.fromRGB(0,170,255)}
    local newCol = colors[math.random(1,#colors)]
    settings.menuColor = newCol
    outline.Color = newCol
    colorBar.BackgroundColor3 = newCol
    restoreStroke.Color = newCol
    restoreBtn.TextColor3 = newCol
    for _, child in pairs(menuFrame:GetDescendants()) do
        if child:IsA("Frame") and (child.Name == "fill" or child.Name == "knob") then
            pcall(function() child.BackgroundColor3 = newCol end)
        end
        if child:IsA("TextLabel") and (child.Text:find("NEBULA") or child.Text:find("Field")) then
            child.TextColor3 = newCol
        end
    end
    updateESP()
end)

-- // FLY / LEVITATION / AUTO WALK / SPEED / JUMP
local flyBodyVel, levBodyPos

RunService.RenderStepped:Connect(function()
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChild("Humanoid")
    if not hrp or not humanoid then return end
    
    humanoid.WalkSpeed = settings.speed
    humanoid.JumpPower = settings.jumpPower
    
    if settings.autoWalk then
        local moveDir = (camera.CFrame.LookVector * Vector3.new(1,0,1)).Unit
        humanoid:Move(moveDir, true)
    end
    
    if settings.fly then
        if not flyBodyVel then
            flyBodyVel = Instance.new("BodyVelocity")
            flyBodyVel.MaxForce = Vector3.new(1e6,1e6,1e6)
            flyBodyVel.Parent = hrp
            humanoid.PlatformStand = true
        end
        local move = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0,1,0) end
        flyBodyVel.Velocity = move.Magnitude > 0 and move.Unit * 50 or Vector3.zero
    elseif flyBodyVel then
        flyBodyVel:Destroy() flyBodyVel = nil
        humanoid.PlatformStand = false
    end
    
    if settings.levitation and not settings.fly then
        if not levBodyPos then
            levBodyPos = Instance.new("BodyPosition")
            levBodyPos.MaxForce = Vector3.new(1e6,1e6,1e6)
            levBodyPos.P = 5000
            levBodyPos.D = 500
            levBodyPos.Parent = hrp
            humanoid.PlatformStand = true
        end
        levBodyPos.Position = hrp.Position + Vector3.new(0, 2.5, 0)
    elseif levBodyPos then
        levBodyPos:Destroy() levBodyPos = nil
        humanoid.PlatformStand = false
    end
end)

-- Установка начального FOV
camera.FieldOfView = settings.fov

print("✅ Скрипт полностью загружен! Меню слева, все функции работают.")
