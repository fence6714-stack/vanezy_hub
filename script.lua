-- Vanezy GUI + AutoWalk

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

-- GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "VanezyMenu"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 250, 0, 150)
frame.Position = UDim2.new(0.1, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)

-- Title
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Text = "Vanezy Script"
title.TextColor3 = Color3.new(1,1,1)

-- Close
local close = Instance.new("TextButton", frame)
close.Size = UDim2.new(0,30,0,30)
close.Position = UDim2.new(1,-30,0,0)
close.Text = "X"
close.BackgroundColor3 = Color3.fromRGB(200,0,0)

-- Minimize
local minimize = Instance.new("TextButton", frame)
minimize.Size = UDim2.new(0,30,0,30)
minimize.Position = UDim2.new(1,-60,0,0)
minimize.Text = "-"
minimize.BackgroundColor3 = Color3.fromRGB(100,100,100)

-- AutoWalk button
local walkBtn = Instance.new("TextButton", frame)
walkBtn.Size = UDim2.new(0,200,0,40)
walkBtn.Position = UDim2.new(0.5,-100,0.5,0)
walkBtn.Text = "AutoWalk OFF"
walkBtn.BackgroundColor3 = Color3.fromRGB(255,0,0)

-- DRAG (мобилка + ПК)
local dragging, dragInput, dragStart, startPos

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- Close
close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- Minimize
local minimized = false
minimize.MouseButton1Click:Connect(function()
    minimized = not minimized

    if minimized then
        frame.Size = UDim2.new(0,250,0,30)
        walkBtn.Visible = false
    else
        frame.Size = UDim2.new(0,250,0,150)
        walkBtn.Visible = true
-- Vanezy UI System (safe version for Roblox Studio)

local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

-- GUI
local gui = Instance.new("ScreenGui")
gui.Parent = game.CoreGui
gui.Name = "VanezyUI"

------------------------------------------------
-- LOADING
------------------------------------------------
local loadFrame = Instance.new("Frame", gui)
loadFrame.Size = UDim2.new(0, 220, 0, 60)
loadFrame.Position = UDim2.new(0.5, -110, 0.5, -30)
loadFrame.BackgroundColor3 = Color3.fromRGB(20,20,20)

local loadText = Instance.new("TextLabel", loadFrame)
loadText.Size = UDim2.new(1,0,1,0)
loadText.BackgroundTransparency = 1
loadText.Text = "loading..."
loadText.TextColor3 = Color3.new(1,1,1)
loadText.TextScaled = true

TweenService:Create(loadText, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
task.wait(2)

TweenService:Create(loadText, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
TweenService:Create(loadFrame, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()

task.wait(0.6)
loadFrame:Destroy()

------------------------------------------------
-- MAIN MENU
------------------------------------------------
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 260, 0, 160)
frame.Position = UDim2.new(0.1, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.BackgroundTransparency = 1

TweenService:Create(frame, TweenInfo.new(0.6), {
    BackgroundTransparency = 0
}):Play()

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Text = "Vanezy Script Menu"
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

local walkBtn = Instance.new("TextButton", frame)
walkBtn.Size = UDim2.new(0,200,0,40)
walkBtn.Position = UDim2.new(0.5,-100,0.6,0)
walkBtn.Text = "AutoWalk OFF"
walkBtn.BackgroundColor3 = Color3.fromRGB(200,0,0)

------------------------------------------------
-- DRAG SYSTEM
------------------------------------------------
local dragging, dragStart, startPos

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseMovement) then

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
        frame.Size = UDim2.new(0,260,0,30)
        walkBtn.Visible = false
    else
        frame.Size = UDim2.new(0,260,0,160)
        walkBtn.Visible = true
    end
end)

------------------------------------------------
-- AUTOWALK (DEMO)
------------------------------------------------
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

RunService.RenderStepped:Connect(function()
    if walking and Character and Character:FindFirstChild("Humanoid") then
        Character.Humanoid:Move(Vector3.new(0,0,-1), true)
    end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
end)
