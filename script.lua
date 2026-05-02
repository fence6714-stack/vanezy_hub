-- Vanezy Pro Framework (Studio Safe)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera
local char = lp.Character or lp.CharacterAdded:Wait()

------------------------------------------------
-- GUI BASE
------------------------------------------------
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "VanezyProFramework"

------------------------------------------------
-- LOADING (CENTER + SMOOTH)
------------------------------------------------
local load = Instance.new("TextLabel", gui)
load.Size = UDim2.new(0,250,0,60)
load.Position = UDim2.new(0.5,0,0.5,0)
load.AnchorPoint = Vector2.new(0.5,0.5)
load.BackgroundTransparency = 1
load.Text = "loading..."
load.TextColor3 = Color3.new(1,1,1)
load.TextScaled = true
load.TextTransparency = 1

TweenService:Create(load, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
task.wait(1.3)
TweenService:Create(load, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
task.wait(0.5)
load:Destroy()

------------------------------------------------
-- MAIN WINDOW
------------------------------------------------
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0,340,0,260)
main.Position = UDim2.new(0.1,0,0.3,0)
main.BackgroundColor3 = Color3.fromRGB(25,25,25)
main.BorderSizePixel = 0

TweenService:Create(main, TweenInfo.new(0.4), {
    BackgroundTransparency = 0
}):Play()

------------------------------------------------
-- TOP BAR
------------------------------------------------
local top = Instance.new("Frame", main)
top.Size = UDim2.new(1,0,0,30)
top.BackgroundColor3 = Color3.fromRGB(35,35,35)

local title = Instance.new("TextLabel", top)
title.Size = UDim2.new(1,0,1,0)
title.BackgroundTransparency = 1
title.Text = "Vanezy Pro Framework"
title.TextColor3 = Color3.new(1,1,1)

------------------------------------------------
-- TABS
------------------------------------------------
local tabMain = Instance.new("TextButton", main)
tabMain.Size = UDim2.new(0,170,0,25)
tabMain.Text = "Main"

local tabTheme = Instance.new("TextButton", main)
tabTheme.Size = UDim2.new(0,170,0,25)
tabTheme.Position = UDim2.new(0.5,0,0,30)
tabTheme.Text = "Theme"

------------------------------------------------
-- PAGES
------------------------------------------------
local pageMain = Instance.new("Frame", main)
pageMain.Size = UDim2.new(1,0,1,-60)
pageMain.Position = UDim2.new(0,0,0,60)
pageMain.BackgroundTransparency = 1

local pageTheme = Instance.new("Frame", main)
pageTheme.Size = pageMain.Size
pageTheme.Position = pageMain.Position
pageTheme.BackgroundTransparency = 1
pageTheme.Visible = false

------------------------------------------------
-- TOGGLE FACTORY (UI STYLE)
------------------------------------------------
local function toggle(text, y, parent)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0,300,0,30)
    btn.Position = UDim2.new(0.5,-150,0,y)
    btn.Text = text .. ": OFF"
    btn.BackgroundColor3 = Color3.fromRGB(45,45,45)
    btn.TextColor3 = Color3.new(1,1,1)

    local state = false

    return btn, function(onText, offText, callback)
        btn.MouseButton1Click:Connect(function()
            state = not state
            btn.Text = state and (text..": ON") or (text..": OFF")
            callback(state)
        end)
    end
end

------------------------------------------------
-- MAIN FEATURES
------------------------------------------------
local espBtn, espToggle = toggle("ESP", 0, pageMain)
local autoBtn, autoToggle = toggle("AutoWalk", 0.15, pageMain)

local speedBtn, speedToggle = toggle("Speed +5", 0.3, pageMain)
local jumpBtn, jumpToggle = toggle("Jump +10", 0.45, pageMain)
local fovBtn, fovToggle = toggle("FOV Boost", 0.6, pageMain)

------------------------------------------------
-- STATES
------------------------------------------------
local ESP = false
local auto = false
local speed = 16
local jump = 50
local fov = 70

------------------------------------------------
-- APPLY LOGIC
------------------------------------------------
espBtn.MouseButton1Click:Connect(function()
    ESP = not ESP
end)

autoBtn.MouseButton1Click:Connect(function()
    auto = not auto
end)

speedBtn.MouseButton1Click:Connect(function()
    speed += 5
    if char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = speed
    end
end)

jumpBtn.MouseButton1Click:Connect(function()
    jump += 10
    if char:FindFirstChild("Humanoid") then
        char.Humanoid.JumpPower = jump
    end
end)

fovBtn.MouseButton1Click:Connect(function()
    fov += 10
    if fov > 120 then fov = 70 end
    cam.FieldOfView = fov
end)

------------------------------------------------
-- AUTO WALK LOOP
------------------------------------------------
RunService.RenderStepped:Connect(function()
    if auto and char and char:FindFirstChild("Humanoid") then
        char.Humanoid:Move(Vector3.new(0,0,-1), true)
    end
end)

------------------------------------------------
-- ESP (DEV SAFE)
------------------------------------------------
local function addESP(p, c)
    if not ESP then return end
    if c:FindFirstChild("ESP") then return end

    local h = Instance.new("Highlight", c)
    h.Name = "ESP"
    h.FillColor = Color3.fromRGB(0,255,0)
end

for _,p in pairs(Players:GetPlayers()) do
    if p ~= lp then
        p.CharacterAdded:Connect(function(c)
            task.wait(1)
            addESP(p,c)
        end)
    end
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function(c)
        task.wait(1)
        addESP(p,c)
    end)
end)

lp.CharacterAdded:Connect(function(c)
    char = c
end)

------------------------------------------------
-- TABS SWITCH
------------------------------------------------
tabMain.MouseButton1Click:Connect(function()
    pageMain.Visible = true
    pageTheme.Visible = false
end)

tabTheme.MouseButton1Click:Connect(function()
    pageMain.Visible = false
    pageTheme.Visible = true
end)

------------------------------------------------
-- THEME SYSTEM
------------------------------------------------
local function makeTheme(name, color, y)
    local b = Instance.new("TextButton", pageTheme)
    b.Size = UDim2.new(0,300,0,30)
    b.Position = UDim2.new(0.5,-150,0,y)
    b.Text = name
    b.BackgroundColor3 = color
    b.TextColor3 = Color3.new(1,1,1)

    b.MouseButton1Click:Connect(function()
        main.BackgroundColor3 = color
    end)
end

makeTheme("Red", Color3.fromRGB(120,0,0), 0)
makeTheme("Blue", Color3.fromRGB(0,0,120), 0.2)
makeTheme("Green", Color3.fromRGB(0,120,0), 0.4)
makeTheme("Yellow", Color3.fromRGB(120,120,0), 0.6)
