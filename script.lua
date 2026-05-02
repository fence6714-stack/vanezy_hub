-- Vanezy Pro Dev UI (Studio version)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local lp = Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local cam = workspace.CurrentCamera

------------------------------------------------
-- GUI
------------------------------------------------
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "VanezyProUI"

------------------------------------------------
-- LOADING
------------------------------------------------
local load = Instance.new("TextLabel", gui)
load.Size = UDim2.new(0,220,0,50)
load.Position = UDim2.new(0.5,-110,0.5,-25)
load.BackgroundTransparency = 1
load.Text = "loading..."
load.TextColor3 = Color3.new(1,1,1)
load.TextScaled = true
load.TextTransparency = 1

TweenService:Create(load, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
task.wait(1.2)
TweenService:Create(load, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
task.wait(0.6)
load:Destroy()

------------------------------------------------
-- MAIN FRAME
------------------------------------------------
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,320,0,240)
frame.Position = UDim2.new(0.1,0,0.3,0)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.BorderSizePixel = 0

TweenService:Create(frame, TweenInfo.new(0.4), {
    BackgroundTransparency = 0
}):Play()

------------------------------------------------
-- TOP BAR
------------------------------------------------
local top = Instance.new("Frame", frame)
top.Size = UDim2.new(1,0,0,30)
top.BackgroundColor3 = Color3.fromRGB(30,30,30)

local title = Instance.new("TextLabel", top)
title.Size = UDim2.new(1,0,1,0)
title.BackgroundTransparency = 1
title.Text = "Vanezy Pro Menu"
title.TextColor3 = Color3.new(1,1,1)

------------------------------------------------
-- TABS
------------------------------------------------
local mainTab = Instance.new("TextButton", frame)
mainTab.Size = UDim2.new(0,160,0,25)
mainTab.Position = UDim2.new(0,0,0,30)
mainTab.Text = "Main"

local themeTab = Instance.new("TextButton", frame)
themeTab.Size = UDim2.new(0,160,0,25)
themeTab.Position = UDim2.new(0.5,0,0,30)
themeTab.Text = "Theme"

------------------------------------------------
-- MAIN PAGE
------------------------------------------------
local main = Instance.new("Frame", frame)
main.Size = UDim2.new(1,0,1,-55)
main.Position = UDim2.new(0,0,0,55)
main.BackgroundTransparency = 1

------------------------------------------------
-- THEME PAGE
------------------------------------------------
local theme = Instance.new("Frame", frame)
theme.Size = main.Size
theme.Position = main.Position
theme.BackgroundTransparency = 1
theme.Visible = false

------------------------------------------------
-- BUTTONS
------------------------------------------------
local function btn(text, y)
    local b = Instance.new("TextButton", main)
    b.Size = UDim2.new(0,280,0,30)
    b.Position = UDim2.new(0.5,-140,0,y)
    b.Text = text
    b.BackgroundColor3 = Color3.fromRGB(40,40,40)
    return b
end

local espBtn = btn("ESP OFF", 0)
local autoBtn = btn("AutoWalk OFF", 0.2)
local speedBtn = btn("Speed: 16", 0.4)
local jumpBtn = btn("Jump: 50", 0.6)
local fovBtn = btn("FOV: 70", 0.8)

------------------------------------------------
-- THEME BUTTONS
------------------------------------------------
local function tbtn(name, color, y)
    local b = Instance.new("TextButton", theme)
    b.Size = UDim2.new(0,280,0,30)
    b.Position = UDim2.new(0.5,-140,0,y)
    b.Text = name
    b.BackgroundColor3 = color

    b.MouseButton1Click:Connect(function()
        frame.BackgroundColor3 = color
    end)
end

tbtn("Red", Color3.fromRGB(120,0,0), 0)
tbtn("Blue", Color3.fromRGB(0,0,120), 0.2)
tbtn("Green", Color3.fromRGB(0,120,0), 0.4)
tbtn("Yellow", Color3.fromRGB(120,120,0), 0.6)

------------------------------------------------
-- SYSTEMS
------------------------------------------------
local ESP = false
local auto = false
local speed = 16
local jump = 50
local fov = 70

------------------------------------------------
-- TOGGLES
------------------------------------------------
espBtn.MouseButton1Click:Connect(function()
    ESP = not ESP
    espBtn.Text = ESP and "ESP ON" or "ESP OFF"
end)

autoBtn.MouseButton1Click:Connect(function()
    auto = not auto
    autoBtn.Text = auto and "AutoWalk ON" or "AutoWalk OFF"
end)

speedBtn.MouseButton1Click:Connect(function()
    speed += 4
    speedBtn.Text = "Speed: "..speed
    if char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = speed
    end
end)

jumpBtn.MouseButton1Click:Connect(function()
    jump += 10
    jumpBtn.Text = "Jump: "..jump
    if char:FindFirstChild("Humanoid") then
        char.Humanoid.JumpPower = jump
    end
end)

fovBtn.MouseButton1Click:Connect(function()
    fov += 10
    if fov > 120 then fov = 70 end
    cam.FieldOfView = fov
    fovBtn.Text = "FOV: "..fov
end)

------------------------------------------------
-- TAB SWITCH
------------------------------------------------
mainTab.MouseButton1Click:Connect(function()
    main.Visible = true
    theme.Visible = false
end)

themeTab.MouseButton1Click:Connect(function()
    main.Visible = false
    theme.Visible = true
end)

------------------------------------------------
-- AUTOWALK
------------------------------------------------
RunService.RenderStepped:Connect(function()
    if auto and char and char:FindFirstChild("Humanoid") then
        char.Humanoid:Move(Vector3.new(0,0,-1), true)
    end
end)

------------------------------------------------
-- ESP (DEV SIMPLE)
------------------------------------------------
local function add(plr, c)
    if not ESP then return end
    if c:FindFirstChild("DEV") then return end

    local h = Instance.new("Highlight", c)
    h.Name = "DEV"
    h.FillColor = Color3.fromRGB(0,255,0)
end

for _,p in pairs(Players:GetPlayers()) do
    if p ~= lp then
        if p.Character then add(p, p.Character) end
        p.CharacterAdded:Connect(function(c)
            task.wait(1)
            add(p,c)
        end)
    end
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function(c)
        task.wait(1)
        add(p,c)
    end)
end)

lp.CharacterAdded:Connect(function(c)
    char = c
end)
