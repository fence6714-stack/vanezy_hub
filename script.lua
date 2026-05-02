-- Vanezy UI (Studio / Dev Tool)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

------------------------------------------------
-- GUI
------------------------------------------------
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "VanezyUI"

------------------------------------------------
-- WHITE LOADING (NO BACKGROUND)
------------------------------------------------
local loadText = Instance.new("TextLabel", gui)
loadText.Size = UDim2.new(0,200,0,50)
loadText.Position = UDim2.new(0.5,-100,0.5,-25)
loadText.BackgroundTransparency = 1
loadText.Text = "loading..."
loadText.TextColor3 = Color3.new(1,1,1)
loadText.TextTransparency = 1
loadText.TextScaled = true

TweenService:Create(loadText, TweenInfo.new(0.5), {
    TextTransparency = 0
}):Play()

task.wait(1.5)

TweenService:Create(loadText, TweenInfo.new(0.5), {
    TextTransparency = 1
}):Play()

task.wait(0.6)
loadText:Destroy()

------------------------------------------------
-- MAIN MENU
------------------------------------------------
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,260,0,180)
frame.Position = UDim2.new(0.1,0,0.3,0)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.BackgroundTransparency = 1

TweenService:Create(frame, TweenInfo.new(0.5), {
    BackgroundTransparency = 0
}):Play()

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Text = "Vanezy Dev Menu"
title.TextColor3 = Color3.new(1,1,1)

------------------------------------------------
-- CLOSE
------------------------------------------------
local close = Instance.new("TextButton", frame)
close.Size = UDim2.new(0,30,0,30)
close.Position = UDim2.new(1,-30,0,0)
close.Text = "X"
close.BackgroundColor3 = Color3.fromRGB(200,0,0)

close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

------------------------------------------------
-- MINIMIZE
------------------------------------------------
local mini = Instance.new("TextButton", frame)
mini.Size = UDim2.new(0,30,0,30)
mini.Position = UDim2.new(1,-60,0,0)
mini.Text = "-"
mini.BackgroundColor3 = Color3.fromRGB(120,120,120)

local minimized = false

mini.MouseButton1Click:Connect(function()
    minimized = not minimized

    if minimized then
        frame.Size = UDim2.new(0,260,0,30)
        toggleESP.Visible = false
    else
        frame.Size = UDim2.new(0,260,0,180)
        toggleESP.Visible = true
    end
end)

------------------------------------------------
-- ESP TOGGLE (DEV ONLY)
------------------------------------------------
local ESPEnabled = false

local toggleESP = Instance.new("TextButton", frame)
toggleESP.Size = UDim2.new(0,220,0,40)
toggleESP.Position = UDim2.new(0.5,-110,0.5,0)
toggleESP.Text = "ESP OFF"
toggleESP.BackgroundColor3 = Color3.fromRGB(200,0,0)

local function getPart(char)
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
end

local function addESP(plr, char)
    if not ESPEnabled then return end
    if char:FindFirstChild("DEV_ESP") then return end

    local h = Instance.new("Highlight")
    h.Name = "DEV_ESP"
    h.FillColor = Color3.fromRGB(0,255,0)
    h.OutlineColor = Color3.new(1,1,1)
    h.Parent = char

    local part = getPart(char)
    if not part then return end

    local bb = Instance.new("BillboardGui", part)
    bb.Size = UDim2.new(0,120,0,50)
    bb.AlwaysOnTop = true

    local text = Instance.new("TextLabel", bb)
    text.Size = UDim2.new(1,0,1,0)
    text.BackgroundTransparency = 1
    text.TextColor3 = Color3.new(1,1,1)
    text.TextScaled = true

    RunService.RenderStepped:Connect(function()
        if char and char:FindFirstChild("Humanoid") and Character and Character:FindFirstChild("HumanoidRootPart") then
            local hp = math.floor(char.Humanoid.Health)
            local dist = math.floor((part.Position - Character.HumanoidRootPart.Position).Magnitude)

            text.Text = plr.Name ..
            "\nHP: "..hp..
            "\nDist: "..dist
        end
    end)
end

toggleESP.MouseButton1Click:Connect(function()
    ESPEnabled = not ESPEnabled

    if ESPEnabled then
        toggleESP.Text = "ESP ON"
        toggleESP.BackgroundColor3 = Color3.fromRGB(0,200,0)
    else
        toggleESP.Text = "ESP OFF"
        toggleESP.BackgroundColor3 = Color3.fromRGB(200,0,0)
    end

    for _,p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            addESP(p, p.Character)
        end
    end
end)

------------------------------------------------
-- PLAYER HOOK
------------------------------------------------
for _,p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        p.CharacterAdded:Connect(function(char)
            task.wait(1)
            addESP(p, char)
        end)
    end
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function(char)
        task.wait(1)
        addESP(p, char)
    end)
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
end)
