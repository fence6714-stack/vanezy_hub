--[[
    STRONGEST SIMULATOR - v9 FINAL
    Полный рефакторинг: реальные действия через game:GetService
    Телепорт: CFrame.new напрямую в HumanoidRootPart
    Клики: VirtualInputManager с реальными координатами кнопок
    GUI: 320x300
--]]

-- Ждём полной загрузки игры
repeat task.wait(0.1) until game:IsLoaded()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- Ждём персонажа
repeat task.wait(0.1) until LocalPlayer.Character
local Character = LocalPlayer.Character
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

-- Переменные состояния
local AutoFarmEnabled = false
local AutoLiftEnabled = false
local freezeConnection = nil

-- Позиции
local TrainingPosition = Vector3.new(2284.360, 49.147, 5903.271)
local LiftStartPosition = Vector3.new(2554.064, 13.710, 5502.688)
local LiftFinishPosition = Vector3.new(2542.465, 13.186, 6129.139)

-- При респавне переподключаем
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    HumanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
    Humanoid = newChar:WaitForChild("Humanoid")
    
    if AutoFarmEnabled then
        task.wait(0.5)
        task.spawn(function() 
            startFarmClickLoop() 
        end)
    end
    if AutoLiftEnabled then
        task.wait(0.5)
        task.spawn(function() 
            liftLoop() 
        end)
    end
end)

-- ==================== ФУНКЦИИ ====================

-- Телепорт (прямая установка CFrame)
local function teleportTo(pos)
    local char = LocalPlayer.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = CFrame.new(pos)
            return true
        end
    end
    return false
end

-- Заморозка в воздухе
local function freezeCharacter()
    if freezeConnection then 
        freezeConnection:Disconnect() 
    end
    
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not hrp or not hum then return end
    
    local frozenPos = hrp.Position
    
    freezeConnection = RunService.RenderStepped:Connect(function()
        local c = LocalPlayer.Character
        if c then
            local h = c:FindFirstChild("HumanoidRootPart")
            local hm = c:FindFirstChild("Humanoid")
            if h then
                h.CFrame = CFrame.new(frozenPos)
                h.Velocity = Vector3.zero
            end
            if hm then
                hm.PlatformStand = true
            end
        end
    end)
end

-- Разморозка
local function unfreezeCharacter()
    if freezeConnection then
        freezeConnection:Disconnect()
        freezeConnection = nil
    end
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            hum.PlatformStand = false
        end
    end
end

-- Поиск кнопки в игре
local function findButton(names)
    local all = game:GetDescendants()
    for _, obj in ipairs(all) do
        if obj:IsA("TextButton") or obj:IsA("ImageButton") then
            local objName = obj.Name:lower()
            local objText = ""
            pcall(function() 
                if obj:IsA("TextButton") then 
                    objText = obj.Text:lower() 
                end 
            end)
            
            for _, n in ipairs(names) do
                local nl = n:lower()
                if objName:find(nl) or objText:find(nl) then
                    return obj
                end
            end
        end
    end
    return nil
end

-- Клик по конкретному элементу GUI
local function clickGuiButton(buttonName)
    local btn = findButton(buttonName)
    if btn then
        local x = btn.AbsolutePosition.X + btn.AbsoluteSize.X / 2
        local y = btn.AbsolutePosition.Y + btn.AbsoluteSize.Y / 2
        
        VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 1)
        task.wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 1)
        
        print("Кликнул по кнопке: " .. btn.Name .. " на " .. x .. ", " .. y)
        return true
    else
        print("Кнопка не найдена: " .. buttonName[1])
        -- Фолбэк: клик в центр экрана
        VirtualInputManager:SendMouseButtonEvent(960, 540, 0, true, game, 1)
        task.wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(960, 540, 0, false, game, 1)
        return false
    end
end

