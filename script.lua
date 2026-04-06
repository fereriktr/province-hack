-- SWILL: COUNTER BLOX (RBX) - AIMBOT + BOXESP
-- МЕНЮ: INSERT | АИМ: ПРАВАЯ КНОПКА МЫШИ

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ========== НАСТРОЙКИ ==========
local Settings = {
    MenuOpen = false,
    Aimbot = true,
    Smoothness = 0.3,
    FOV = 150,
    TeamCheck = true,
    AimPart = "Head",
    BoxESP = true,
    NameESP = true,
    HealthBar = true,
    SkeletonESP = false
}

-- ========== GUI МЕНЮ ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SWILL_CounterBlox"
ScreenGui.ResetOnSpawn = false

pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ScreenGui.Parent then
    pcall(function() ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end)
end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 400, 0, 450)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 45)
TitleBar.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -50, 1, 0)
TitleText.Position = UDim2.new(0, 15, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "SWILL | COUNTER BLOX"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextSize = 18
TitleText.Font = Enum.Font.GothamBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 40, 0, 40)
CloseBtn.Position = UDim2.new(1, -45, 0, 2)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 20
CloseBtn.Font = Enum.Font.Gotham
CloseBtn.Parent = TitleBar
CloseBtn.MouseButton1Click:Connect(function()
    Settings.MenuOpen = false
    MainFrame.Visible = false
end)

local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Size = UDim2.new(1, -20, 1, -60)
ContentFrame.Position = UDim2.new(0, 10, 0, 55)
ContentFrame.BackgroundTransparency = 1
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 500)
ContentFrame.ScrollBarThickness = 5
ContentFrame.Parent = MainFrame

