--[[
    TWKS SYNAPSE UI v6 - DELTA COMPATIBLE
    NO: getrawmetatable, setreadonly, __index hooks, CoreGui issues
    FULL pcall protection
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
if not player then
    player = Players.PlayerAdded:Wait()
end

-- =========== SAFE STORAGE ==========
local StorageValues = Instance.new("Folder")
StorageValues.Name = "UISettings"
pcall(function() StorageValues.Parent = player end)

local function loadValue(name, default)
    local success, val = pcall(function() return StorageValues:GetAttribute(name) end)
    if success and val ~= nil then return val end
    return default
end

local function saveValue(name, value)
    pcall(function() StorageValues:SetAttribute(name, value) end)
end

-- Load settings
local savedWalkSpeed = loadValue("WalkSpeed", 16)
local savedJumpPower = loadValue("JumpPower", 50)
local savedFOV = loadValue("FOV", 70)
local savedAutoWalk = loadValue("AutoWalk", false)
local savedESP = loadValue("ESP", false)
local savedSpeedHack = loadValue("SpeedHack", false)
local savedNoclip = loadValue("Noclip", false)
local savedFly = loadValue("Fly", false)
local savedInfiniteJump = loadValue("InfiniteJump", false)
local savedWalkspeedValue = loadValue("WalkspeedValue", 50)
local savedJumppowerValue = loadValue("JumppowerValue", 80)

-- State
local autoWalkEnabled = savedAutoWalk
local autoWalkConnection = nil
local espEnabled = savedESP
local espHighlights = {}
local speedHackEnabled = savedSpeedHack
local noclipEnabled = savedNoclip
local flyEnabled = savedFly
local infiniteJumpEnabled = savedInfiniteJump
local currentWalkspeedValue = savedWalkspeedValue
local currentJumppowerValue = savedJumppowerValue

-- Fly variables
local flyBodyVel = nil
local flyBodyGyro = nil
local flyConnection = nil
local keysPressed = {}

-- Noclip connection
local noclipConnection = nil

-- Infinite jump connection
local infiniteJumpConnection = nil

-- Character variables
local character = nil
local humanoid = nil
local camera = nil

-- Menu toggle
local menuVisible = true

-- Keyboard state
pcall(function()
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        keysPressed[input.KeyCode.Name] = true
        
        -- RightAlt toggle menu
        if input.KeyCode == Enum.KeyCode.RightAlt then
            menuVisible = not menuVisible
            if ScreenGui then
                ScreenGui.Enabled = menuVisible
            end
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input, gpe)
        keysPressed[input.KeyCode.Name] = false
    end)
end)

local function getChar()
    pcall(function()
        local char = player.Character
        if char then
            character = char
            local hum = char:FindFirstChild("Humanoid")
            if hum then
                humanoid = hum
                if speedHackEnabled then
                    humanoid.WalkSpeed = currentWalkspeedValue
                else
                    humanoid.WalkSpeed = savedWalkSpeed
                end
                if infiniteJumpEnabled then
                    humanoid.JumpPower = currentJumppowerValue
                else
                    humanoid.JumpPower = savedJumpPower
                end
            end
        end
        if Workspace.CurrentCamera then
            camera = Workspace.CurrentCamera
            camera.FieldOfView = savedFOV
        end
    end)
end

pcall(getChar)

pcall(function()
    if not character then
        character = player.CharacterAdded:Wait()
        humanoid = character:WaitForChild("Humanoid")
        humanoid.WalkSpeed = speedHackEnabled and currentWalkspeedValue or savedWalkSpeed
        humanoid.JumpPower = infiniteJumpEnabled and currentJumppowerValue or savedJumpPower
    end
    if not camera then
        camera = Workspace.CurrentCamera
        if camera then
            camera.FieldOfView = savedFOV
        end
    end
end)

-- =========== SPEED HACK ==========
local function applySpeedHack(state)
    pcall(function()
        local char = player.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then
                if state then
                    hum.WalkSpeed = currentWalkspeedValue
                else
                    hum.WalkSpeed = savedWalkSpeed
                end
            end
        end
    end)
end

-- =========== NOCLIP ==========
local function toggleNoclip(state)
    pcall(function()
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        if state then
            noclipConnection = RunService.Stepped:Connect(function()
                if not noclipEnabled then return end
                local char = player.Character
                if not char then return end
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        pcall(function() part.CanCollide = false end)
                    end
                end
            end)
        end
    end)
end

