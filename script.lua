--[[
  POSITION TRACKER + NOCLIP + SPEED
  Vanezy Mobile Tool
--]]

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Parent = CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 280, 0, 320)
mainFrame.Position = UDim2.new(0.5, -140, 0.5, -160)
mainFrame.BackgroundColor3 = Color3.fromRGB(30,30,40)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 40)
topBar.BackgroundColor3 = Color3.fromRGB(50,50,60)
topBar.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 1, 0)
title.BackgroundTransparency = 1
title.Text = "POSITION TRACKER"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.Parent = topBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 40, 1, 0)
closeBtn.Position = UDim2.new(1, -40, 0, 0)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255,100,100)
closeBtn.TextSize = 18
closeBtn.Parent = topBar

local dragStart, dragPos
topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragStart = input.Position
        dragPos = mainFrame.Position
    end
end)
topBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch and dragStart then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(dragPos.X.Scale, dragPos.X.Offset + delta.X, dragPos.Y.Scale, dragPos.Y.Offset + delta.Y)
    end
end)
topBar.InputEnded:Connect(function()
    dragStart = nil
end)

-- Позиция
local posFrame = Instance.new("Frame")
posFrame.Size = UDim2.new(0.9, 0, 0, 80)
posFrame.Position = UDim2.new(0.05, 0, 0.15, 0)
posFrame.BackgroundColor3 = Color3.fromRGB(40,40,50)
posFrame.BorderSizePixel = 0
posFrame.Parent = mainFrame

local posLabel = Instance.new("TextLabel")
posLabel.Size = UDim2.new(1, 0, 0.5, 0)
posLabel.Position = UDim2.new(0, 0, 0, 0)
posLabel.BackgroundTransparency = 1
posLabel.Text = "X: 0.00"
posLabel.TextColor3 = Color3.fromRGB(255,255,255)
posLabel.TextSize = 18
posLabel.Font = Enum.Font.GothamBold
posLabel.Parent = posFrame

local posYLabel = Instance.new("TextLabel")
posYLabel.Size = UDim2.new(1, 0, 0.5, 0)
posYLabel.Position = UDim2.new(0, 0, 0.5, 0)
posYLabel.BackgroundTransparency = 1
posYLabel.Text = "Y: 0.00  Z: 0.00"
posYLabel.TextColor3 = Color3.fromRGB(200,200,200)
posYLabel.TextSize = 14
posYLabel.Font = Enum.Font.Gotham
posYLabel.Parent = posFrame

local getPosBtn = Instance.new("TextButton")
getPosBtn.Size = UDim2.new(0.8, 0, 0, 45)
getPosBtn.Position = UDim2.new(0.1, 0, 0.42, 0)
getPosBtn.BackgroundColor3 = Color3.fromRGB(0,120,200)
getPosBtn.Text = "УЗНАТЬ ПОЗИЦИЮ"
getPosBtn.TextColor3 = Color3.fromRGB(255,255,255)
getPosBtn.TextSize = 14
getPosBtn.Font = Enum.Font.GothamBold
getPosBtn.Parent = mainFrame

local copyBtn = Instance.new("TextButton")
copyBtn.Size = UDim2.new(0.8, 0, 0, 45)
copyBtn.Position = UDim2.new(0.1, 0, 0.55, 0)
copyBtn.BackgroundColor3 = Color3.fromRGB(80,80,100)
copyBtn.Text = "СКОПИРОВАТЬ ПОЗИЦИЮ"
copyBtn.TextColor3 = Color3.fromRGB(255,255,255)
copyBtn.TextSize = 14
copyBtn.Font = Enum.Font.GothamBold
copyBtn.Parent = mainFrame

local lastPosition = {X = 0, Y = 0, Z = 0}

getPosBtn.MouseButton1Click:Connect(function()
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local pos = hrp.Position
    lastPosition = {X = pos.X, Y = pos.Y, Z = pos.Z}
    posLabel.Text = string.format("X: %.2f", pos.X)
    posYLabel.Text = string.format("Y: %.2f  Z: %.2f", pos.Y, pos.Z)
end)

copyBtn.MouseButton1Click:Connect(function()
    local textToCopy = string.format("Vector3.new(%.2f, %.2f, %.2f)", lastPosition.X, lastPosition.Y, lastPosition.Z)
    setclipboard or toclipboard or (function() end)
    if setclipboard then
        setclipboard(textToCopy)
    elseif toclipboard then
        toclipboard(textToCopy)
    end
    copyBtn.Text = "СКОПИРОВАНО!"
    task.wait(1)
    copyBtn.Text = "СКОПИРОВАТЬ ПОЗИЦИЮ"
end)