local function CreateCheckbox(parent, text, yPos, settingName)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 35)
    frame.Position = UDim2.new(0, 0, 0, yPos)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 25, 0, 25)
    btn.Position = UDim2.new(0, 5, 0.5, -12)
    btn.BackgroundColor3 = Settings[settingName] and Color3.fromRGB(255, 70, 70) or Color3.fromRGB(50, 50, 65)
    btn.Text = Settings[settingName] and "✓" or ""
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 16
    btn.BorderSizePixel = 0
    btn.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -40, 1, 0)
    label.Position = UDim2.new(0, 40, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    btn.MouseButton1Click:Connect(function()
        Settings[settingName] = not Settings[settingName]
        btn.BackgroundColor3 = Settings[settingName] and Color3.fromRGB(255, 70, 70) or Color3.fromRGB(50, 50, 65)
        btn.Text = Settings[settingName] and "✓" or ""
    end)
    
    return frame
end

local function CreateSlider(parent, text, yPos, minVal, maxVal, settingName, isInt)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 60)
    frame.Position = UDim2.new(0, 0, 0, yPos)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 25)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. tostring(Settings[settingName])
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextSize = 13
    label.Parent = frame
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, 0, 0, 5)
    sliderBg.Position = UDim2.new(0, 0, 0, 35)
    sliderBg.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = frame
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((Settings[settingName] - minVal) / (maxVal - minVal), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
    fill.BorderSizePixel = 0
    fill.Parent = sliderBg
    
    local knob = Instance.new("TextButton")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new((Settings[settingName] - minVal) / (maxVal - minVal), -7, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.Text = ""
    knob.BorderSizePixel = 0
    knob.Parent = sliderBg
    
    local dragging = false
    knob.MouseButton1Down:Connect(function() dragging = true end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    
    knob.MouseMoved:Connect(function()
        if not dragging then return end
        local mouseX = UserInputService:GetMouseLocation().X
        local barX = sliderBg.AbsolutePosition.X
        local barW = sliderBg.AbsoluteSize.X
        local percent = math.clamp((mouseX - barX) / barW, 0, 1)
        local value = minVal + percent * (maxVal - minVal)
        if isInt then value = math.floor(value) end
        value = math.clamp(value, minVal, maxVal)
        Settings[settingName] = value
        fill.Size = UDim2.new((Settings[settingName] - minVal) / (maxVal - minVal), 0, 1, 0)
        knob.Position = UDim2.new((Settings[settingName] - minVal) / (maxVal - minVal), -7, 0.5, -7)
        label.Text = text .. ": " .. tostring(Settings[settingName])
    end)
    
    return frame
end

local y = 5
CreateCheckbox(ContentFrame, "Aimbot (ПКМ)", y, "Aimbot")
y = y + 40
CreateSlider(ContentFrame, "FOV (градусы)", y, 10, 360, "FOV", true)
y = y + 65
CreateSlider(ContentFrame, "Плавность", y, 0, 1, "Smoothness", false)
y = y + 65
CreateCheckbox(ContentFrame, "Box ESP", y, "BoxESP")
y = y + 40
CreateCheckbox(ContentFrame, "Name + Health", y, "NameESP")
y = y + 40
CreateCheckbox(ContentFrame, "Health Bar", y, "HealthBar")
y = y + 40
CreateCheckbox(ContentFrame, "Team Check", y, "TeamCheck")
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, y + 50)

-- ========== BOX ESP ДЛЯ COUNTER BLOX ==========
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "SWILL_CB_ESP"
pcall(function() ESPFolder.Parent = game:GetService("CoreGui") end)
if not ESPFolder.Parent then
    pcall(function() ESPFolder.Parent = LocalPlayer:WaitForChild("PlayerGui") end)
end

local function CreateBoxESP(player)
    if player == LocalPlayer then return end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_" .. player.Name
    billboard.Size = UDim2.new(0, 200, 0, 150)
    billboard.StudsOffset = Vector3.new(0, 1, 0)
    billboard.AlwaysOnTop = true
    billboard.Enabled = true
    billboard.Parent = ESPFolder
    
    local boxFrame = Instance.new("Frame")
    boxFrame.Name = "Box"
    boxFrame.Size = UDim2.new(0, 80, 0, 100)
    boxFrame.Position = UDim2.new(0.5, -40, 0.5, -50)
    boxFrame.BackgroundTransparency = 1
    boxFrame.BorderSizePixel = 2
    boxFrame.BorderColor3 = Color3.fromRGB(255, 0, 0)
    boxFrame.Parent = billboard
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "Name"
    nameLabel.Size = UDim2.new(1, 0, 0, 20)
    nameLabel.Position = UDim2.new(0, 0, 0, -20)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextSize = 12
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextStrokeTransparency = 0.3
    nameLabel.Parent = billboard
    
    local healthBar = Instance.new("Frame")
    healthBar.Name = "Health"
    healthBar.Size = UDim2.new(0, 80, 0, 6)
    healthBar.Position = UDim2.new(0.5, -40, 1, 5)
    healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    healthBar.BorderSizePixel = 0
    healthBar.Parent = billboard
    
    local healthBg = Instance.new("Frame")
    healthBg.Size = UDim2.new(1, 0, 1, 0)
    healthBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    healthBg.BorderSizePixel = 0
    healthBg.Parent = healthBar
    
    local function UpdateESP()
        if not player.Character then
            billboard.Adornee = nil
            return
        end
        
        billboard.Adornee = player.Character
        billboard.Enabled = Settings.BoxESP or Settings.NameESP or Settings.HealthBar
        
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if humanoid then
            local hp = math.floor(humanoid.Health)
            local maxHp = humanoid.MaxHealth or 100
            local hpPercent = math.clamp(hp / maxHp, 0, 1)
            
            -- Цвет рамки в зависимости от здоровья
            local boxColor = Color3.fromRGB(255 - (hp * 2.55), hp * 2.55, 0)
            boxFrame.BorderColor3 = boxColor
            
            -- Полоска здоровья
            healthBar.Size = UDim2.new(hpPercent, 0, 0, 6)
            healthBar.BackgroundColor3 = boxColor
            
            -- Имя с здоровьем
            nameLabel.Text = player.Name .. " [" .. hp .. " HP]"
            nameLabel.TextColor3 = boxColor
            
            -- Видимость элементов
            boxFrame.Visible = Settings.BoxESP
            nameLabel.Visible = Settings.NameESP
            healthBar.Visible = Settings.HealthBar
        end
    end
    
    player.CharacterAdded:Connect(UpdateESP)
    player.CharacterRemoving:Connect(UpdateESP)
    UpdateESP()
    RunService.Heartbeat:Connect(UpdateESP)
end

for _, plr in ipairs(Players:GetPlayers()) do CreateBoxESP(plr) end
Players.PlayerAdded:Connect(CreateBoxESP)

-- ========== AIMBOT ДЛЯ COUNTER BLOX (НАВЕДЕНИЕ МЫШКОЙ) ==========
local function GetClosestTarget()
    local closestDist = Settings.FOV
    local closestTarget = nil
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if Settings.TeamCheck and plr.Team == LocalPlayer.Team then continue end
        if not plr.Character then continue end
        
        local hum = plr.Character:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        
        local targetPart = plr.Character:FindFirstChild(Settings.AimPart) or plr.Character:FindFirstChild("Head")
        if not targetPart then continue end
        
        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
        if not onScreen then continue end
        
        local dist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
        if dist < closestDist then
            closestDist = dist
            closestTarget = plr
        end
    end
    
    return closestTarget
end

-- Функция плавного наведения мыши
local function SmoothAim(target)
    if not target or not target.Character then return end
    
    local aimPart = target.Character:FindFirstChild(Settings.AimPart) or target.Character:FindFirstChild("Head")
    if not aimPart then return end
    
    local targetScreen = Camera:WorldToViewportPoint(aimPart.Position)
    local targetPos = Vector2.new(targetScreen.X, targetScreen.Y)
    local currentPos = Vector2.new(Mouse.X, Mouse.Y)
    local delta = (targetPos - currentPos) * (1 - Settings.Smoothness)
    
    -- Движение мыши для XENO
    pcall(function()
        mousemoverel(delta.X, delta.Y)
    end)
end

-- Аим при зажатой правой кнопке
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 and Settings.Aimbot then
        local target = GetClosestTarget()
        if target then
            SmoothAim(target)
        end
    end
end)

-- ========== ОТКРЫТИЕ МЕНЮ ==========
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        Settings.MenuOpen = not Settings.MenuOpen
        MainFrame.Visible = Settings.MenuOpen
    end
end)

