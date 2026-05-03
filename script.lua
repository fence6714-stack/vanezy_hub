--[[
    STRONGEST_SIMULATOR_TWEAK_v3_FINAL.lua
    GUI: 380x420 (компактный)
    Авто-штанга: ЗАВИСАНИЕ В ВОЗДУХЕ (CFrame заморозка)
    Клики: БЕЗ КУЛДАУНА (мгновенный спам VirtualInputManager)
    Телепорт: мгновенный, без твинов
--]]

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    HumanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
    Humanoid = newChar:WaitForChild("Humanoid")
    -- Если авто-штанга была включена, перезапустить зависание
    if AutoFarmEnabled then
        freezeCharacter()
    end
end)

-- ==================== ДАННЫЕ ====================
local Locations = {
    ["Последняя локация"] = Vector3.new(2284.360, 49.147, 5903.271),
    ["Локация 1"] = Vector3.new(342.120, 15.450, 1024.870),
    ["Локация 2"] = Vector3.new(890.450, 22.100, 1340.560),
    ["Локация 3"] = Vector3.new(1150.780, 30.890, 2150.340),
    ["Локация 4"] = Vector3.new(1670.230, 45.670, 3480.910),
    ["Локация 5"] = Vector3.new(2010.590, 48.230, 4720.650),
    ["Локация 6"] = Vector3.new(2284.360, 49.147, 5903.271)
}

local TrainingPosition = Vector3.new(2284.360, 49.147, 5903.271)
local LiftStartPosition = Vector3.new(2554.064, 13.710, 5502.688)
local LiftFinishPosition = Vector3.new(2542.465, 13.186, 6129.139)

local SelectedLocation = "Последняя локация"
local AutoFarmEnabled = false
local AutoLiftEnabled = false
local freezeConnection = nil

-- ==================== УТИЛИТЫ ====================

-- Мгновенный телепорт
local function teleportTo(pos)
    if Character and HumanoidRootPart then
        HumanoidRootPart.CFrame = CFrame.new(pos)
    end
end

-- ЗАВИСАНИЕ В ВОЗДУХЕ (CFrame заморозка)
local function freezeCharacter()
    if not Character or not HumanoidRootPart then return end
    
    -- Отключаем предыдущую заморозку если была
    if freezeConnection then
        freezeConnection:Disconnect()
        freezeConnection = nil
    end
    
    local frozenCFrame = HumanoidRootPart.CFrame
    
    -- Каждый кадр (RenderStepped) возвращаем персонажа в замороженную позицию
    freezeConnection = RunService.RenderStepped:Connect(function()
        if Character and HumanoidRootPart then
            -- Сохраняем ту же высоту (Y) но фиксируем позицию
            frozenCFrame = CFrame.new(frozenCFrame.X, frozenCFrame.Y, frozenCFrame.Z)
            HumanoidRootPart.CFrame = frozenCFrame
            HumanoidRootPart.Velocity = Vector3.new(0, 0, 0) -- обнуляем скорость
            if Humanoid then
                Humanoid.PlatformStand = true -- персонаж зависает в воздухе (как при клике)
            end
        end
    end)
end

-- Разморозка персонажа
local function unfreezeCharacter()
    if freezeConnection then
        freezeConnection:Disconnect()
        freezeConnection = nil
    end
    if Character and Humanoid then
        Humanoid.PlatformStand = false -- возвращаем нормальное состояние
    end
end

-- Мгновенный клик (без кулдауна)
local function instantClick()
    -- Используем Button1Down/Button1Up напрямую = мгновенный клик без задержки
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
end

-- Спам кликов (мгновенно, без wait)
local function clickSpam(amount)
    amount = amount or 20
    for i = 1, amount do
        instantClick()
    end
end

-- Поиск кнопок в GUI
local function findButton(name)
    for _, obj in pairs(game:GetDescendants()) do
        if (obj:IsA("TextButton") or obj:IsA("ImageButton")) and obj.Name == name then
            return obj
        end
    end
    return nil
end

-- Нажатие кнопки тренировки
local function activateTraining()
    local btn = findButton("Train") or findButton("TrainButton") or findButton("Качаться")
    if btn then
        local absPos = btn.AbsolutePosition
        local absSize = btn.AbsoluteSize
        VirtualInputManager:SendMouseButtonEvent(absPos.X + absSize.X/2, absPos.Y + absSize.Y/2, 0, true, game, 1)
        VirtualInputManager:SendMouseButtonEvent(absPos.X + absSize.X/2, absPos.Y + absSize.Y/2, 0, false, game, 1)
    else
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
    end
end

