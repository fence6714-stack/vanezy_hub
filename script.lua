--[[
    STRONGEST SIMULATOR - АВТО-ШТАНГА + АВТО-ПРЕДМЕТЫ v8
    Штанга: телепорт → 0.5с → зажать кнопку Train 1с → клики каждые 0.7с
    Предметы: телепорт к предмету → клик "Взять" каждые 0.5с И телепорт на финиш каждые 0.5с
    GUI: 320x280
--]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    HumanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
    Humanoid = newChar:WaitForChild("Humanoid")
    if AutoFarmEnabled then
        task.spawn(clickLoopOnly)
    end
    if AutoLiftEnabled then
        task.spawn(liftLoopOnly)
    end
end)

-- ==================== ДАННЫЕ ====================
local TrainingPosition = Vector3.new(2284.360, 49.147, 5903.271)
local LiftStartPosition = Vector3.new(2554.064, 13.710, 5502.688)
local LiftFinishPosition = Vector3.new(2542.465, 13.186, 6129.139)

local AutoFarmEnabled = false
local AutoLiftEnabled = false
local freezeConnection = nil

-- ==================== УТИЛИТЫ ОБЩИЕ ====================
local function teleportTo(pos)
    if Character and HumanoidRootPart then
        HumanoidRootPart.CFrame = CFrame.new(pos)
    end
end

local function freezeCharacter()
    if not Character or not HumanoidRootPart then return end
    if freezeConnection then freezeConnection:Disconnect() end
    
    local frozenCFrame = HumanoidRootPart.CFrame
    
    freezeConnection = RunService.RenderStepped:Connect(function()
        if Character and HumanoidRootPart and Humanoid then
            HumanoidRootPart.CFrame = frozenCFrame
            HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
            Humanoid.PlatformStand = true
        end
    end)
end

local function unfreezeCharacter()
    if freezeConnection then
        freezeConnection:Disconnect()
        freezeConnection = nil
    end
    if Character and Humanoid then
        Humanoid.PlatformStand = false
    end
end

-- ==================== ПОИСК КНОПОК ====================
local function findButtonByNames(...)
    local names = {...}
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("TextButton") or obj:IsA("ImageButton") then
            local objName = obj.Name:lower()
            local objText = obj:IsA("TextButton") and obj.Text:lower() or ""
            
            for _, name in ipairs(names) do
                local n = name:lower()
                if objName:find(n) or objText:find(n) then
                    return obj
                end
            end
        end
    end
    return nil
end

local function findTrainButton()
    return findButtonByNames("train", "качаться", "work", "тренировка", "качать")
end

local function findLiftButton()
    return findButtonByNames("lift", "grab", "поднять", "взять", "carry", "нести", "схватить")
end

-- ==================== КЛИКИ ПО КНОПКАМ ====================
local function clickButton(btn)
    if btn then
        local absPos = btn.AbsolutePosition
        local absSize = btn.AbsoluteSize
        local x = absPos.X + absSize.X / 2
        local y = absPos.Y + absSize.Y / 2
        VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 1)
        VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 1)
    else
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
    end
end

local function holdButton(btn, duration)
    if btn then
        local absPos = btn.AbsolutePosition
        local absSize = btn.AbsoluteSize
        local x = absPos.X + absSize.X / 2
        local y = absPos.Y + absSize.Y / 2
        VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 1)
        task.wait(duration)
        VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 1)
    else
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
        task.wait(duration)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
    end
end

local function clickTrainButton()
    clickButton(findTrainButton())
end

local function holdTrainButton(duration)
    holdButton(findTrainButton(), duration)
end

local function clickLiftButton()
    clickButton(findLiftButton())
end

-- ==================== АВТО-ШТАНГА ====================
local function clickLoopOnly()
    while AutoFarmEnabled do
        if not Character or not HumanoidRootPart then
            Character = LocalPlayer.Character
            if Character then
                HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
                Humanoid = Character:WaitForChild("Humanoid")
                freezeCharacter()
            end
        end
        
        if Character and HumanoidRootPart and AutoFarmEnabled then
            clickTrainButton()
            task.wait(0.7)
        else
            task.wait(0.1)
        end
    end
    unfreezeCharacter()
