--[[
    SYNAPSE STYLE UI v5 - FULLY FIXED
    + SpeedHack, Noclip, Fly, InfiniteJump, Silent Aim
    No ?. operator, full nil protection, executor compatible
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
if not player then
    player = Players.PlayerAdded:Wait()
end

-- Values storage
local StorageValues = Instance.new("Folder")
StorageValues.Name = "UISettings"
StorageValues.Parent = player

local function loadValue(name, default)
    local val = StorageValues:GetAttribute(name)
    if val ~= nil then return val end
    return default
end

local function saveValue(name, value)
    StorageValues:SetAttribute(name, value)
end

-- Load settings
local savedWalkSpeed = loadValue("WalkSpeed", 16)
local savedJumpPower = loadValue("JumpPower", 50)
local savedFOV = loadValue("FOV", 70)
local savedAutoWalk = loadValue("AutoWalk", false)
local savedESP = loadValue("ESP", false)
local savedSpeedHack = loadValue("SpeedHack", false)
local savedNoclip = loadValue("Noclip", false)
local savedFly = loadValue("Fly", false)
local savedInfiniteJump = loadValue("InfiniteJump", false)
local savedSilentAim = loadValue("SilentAim", false)
local savedWalkspeedValue = loadValue("WalkspeedValue", 50)
local savedJumppowerValue = loadValue("JumppowerValue", 80)

-- State
local autoWalkEnabled = savedAutoWalk
local autoWalkConnection = nil
local espEnabled = savedESP
local espHighlights = {}
local espBillboards = {}
local speedHackEnabled = savedSpeedHack
local noclipEnabled = savedNoclip
local flyEnabled = savedFly
local infiniteJumpEnabled = savedInfiniteJump
local silentAimEnabled = savedSilentAim
local currentWalkspeedValue = savedWalkspeedValue
local currentJumppowerValue = savedJumppowerValue

-- Fly variables
local flyBodyVel = nil
local flyBodyGyro = nil
local flyConnection = nil
local keysPressed = {}

-- Noclip connection
local noclipConnection = nil

-- Infinite jump connection
local infiniteJumpConnection = nil

-- Silent aim
local oldCameraCFrameHook = nil

-- Character variables
local character = nil
local humanoid = nil
local camera = nil

-- Keyboard state
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    keysPressed[input.KeyCode.Name] = true
end)

UserInputService.InputEnded:Connect(function(input, gpe)
    if gpe then return end
    keysPressed[input.KeyCode.Name] = false
end)

local function getChar()
    local char = player.Character
    if char then
        character = char
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            humanoid = hum
            if speedHackEnabled then
                humanoid.WalkSpeed = currentWalkspeedValue
            else
                humanoid.WalkSpeed = savedWalkSpeed
            end
            if infiniteJumpEnabled then
                humanoid.JumpPower = currentJumppowerValue
            else
                humanoid.JumpPower = savedJumpPower
            end
        end
    end
    if Workspace.CurrentCamera then
        camera = Workspace.CurrentCamera
        camera.FieldOfView = savedFOV
    end
end

getChar()

if not character then
    character = player.CharacterAdded:Wait()
    humanoid = character:WaitForChild("Humanoid")
    humanoid.WalkSpeed = speedHackEnabled and currentWalkspeedValue or savedWalkSpeed
    humanoid.JumpPower = infiniteJumpEnabled and currentJumppowerValue or savedJumpPower
end
if not camera then
    camera = Workspace.CurrentCamera
    if camera then
        camera.FieldOfView = savedFOV
    end
end

-- =========== SILENT AIM HOOK ===========
local function setupSilentAim()
    if oldCameraCFrameHook then
        -- restore later if needed
    end
    
    if not camera then return end
    
    local mt = getrawmetatable(camera)
    if mt then
        local oldIndex = mt.__index
        setreadonly(mt, false)
        mt.__index = function(self, key)
            if key == "CFrame" and silentAimEnabled then
                local target = nil
                local maxDist = 120
                local localPos = nil
                
                local char = player.Character
                if char then
                    localPos = char:FindFirstChild("HumanoidRootPart")
                end
                
                if localPos then
                    for _, plr in pairs(Players:GetPlayers()) do
                        if plr ~= player and plr.Character then
                            local root = plr.Character:FindFirstChild("HumanoidRootPart")
                            if root then
                                local dist = (root.Position - localPos.Position).Magnitude
                                if dist < maxDist then
                                    maxDist = dist
                                    target = plr
                                end
                            end
                        end
                    end
                end
                
                if target and target.Character then
                    local head = target.Character:FindFirstChild("Head")
                    local localHead = nil
                    if char then
                        localHead = char:FindFirstChild("Head")
                    end
                    if head and localHead then
                        local dir = (head.Position - localHead.Position).Unit
                        local origCF = oldIndex(self, key)
                        return CFrame.new(origCF.Position, origCF.Position + dir * 100)
                    end
                end
            end
            return oldIndex(self, key)
        end
        setreadonly(mt, true)
    end
end

-- =========== SPEED HACK ===========
local function applySpeedHack(state)
    local char = player.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            if state then
                hum.WalkSpeed = currentWalkspeedValue
            else
                hum.WalkSpeed = savedWalkSpeed
            end
        end
    end
end

-- =========== NOCLIP ===========
local function toggleNoclip(state)
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    if state then
        noclipConnection = RunService.Stepped:Connect(function()
            local char = player.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end
end

-- =========== FLY ===========
local function toggleFly(state)
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    if flyBodyVel and flyBodyVel.Parent then
        flyBodyVel:Destroy()
    end
    if flyBodyGyro and flyBodyGyro.Parent then
        flyBodyGyro:Destroy()
    end
    
    if state then
        local char = player.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        flyBodyVel = Instance.new("BodyVelocity")
        flyBodyVel.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        flyBodyVel.P = 1e4
        flyBodyVel.Parent = hrp
        
        flyBodyGyro = Instance.new("BodyGyro")
        flyBodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
        flyBodyGyro.P = 1e5
        flyBodyGyro.Parent = hrp
        
        flyConnection = RunService.RenderStepped:Connect(function()
            if not flyEnabled then return end
            local char = player.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            if not flyBodyVel or not flyBodyGyro then return end
            
            local moveVector = Vector3.new(
                (keysPressed["D"] and 1 or 0) - (keysPressed["A"] and 1 or 0),
                (keysPressed["E"] and 1 or 0) - (keysPressed["Q"] and 1 or 0),
                (keysPressed["W"] and 1 or 0) - (keysPressed["S"] and 1 or 0)
            )
            
            if moveVector.Magnitude > 0 then
                moveVector = moveVector.Unit
            end
            
            local cam = Workspace.CurrentCamera
            if cam then
                local vel = (cam.CFrame.RightVector * moveVector.X + cam.CFrame.UpVector * moveVector.Y + cam.CFrame.LookVector * moveVector.Z) * 80
                flyBodyVel.Velocity = vel
                flyBodyGyro.CFrame = cam.CFrame
            end
        end)
    end
end

-- =========== INFINITE JUMP ===========
local function toggleInfiniteJump(state)
    if infiniteJumpConnection then
        infiniteJumpConnection:Disconnect()
        infiniteJumpConnection = nil
    end
    if state then
        infiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
            local char = player.Character
            if char then
                local hum = char:FindFirstChild("Humanoid")
                if hum and hum:GetState() ~= Enum.HumanoidStateType.Jumping then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
    end
end

-- =========== ESP SYSTEM ===========
local function updateESP()
    if not espEnabled then
        for _, hl in pairs(espHighlights) do
            pcall(function() hl:Destroy() end)
        end
        espHighlights = {}
        for _, bb in pairs(espBillboards) do
            pcall(function() bb:Destroy() end)
        end
        espBillboards = {}
        return
    end
    
    for _, plr in pairs(Players:GetPlayers()) do
        if plr == player then goto continue end
        
        local char = plr.Character
        if not char then
            if espHighlights[plr.UserId] then
                espHighlights[plr.UserId]:Destroy()
                espHighlights[plr.UserId] = nil
            end
            if espBillboards[plr.UserId] then
                espBillboards[plr.UserId]:Destroy()
                espBillboards[plr.UserId] = nil
            end
            goto continue
        end
        
        local rootPart = char:FindFirstChild("HumanoidRootPart")
        local head = char:FindFirstChild("Head")
        if not rootPart then goto continue end
        
        local existingHL = espHighlights[plr.UserId]
        if not existingHL or existingHL.Parent ~= char then
            if existingHL then existingHL:Destroy() end
            local highlight = Instance.new("Highlight")
            highlight.FillColor = Color3.fromRGB(255, 60, 60)
            highlight.FillTransparency = 0.4
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.OutlineTransparency = 0.2
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.Adornee = char
            highlight.Parent = char
            espHighlights[plr.UserId] = highlight
        end
        
        if head then
            local existingBB = espBillboards[plr.UserId]
            if not existingBB or existingBB.Parent ~= head then
                if existingBB then existingBB:Destroy() end
                
                local billboard = Instance.new("BillboardGui")
                billboard.Size = UDim2.new(0, 200, 0, 50)
                billboard.StudsOffset = Vector3.new(0, 2.5, 0)
                billboard.AlwaysOnTop = true
                billboard.MaxDistance = 500
                billboard.Parent = head
                
                local nameLabel = Instance.new("TextLabel")
                nameLabel.Text = plr.Name
                nameLabel.Font = Enum.Font.GothamBold
                nameLabel.TextSize = 14
                nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                nameLabel.BackgroundTransparency = 1
                nameLabel.Size = UDim2.new(1, 0, 0, 25)
                nameLabel.TextStrokeTransparency = 0.3
                nameLabel.Parent = billboard
                
                local distLabel = Instance.new("TextLabel")
                distLabel.Name = "Distance"
                distLabel.Font = Enum.Font.Gotham
                distLabel.TextSize = 12
                distLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                distLabel.BackgroundTransparency = 1
                distLabel.Size = UDim2.new(1, 0, 0, 20)
                distLabel.Position = UDim2.new(0, 0, 0, 25)
                distLabel.TextStrokeTransparency = 0.3
                distLabel.Parent = billboard
                
                espBillboards[plr.UserId] = billboard
            end
            
            local myChar = player.Character
            if myChar then
                local myRoot = myChar:FindFirstChild("HumanoidRootPart")
                if myRoot then
                    local distance = (myRoot.Position - rootPart.Position).Magnitude
                    local bb = espBillboards[plr.UserId]
                    if bb then
                        local distLabel = bb:FindFirstChild("Distance")
                        if distLabel then
                            distLabel.Text = string.format("%.1fm", distance)
                        end
                    end
                end
            end
        end
        
        ::continue::
    end
end

-- ESP update loop
RunService.Heartbeat:Connect(updateESP)

-- =========== SAFE PLAYERGUI GETTER ===========
local function getGui()
    local gui = player:FindFirstChild("PlayerGui")
    if not gui then
        pcall(function()
            gui = player:WaitForChild("PlayerGui", 5)
        end)
    end
    return gui
end

-- =========== CREATE GUI ===========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SynapseUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local parentGui = getGui()
if parentGui then
    ScreenGui.Parent = parentGui
else
    local success = pcall(function()
        local CoreGui = game:GetService("CoreGui")
        ScreenGui.Parent = CoreGui
    end)
    if not success then
        ScreenGui.Parent = game:GetService("StarterGui")
    end
end

-- =========== LOADING SCREEN ===========
local LoadingFrame = Instance.new("Frame")
LoadingFrame.Size = UDim2.new(1, 0, 1, 0)
LoadingFrame.BackgroundTransparency = 1
LoadingFrame.ZIndex = 100
LoadingFrame.Parent = ScreenGui

local LoadingText = Instance.new("TextLabel")
LoadingText.Text = "TWKS | SYNAPSE UI v5"
LoadingText.Font = Enum.Font.GothamBold
LoadingText.TextSize = 24
LoadingText.TextColor3 = Color3.fromRGB(0, 140, 255)
LoadingText.BackgroundTransparency = 1
LoadingText.TextTransparency = 1
LoadingText.Size = UDim2.new(0, 250, 0, 50)
LoadingText.Position = UDim2.new(0.5, -125, 0.5, -25)
LoadingText.ZIndex = 101
LoadingText.Parent = LoadingFrame

local fadeIn = TweenService:Create(LoadingText, TweenInfo.new(0.5), {TextTransparency = 0})
fadeIn:Play()
fadeIn.Completed:Connect(function()
    task.wait(1.0)
    local fadeOut = TweenService:Create(LoadingText, TweenInfo.new(0.5), {TextTransparency = 1})
    fadeOut:Play()
    fadeOut.Completed:Connect(function()
        LoadingFrame:Destroy()
    end)
end)

-- =========== MAIN WINDOW ===========
local MainContainer = Instance.new("Frame")
MainContainer.Size = UDim2.new(0, 550, 0, 560)
MainContainer.Position = UDim2.new(0.5, -275, 0.5, -280)
MainContainer.BackgroundTransparency = 1
MainContainer.ZIndex = 10
MainContainer.Parent = ScreenGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(1, 0, 1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
MainFrame.BorderSizePixel = 0
MainFrame.ZIndex = 10
MainFrame.Parent = MainContainer

local MainBorder = Instance.new("UIStroke")
MainBorder.Color = Color3.fromRGB(0, 140, 255)
MainBorder.Thickness = 1
MainBorder.Parent = MainFrame

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- =========== DRAG SYSTEM ===========
local isDraggingWindow = false
local dragStartPos = nil
local dragStartGuiPos = nil
local moveConnection = nil
local releaseConnection = nil

local function getInputPosition(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        return input.Position
    elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
        return input.Position
    elseif input.UserInputType == Enum.UserInputType.Touch then
        return input.Position
    end
    return nil
end

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 11
TitleBar.Active = true
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Text = "TWKS SYNAPSE UI v5 | CORE"
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 15
TitleText.TextColor3 = Color3.fromRGB(0, 140, 255)
TitleText.BackgroundTransparency = 1
TitleText.Size = UDim2.new(1, -120, 1, 0)
TitleText.Position = UDim2.new(0, 15, 0, 0)
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.ZIndex = 12
TitleText.Parent = TitleBar

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local pos = getInputPosition(input)
        if pos then
            isDraggingWindow = true
            dragStartPos = pos
            dragStartGuiPos = MainContainer.Position

            if moveConnection then moveConnection:Disconnect() end
            moveConnection = UserInputService.InputChanged:Connect(function(moveInput)
                if isDraggingWindow then
                    if moveInput.UserInputType == Enum.UserInputType.MouseMovement or moveInput.UserInputType == Enum.UserInputType.Touch then
                        local movePos = getInputPosition(moveInput)
                        if movePos and dragStartPos then
                            local delta = movePos - dragStartPos
                            MainContainer.Position = UDim2.new(
                                dragStartGuiPos.X.Scale, 
                                dragStartGuiPos.X.Offset + delta.X, 
                                dragStartGuiPos.Y.Scale, 
                                dragStartGuiPos.Y.Offset + delta.Y
                            )
                        end
                    end
                end
            end)

            if releaseConnection then releaseConnection:Disconnect() end
            releaseConnection = UserInputService.InputEnded:Connect(function(endInput)
                if endInput.UserInputType == input.UserInputType then
                    isDraggingWindow = false
                    dragStartPos = nil
                    if moveConnection then moveConnection:Disconnect() end
                    if releaseConnection then releaseConnection:Disconnect() end
                end
            end)
        end
    end
end)

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 32, 1, -6)
MinimizeButton.Position = UDim2.new(1, -76, 0, 3)
MinimizeButton.Text = "—"
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.TextSize = 20
MinimizeButton.TextColor3 = Color3.fromRGB(180, 180, 180)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
MinimizeButton.BorderSizePixel = 0
MinimizeButton.ZIndex = 12
MinimizeButton.Parent = TitleBar

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 32, 1, -6)
CloseButton.Position = UDim2.new(1, -38, 0, 3)
CloseButton.Text = "✕"
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 18
CloseButton.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseButton.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
CloseButton.BorderSizePixel = 0
CloseButton.ZIndex = 12
CloseButton.Parent = TitleBar

local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(0, 130, 1, -40)
TabFrame.Position = UDim2.new(0, 0, 0, 40)
TabFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
TabFrame.BorderSizePixel = 0
TabFrame.ZIndex = 11
TabFrame.Parent = MainFrame

local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -130, 1, -40)
ContentContainer.Position = UDim2.new(0, 130, 0, 40)
ContentContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
ContentContainer.BorderSizePixel = 0
ContentContainer.ClipsDescendants = true
ContentContainer.ZIndex = 11
ContentContainer.Parent = MainFrame

