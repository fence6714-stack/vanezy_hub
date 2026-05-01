-- Вставьте в StarterGui как LocalScript

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- Создаём GUI для ESP
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ESP_System"
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Функция создания метки для игрока
local function createESP(targetPlayer)
    local character = targetPlayer.Character
    if not character then return nil end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return nil end
    
    -- Создаём текстовую метку
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(0, 200, 0, 30)
    textLabel.BackgroundTransparency = 0.5
    textLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    textLabel.TextStrokeTransparency = 0
    textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextSize = 14
    textLabel.Parent = screenGui
    
    -- Обновление позиции и текста
    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            textLabel:Destroy()
            connection:Disconnect()
            return
        end
        
        local rootPart = targetPlayer.Character.HumanoidRootPart
        local vector2, onScreen = workspace.CurrentCamera:WorldToViewportPoint(rootPart.Position)
        
        if onScreen then
            textLabel.Visible = true
            textLabel.Position = UDim2.new(0, vector2.X - 100, 0, vector2.Y - 50)
            
            local humanoid = targetPlayer.Character:FindFirstChild("Humanoid")
            local health = humanoid and math.floor(humanoid.Health) or 0
            
            textLabel.Text = string.format("%s | ❤️ %d | %.0fm", 
                targetPlayer.Name, 
                health,
                (rootPart.Position - (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position or Vector3.new())).Magnitude / 10
            )
            
            -- Цвет здоровья
            if health < 30 then
                textLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
            elseif health < 70 then
                textLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
            else
                textLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            end
        else
            textLabel.Visible = false
        end
    end)
    
    return textLabel
end

-- Отслеживаем появление игроков
local espLabels = {}

local function onPlayerAdded(player)
    if player == LocalPlayer then return end
    
    -- Ждём появления персонажа
    player.CharacterAdded:Connect(function(character)
        -- Небольшая задержка для загрузки
        task.wait(0.5)
        if espLabels[player] then
            espLabels[player]:Destroy()
        end
        espLabels[player] = createESP(player)
    end)
    
    -- Если персонаж уже есть
    if player.Character then
        task.wait(0.5)
        espLabels[player] = createESP(player)
    end
end

local function onPlayerRemoving(player)
    if espLabels[player] then
        espLabels[player]:Destroy()
        espLabels[player] = nil
    end
end

-- Подключаем для существующих игроков
for _, player in pairs(Players:GetPlayers()) do
    onPlayerAdded(player)
end

-- Подключаем события
Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

-- ESP для самого игрока (опционально)
local function localPlayerESP()
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(0, 200, 0, 30)
    textLabel.BackgroundTransparency = 0.5
    textLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 255)
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.Text = "ВЫ"
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextSize = 14
    textLabel.Parent = screenGui
    
    RunService.RenderStepped:Connect(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = LocalPlayer.Character.HumanoidRootPart
            local vector2, onScreen = workspace.CurrentCamera:WorldToViewportPoint(rootPart.Position)
            
            if onScreen then
                textLabel.Visible = true
                textLabel.Position = UDim2.new(0, vector2.X - 100, 0, vector2.Y - 50)
            else
                textLabel.Visible = false
            end
        end
    end)
end

localPlayerESP()

-- Создаём кнопку включения/выключения ESP
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 120, 0, 40)
toggleBtn.Position = UDim2.new(0, 10, 0, 50)
toggleBtn.Text = "ESP: ON"
toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Parent = screenGui

local espEnabled = true
toggleBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    toggleBtn.Text = espEnabled and "ESP: ON" or "ESP: OFF"
    
    for _, label in pairs(espLabels) do
        if label then
            label.Visible = espEnabled
        end
    end
end)
