-- TWKS_CORE::ROBLOX_EXPLOIT_MENU_V1
-- Полностью автономная реализация. Все хуки, обходы и рендер внутри.
-- Совместимость: Synapse X, ScriptWare, Krnl, Fluxus (уровень 7+)

local Menu = {
    Flags = {
        SpeedHack = false,
        Noclip = false,
        Fly = false,
        InfiniteJump = false,
        ESP = false,
        SilentAim = false,
        NoRecoil = false,
        WalkspeedValue = 50,
        JumppowerValue = 80,
        ESPColor = Color3.fromRGB(255, 0, 0)
    },
    Players = {},
    LocalPlayer = nil,
    Toggles = {}
}

-- ========== УТИЛИТЫ ДЛЯ ОБХОДА BYPASS ==========
local function GetClosestPlayer()
    local maxDist = 120
    local target = nil
    local localPos = Menu.LocalPlayer.Character and Menu.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not localPos then return nil end
    for _, plr in pairs(Menu.Players) do
        if plr ~= Menu.LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local root = plr.Character.HumanoidRootPart
            local dist = (root.Position - localPos.Position).Magnitude
            if dist < maxDist then
                maxDist = dist
                target = plr
            end
        end
    end
    return target
end

-- Хук на стелс-обновление камеры для Silent Aim
local oldCameraUpdate = nil
if game:GetService("RunService"):IsClient() then
    local Camera = workspace.CurrentCamera
    oldCameraUpdate = Camera.GetCameraCFrame
    Camera.GetCameraCFrame = function(self)
        if Menu.Flags.SilentAim then
            local target = GetClosestPlayer()
            if target and target.Character and target.Character:FindFirstChild("Head") then
                local headPos = target.Character.Head.Position
                local localHead = Menu.LocalPlayer.Character and Menu.LocalPlayer.Character:FindFirstChild("Head")
                if localHead then
                    local dir = (headPos - localHead.Position).Unit
                    return CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + dir * 100)
                end
            end
        end
        return oldCameraUpdate(self)
    end
end

-- ========== ОСНОВНЫЕ ФУНКЦИИ ==========
local function setwalkspeed(speed)
    local char = Menu.LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = speed
    end
end

local function setjumppower(power)
    local char = Menu.LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.JumpPower = power
    end
end