-- =========== FLY ==========
local function toggleFly(state)
    pcall(function()
        if flyConnection then
            flyConnection:Disconnect()
            flyConnection = nil
        end
        if flyBodyVel then
            flyBodyVel:Destroy()
            flyBodyVel = nil
        end
        if flyBodyGyro then
            flyBodyGyro:Destroy()
            flyBodyGyro = nil
        end
        
        flyEnabled = state
        
        if not state then return end
        
        local char = player.Character
        if not char then
            char = player.CharacterAdded:Wait()
        end
        
        task.wait(0.15)
        
        if not char then return end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        flyBodyVel = Instance.new("BodyVelocity")
        flyBodyVel.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        flyBodyVel.P = 1e4
        flyBodyVel.Parent = hrp
        
        flyBodyGyro = Instance.new("BodyGyro")
        flyBodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
        flyBodyGyro.P = 1e5
        flyBodyGyro.Parent = hrp
        
        flyConnection = RunService.RenderStepped:Connect(function()
            if not flyEnabled then return end
            local currentChar = player.Character
            if not currentChar then return end
            local hrpCurrent = currentChar:FindFirstChild("HumanoidRootPart")
            if not hrpCurrent then return end
            
            if not flyBodyVel or not flyBodyGyro then return end
            
            local moveVector = Vector3.new(
                (keysPressed["D"] and 1 or 0) - (keysPressed["A"] and 1 or 0),
                (keysPressed["E"] and 1 or 0) - (keysPressed["Q"] and 1 or 0),
                (keysPressed["W"] and 1 or 0) - (keysPressed["S"] and 1 or 0)
            )
            
            if moveVector.Magnitude > 0 then
                moveVector = moveVector.Unit
            end
            
            local cam = Workspace.CurrentCamera
            if cam then
                local vel = (cam.CFrame.RightVector * moveVector.X + 
                            cam.CFrame.UpVector * moveVector.Y + 
                            cam.CFrame.LookVector * moveVector.Z) * 80
                flyBodyVel.Velocity = vel
                flyBodyGyro.CFrame = cam.CFrame
            end
        end)
    end)
end

-- =========== INFINITE JUMP ==========
local function toggleInfiniteJump(state)
    pcall(function()
        if infiniteJumpConnection then
            infiniteJumpConnection:Disconnect()
            infiniteJumpConnection = nil
        end
        if state then
            infiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
                local char = player.Character
                if char then
                    local hum = char:FindFirstChild("Humanoid")
                    if hum and hum:GetState() ~= Enum.HumanoidStateType.Jumping then
                        hum:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end
            end)
        end
    end)
end

-- =========== ESP (SIMPLIFIED, NO HIGHLIGHT) ==========
local function updateESP()
    pcall(function()
        if not espEnabled then
            for _, hl in pairs(espHighlights) do
                if hl then pcall(function() hl:Destroy() end) end
            end
            espHighlights = {}
            return
        end
        
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= player then
                local char = plr.Character
                if char then
                    local rootPart = char:FindFirstChild("HumanoidRootPart")
                    if rootPart then
                        local existing = espHighlights[plr.UserId]
                        if not existing or existing.Parent ~= char then
                            if existing then pcall(function() existing:Destroy() end) end
                            
                            local billboard = Instance.new("BillboardGui")
                            billboard.Size = UDim2.new(0, 200, 0, 40)
                            billboard.StudsOffset = Vector3.new(0, 2.5, 0)
                            billboard.AlwaysOnTop = true
                            billboard.Parent = rootPart
                            
                            local nameLabel = Instance.new("TextLabel")
                            nameLabel.Text = plr.Name
                            nameLabel.Font = Enum.Font.GothamBold
                            nameLabel.TextSize = 14
                            nameLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
                            nameLabel.BackgroundTransparency = 1
                            nameLabel.Size = UDim2.new(1, 0, 1, 0)
                            nameLabel.TextStrokeTransparency = 0.3
                            nameLabel.Parent = billboard
                            
                            espHighlights[plr.UserId] = billboard
                        end
                    end
                else
                    if espHighlights[plr.UserId] then
                        pcall(function() espHighlights[plr.UserId]:Destroy() end)
                        espHighlights[plr.UserId] = nil
                    end
                end
            end
        end
    end)
end

-- ESP update loop (throttled)
local lastESPUpdate = 0
local ESP_INTERVAL = 0.3

pcall(function()
    RunService.Heartbeat:Connect(function(dt)
        lastESPUpdate = lastESPUpdate + dt
        if lastESPUpdate >= ESP_INTERVAL then
            lastESPUpdate = 0
            updateESP()
        end
    end)
end)

-- =========== CREATE GUI (SAFE) ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TWKS_Menu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Enabled = true

-- Try multiple parents
local guiParent = nil
pcall(function() guiParent = player:WaitForChild("PlayerGui", 2) end)
if not guiParent then
    pcall(function() guiParent = game:GetService("CoreGui") end)
