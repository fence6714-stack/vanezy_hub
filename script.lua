-- Vanezy Universal ESP (Max Compatible)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

local ESPEnabled = true

-- GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "VanezyESP"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 220, 0, 120)
Frame.Position = UDim2.new(0.05, 0, 0.3, 0)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "Vanezy Script Universal Esp"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextScaled = true

local Toggle = Instance.new("TextButton", Frame)
Toggle.Size = UDim2.new(0, 160, 0, 40)
Toggle.Position = UDim2.new(0.5, -80, 0.6, 0)
Toggle.Text = "ON"
Toggle.BackgroundColor3 = Color3.fromRGB(0,200,0)
Toggle.TextScaled = true

-- Найти любую часть персонажа (если нет Head)
local function getPart(char)
    return char:FindFirstChild("Head")
        or char:FindFirstChild("HumanoidRootPart")
        or char:FindFirstChildWhichIsA("BasePart")
end

-- ESP
local function addESP(char, player)
    if not ESPEnabled then return end
    if not char or not char.Parent then return end

    local part = getPart(char)
    if not part then return end

    -- Highlight (если не удаляется игрой)
    if not char:FindFirstChild("ESP") then
        local h = Instance.new("Highlight")
        h.Name = "ESP"
        h.FillColor = Color3.fromRGB(0,255,0)
        h.OutlineColor = Color3.new(1,1,1)
        h.FillTransparency = 0.5
        pcall(function()
            h.Parent = char
        end)
    end

    -- Ник
    if not part:FindFirstChild("ESP_NAME") then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESP_NAME"
        billboard.Size = UDim2.new(0, 100, 0, 40)
        billboard.AlwaysOnTop = true
        billboard.Parent = part

        local text = Instance.new("TextLabel", billboard)
        text.Size = UDim2.new(1,0,1,0)
        text.BackgroundTransparency = 1
        text.Text = player.Name
        text.TextColor3 = Color3.new(1,1,1)
        text.TextStrokeTransparency = 0
    end
end

local function removeESP(char)
    if char:FindFirstChild("ESP") then
        char.ESP:Destroy()
    end
    for _, v in pairs(char:GetDescendants()) do
        if v.Name == "ESP_NAME" then
            v:Destroy()
        end
    end
end

-- Постоянное обновление (если игра удаляет ESP — вернёт обратно)
RunService.RenderStepped:Connect(function()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if ESPEnabled then
                addESP(player.Character, player)
            else
                removeESP(player.Character)
            end
        end
    end
end)

-- Кнопка
Toggle.MouseButton1Click:Connect(function()
    ESPEnabled = not ESPEnabled

    if ESPEnabled then
        Toggle.Text = "ON"
        Toggle.BackgroundColor3 = Color3.fromRGB(0,200,0)
    else
        Toggle.Text = "OFF"
        Toggle.BackgroundColor3 = Color3.fromRGB(255,0,0)
    end
end)