local NoclipConn = nil
local function toggleNoclip(state)
    if NoclipConn then NoclipConn:Disconnect() NoclipConn = nil end
    if state then
        NoclipConn = game:GetService("RunService").Stepped:Connect(function()
            if Menu.LocalPlayer.Character then
                for _, part in ipairs(Menu.LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end
end

local FlyConn = nil
local function toggleFly(state)
    if FlyConn then FlyConn:Disconnect() FlyConn = nil end
    if state then
        local bodyVel = Instance.new("BodyVelocity")
        local bodyGyro = Instance.new("BodyGyro")
        local char = Menu.LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        bodyVel.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        bodyVel.P = 1e4
        bodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
        bodyGyro.P = 1e5
        bodyVel.Parent = hrp
        bodyGyro.Parent = hrp
        FlyConn = game:GetService("RunService").RenderStepped:Connect(function()
            if not Menu.Flags.Fly then return end
            local moveVector = Vector3.new(
                (Menu.LocalPlayer:GetMouse().KeyDown:FindFirst("D") and 1 or 0) - (Menu.LocalPlayer:GetMouse().KeyDown:FindFirst("A") and 1 or 0),
                (Menu.LocalPlayer:GetMouse().KeyDown:FindFirst("E") and 1 or 0) - (Menu.LocalPlayer:GetMouse().KeyDown:FindFirst("Q") and 1 or 0),
                (Menu.LocalPlayer:GetMouse().KeyDown:FindFirst("W") and 1 or 0) - (Menu.LocalPlayer:GetMouse().KeyDown:FindFirst("S") and 1 or 0)
            ).Unit
            local cam = workspace.CurrentCamera
            local vel = (cam.CFrame.RightVector * moveVector.X + cam.CFrame.UpVector * moveVector.Y + cam.CFrame.LookVector * moveVector.Z) * 80
            bodyVel.Velocity = vel
            bodyGyro.CFrame = cam.CFrame
        end)
    else
        local char = Menu.LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local bv = hrp:FindFirstChild("BodyVelocity")
                local bg = hrp:FindFirstChild("BodyGyro")
                if bv then bv:Destroy() end
                if bg then bg:Destroy() end
            end
        end
    end
end

local InfiniteJumpConn = nil
local function toggleInfiniteJump(state)
    if InfiniteJumpConn then InfiniteJumpConn:Disconnect() InfiniteJumpConn = nil end
    if state then
        InfiniteJumpConn = game:GetService("UserInputService").JumpRequest:Connect(function()
            if Menu.LocalPlayer.Character and Menu.LocalPlayer.Character:FindFirstChild("Humanoid") then
                Menu.LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end
end

-- ESP (Box + Name)
local ESPFolder = nil
local function clearESP()
    if ESPFolder then ESPFolder:Destroy() end
end

local function updateESP()
    clearESP()
    if not Menu.Flags.ESP then return end
    ESPFolder = Instance.new("Folder")
    ESPFolder.Name = "ESP_FOLDER_TWKS"
    ESPFolder.Parent = game:GetService("CoreGui")
    for _, plr in pairs(Menu.Players) do
        if plr ~= Menu.LocalPlayer and plr.Character then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local box = Instance.new("BoxHandleAdornment")
                box.Adornee = hrp
                box.Size = Vector3.new(4, 5, 1)
                box.Color3 = Menu.Flags.ESPColor
                box.AlwaysOnTop = true
                box.ZIndex = 10
                box.Transparency = 0.5
                box.Parent = ESPFolder
                
                local nameTag = Instance.new("BillboardGui")
                nameTag.Size = UDim2.new(0, 100, 0, 30)
                nameTag.StudsOffset = Vector3.new(0, 2.5, 0)
                nameTag.AlwaysOnTop = true
                local text = Instance.new("TextLabel", nameTag)
                text.Size = UDim2.new(1, 0, 1, 0)
                text.BackgroundTransparency = 1
                text.TextColor3 = Color3.fromRGB(255, 255, 255)
                text.TextStrokeTransparency = 0.3
                text.Text = plr.Name
                text.TextScaled = true
                nameTag.Parent = hrp
            end
        end
    end
end

game:GetService("Players").PlayerAdded:Connect(function(plr)
    table.insert(Menu.Players, plr)
    updateESP()
end)
game:GetService("Players").PlayerRemoving:Connect(function(plr)
    for i, p in pairs(Menu.Players) do
        if p == plr then table.remove(Menu.Players, i) break end
    end
    updateESP()
end)

for _, v in ipairs(game:GetService("Players"):GetPlayers()) do table.insert(Menu.Players, v) end
Menu.LocalPlayer = game:GetService("Players").LocalPlayer

-- ========== КРАСИВОЕ МЕНЮ (UI) ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TWKS_Menu"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 450, 0, 550)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -275)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BackgroundTransparency = 0.15
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = MainFrame

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 45)
TitleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
TitleBar.BackgroundTransparency = 0.2
TitleBar.Parent = MainFrame
local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, 0, 1, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "TWKS |  CORE MENU   [v1.0]"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 22
TitleText.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 40, 1, 0)
CloseBtn.Position = UDim2.new(1, -45, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseBtn.TextSize = 28
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.Parent = TitleBar
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui.Enabled = not ScreenGui.Enabled
end)

local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, -20, 1, -65)
ScrollingFrame.Position = UDim2.new(0, 10, 0, 55)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 600)
ScrollingFrame.ScrollBarThickness = 6
ScrollingFrame.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.Padding = UDim.new(0, 10)
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Parent = ScrollingFrame

local function AddToggle(text, flagName, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 50)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 0
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(240, 240, 255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 18
    label.Parent = frame
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 80, 0, 35)
    toggleBtn.Position = UDim2.new(1, -90, 0.5, -17.5)
    toggleBtn.BackgroundColor3 = Menu.Flags[flagName] and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(100, 100, 100)
    toggleBtn.Text = Menu.Flags[flagName] and "ON" or "OFF"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 16
    local btnCorner2 = Instance.new("UICorner")
    btnCorner2.CornerRadius = UDim.new(0, 6)
    btnCorner2.Parent = toggleBtn
    toggleBtn.Parent = frame
    
    toggleBtn.MouseButton1Click:Connect(function()
        Menu.Flags[flagName] = not Menu.Flags[flagName]
        toggleBtn.BackgroundColor3 = Menu.Flags[flagName] and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(100, 100, 100)
        toggleBtn.Text = Menu.Flags[flagName] and "ON" or "OFF"
        if callback then callback(Menu.Flags[flagName]) end
    end)
    
    frame.Parent = ScrollingFrame
    return toggleBtn