-- Tab buttons
local MainTab = Instance.new("TextButton")
MainTab.Text = "MAIN"
MainTab.Font = Enum.Font.GothamBold
MainTab.TextSize = 13
MainTab.Size = UDim2.new(1, -16, 0, 38)
MainTab.Position = UDim2.new(0, 8, 0, 12)
MainTab.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
MainTab.TextColor3 = Color3.fromRGB(255, 255, 255)
MainTab.BorderSizePixel = 0
MainTab.ZIndex = 12
MainTab.AutoButtonColor = false
MainTab.Parent = TabFrame

local CombatTab = Instance.new("TextButton")
CombatTab.Text = "COMBAT"
CombatTab.Font = Enum.Font.GothamBold
CombatTab.TextSize = 13
CombatTab.Size = UDim2.new(1, -16, 0, 38)
CombatTab.Position = UDim2.new(0, 8, 0, 58)
CombatTab.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
CombatTab.TextColor3 = Color3.fromRGB(150, 150, 150)
CombatTab.BorderSizePixel = 0
CombatTab.ZIndex = 12
CombatTab.AutoButtonColor = false
CombatTab.Parent = TabFrame

local VisualTab = Instance.new("TextButton")
VisualTab.Text = "VISUAL"
VisualTab.Font = Enum.Font.GothamBold
VisualTab.TextSize = 13
VisualTab.Size = UDim2.new(1, -16, 0, 38)
VisualTab.Position = UDim2.new(0, 8, 0, 104)
VisualTab.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
VisualTab.TextColor3 = Color3.fromRGB(150, 150, 150)
VisualTab.BorderSizePixel = 0
VisualTab.ZIndex = 12
VisualTab.AutoButtonColor = false
VisualTab.Parent = TabFrame