-- Зажатие кнопки
local function holdGuiButton(buttonName, duration)
    local btn = findButton(buttonName)
    if btn then
        local x = btn.AbsolutePosition.X + btn.AbsoluteSize.X / 2
        local y = btn.AbsolutePosition.Y + btn.AbsoluteSize.Y / 2
        
        VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 1)
        task.wait(duration)
        VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 1)
        
        print("Зажал кнопку: " .. btn.Name .. " на " .. duration .. "с")
        return true
    else
        print("Кнопка не найдена для зажатия: " .. buttonName[1])
        return false
    end
end

-- ==================== АВТО-ШТАНГА ====================

-- Цикл кликов после инициализации
function startFarmClickLoop()
    while AutoFarmEnabled do
        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            task.wait(0.5)
            continue
        end
        
        clickGuiButton({"train", "качаться", "work", "тренировка", "качать"})
        task.wait(0.7)
    end
    unfreezeCharacter()
    print("Авто-штанга остановлена")
end

-- Полный цикл штанги с инициализацией
function autoFarm()
    print("=== Запуск авто-штанги ===")
    
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        print("Нет персонажа, ждём...")
        repeat task.wait(0.1) until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        Character = LocalPlayer.Character
        HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
        Humanoid = Character:FindFirstChild("Humanoid")
    end
    
    -- 1. Телепорт к штанге
    print("Телепорт к штанге: " .. tostring(TrainingPosition))
    local tpSuccess = teleportTo(TrainingPosition)
    print("Телепорт выполнен: " .. tostring(tpSuccess))
    
    -- 2. Заморозка
    print("Заморозка персонажа")
    freezeCharacter()
    
    -- 3. Пауза 0.5 сек
    task.wait(0.5)
    
    -- 4. Зажать кнопку Train на 1 сек
    print("Зажимаем кнопку Train на 1 секунду")
    holdGuiButton({"train", "качаться", "work", "тренировка", "качать"}, 1.0)
    
    -- 5. Запуск цикла кликов
    print("Запуск цикла кликов каждые 0.7 сек")
    startFarmClickLoop()
end

-- ==================== АВТО-ПРЕДМЕТЫ ====================

function liftLoop()
    print("=== Запуск авто-предметов ===")
    
    while AutoLiftEnabled do
        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            task.wait(0.5)
            continue
        end
        
        -- 1. Телепорт к предмету
        print("Телепорт к предмету: " .. tostring(LiftStartPosition))
        teleportTo(LiftStartPosition)
        
        -- 2. Клик "Взять"
        print("Клик по кнопке Взять")
        clickGuiButton({"lift", "grab", "поднять", "взять", "carry", "нести", "схватить"})
        
        -- 3. Телепорт на финиш (предмет следует за персонажем)
        print("Телепорт на финиш: " .. tostring(LiftFinishPosition))
        teleportTo(LiftFinishPosition)
        
        -- 4. Клик "Сдать"/"Положить" (если нужен)
        clickGuiButton({"place", "drop", "положить", "сдать", "finish", "финиш"})
        
        task.wait(0.5)
    end
    print("Авто-предметы остановлены")
end

-- ==================== GUI (НАТИВНЫЙ) ====================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TWEAK_v9"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 320, 0, 300)
Main.Position = UDim2.new(1, -340, 0.5, -150)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

-- Хедер
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(140, 100, 255)
Header.BorderSizePixel = 0
Header.Parent = Main
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 10)

local HeaderLabel = Instance.new("TextLabel")
HeaderLabel.Size = UDim2.new(1, -20, 1, 0)
HeaderLabel.Position = UDim2.new(0, 15, 0, 0)
HeaderLabel.BackgroundTransparency = 1
HeaderLabel.Text = "TWEAK | Strongest Simulator v9"
HeaderLabel.TextColor3 = Color3.new(1, 1, 1)
HeaderLabel.Font = Enum.Font.GothamBold
HeaderLabel.TextSize = 13
HeaderLabel.TextXAlignment = Enum.TextXAlignment.Left
HeaderLabel.Parent = Header