-- Поднятие предмета
local function liftObject()
    local btn = findButton("Lift") or findButton("Grab") or findButton("Поднять")
    if btn then
        local absPos = btn.AbsolutePosition
        local absSize = btn.AbsoluteSize
        VirtualInputManager:SendMouseButtonEvent(absPos.X + absSize.X/2, absPos.Y + absSize.Y/2, 0, true, game, 1)
        VirtualInputManager:SendMouseButtonEvent(absPos.X + absSize.X/2, absPos.Y + absSize.Y/2, 0, false, game, 1)
    else
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
    end
end

-- Проверка предмета в руках
local function hasObject()
    if not Character then return false end
    for _, child in pairs(Character:GetChildren()) do
        if child:IsA("Tool") then return true end
    end
    return false
end

-- ==================== ЦИКЛЫ БОТА ====================

-- Авто-штанга (с зависанием)
local function autoFarmLoop()
    while AutoFarmEnabled do
        if not Character or not HumanoidRootPart then
            Character = LocalPlayer.Character
            if Character then 
                HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
                Humanoid = Character:WaitForChild("Humanoid")
            end
        end
        
        if Character and HumanoidRootPart then
            -- Телепорт к штанге
            teleportTo(TrainingPosition)
            
            -- Заморозка в воздухе
            freezeCharacter()
            
            -- Нажатие кнопки тренировки
            activateTraining()
            
            -- Мгновенный спам кликов (без кулдауна)
            clickSpam(30)
        end
        
        task.wait(0.05) -- Минимальная задержка для цикла
    end
    -- Если цикл остановлен, размораживаем
    unfreezeCharacter()
end

-- Авто-поднятие предметов
local function autoLiftLoop()
    while AutoLiftEnabled do
        if not Character or not HumanoidRootPart then
            Character = LocalPlayer.Character
            if Character then 
                HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
            end
        end
        
        if Character and HumanoidRootPart then
            teleportTo(LiftStartPosition)
            task.wait(0.3)
            
            liftObject()
            task.wait(0.2)
            
            if hasObject() then
                teleportTo(LiftFinishPosition)
                task.wait(0.15)
                liftObject()
                task.wait(0.1)
            end
        end
        task.wait(0.3)
    end
end

-- ==================== GUI КОМПАКТНЫЙ ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TWEAK_UI"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 380, 0, 420)
MainFrame.Position = UDim2.new(1, -400, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 38)
Header.BackgroundColor3 = Color3.fromRGB(140, 100, 255)
Header.BorderSizePixel = 0
Header.Parent = MainFrame
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 10)

local HeaderText = Instance.new("TextLabel")
HeaderText.Size = UDim2.new(1, -20, 1, 0)
HeaderText.Position = UDim2.new(0, 15, 0, 0)
HeaderText.BackgroundTransparency = 1
HeaderText.Text = "Strongest Sim | TWEAK v3"
HeaderText.TextColor3 = Color3.fromRGB(255, 255, 255)
HeaderText.Font = Enum.Font.GothamBold
HeaderText.TextSize = 16
HeaderText.TextXAlignment = Enum.TextXAlignment.Left
HeaderText.Parent = Header

local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(0, 100, 1, -38)
TabContainer.Position = UDim2.new(0, 0, 0, 38)
TabContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
TabContainer.BorderSizePixel = 0
TabContainer.Parent = MainFrame

local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -100, 1, -38)
ContentContainer.Position = UDim2.new(0, 100, 0, 38)
ContentContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
ContentContainer.BorderSizePixel = 0
ContentContainer.Parent = MainFrame

-- Вкладки
local tabs = {}
local activeContent = nil

