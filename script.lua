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
    end
end)

-- AutoWalk
local walking = false

walkBtn.MouseButton1Click:Connect(function()
    walking = not walking

    if walking then
        walkBtn.Text = "AutoWalk ON"
        walkBtn.BackgroundColor3 = Color3.fromRGB(0,200,0)
    else
        walkBtn.Text = "AutoWalk OFF"
        walkBtn.BackgroundColor3 = Color3.fromRGB(255,0,0)
    end
end)

RunService.RenderStepped:Connect(function()
    if walking and Character and Character:FindFirstChild("Humanoid") then
        Character.Humanoid:Move(Vector3.new(0,0,-1), true)
    end
end)

-- Обновление персонажа после смерти
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
end)