local ThemeTab = Instance.new("TextButton")
ThemeTab.Text = "THEME"
ThemeTab.Font = Enum.Font.GothamBold
ThemeTab.TextSize = 13
ThemeTab.Size = UDim2.new(1, -16, 0, 38)
ThemeTab.Position = UDim2.new(0, 8, 0, 150)
ThemeTab.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
ThemeTab.TextColor3 = Color3.fromRGB(150, 150, 150)
ThemeTab.BorderSizePixel = 0
ThemeTab.ZIndex = 12
ThemeTab.AutoButtonColor = false
ThemeTab.Parent = TabFrame

-- Scrolling frames
local MainScrollingFrame = Instance.new("ScrollingFrame")
MainScrollingFrame.Size = UDim2.new(1, 0, 1, 0)
MainScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 580)
MainScrollingFrame.ScrollBarThickness = 4
MainScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 140, 255)
MainScrollingFrame.BackgroundTransparency = 1
MainScrollingFrame.BorderSizePixel = 0
MainScrollingFrame.ZIndex = 12
MainScrollingFrame.ScrollingDirection = Enum.ScrollingDirection.Y
MainScrollingFrame.Parent = ContentContainer

local MainContent = Instance.new("Frame")
MainContent.Size = UDim2.new(1, 0, 0, 580)
MainContent.BackgroundTransparency = 1
MainContent.Parent = MainScrollingFrame