-- NOCLIP
local noclipFrame = Instance.new("Frame")
noclipFrame.Size = UDim2.new(0.9, 0, 0, 45)
noclipFrame.Position = UDim2.new(0.05, 0, 0.7, 0)
noclipFrame.BackgroundColor3 = Color3.fromRGB(40,40,50)
noclipFrame.BorderSizePixel = 0
noclipFrame.Parent = mainFrame

local noclipBtn = Instance.new("TextButton")
noclipBtn.Size = UDim2.new(0.9, 0, 0.8, 0)
noclipBtn.Position = UDim2.new(0.05, 0, 0.1, 0)
noclipBtn.BackgroundColor3 = Color3.fromRGB(255,50,50)
noclipBtn.Text = "NOCLIP: ВЫКЛ"
noclipBtn.TextColor3 = Color3.fromRGB(255,255,255)
noclipBtn.TextSize = 14
noclipBtn.Font = Enum.Font.GothamBold
noclipBtn.Parent = noclipFrame

local noclipEnabled = false
local noclipConnection = nil

local function updateNoclip()
    if noclipEnabled then
        if noclipConnection then noclipConnection:Disconnect() end
        noclipConnection = RunService.RenderStepped:Connect(function()
            local char = player.Character
            if not char then return end
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
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

noclipBtn.MouseButton1Click:Connect(function()
    noclipEnabled = not noclipEnabled
    if noclipEnabled then
        noclipBtn.BackgroundColor3 = Color3.fromRGB(50,200,50)
        noclipBtn.Text = "NOCLIP: ВКЛ"
    else
        noclipBtn.BackgroundColor3 = Color3.fromRGB(255,50,50)
        noclipBtn.Text = "NOCLIP: ВЫКЛ"
    end
    updateNoclip()
end)

-- SPEED
local speedFrame = Instance.new("Frame")
speedFrame.Size = UDim2.new(0.9, 0, 0, 60)
speedFrame.Position = UDim2.new(0.05, 0, 0.85, 0)
speedFrame.BackgroundColor3 = Color3.fromRGB(40,40,50)
speedFrame.BorderSizePixel = 0
speedFrame.Parent = mainFrame

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.8, 0, 0.35, 0)
speedLabel.Position = UDim2.new(0.05, 0, 0.1, 0)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Скорость: 16"
speedLabel.TextColor3 = Color3.fromRGB(255,255,255)
speedLabel.TextSize = 12
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = speedFrame

local speedSlider = Instance.new("Frame")
speedSlider.Size = UDim2.new(0.85, 0, 0, 4)
speedSlider.Position = UDim2.new(0.05, 0, 0.55, 0)
speedSlider.BackgroundColor3 = Color3.fromRGB(80,80,90)
speedSlider.BorderSizePixel = 0
speedSlider.Parent = speedFrame

local speedFill = Instance.new("Frame")
speedFill.Size = UDim2.new(0, 0, 1, 0)
speedFill.BackgroundColor3 = Color3.fromRGB(0,200,0)
speedFill.BorderSizePixel = 0
speedFill.Parent = speedSlider

local speedKnob = Instance.new("Frame")
speedKnob.Size = UDim2.new(0, 12, 0, 12)
speedKnob.Position = UDim2.new(0, -6, 0.5, -6)
speedKnob.BackgroundColor3 = Color3.fromRGB(255,255,255)
speedKnob.BorderSizePixel = 0
speedKnob.Parent = speedSlider

local speedValue = 16
local minSpeed = 16
local maxSpeed = 500
local draggingSpeed = false

local function updateSpeedUI(val)
    local rel = (val - minSpeed) / (maxSpeed - minSpeed)
    speedFill.Size = UDim2.new(rel, 0, 1, 0)
    speedKnob.Position = UDim2.new(rel, -6, 0.5, -6)
    speedLabel.Text = "Скорость: " .. math.floor(val)
end

local function applySpeed(val)
    speedValue = val
    updateSpeedUI(val)
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = val
    end
end

speedKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        draggingSpeed = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        draggingSpeed = false
    end
end)

local RunService = game:GetService("RunService")
RunService.RenderStepped:Connect(function()
    if draggingSpeed then
        local touches = UserInputService:GetTouchPositions()
        if #touches > 0 then
            local relX = math.clamp((touches[1].X - speedSlider.AbsolutePosition.X) / speedSlider.AbsoluteSize.X, 0, 1)
            local val = minSpeed + relX * (maxSpeed - minSpeed)
            val = math.floor(val)
            applySpeed(val)
        end
    end
end)

applySpeed(16)

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
    if noclipEnabled then
        noclipEnabled = false
        updateNoclip()
    end
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = 16
    end
end)

player.CharacterAdded:Connect(function()
    task.wait(0.5)
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = speedValue
    end
    if noclipEnabled then updateNoclip() end
end)

print("POSITION TRACKER LOADED")