end

local function autoFarmFullCycle()
    if not Character or not HumanoidRootPart then
        Character = LocalPlayer.Character
        if Character then
            HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
            Humanoid = Character:WaitForChild("Humanoid")
        end
    end
    
    if not Character or not HumanoidRootPart then
        unfreezeCharacter()
        return
    end
    
    -- Телепорт к штанге
    teleportTo(TrainingPosition)
    
    -- Заморозка
    freezeCharacter()
    
    -- Пауза 0.5 сек
    task.wait(0.5)
    
    -- Зажать кнопку Train на 1 сек
    holdTrainButton(1.0)
    
    -- Бесконечные клики каждые 0.7 сек
    clickLoopOnly()
end

-- ==================== АВТО-ПРЕДМЕТЫ ====================
local function liftLoopOnly()
    while AutoLiftEnabled do
        if not Character or not HumanoidRootPart then
            Character = LocalPlayer.Character
            if Character then
                HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
                Humanoid = Character:WaitForChild("Humanoid")
            end
        end
        
        if Character and HumanoidRootPart and AutoLiftEnabled then
            -- 1. Телепорт к предмету
            teleportTo(LiftStartPosition)
            
            -- 2. Клик "Взять"
            clickLiftButton()
            
            -- 3. Телепорт на финиш (с предметом если взяли)
            teleportTo(LiftFinishPosition)
            
            task.wait(0.5)
        else
            task.wait(0.1)
        end
    end
end

local function autoLiftFullCycle()
    if not Character or not HumanoidRootPart then
        Character = LocalPlayer.Character
        if Character then
            HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
            Humanoid = Character:WaitForChild("Humanoid")
        end
    end
    
    if not Character or not HumanoidRootPart then return end
    
    liftLoopOnly()
end

-- ==================== GUI 320x280 ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TWEAK_UI"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 280)
MainFrame.Position = UDim2.new(1, -340, 0.5, -140)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- Хедер
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 35)
Header.BackgroundColor3 = Color3.fromRGB(140, 100, 255)
Header.BorderSizePixel = 0
Header.Parent = MainFrame
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 10)

local HeaderText = Instance.new("TextLabel")
HeaderText.Size = UDim2.new(1, -20, 1, 0)
HeaderText.Position = UDim2.new(0, 15, 0, 0)
HeaderText.BackgroundTransparency = 1
HeaderText.Text = "TWEAK | v8 Штанга + Предметы"
HeaderText.TextColor3 = Color3.fromRGB(255, 255, 255)
HeaderText.Font = Enum.Font.GothamBold
HeaderText.TextSize = 13
HeaderText.TextXAlignment = Enum.TextXAlignment.Left
HeaderText.Parent = Header

-- Контент
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -20, 1, -35)
Content.Position = UDim2.new(0, 10, 0, 35)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.Parent = MainFrame

-- ====== СЕКЦИЯ ШТАНГА ======
local FarmSection = Instance.new("TextLabel")
FarmSection.Size = UDim2.new(1, 0, 0, 22)
FarmSection.Position = UDim2.new(0, 0, 0, 5)
FarmSection.BackgroundTransparency = 1
FarmSection.Text = "— Авто-штанга"
FarmSection.TextColor3 = Color3.fromRGB(140, 100, 255)
FarmSection.Font = Enum.Font.GothamBold
FarmSection.TextSize = 12
FarmSection.TextXAlignment = Enum.TextXAlignment.Left
FarmSection.Parent = Content

-- Тоггл штанги
local FarmToggleFrame = Instance.new("Frame")
FarmToggleFrame.Size = UDim2.new(1, 0, 0, 38)
FarmToggleFrame.Position = UDim2.new(0, 0, 0, 30)
FarmToggleFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
FarmToggleFrame.BorderSizePixel = 0
FarmToggleFrame.Parent = Content
Instance.new("UICorner", FarmToggleFrame).CornerRadius = UDim.new(0, 6)