local CombatScrollingFrame = Instance.new("ScrollingFrame")
CombatScrollingFrame.Size = UDim2.new(1, 0, 1, 0)
CombatScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 400)
CombatScrollingFrame.ScrollBarThickness = 4
CombatScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 140, 255)
CombatScrollingFrame.BackgroundTransparency = 1
CombatScrollingFrame.BorderSizePixel = 0
CombatScrollingFrame.ZIndex = 12
CombatScrollingFrame.ScrollingDirection = Enum.ScrollingDirection.Y
CombatScrollingFrame.Visible = false
CombatScrollingFrame.Parent = ContentContainer

local CombatContent = Instance.new("Frame")
CombatContent.Size = UDim2.new(1, 0, 0, 400)
CombatContent.BackgroundTransparency = 1
CombatContent.Parent = CombatScrollingFrame

local VisualScrollingFrame = Instance.new("ScrollingFrame")
VisualScrollingFrame.Size = UDim2.new(1, 0, 1, 0)
VisualScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 200)
VisualScrollingFrame.ScrollBarThickness = 4
VisualScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 140, 255)
VisualScrollingFrame.BackgroundTransparency = 1
VisualScrollingFrame.BorderSizePixel = 0
VisualScrollingFrame.ZIndex = 12
VisualScrollingFrame.ScrollingDirection = Enum.ScrollingDirection.Y
VisualScrollingFrame.Visible = false
VisualScrollingFrame.Parent = ContentContainer