end
if not guiParent then
    pcall(function() guiParent = game:GetService("StarterGui") end)
end
if guiParent then
    pcall(function() ScreenGui.Parent = guiParent end)
end

-- Small loading indicator
local loadingText = Instance.new("TextLabel")
loadingText.Text = "TWKS v6 LOADED"
loadingText.Font = Enum.Font.GothamBold
loadingText.TextSize = 18
loadingText.TextColor3 = Color3.fromRGB(0, 180, 255)
loadingText.BackgroundTransparency = 1
loadingText.Size = UDim2.new(0, 200, 0, 40)
loadingText.Position = UDim2.new(0.5, -100, 0.5, -20)
loadingText.Parent = ScreenGui
task.wait(1.5)
pcall(function() loadingText:Destroy() end)

-- =========== MAIN MENU (SIMPLIFIED, STABLE) ==========
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 400, 0, 450)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Color3.fromRGB(0, 130, 230)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Text = "TWKS SYNAPSE v6"
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 16
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.BackgroundTransparency = 1
TitleText.Size = UDim2.new(1, -80, 1, 0)
TitleText.Position = UDim2.new(0, 15, 0, 0)
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 35, 1, -6)
CloseBtn.Position = UDim2.new(1, -40, 0, 3)
CloseBtn.Text = "X"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TitleBar
pcall(function()
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
end)

local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, -20, 1, -55)
ScrollingFrame.Position = UDim2.new(0, 10, 0, 45)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 500)
ScrollingFrame.ScrollBarThickness = 4
ScrollingFrame.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.Padding = UDim.new(0, 8)
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Parent = ScrollingFrame

-- Simple toggle function
local function addToggle(text, yOffset, defaultValue, onChange)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 45)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    frame.BorderSizePixel = 0
    frame.Parent = ScrollingFrame
    
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 6)
    frameCorner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Text = text
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 60, 0, 32)
    btn.Position = UDim2.new(1, -72, 0.5, -16)
    btn.Text = defaultValue and "ON" or "OFF"
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundColor3 = defaultValue and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(60, 60, 70)
    btn.BorderSizePixel = 0
    btn.Parent = frame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = btn
    
    local state = defaultValue
    
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = state and "ON" or "OFF"
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(60, 60, 70)
        if onChange then onChange(state) end
    end)
    
    if onChange and defaultValue then
        task.spawn(function() onChange(defaultValue) end)
    end
    
    return btn
end

local function addSlider(text, minVal, maxVal, defaultVal, onChange)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 65)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    frame.BorderSizePixel = 0
    frame.Parent = ScrollingFrame
    
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 6)
    frameCorner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Text = text .. " [" .. tostring(defaultVal) .. "]"
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, -20, 0, 25)
    label.Position = UDim2.new(0, 10, 0, 5)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -24, 0, 6)
    bar.Position = UDim2.new(0, 12, 0, 42)
    bar.BackgroundColor3 = Color3.fromRGB(45, 45, 53)
    bar.BorderSizePixel = 0
    bar.Parent = frame
    
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(1, 0)
    barCorner.Parent = bar
    
    local ratio = (defaultVal - minVal) / (maxVal - minVal)
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(ratio, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    fill.BorderSizePixel = 0
    fill.Parent = bar
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill
    
    local currentVal = defaultVal
    
    local function updateSlider(input)
        local barPos = bar.AbsolutePosition
        local barSize = bar.AbsoluteSize
        if not barPos or not barSize then return end
        
        local percent = (input.Position.X - barPos.X) / barSize.X
        percent = math.clamp(percent, 0, 1)
        
        local val = minVal + (maxVal - minVal) * percent
        val = math.floor(val * 10 + 0.5) / 10
        
        fill.Size = UDim2.new(percent, 0, 1, 0)
        label.Text = text .. " [" .. tostring(val) .. "]"
        currentVal = val
        if onChange then onChange(val) end
    end
    
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            updateSlider(input)
        end
    end)
    
    local dragging = false
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateSlider(input)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    if onChange then onChange(defaultVal) end
    
    return {
        setValue = function(val)
            local r = (val - minVal) / (maxVal - minVal)
            r = math.clamp(r, 0, 1)
            fill.Size = UDim2.new(r, 0, 1, 0)
            label.Text = text .. " [" .. tostring(val) .. "]"
            currentVal = val
            if onChange then onChange(val) end
        end
    }
end