local function createTab(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -8, 0, 30)
    btn.Position = UDim2.new(0, 4, 0, #tabs * 34 + 4)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(180, 180, 190)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 12
    btn.BorderSizePixel = 0
    btn.Parent = TabContainer
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    
    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1, -8, 1, -8)
    content.Position = UDim2.new(0, 4, 0, 4)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 3
    content.ScrollBarImageColor3 = Color3.fromRGB(140, 100, 255)
    content.CanvasSize = UDim2.new(0, 0, 0, 400)
    content.Visible = false
    content.Parent = ContentContainer
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 6)
    layout.Parent = content
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        content.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 15)
    end)
    
    local elements = {}
    
    btn.MouseButton1Click:Connect(function()
        for _, tab in pairs(tabs) do
            tab.content.Visible = false
            tab.btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
            tab.btn.TextColor3 = Color3.fromRGB(180, 180, 190)
        end
        content.Visible = true
        btn.BackgroundColor3 = Color3.fromRGB(140, 100, 255)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        activeContent = content
    end)
    
    if #tabs == 0 then
        content.Visible = true
        btn.BackgroundColor3 = Color3.fromRGB(140, 100, 255)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        activeContent = content
    end
    
    local tabObj = { btn = btn, content = content, elements = elements }
    
    function tabObj:createSection(name)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 0, 18)
        lbl.BackgroundTransparency = 1
        lbl.Text = name
        lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 11
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.LayoutOrder = #elements + 1
        lbl.Parent = content
        table.insert(elements, lbl)
        return lbl
    end
    
    function tabObj:createToggle(config)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 36)
        frame.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        frame.BorderSizePixel = 0
        frame.LayoutOrder = #elements + 1
        frame.Parent = content
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.65, 0, 1, 0)
        label.Position = UDim2.new(0, 8, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = config.Name or "Toggle"
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.Font = Enum.Font.GothamMedium
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        local toggleBtn = Instance.new("TextButton")
        toggleBtn.Size = UDim2.new(0, 44, 0, 22)
        toggleBtn.Position = UDim2.new(1, -52, 0.5, -11)
        toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 70, 70)
        toggleBtn.Text = ""
        toggleBtn.BorderSizePixel = 0
        toggleBtn.Parent = frame
        Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 11)
        
        local circle = Instance.new("Frame")
        circle.Size = UDim2.new(0, 16, 0, 16)
        circle.Position = UDim2.new(0, 3, 0.5, -8)
        circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        circle.BorderSizePixel = 0
        circle.Parent = toggleBtn
        Instance.new("UICorner", circle).CornerRadius = UDim.new(0, 8)
        
        local enabled = config.CurrentValue or false
        
        local function updateVis()
            if enabled then
                toggleBtn.BackgroundColor3 = Color3.fromRGB(80, 200, 120)
                circle.Position = UDim2.new(1, -19, 0.5, -8)
            else
                toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 70, 70)
                circle.Position = UDim2.new(0, 3, 0.5, -8)
            end
        end
        
        toggleBtn.MouseButton1Click:Connect(function()
            enabled = not enabled
            updateVis()
            if config.Callback then config.Callback(enabled) end
        end)
        
        updateVis()
        table.insert(elements, frame)
        
        return {
            Set = function(_, val) enabled = val; updateVis() end,
            Get = function() return enabled end
        }
    end
    
    function tabObj:createDropdown(config)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 40)
        frame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        frame.BorderSizePixel = 0
        frame.LayoutOrder = #elements + 1
        frame.Parent = content
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -40, 0, 16)
        label.Position = UDim2.new(0, 8, 0, 2)
        label.BackgroundTransparency = 1
        label.Text = config.Name or "Dropdown"
        label.TextColor3 = Color3.fromRGB(180, 180, 190)
        label.Font = Enum.Font.GothamMedium
        label.TextSize = 10
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        local selected = Instance.new("TextLabel")
        selected.Size = UDim2.new(1, -40, 0, 18)
        selected.Position = UDim2.new(0, 8, 0, 18)
        selected.BackgroundTransparency = 1
        selected.Text = config.CurrentOption or config.Options[1]
        selected.TextColor3 = Color3.fromRGB(255, 255, 255)
        selected.Font = Enum.Font.GothamBold
        selected.TextSize = 12
        selected.TextXAlignment = Enum.TextXAlignment.Left
        selected.Parent = frame
        
        local arrow = Instance.new("TextButton")
        arrow.Size = UDim2.new(0, 26, 0, 26)
        arrow.Position = UDim2.new(1, -30, 0, 7)
        arrow.BackgroundColor3 = Color3.fromRGB(140, 100, 255)
        arrow.Text = "▼"
        arrow.TextColor3 = Color3.fromRGB(255, 255, 255)
        arrow.Font = Enum.Font.GothamBold
        arrow.TextSize = 10
        arrow.BorderSizePixel = 0
        arrow.Parent = frame
        Instance.new("UICorner", arrow).CornerRadius = UDim.new(0, 5)
        
        local optsFrame = Instance.new("Frame")
        optsFrame.Size = UDim2.new(1, 0, 0, 0)
        optsFrame.Position = UDim2.new(0, 0, 1, 3)
        optsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        optsFrame.BorderSizePixel = 0
        optsFrame.Visible = false
        optsFrame.ZIndex = 10
        optsFrame.Parent = frame
        Instance.new("UICorner", optsFrame).CornerRadius = UDim.new(0, 6)
        
        local optsList = Instance.new("UIListLayout")
        optsList.SortOrder = Enum.SortOrder.LayoutOrder
        optsList.Parent = optsFrame
        
        for i, opt in ipairs(config.Options) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, -4, 0, 26)
            optBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 72)
            optBtn.Text = opt
            optBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            optBtn.Font = Enum.Font.GothamMedium
            optBtn.TextSize = 11
            optBtn.BorderSizePixel = 0
            optBtn.ZIndex = 11
            optBtn.LayoutOrder = i
            optBtn.Parent = optsFrame
            Instance.new("UICorner", optBtn).CornerRadius = UDim.new(0, 4)
            
            optBtn.MouseButton1Click:Connect(function()
                selected.Text = opt
                optsFrame.Visible = false
                frame.Size = UDim2.new(1, 0, 0, 40)
                if config.Callback then config.Callback(opt) end
            end)
        end
        
        local open = false
        arrow.MouseButton1Click:Connect(function()
            open = not open
            if open then
                optsFrame.Visible = true
                optsFrame.Size = UDim2.new(1, 0, 0, #config.Options * 28 + 4)
                frame.Size = UDim2.new(1, 0, 0, 40 + #config.Options * 28 + 8)
                arrow.Text = "▲"
            else
                optsFrame.Visible = false
                frame.Size = UDim2.new(1, 0, 0, 40)
                arrow.Text = "▼"
            end
            content.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 15)
        end)
        
        table.insert(elements, frame)
        return {
            Set = function(_, opt) selected.Text = opt end,
            Get = function() return selected.Text end
        }
    end
    
    function tabObj:createButton(config)
        local btn2 = Instance.new("TextButton")
        btn2.Size = UDim2.new(1, 0, 0, 34)
        btn2.BackgroundColor3 = Color3.fromRGB(140, 100, 255)
        btn2.Text = config.Name or "Button"
        btn2.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn2.Font = Enum.Font.GothamBold
        btn2.TextSize = 13
        btn2.BorderSizePixel = 0
        btn2.LayoutOrder = #elements + 1
        btn2.Parent = content
        Instance.new("UICorner", btn2).CornerRadius = UDim.new(0, 6)
        
        btn2.MouseButton1Click:Connect(function()
            if config.Callback then config.Callback() end
        end)
        
        table.insert(elements, btn2)
        return btn2
    end
    
    function tabObj:createLabel(config)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 0, 20)
        lbl.BackgroundTransparency = 1
        lbl.Text = config.Text or "Label"
        lbl.TextColor3 = Color3.fromRGB(180, 180, 190)
        lbl.Font = Enum.Font.GothamMedium
        lbl.TextSize = 11
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.LayoutOrder = #elements + 1
        lbl.Parent = content
        table.insert(elements, lbl)
        return { Set = function(_, t) lbl.Text = t end }
    end
    
    table.insert(tabs, tabObj)
    return tabObj