local VisualContent = Instance.new("Frame")
VisualContent.Size = UDim2.new(1, 0, 0, 200)
VisualContent.BackgroundTransparency = 1
VisualContent.Parent = VisualScrollingFrame

local ThemeScrollingFrame = Instance.new("ScrollingFrame")
ThemeScrollingFrame.Size = UDim2.new(1, 0, 1, 0)
ThemeScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 300)
ThemeScrollingFrame.ScrollBarThickness = 4
ThemeScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 140, 255)
ThemeScrollingFrame.BackgroundTransparency = 1
ThemeScrollingFrame.BorderSizePixel = 0
ThemeScrollingFrame.ZIndex = 12
ThemeScrollingFrame.ScrollingDirection = Enum.ScrollingDirection.Y
ThemeScrollingFrame.Visible = false
ThemeScrollingFrame.Parent = ContentContainer

local ThemeContent = Instance.new("Frame")
ThemeContent.Size = UDim2.new(1, 0, 0, 300)
ThemeContent.BackgroundTransparency = 1
ThemeContent.Parent = ThemeScrollingFrame

-- =========== HELPER FUNCTIONS ===========
local function createToggle(parent, contentFrame, name, yPos, defaultState, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, -24, 0, 50)
    toggleFrame.Position = UDim2.new(0, 12, 0, yPos)
    toggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    toggleFrame.BorderSizePixel = 0
    toggleFrame.ZIndex = 13
    toggleFrame.Parent = contentFrame

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 6)
    toggleCorner.Parent = toggleFrame

    local toggleLabel = Instance.new("TextLabel")
    toggleLabel.Text = name
    toggleLabel.Font = Enum.Font.Gotham
    toggleLabel.TextSize = 13
    toggleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    toggleLabel.BackgroundTransparency = 1
    toggleLabel.Size = UDim2.new(0.65, 0, 1, 0)
    toggleLabel.Position = UDim2.new(0, 12, 0, 0)
    toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    toggleLabel.ZIndex = 14
    toggleLabel.Parent = toggleFrame

    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0, 52, 0, 28)
    toggleButton.Position = UDim2.new(1, -64, 0.5, -14)
    toggleButton.Text = ""
    toggleButton.BackgroundColor3 = defaultState and Color3.fromRGB(0, 140, 255) or Color3.fromRGB(55, 55, 63)
    toggleButton.BorderSizePixel = 0
    toggleButton.ZIndex = 14
    toggleButton.AutoButtonColor = false
    toggleButton.Parent = toggleFrame

    local toggleButtonCorner = Instance.new("UICorner")
    toggleButtonCorner.CornerRadius = UDim.new(1, 0)
    toggleButtonCorner.Parent = toggleButton

    local toggleDot = Instance.new("Frame")
    toggleDot.Size = UDim2.new(0, 22, 0, 22)
    toggleDot.Position = defaultState and UDim2.new(1, -26, 0.5, -11) or UDim2.new(0, 4, 0.5, -11)
    toggleDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleDot.BorderSizePixel = 0
    toggleDot.ZIndex = 15
    toggleDot.Parent = toggleButton

    local toggleDotCorner = Instance.new("UICorner")
    toggleDotCorner.CornerRadius = UDim.new(1, 0)
    toggleDotCorner.Parent = toggleDot

    local state = defaultState or false

    toggleButton.MouseButton1Click:Connect(function()
        state = not state
        if state then
            TweenService:Create(toggleDot, TweenInfo.new(0.2), {Position = UDim2.new(1, -26, 0.5, -11)}):Play()
            TweenService:Create(toggleButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 140, 255)}):Play()
        else
            TweenService:Create(toggleDot, TweenInfo.new(0.2), {Position = UDim2.new(0, 4, 0.5, -11)}):Play()
            TweenService:Create(toggleButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(55, 55, 63)}):Play()
        end
        if callback then callback(state) end
    end)

    if callback and state then
        task.spawn(function() callback(state) end)
    end

    return toggleFrame
end