-- =========== BUILD MENU ==========
addToggle("Auto Walk", 0, autoWalkEnabled, function(state)
    autoWalkEnabled = state
    saveValue("AutoWalk", state)
    if autoWalkConnection then autoWalkConnection:Disconnect() end
    if autoWalkEnabled then
        autoWalkConnection = RunService.Heartbeat:Connect(function()
            local char = player.Character
            if not char then return end
            local hum = char:FindFirstChild("Humanoid")
            local root = char:FindFirstChild("HumanoidRootPart")
            if not hum or not root then return end
            if hum.MoveDirection.Magnitude < 0.1 then
                local dir = root.CFrame.LookVector * Vector3.new(1, 0, 1)
                if dir.Magnitude > 0.01 then
                    hum:Move(dir.Unit, false)
                end
            end
        end)
    end
end)

addSlider("Walk Speed", 8, 100, savedWalkSpeed, function(val)
    saveValue("WalkSpeed", val)
    local char = player.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum and not speedHackEnabled then hum.WalkSpeed = val end
    end
end)

addToggle("Speed Hack", 0, speedHackEnabled, function(state)
    speedHackEnabled = state
    saveValue("SpeedHack", state)
    applySpeedHack(state)
end)

addSlider("Speed Value", 20, 250, currentWalkspeedValue, function(val)
    currentWalkspeedValue = val
    saveValue("WalkspeedValue", val)
    if speedHackEnabled then applySpeedHack(true) end
end)

addToggle("Noclip", 0, noclipEnabled, function(state)
    noclipEnabled = state
    saveValue("Noclip", state)
    toggleNoclip(state)
end)

addToggle("Fly", 0, flyEnabled, function(state)
    flyEnabled = state
    saveValue("Fly", state)
    toggleFly(state)
end)

addToggle("Infinite Jump", 0, infiniteJumpEnabled, function(state)
    infiniteJumpEnabled = state
    saveValue("InfiniteJump", state)
    toggleInfiniteJump(state)
    local char = player.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            hum.JumpPower = infiniteJumpEnabled and currentJumppowerValue or savedJumpPower
        end
    end
end)

addSlider("Jump Value", 30, 200, currentJumppowerValue, function(val)
    currentJumppowerValue = val
    saveValue("JumppowerValue", val)
    if infiniteJumpEnabled then
        local char = player.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then hum.JumpPower = val end
        end
    end
end)

addToggle("ESP Players", 0, espEnabled, function(state)
    espEnabled = state
    saveValue("ESP", state)
    updateESP()
end)

addSlider("FOV", 30, 120, savedFOV, function(val)
    saveValue("FOV", val)
    if camera then camera.FieldOfView = val end
end)

-- =========== RESPAWN HANDLER ==========
player.CharacterAdded:Connect(function(newChar)
    task.wait(0.2)
    character = newChar
    humanoid = newChar:FindFirstChild("Humanoid")
    camera = Workspace.CurrentCamera
    
    if humanoid then
        if speedHackEnabled then
            humanoid.WalkSpeed = currentWalkspeedValue
        else
            humanoid.WalkSpeed = loadValue("WalkSpeed", 16)
        end
        if infiniteJumpEnabled then
            humanoid.JumpPower = currentJumppowerValue
        else
            humanoid.JumpPower = loadValue("JumpPower", 50)
        end
    end
    if camera then
        camera.FieldOfView = loadValue("FOV", 70)
    end
    
    if flyEnabled then
        task.wait(0.15)
        toggleFly(true)
    end
    if noclipEnabled then
        toggleNoclip(true)
    end
    if infiniteJumpEnabled then
        toggleInfiniteJump(true)
    end
    
    -- Clean ESP
    for _, v in pairs(espHighlights) do
        pcall(function() v:Destroy() end)
    end
    espHighlights = {}
end)

-- =========== DRAG SYSTEM ==========
local dragging = false
local dragPos = nil

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragPos = input.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragPos
        MainFrame.Position = UDim2.new(
            MainFrame.Position.X.Scale,
            MainFrame.Position.X.Offset + delta.X,
            MainFrame.Position.Y.Scale,
            MainFrame.Position.Y.Offset + delta.Y
        )
        dragPos = input.Position
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- =========== INIT ==========
if autoWalkEnabled then
    autoWalkConnection = RunService.Heartbeat:Connect(function()
        local char = player.Character
        if not char then return end
        local hum = char:FindFirstChild("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if not hum or not root then return end
        if hum.MoveDirection.Magnitude < 0.1 then
            local dir = root.CFrame.LookVector * Vector3.new(1, 0, 1)
            if dir.Magnitude > 0.01 then
                hum:Move(dir.Unit, false)
            end
        end
    end)
end

if noclipEnabled then toggleNoclip(true) end
if flyEnabled then toggleFly(true) end
if infiniteJumpEnabled then toggleInfiniteJump(true) end
if speedHackEnabled then applySpeedHack(true) end

print("✅ TWKS v6 LOADED | Delta Compatible | RightAlt toggles menu")