end

-- ==================== СТРОИМ ГЛАВНУЮ ВКЛАДКУ ====================
local MainTab = createTab("Главная")

MainTab:createSection("Телепортация")

local locDropdown = MainTab:createDropdown({
    Name = "Локация",
    Options = {"Последняя локация", "Локация 1", "Локация 2", "Локация 3", "Локация 4", "Локация 5", "Локация 6"},
    CurrentOption = "Последняя локация",
    Callback = function(opt) SelectedLocation = opt end
})

local locLabel = MainTab:createLabel({ Text = "Выбрано: Последняя локация" })

MainTab:createButton({
    Name = "Телепорт",
    Callback = function()
        local pos = Locations[SelectedLocation] or TrainingPosition
        teleportTo(pos)
        locLabel:Set("Телепорт: " .. SelectedLocation)
    end
})

MainTab:createSection("Автоматизация")

local farmToggle = MainTab:createToggle({
    Name = "Авто-штанга (зависание)",
    CurrentValue = false,
    Callback = function(val)
        AutoFarmEnabled = val
        if val then
            task.spawn(autoFarmLoop)
        else
            unfreezeCharacter()
        end
    end
})

local liftToggle = MainTab:createToggle({
    Name = "Авто-поднятие предметов",
    CurrentValue = false,
    Callback = function(val)
        AutoLiftEnabled = val
        if val then
            task.spawn(autoLiftLoop)
        end
    end
})

local statusLabel = MainTab:createLabel({ Text = "Статус: Готов" })

MainTab:createButton({
    Name = "СТОП ВСЁ",
    Callback = function()
        AutoFarmEnabled = false
        AutoLiftEnabled = false
        unfreezeCharacter()
        farmToggle:Set(false)
        liftToggle:Set(false)
        statusLabel:Set("Статус: Остановлено")
    end
})

-- ==================== ВКЛАДКА ИНФО ====================
local InfoTab = createTab("Инфо")
InfoTab:createSection("Координаты")
InfoTab:createLabel({ Text = "Штанга: 2284, 49, 5903" })
InfoTab:createLabel({ Text = "Предметы: 2554, 13, 5502" })
InfoTab:createLabel({ Text = "Финиш: 2542, 13, 6129" })
InfoTab:createLabel({ Text = "Версия: v3 Final" })
InfoTab:createLabel({ Text = "GUI: 380x420 | 0 HTTP" })

statusLabel:Set("Статус: Готов к работе")
print("=== TWEAK STRONGEST SIMULATOR v3 FINAL LOADED ===")
print("Фичи: Зависание в воздухе + Мгновенные клики + Компактный GUI")