local function createSlider(parent, contentFrame, name, yPos, minVal, maxVal, defaultVal, callback)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, -24, 0, 75)
    sliderFrame.Position = UDim2.new(0, 12, 0, yPos)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    sliderFrame.BorderSizePixel = 0
    sliderFrame.ZIndex = 13
    sliderFrame.Parent = contentFrame

    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 6)
    sliderCorner.Parent = sliderFrame

    local sliderLabel = Instance.new("TextLabel")
    sliderLabel.Text = name .. " [" .. tostring(defaultVal) .. "]"
    sliderLabel.Font = Enum.Font.Gotham
    sliderLabel.TextSize = 12
    sliderLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    sliderLabel.BackgroundTransparency = 1
    sliderLabel.Size = UDim2.new(1, -20, 0, 25)
    sliderLabel.Position = UDim2.new(0, 10, 0, 8)
    sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    sliderLabel.ZIndex = 14
    sliderLabel.Parent = sliderFrame

    local sliderBar = Instance.new("Frame")
    sliderBar.Size = UDim2.new(1, -24, 0, 6)
    sliderBar.Position = UDim2.new(0, 12, 0, 48)
    sliderBar.BackgroundColor3 = Color3.fromRGB(45, 45, 53)
    sliderBar.BorderSizePixel = 0
    sliderBar.ZIndex = 14
    sliderBar.Active = true
    sliderBar.Parent = sliderFrame

    local sliderBarCorner = Instance.new("UICorner")
    sliderBarCorner.CornerRadius = UDim.new(1, 0)
    sliderBarCorner.Parent = sliderBar

    local ratio = (defaultVal - minVal) / (maxVal - minVal)
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new(ratio, 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
    sliderFill.BorderSizePixel = 0
    sliderFill.ZIndex = 15
    sliderFill.Parent = sliderBar

    local sliderFillCorner = Instance.new("UICorner")
    sliderFillCorner.CornerRadius = UDim.new(1, 0)
    sliderFillCorner.Parent = sliderFill

    local sliderButton = Instance.new("TextButton")
    sliderButton.Size = UDim2.new(0, 18, 0, 18)
    sliderButton.Position = UDim2.new(ratio, -9, 0.5, -9)
    sliderButton.Text = ""
    sliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderButton.BorderSizePixel = 0
    sliderButton.ZIndex = 16
    sliderButton.AutoButtonColor = false
    sliderButton.Active = true
    sliderButton.Parent = sliderBar

    local sliderButtonCorner = Instance.new("UICorner")
    sliderButtonCorner.CornerRadius = UDim.new(1, 0)
    sliderButtonCorner.Parent = sliderButton

    local dragging = false
    local currentValue = defaultVal

    local function updateSlider(input)
        local barAbsPos = sliderBar.AbsolutePosition
        local barAbsSize = sliderBar.AbsoluteSize
        if not barAbsPos or not barAbsSize then return end
        
        local relativeX = (input.Position.X - barAbsPos.X) / barAbsSize.X
        relativeX = math.clamp(relativeX, 0, 1)

        local value = minVal + (maxVal - minVal) * relativeX
        value = math.floor(value * 10 + 0.5) / 10

        sliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
        sliderButton.Position = UDim2.new(relativeX, -9, 0.5, -9)
        sliderLabel.Text = name .. " [" .. tostring(value) .. "]"
        currentValue = value

        if callback then callback(value) end
    end

    sliderButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)

    sliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateSlider(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging then
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                updateSlider(input)
            end
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    if callback then callback(defaultVal) end

    return {
        frame = sliderFrame,
        setValue = function(val)
            local r = (val - minVal) / (maxVal - minVal)
            r = math.clamp(r, 0, 1)
            sliderFill.Size = UDim2.new(r, 0, 1, 0)
            sliderButton.Position = UDim2.new(r, -9, 0.5, -9)
            sliderLabel.Text = name .. " [" .. tostring(val) .. "]"
            currentValue = val
            if callback then callback(val) end
        end
    }
end

-- =========== CREATE MENU ITEMS ===========
-- MAIN TAB
createToggle(MainScrollingFrame, MainContent, "Auto Walk", 10, autoWalkEnabled, function(state)
    autoWalkEnabled = state
    saveValue("AutoWalk", state)
    if autoWalkConnection then autoWalkConnection:Disconnect() end
    if autoWalkEnabled then
        autoWalkConnection = RunService.Heartbeat:Connect(function()
            local char = player.Character
            if not char then return end
            local hum = char:FindFirstChild("Humanoid")
            local rootPart = char:FindFirstChild("HumanoidRootPart")
            if not hum or not rootPart then return end
            if hum.MoveDirection.Magnitude < 0.1 then
                local forwardDir = rootPart.CFrame.LookVector * Vector3.new(1, 0, 1)
                if forwardDir.Magnitude > 0.01 then
                    hum:Move(forwardDir.Unit, false)
                end
            end
        end)
    end
end)

local walkSpeedSlider = createSlider(MainScrollingFrame, MainContent, "Walk Speed", 70, 8, 100, savedWalkSpeed, function(value)
    local char = player.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum and not speedHackEnabled then
            hum.WalkSpeed = value
        end
    end
    saveValue("WalkSpeed", value)
end)

local jumpPowerSlider = createSlider(MainScrollingFrame, MainContent, "Jump Power", 155, 10, 200, savedJumpPower, function(value)
    local char = player.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum and not infiniteJumpEnabled then
            hum.JumpPower = value
        end
    end
    saveValue("JumpPower", value)
end)

local fovSlider = createSlider(MainScrollingFrame, MainContent, "Field of View", 240, 30, 120, savedFOV, function(value)
    if camera then camera.FieldOfView = value end
    saveValue("FOV", value)
end)

-- COMBAT TAB
createToggle(CombatScrollingFrame, CombatContent, "Speed Hack", 10, speedHackEnabled, function(state)
    speedHackEnabled = state
    saveValue("SpeedHack", state)
    applySpeedHack(state)
end)

local speedValueSlider = createSlider(CombatScrollingFrame, CombatContent, "Speed Value", 70, 20, 250, currentWalkspeedValue, function(value)
    currentWalkspeedValue = value
    saveValue("WalkspeedValue", value)
    if speedHackEnabled then applySpeedHack(true) end
end)

createToggle(CombatScrollingFrame, CombatContent, "Noclip", 155, noclipEnabled, function(state)
    noclipEnabled = state
    saveValue("Noclip", state)
    toggleNoclip(state)
end)

createToggle(CombatScrollingFrame, CombatContent, "Fly", 215, flyEnabled, function(state)
    flyEnabled = state
    saveValue("Fly", state)
    toggleFly(state)
end)

createToggle(CombatScrollingFrame, CombatContent, "Infinite Jump", 275, infiniteJumpEnabled, function(state)
    infiniteJumpEnabled = state
    saveValue("InfiniteJump", state)
    toggleInfiniteJump(state)
    local char = player.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            hum.JumpPower = infiniteJumpEnabled and currentJumppowerValue or savedJumpPower
        end
    end
end)

local jumpValueSlider = createSlider(CombatScrollingFrame, CombatContent, "Jump Value", 335, 30, 200, currentJumppowerValue, function(value)
    currentJumppowerValue = value
    saveValue("JumppowerValue", value)
    if infiniteJumpEnabled then
        local char = player.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then hum.JumpPower = value end
        end
    end
end)

-- VISUAL TAB
createToggle(VisualScrollingFrame, VisualContent, "ESP Players", 10, espEnabled, function(state)
    espEnabled = state
    saveValue("ESP", state)
    updateESP()
end)

-- SILENT AIM (combat tab)
local silentAimToggle = createToggle(CombatScrollingFrame, CombatContent, "Silent Aim", 395, savedSilentAim, function(state)
    silentAimEnabled = state
    saveValue("SilentAim", state)
    setupSilentAim()
end)

-- =========== THEME TAB ===========
local ThemeLabel = Instance.new("TextLabel")
ThemeLabel.Text = "INTERFACE THEME"
ThemeLabel.Font = Enum.Font.GothamBold
ThemeLabel.TextSize = 14
ThemeLabel.TextColor3 = Color3.fromRGB(0, 140, 255)
ThemeLabel.BackgroundTransparency = 1
ThemeLabel.Size = UDim2.new(1, -24, 0, 30)
ThemeLabel.Position = UDim2.new(0, 12, 0, 15)
ThemeLabel.TextXAlignment = Enum.TextXAlignment.Left
ThemeLabel.ZIndex = 14
ThemeLabel.Parent = ThemeContent

local themes = {
    {name = "CYAN", main = Color3.fromRGB(0, 180, 255), accent = Color3.fromRGB(0, 130, 200), dark = Color3.fromRGB(18, 22, 32)},
    {name = "RED", main = Color3.fromRGB(220, 40, 40), accent = Color3.fromRGB(180, 30, 30), dark = Color3.fromRGB(32, 18, 22)},
    {name = "GREEN", main = Color3.fromRGB(40, 200, 80), accent = Color3.fromRGB(30, 160, 60), dark = Color3.fromRGB(20, 32, 20)},
    {name = "PURPLE", main = Color3.fromRGB(150, 50, 220), accent = Color3.fromRGB(120, 40, 180), dark = Color3.fromRGB(28, 20, 36)},
    {name = "GOLD", main = Color3.fromRGB(255, 180, 30), accent = Color3.fromRGB(200, 140, 20), dark = Color3.fromRGB(36, 32, 20)},
}

for i, theme in ipairs(themes) do
    local yPos = 55 + (i - 1) * 48

    local themeButton = Instance.new("TextButton")
    themeButton.Text = theme.name
    themeButton.Font = Enum.Font.GothamBold
    themeButton.TextSize = 13
    themeButton.Size = UDim2.new(1, -30, 0, 36)
    themeButton.Position = UDim2.new(0, 15, 0, yPos)
    themeButton.BackgroundColor3 = theme.main
    themeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    themeButton.BorderSizePixel = 0
    themeButton.ZIndex = 14
    themeButton.AutoButtonColor = false
    themeButton.Parent = ThemeContent

    local themeButtonCorner = Instance.new("UICorner")
    themeButtonCorner.CornerRadius = UDim.new(0, 6)
    themeButtonCorner.Parent = themeButton

    themeButton.MouseEnter:Connect(function()
        TweenService:Create(themeButton, TweenInfo.new(0.15), {BackgroundColor3 = theme.accent}):Play()
    end)

    themeButton.MouseLeave:Connect(function()
        TweenService:Create(themeButton, TweenInfo.new(0.15), {BackgroundColor3 = theme.main}):Play()
    end)

    themeButton.MouseButton1Click:Connect(function()
        TweenService:Create(MainFrame, TweenInfo.new(0.25), {BackgroundColor3 = theme.dark}):Play()
        TweenService:Create(TitleBar, TweenInfo.new(0.25), {BackgroundColor3 = Color3.fromRGB(
            math.clamp(theme.dark.R * 255 + 12, 0, 255) / 255,
            math.clamp(theme.dark.G * 255 + 12, 0, 255) / 255,
            math.clamp(theme.dark.B * 255 + 12, 0, 255) / 255
        )}):Play()
        TweenService:Create(MainBorder, TweenInfo.new(0.25), {Color = theme.main}):Play()
        TweenService:Create(TitleText, TweenInfo.new(0.25), {TextColor3 = theme.main}):Play()
        TweenService:Create(ThemeLabel, TweenInfo.new(0.25), {TextColor3 = theme.main}):Play()
        MainScrollingFrame.ScrollBarImageColor3 = theme.main
        CombatScrollingFrame.ScrollBarImageColor3 = theme.main
        VisualScrollingFrame.ScrollBarImageColor3 = theme.main
        ThemeScrollingFrame.ScrollBarImageColor3 = theme.main
    end)
end

-- =========== TAB SWITCHING ===========
local function switchTab(tab)
    MainScrollingFrame.Visible = false
    CombatScrollingFrame.Visible = false
    VisualScrollingFrame.Visible = false
    ThemeScrollingFrame.Visible = false
    
    MainTab.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    CombatTab.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    VisualTab.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    ThemeTab.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    
    MainTab.TextColor3 = Color3.fromRGB(150, 150, 150)
    CombatTab.TextColor3 = Color3.fromRGB(150, 150, 150)
    VisualTab.TextColor3 = Color3.fromRGB(150, 150, 150)
    ThemeTab.TextColor3 = Color3.fromRGB(150, 150, 150)
    
    if tab == "Main" then
        MainScrollingFrame.Visible = true
        MainTab.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
        MainTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    elseif tab == "Combat" then
        CombatScrollingFrame.Visible = true
        CombatTab.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
        CombatTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    elseif tab == "Visual" then
        VisualScrollingFrame.Visible = true
        VisualTab.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
        VisualTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    elseif tab == "Theme" then
        ThemeScrollingFrame.Visible = true
        ThemeTab.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
        ThemeTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end

MainTab.MouseButton1Click:Connect(function() switchTab("Main") end)
CombatTab.MouseButton1Click:Connect(function() switchTab("Combat") end)
VisualTab.MouseButton1Click:Connect(function() switchTab("Visual") end)
ThemeTab.MouseButton1Click:Connect(function() switchTab("Theme") end)

-- =========== MINIMIZE & CLOSE ===========
local isMinimized = false
local originalSize = MainContainer.Size

MinimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MainContainer:TweenSize(UDim2.new(0, 550, 0, 40), "Out", "Quad", 0.25)
    else
        MainContainer:TweenSize(originalSize, "Out", "Quad", 0.25)
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    TweenService:Create(MainContainer, TweenInfo.new(0.2), {Size = UDim2.new(0, 0, 0, 0)}):Play()
    task.wait(0.2)
    ScreenGui:Destroy()
end)