local FarmToggleLabel = Instance.new("TextLabel")
FarmToggleLabel.Size = UDim2.new(0.55, 0, 1, 0)
FarmToggleLabel.Position = UDim2.new(0, 10, 0, 0)
FarmToggleLabel.BackgroundTransparency = 1
FarmToggleLabel.Text = "Авто-штанга"
FarmToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
FarmToggleLabel.Font = Enum.Font.GothamMedium
FarmToggleLabel.TextSize = 13
FarmToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
FarmToggleLabel.Parent = FarmToggleFrame

local FarmToggleBtn = Instance.new("TextButton")
FarmToggleBtn.Size = UDim2.new(0, 46, 0, 22)
FarmToggleBtn.Position = UDim2.new(1, -54, 0.5, -11)
FarmToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 70, 70)
FarmToggleBtn.Text = ""
FarmToggleBtn.BorderSizePixel = 0
FarmToggleBtn.Parent = FarmToggleFrame
Instance.new("UICorner", FarmToggleBtn).CornerRadius = UDim.new(0, 11)

local FarmToggleCircle = Instance.new("Frame")
FarmToggleCircle.Size = UDim2.new(0, 16, 0, 16)
FarmToggleCircle.Position = UDim2.new(0, 3, 0.5, -8)
FarmToggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
FarmToggleCircle.BorderSizePixel = 0
FarmToggleCircle.Parent = FarmToggleBtn
Instance.new("UICorner", FarmToggleCircle).CornerRadius = UDim.new(0, 8)

-- ====== СЕКЦИЯ ПРЕДМЕТЫ ======
local LiftSection = Instance.new("TextLabel")
LiftSection.Size = UDim2.new(1, 0, 0, 22)
LiftSection.Position = UDim2.new(0, 0, 0, 78)
LiftSection.BackgroundTransparency = 1
LiftSection.Text = "— Авто-предметы"
LiftSection.TextColor3 = Color3.fromRGB(140, 100, 255)
LiftSection.Font = Enum.Font.GothamBold
LiftSection.TextSize = 12
LiftSection.TextXAlignment = Enum.TextXAlignment.Left
LiftSection.Parent = Content

-- Тоггл предметов
local LiftToggleFrame = Instance.new("Frame")
LiftToggleFrame.Size = UDim2.new(1, 0, 0, 38)
LiftToggleFrame.Position = UDim2.new(0, 0, 0, 103)
LiftToggleFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
LiftToggleFrame.BorderSizePixel = 0
LiftToggleFrame.Parent = Content
Instance.new("UICorner", LiftToggleFrame).CornerRadius = UDim.new(0, 6)

local LiftToggleLabel = Instance.new("TextLabel")
LiftToggleLabel.Size = UDim2.new(0.55, 0, 1, 0)
LiftToggleLabel.Position = UDim2.new(0, 10, 0, 0)
LiftToggleLabel.BackgroundTransparency = 1
LiftToggleLabel.Text = "Авто-предметы"
LiftToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
LiftToggleLabel.Font = Enum.Font.GothamMedium
LiftToggleLabel.TextSize = 13
LiftToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
LiftToggleLabel.Parent = LiftToggleFrame

local LiftToggleBtn = Instance.new("TextButton")
LiftToggleBtn.Size = UDim2.new(0, 46, 0, 22)
LiftToggleBtn.Position = UDim2.new(1, -54, 0.5, -11)
LiftToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 70, 70)
LiftToggleBtn.Text = ""
LiftToggleBtn.BorderSizePixel = 0
LiftToggleBtn.Parent = LiftToggleFrame
Instance.new("UICorner", LiftToggleBtn).CornerRadius = UDim.new(0, 11)