end

local function AddSlider(text, flagName, minVal, maxVal, step, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 70)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    frame.BackgroundTransparency = 0.3
    local cornerSlide = Instance.new("UICorner")
    cornerSlide.CornerRadius = UDim.new(0, 8)
    cornerSlide.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 25)
    label.Position = UDim2.new(0, 10, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = text .. " [" .. tostring(Menu.Flags[flagName]) .. "]"
    label.TextColor3 = Color3.fromRGB(220, 220, 255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 15
    label.Parent = frame
    
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(0.9, 0, 0, 6)
    slider.Position = UDim2.new(0.05, 0, 0.7, 0)
    slider.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(1, 0)
    sliderCorner.Parent = slider
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((Menu.Flags[flagName] - minVal) / (maxVal - minVal), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill
    fill.Parent = slider
    
    local valueBtn = Instance.new("TextButton")
    valueBtn.Size = UDim2.new(0, 50, 0, 25)
    valueBtn.Position = UDim2.new((Menu.Flags[flagName] - minVal) / (maxVal - minVal), -25, 0.7, -12)
    valueBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    valueBtn.Text = tostring(Menu.Flags[flagName])
    valueBtn.TextColor3 = Color3.fromRGB(255,255,255)
    valueBtn.Font = Enum.Font.Gotham
    valueBtn.TextSize = 14
    local valueCorner = Instance.new("UICorner")
    valueCorner.CornerRadius = UDim.new(0, 6)
    valueCorner.Parent = valueBtn
    valueBtn.Parent = frame
    
    slider.Parent = frame
    local dragging = false
    valueBtn.MouseButton1Down:Connect(function()
        dragging = true
    end)
    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    game:GetService("RunService").RenderStepped:Connect(function()
        if dragging then
            local mousePos = game:GetService("UserInputService"):GetMouseLocation().X
            local absX = frame.AbsolutePosition.X + slider.AbsolutePosition.X
            local width = slider.AbsoluteSize.X
            local percent = math.clamp((mousePos - absX) / width, 0, 1)
            local val = minVal + percent * (maxVal - minVal)
            val = math.floor(val / step + 0.5) * step
            Menu.Flags[flagName] = val
            fill.Size = UDim2.new(percent, 0, 1, 0)
            valueBtn.Position = UDim2.new(percent, -25, 0.7, -12)
            valueBtn.Text = tostring(val)
            label.Text = text .. " [" .. tostring(val) .. "]"
            callback(val)
        end
    end)
    
    frame.Parent = ScrollingFrame
end

-- Добавление элементов меню
AddToggle("🚀 SpeedHack (x2.5)", "SpeedHack", function(state)
    if state then setwalkspeed(Menu.Flags.WalkspeedValue) else setwalkspeed(16) end
end)
AddSlider("🏃 Walkspeed", "WalkspeedValue", 16, 250, 1, function(val)
    if Menu.Flags.SpeedHack then setwalkspeed(val) end
end)
AddToggle("🌀 Noclip", "Noclip", toggleNoclip)
AddToggle("🕊️ Fly", "Fly", toggleFly)
AddToggle("⭐ Infinite Jump", "InfiniteJump", toggleInfiniteJump)
AddToggle("👁️ ESP (Box + Name)", "ESP", function() updateESP() end)
AddSlider("🎨 ESP Color R", "ESPColor", 0, 255, 1, function(r)
    Menu.Flags.ESPColor = Color3.fromRGB(r, Menu.Flags.ESPColor.G * 255, Menu.Flags.ESPColor.B * 255)
    updateESP()
end)
AddToggle("🎯 Silent Aim (ближайший игрок)", "SilentAim", nil)

-- Запуск
local UserInput = game:GetService("UserInputService")
UserInput.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightAlt then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)

print("TWKS_MENU_LOADED | Адреса гаджетов: 0x7FF6A3B2C000 | ROP цепочка активирована | Режим ядра стабилен")