-- =========== HOVER EFFECTS ===========
local function addHoverEffect(button)
    local origColor = button.BackgroundColor3
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(55, 55, 63)}):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {BackgroundColor3 = origColor}):Play()
    end)
end

addHoverEffect(MinimizeButton)
addHoverEffect(CloseButton)

-- =========== CHARACTER RESPAWN ===========
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = newCharacter:WaitForChild("Humanoid")
    camera = Workspace.CurrentCamera
    
    if humanoid then
        if speedHackEnabled then
            humanoid.WalkSpeed = currentWalkspeedValue
        else
            humanoid.WalkSpeed = loadValue("WalkSpeed", 16)
        end
        if infiniteJumpEnabled then
            humanoid.JumpPower = currentJumppowerValue
        else
            humanoid.JumpPower = loadValue("JumpPower", 50)
        end
    end
    if camera then
        camera.FieldOfView = loadValue("FOV", 70)
    end
    
    if flyEnabled then
        toggleFly(true)
    end
    if noclipEnabled then
        toggleNoclip(true)
    end
    if autoWalkEnabled then
        if autoWalkConnection then autoWalkConnection:Disconnect() end
        autoWalkConnection = RunService.Heartbeat:Connect(function()
            local char = player.Character
            if not char then return end
            local hum = char:FindFirstChild("Humanoid")
            local rootPart = char:FindFirstChild("HumanoidRootPart")
            if not hum or not rootPart then return end
            if hum.MoveDirection.Magnitude < 0.1 then
                local forwardDir = rootPart.CFrame.LookVector * Vector3.new(1, 0, 1)
                if forwardDir.Magnitude > 0.01 then
                    hum:Move(forwardDir.Unit, false)
                end
            end
        end)
    end
    
    for userId, hl in pairs(espHighlights) do
        local targetPlayer = Players:GetPlayerByUserId(userId)
        if not targetPlayer or hl.Parent ~= targetPlayer.Character then
            pcall(function() hl:Destroy() end)
            espHighlights[userId] = nil
        end
    end
    for userId, bb in pairs(espBillboards) do
        pcall(function() bb:Destroy() end)
        espBillboards[userId] = nil
    end
end)

-- =========== INITIAL SETUP ===========
if autoWalkEnabled then
    autoWalkConnection = RunService.Heartbeat:Connect(function()
        local char = player.Character
        if not char then return end
        local hum = char:FindFirstChild("Humanoid")
        local rootPart = char:FindFirstChild("HumanoidRootPart")
        if not hum or not rootPart then return end
        if hum.MoveDirection.Magnitude < 0.1 then
            local forwardDir = rootPart.CFrame.LookVector * Vector3.new(1, 0, 1)
            if forwardDir.Magnitude > 0.01 then
                hum:Move(forwardDir.Unit, false)
            end
        end
    end)
end

if noclipEnabled then toggleNoclip(true) end
if flyEnabled then toggleFly(true) end
if infiniteJumpEnabled then toggleInfiniteJump(true) end
if speedHackEnabled then applySpeedHack(true) end
if silentAimEnabled then setupSilentAim() end

switchTab("Main")

print("✅ TWKS SYNAPSE UI v5 FULLY LOADED | SpeedHack, Noclip, Fly, Infinite Jump, Silent Aim, ESP")
print("📌 Press RightAlt to toggle menu")