-- ========== ПЕРЕМЕЩЕНИЕ ОКНА ==========
local dragStart, dragPos
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragStart = input.Position
        dragPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragStart and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(dragPos.X.Scale, dragPos.X.Offset + delta.X, dragPos.Y.Scale, dragPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragStart = nil
    end
end)

-- ========== ИНДИКАТОР ==========
local indicator = Instance.new("TextLabel")
indicator.Size = UDim2.new(0, 300, 0, 35)
indicator.Position = UDim2.new(0.5, -150, 0, 10)
indicator.BackgroundTransparency = 0.7
indicator.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
indicator.TextColor3 = Color3.fromRGB(255, 255, 255)
indicator.TextSize = 14
indicator.Font = Enum.Font.GothamBold
pcall(function() indicator.Parent = LocalPlayer.PlayerGui end)

spawn(function()
    while wait(0.3) do
        if Settings.Aimbot then
            local target = GetClosestTarget()
            if target then
                indicator.Text = "🎯 AIM: " .. target.Name .. " | FOV: " .. Settings.FOV
                indicator.TextColor3 = Color3.fromRGB(0, 255, 0)
            else
                indicator.Text = "❌ НЕТ ЦЕЛИ | FOV: " .. Settings.FOV
                indicator.TextColor3 = Color3.fromRGB(255, 100, 100)
            end
        else
            indicator.Text = "⚠️ AIMBOT ВЫКЛЮЧЕН"
            indicator.TextColor3 = Color3.fromRGB(255, 255, 0)
        end
    end
end)

-- ========== УВЕДОМЛЕНИЕ ==========
local function Notify(msg)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "SWILL | COUNTER BLOX",
            Text = msg,
            Duration = 3
        })
    end)
    print("[SWILL] " .. msg)
end

Notify("Загружен! Нажми INSERT для меню")
Notify("Aimbot: ПРАВАЯ кнопка мыши")
Notify("Box ESP активен")