local LiftToggleCircle = Instance.new("Frame")
LiftToggleCircle.Size = UDim2.new(0, 16, 0, 16)
LiftToggleCircle.Position = UDim2.new(0, 3, 0.5, -8)
LiftToggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
LiftToggleCircle.BorderSizePixel = 0
LiftToggleCircle.Parent = LiftToggleBtn
Instance.new("UICorner", LiftToggleCircle).CornerRadius = UDim.new(0, 8)

-- ====== СТАТУС ======
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.Position = UDim2.new(0, 0, 0, 155)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Статус: Выключено"
StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
StatusLabel.Font = Enum.Font.GothamMedium
StatusLabel.TextSize = 11
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = Content

-- ====== КНОПКА СТОП ======
local StopButton = Instance.new("TextButton")
StopButton.Size = UDim2.new(1, 0, 0, 34)
StopButton.Position = UDim2.new(0, 0, 0, 185)
StopButton.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
StopButton.Text = "СТОП ВСЁ"
StopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
StopButton.Font = Enum.Font.GothamBold
StopButton.TextSize = 14
StopButton.BorderSizePixel = 0
StopButton.Parent = Content
Instance.new("UICorner", StopButton).CornerRadius = UDim.new(0, 6)

-- ====== ИНФО ======
local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(1, 0, 0, 28)
InfoLabel.Position = UDim2.new(0, 0, 0, 228)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text = "Штанга: 2284,49,5903\nПредмет: 2554,13,5502 → 2542,13,6129"
InfoLabel.TextColor3 = Color3.fromRGB(120, 120, 130)
InfoLabel.Font = Enum.Font.GothamMedium
InfoLabel.TextSize = 9
InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
InfoLabel.Parent = Content

-- ==================== ЛОГИКА ТОГГЛОВ ====================
local farmEnabled = false
local liftEnabled = false

local function updateFarmVisual()
    if farmEnabled then
        FarmToggleBtn.BackgroundColor3 = Color3.fromRGB(80, 200, 120)
        FarmToggleCircle.Position = UDim2.new(1, -19, 0.5, -8)
    else
        FarmToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 70, 70)
        FarmToggleCircle.Position = UDim2.new(0, 3, 0.5, -8)
    end
    updateStatus()
end

local function updateLiftVisual()
    if liftEnabled then
        LiftToggleBtn.BackgroundColor3 = Color3.fromRGB(80, 200, 120)
        LiftToggleCircle.Position = UDim2.new(1, -19, 0.5, -8)
    else
        LiftToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 70, 70)
        LiftToggleCircle.Position = UDim2.new(0, 3, 0.5, -8)
    end
    updateStatus()
end

local function updateStatus()
    if farmEnabled and liftEnabled then
        StatusLabel.Text = "Статус: Штанга + Предметы активны"
    elseif farmEnabled then
        StatusLabel.Text = "Статус: Только штанга"
    elseif liftEnabled then
        StatusLabel.Text = "Статус: Только предметы"
    else
        StatusLabel.Text = "Статус: Выключено"
    end
end

FarmToggleBtn.MouseButton1Click:Connect(function()
    farmEnabled = not farmEnabled
    AutoFarmEnabled = farmEnabled
    updateFarmVisual()
    
    if farmEnabled then
        task.spawn(autoFarmFullCycle)
    else
        unfreezeCharacter()
    end
end)

LiftToggleBtn.MouseButton1Click:Connect(function()
    liftEnabled = not liftEnabled
    AutoLiftEnabled = liftEnabled
    updateLiftVisual()
    
    if liftEnabled then
        task.spawn(autoLiftFullCycle)
    end
end)

StopButton.MouseButton1Click:Connect(function()
    farmEnabled = false
    liftEnabled = false
    AutoFarmEnabled = false
    AutoLiftEnabled = false
    unfreezeCharacter()
    updateFarmVisual()
    updateLiftVisual()
end)

updateFarmVisual()
updateLiftVisual()

print("=== TWEAK v8 ЗАГРУЖЕН ===")
print("Авто-штанга: телепорт → 0.5с → зажать 1с → клики 0.7с")
print("Авто-предметы: телепорт к предмету + клик Взять + телепорт на финиш каждые 0.5с")
