-- Vanezy Dev Menu (Studio / Admin Tool)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

------------------------------------------------
-- GUI
------------------------------------------------
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "VanezyDevUI"

------------------------------------------------
-- LOADING
------------------------------------------------
local load = Instance.new("Frame", gui)
load.Size = UDim2.new(0,220,0,60)
load.Position = UDim2.new(0.5,-110,0.5,-30)
load.BackgroundColor3 = Color3.fromRGB(20,20,20)

local loadText = Instance.new("TextLabel", load)
loadText.Size = UDim2.new(1,0,1,0)
loadText.BackgroundTransparency = 1
loadText.Text = "loading..."
loadText.TextColor3 = Color3.new(1,1,1)
loadText.TextScaled = true
loadText.TextTransparency = 1

TweenService:Create(loadText, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
task.wait(1.5)

TweenService:Create(loadText, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
TweenService:Create(load, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()

task.wait(0.6)
load:Destroy()

------------------------------------------------
-- MENU
------------------------------------------------
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,280,0,200)
frame.Position = UDim2.new(0.1,0,0.3,0)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Text = "Vanezy Dev Menu"
title.TextColor3 = Color3.new(1,1,1)

local close = Instance.new("TextButton", frame)
close.Size = UDim2.new(0,30,0,30)
close.Position = UDim2.new(1,-30,0,0)
close.Text = "X"
close.BackgroundColor3 = Color3.fromRGB(200,0,0)

local mini = Instance.new("TextButton", frame)
mini.Size = UDim2.new(0,30,0,30)
mini.Position = UDim2.new(1,-60,0,0)
mini.Text = "-"
mini.BackgroundColor3 = Color3.fromRGB(120,120,120)

------------------------------------------------
-- AUTO WALK
------------------------------------------------
local walkBtn = Instance.new("TextButton", frame)
walkBtn.Size = UDim2.new(0,220,0,35)
walkBtn.Position = UDim2.new(0.5,-110,0.75,0)
walkBtn.Text = "AutoWalk OFF"
walkBtn.BackgroundColor3 = Color3.fromRGB(200,0,0)

local walking = false

walkBtn.MouseButton1Click:Connect(function()
    walking = not walking

    if walking then
        walkBtn.Text = "AutoWalk ON"
        walkBtn.BackgroundColor3 = Color3.fromRGB(0,200,0)
    else
        walkBtn.Text = "AutoWalk OFF"
        walkBtn.BackgroundColor3 = Color3.fromRGB(200,0,0)
    end
end)

------------------------------------------------
-- DRAG
------------------------------------------------
local dragging, startPos, dragStart

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch) then

        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

------------------------------------------------
-- CLOSE / MINIMIZE
------------------------------------------------
close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

local minimized = false
mini.MouseButton1Click:Connect(function()
    minimized = not minimized

    if minimized then
        frame.Size = UDim2.new(0,280,0,30)
        walkBtn.Visible = false
    else
        frame.Size = UDim2.new(0,280,0,200)
        walkBtn.Visible = true
    end
end)

------------------------------------------------
-- ESP SYSTEM (DEV ONLY)
------------------------------------------------
local function getPart(char)
    return char:FindFirstChild("HumanoidRootPart")
        or char:FindFirstChild("Head")
end

local function addESP(player, char)
    if char:FindFirstChild("DevESP") then return end

    local h = Instance.new("Highlight")
    h.Name = "DevESP"
    h.FillColor = Color3.fromRGB(0,255,0)
    h.OutlineColor = Color3.new(1,1,1)
    h.Parent = char

    local part = getPart(char)
    if not part then return end

    local gui = Instance.new("BillboardGui", part)
    gui.Name = "Info"
    gui.Size = UDim2.new(0,120,0,50)
    gui.AlwaysOnTop = true

    local label = Instance.new("TextLabel", gui)
    label.Size = UDim2.new(1,0,1,0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1,1,1)
    label.TextScaled = true

    RunService.RenderStepped:Connect(function()
        if char and part and player.Character and player.Character:FindFirstChild("Humanoid") then
            local hp = math.floor(player.Character.Humanoid.Health)
            local dist = math.floor((part.Position - Character.HumanoidRootPart.Position).Magnitude)

            label.Text = player.Name ..
            "\nHP: " .. hp ..
            "\nDist: " .. dist
        end
    end)
end

for _,p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer and p.Character then
        addESP(p, p.Character)
    end

    p.CharacterAdded:Connect(function(char)
        task.wait(1)
        addESP(p, char)
    end)
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function(char)
        task.wait(1)
        addESP(p, char)
    end)
end)

------------------------------------------------
-- AUTOWALK LOOP
------------------------------------------------
RunService.RenderStepped:Connect(function()
    if walking and Character and Character:FindFirstChild("Humanoid") then
        Character.Humanoid:Move(Vector3.new(0,0,-1), true)
    end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
end)