-- Контент
local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -16, 1, -40)
Content.Position = UDim2.new(0, 8, 0, 40)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 3
Content.ScrollBarImageColor3 = Color3.fromRGB(140, 100, 255)
Content.CanvasSize = UDim2.new(0, 0, 0, 260)
Content.Parent = Main

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 8)
Layout.Parent = Content

Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Content.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 20)
end)

-- Функция создания элемента
local function createElement(elementType, properties)
    local element = Instance.new(elementType)
    for k, v in pairs(properties) do
        if k ~= "Parent" then
            element[k] = v
        end
    end
    element.Parent = Content
    return element
end

-- Секция Штанга
createElement("TextLabel", {
    Size = UDim2.new(1, 0, 0, 20),
    BackgroundTransparency = 1,
    Text = "— Авто-штанга",
    TextColor3 = Color3.fromRGB(140, 100, 255),
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left
})

local FarmFrame = createElement("Frame", {
    Size = UDim2.new(1, 0, 0, 42),
    BackgroundColor3 = Color3.fromRGB(45, 45, 55),
    BorderSizePixel = 0
})
Instance.new("UICorner", FarmFrame).CornerRadius = UDim.new(0, 6)

createElement("TextLabel", {
    Parent = FarmFrame,
    Size = UDim2.new(0.6, 0, 1, 0),
    Position = UDim2.new(0, 12, 0, 0),
    BackgroundTransparency = 1,
    Text = "Авто-штанга",
    TextColor3 = Color3.new(1, 1, 1),
    Font = Enum.Font.GothamMedium,
    TextSize = 13,
    TextXAlignment = Enum.TextXAlignment.Left
})

local FarmToggle = createElement("TextButton", {
    Parent = FarmFrame,
    Size = UDim2.new(0, 48, 0, 24),
    Position = UDim2.new(1, -60, 0.5, -12),
    BackgroundColor3 = Color3.fromRGB(200, 70, 70),
    Text = "",
    BorderSizePixel = 0
})
Instance.new("UICorner", FarmToggle).CornerRadius = UDim.new(0, 12)

local FarmCircle = createElement("Frame", {
    Parent = FarmToggle,
    Size = UDim2.new(0, 18, 0, 18),
    Position = UDim2.new(0, 3, 0.5, -9),
    BackgroundColor3 = Color3.new(1, 1, 1),
    BorderSizePixel = 0
})
Instance.new("UICorner", FarmCircle).CornerRadius = UDim.new(0, 9)

-- Секция Предметы
createElement("TextLabel", {
    Size = UDim2.new(1, 0, 0, 20),
    BackgroundTransparency = 1,
    Text = "— Авто-предметы",
    TextColor3 = Color3.fromRGB(140, 100, 255),
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left
})

local LiftFrame = createElement("Frame", {
    Size = UDim2.new(1, 0, 0, 42),
    BackgroundColor3 = Color3.fromRGB(45, 45, 55),
    BorderSizePixel = 0
})
Instance.new("UICorner", LiftFrame).CornerRadius = UDim.new(0, 6)

createElement("TextLabel", {
    Parent = LiftFrame,
    Size = UDim2.new(0.6, 0, 1, 0),
    Position = UDim2.new(0, 12, 0, 0),
    BackgroundTransparency = 1,
    Text = "Авто-предметы",
    TextColor3 = Color3.new(1, 1, 1),
    Font = Enum.Font.GothamMedium,
    TextSize = 13,
    TextXAlignment = Enum.TextXAlignment.Left
})

local LiftToggle = createElement("TextButton", {
    Parent = LiftFrame,
    Size = UDim2.new(0, 48, 0, 24),
    Position = UDim2.new(1, -60, 0.5, -12),
    BackgroundColor3 = Color3.fromRGB(200, 70, 70),
    Text = "",
    BorderSizePixel = 0
})
Instance.new("UICorner", LiftToggle).CornerRadius = UDim.new(0, 12)

local LiftCircle = createElement("Frame", {
    Parent = LiftToggle,
    Size = UDim2.new(0, 18, 0, 18),
    Position = UDim2.new(0, 3, 0.5, -9),
    BackgroundColor3 = Color3.new(1, 1, 1),
    BorderSizePixel = 0
})
Instance.new("UICorner", LiftCircle).CornerRadius = UDim.new(0, 9)

-- Статус
local StatusLabel = createElement("TextLabel", {
    Size = UDim2.new(1, 0, 0, 30),
    BackgroundTransparency = 1,
    Text = "Статус: Готов",
    TextColor3 = Color3.fromRGB(180, 180, 190),
    Font = Enum.Font.GothamMedium,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left
})

-- Кнопка СТОП
local StopBtn = createElement("TextButton", {
    Size = UDim2.new(1, 0, 0, 38),
    BackgroundColor3 = Color3.fromRGB(255, 70, 70),
    Text = "СТОП ВСЁ",
    TextColor3 = Color3.new(1, 1, 1),
    Font = Enum.Font.GothamBold,
    TextSize = 15,
    BorderSizePixel = 0
})
Instance.new("UICorner", StopBtn).CornerRadius = UDim.new(0, 6)

-- Инфо
createElement("TextLabel", {
    Size = UDim2.new(1, 0, 0, 30),
    BackgroundTransparency = 1,
    Text = "Штанга: 2284, 49, 5903\nПредметы: 2554→2542 по 0.5с",
    TextColor3 = Color3.fromRGB(120, 120, 130),
    Font = Enum.Font.GothamMedium,
    TextSize = 9,
    TextXAlignment = Enum.TextXAlignment.Left
})

-- ==================== ЛОГИКА ТОГГЛОВ ====================

local farmOn = false
local liftOn = false

local function updateFarmVisual()
    if farmOn then
        FarmToggle.BackgroundColor3 = Color3.fromRGB(80, 200, 120)
        FarmCircle.Position = UDim2.new(1, -21, 0.5, -9)
    else
        FarmToggle.BackgroundColor3 = Color3.fromRGB(200, 70, 70)
        FarmCircle.Position = UDim2.new(0, 3, 0.5, -9)
    end
    updateStatus()
end

local function updateLiftVisual()
    if liftOn then
        LiftToggle.BackgroundColor3 = Color3.fromRGB(80, 200, 120)
        LiftCircle.Position = UDim2.new(1, -21, 0.5, -9)
    else
        LiftToggle.BackgroundColor3 = Color3.fromRGB(200, 70, 70)
        LiftCircle.Position = UDim2.new(0, 3, 0.5, -9)
    end
    updateStatus()
end

function updateStatus()
    if farmOn and liftOn then
        StatusLabel.Text = "Статус: Штанга + Предметы работают"
    elseif farmOn then
        StatusLabel.Text = "Статус: Штанга работает"
    elseif liftOn then
        StatusLabel.Text = "Статус: Предметы работают"
    else
        StatusLabel.Text = "Статус: Выключено"
    end
end

FarmToggle.MouseButton1Click:Connect(function()
    farmOn = not farmOn
    AutoFarmEnabled = farmOn
    updateFarmVisual()
    
    if farmOn then
        task.spawn(autoFarm)
    else
        unfreezeCharacter()
    end
end)

LiftToggle.MouseButton1Click:Connect(function()
    liftOn = not liftOn
    AutoLiftEnabled = liftOn
    updateLiftVisual()
    
    if liftOn then
        task.spawn(liftLoop)
    end
end)

StopBtn.MouseButton1Click:Connect(function()
    farmOn = false
    liftOn = false
    AutoFarmEnabled = false
    AutoLiftEnabled = false
    unfreezeCharacter()
    updateFarmVisual()
    updateLiftVisual()
end)

updateFarmVisual()
updateLiftVisual()

print("=":rep(40))
print("TWEAK STRONGEST SIMULATOR v9 ЗАГРУЖЕН")
print("Авто-штанга: ТП → заморозка → 0.5с → зажать 1с → клики 0.7с")
print("Авто-предметы: ТП к предмету → Взять → ТП на финиш (0.5с цикл)")
print("Если не работает - открой F9 и смотри консоль на ошибки")
print("=":rep(40))
