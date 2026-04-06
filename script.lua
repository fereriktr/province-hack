-- SWILL: XENO + FLICK (ПОЛНОСТЬЮ РАБОЧАЯ ВЕРСИЯ)
-- МЕНЮ: INSERT | АИМ: ПРАВАЯ КНОПКА МЫШИ

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ========== НАСТРОЙКИ ==========
local Settings = {
    MenuOpen = false,
    Aimbot = true,
    Smoothness = 0.3,
    FOV = 200,
    TeamCheck = true,
    AimPart = "Head",
    Wallhack = true,
    ShowESP = true
}

-- ========== GUI МЕНЮ ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SWILL_Menu"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Пытаемся создать GUI
local success, err = pcall(function()
    ScreenGui.Parent = game:GetService("CoreGui")
end)
if not success then
    pcall(function()
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end)
end

-- Главное окно
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
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

-- Заголовок
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
TitleText.Text = "SWILL HUB | XENO + FLICK"
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

-- Контент
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Size = UDim2.new(1, -20, 1, -60)
ContentFrame.Position = UDim2.new(0, 10, 0, 55)
ContentFrame.BackgroundTransparency = 1
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 400)
ContentFrame.ScrollBarThickness = 5
ContentFrame.Parent = MainFrame

-- Функция создания чекбокса
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

-- Функция создания слайдера
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

-- Создаем элементы меню
local yOffset = 5
CreateCheckbox(ContentFrame, "Aimbot (ПКМ)", yOffset, "Aimbot")
yOffset = yOffset + 40
CreateSlider(ContentFrame, "FOV (градусы)", yOffset, 10, 360, "FOV", true)
yOffset = yOffset + 65
CreateSlider(ContentFrame, "Плавность наведения", yOffset, 0, 1, "Smoothness", false)
yOffset = yOffset + 65
CreateCheckbox(ContentFrame, "Wallhack (подсветка)", yOffset, "Wallhack")
yOffset = yOffset + 40
CreateCheckbox(ContentFrame, "ESP (имя/здоровье)", yOffset, "ShowESP")
yOffset = yOffset + 40
CreateCheckbox(ContentFrame, "Team Check", yOffset, "TeamCheck")

-- Обновляем размер Canvas
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset + 50)

-- ========== WALLHACK + ESP ==========
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "SWILL_ESP"
pcall(function() ESPFolder.Parent = game:GetService("CoreGui") end)
if not ESPFolder.Parent then
    pcall(function() ESPFolder.Parent = LocalPlayer:WaitForChild("PlayerGui") end)
end

local function CreateESP(player)
    if player == LocalPlayer then return end
    
    -- Подсветка через стены
    local highlight = Instance.new("Highlight")
    highlight.Name = "HL_" .. player.Name
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0.2
    highlight.FillColor = Color3.fromRGB(255, 50, 50)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.Parent = ESPFolder
    
    -- Billboard для имени и здоровья
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "BB_" .. player.Name
    billboard.Size = UDim2.new(0, 120, 0, 35)
    billboard.StudsOffset = Vector3.new(0, 2.2, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = ESPFolder
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextStrokeTransparency = 0.2
    textLabel.TextSize = 12
    textLabel.Font = Enum.Font.GothamBold
    textLabel.Parent = billboard
    
    local function UpdateESP()
        if not player.Character then
            highlight.Adornee = nil
            billboard.Adornee = nil
            return
        end
        
        highlight.Adornee = player.Character
        billboard.Adornee = player.Character
        highlight.Enabled = Settings.Wallhack
        billboard.Enabled = Settings.ShowESP
        
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if humanoid then
            local hp = math.floor(humanoid.Health)
            local color = Color3.fromRGB(255 - (hp * 2.55), hp * 2.55, 0)
            textLabel.Text = player.Name .. " | " .. hp .. " HP"
            textLabel.TextColor3 = color
        end
    end
    
    player.CharacterAdded:Connect(UpdateESP)
    player.CharacterRemoving:Connect(UpdateESP)
    UpdateESP()
    
    -- Постоянное обновление
    RunService.Heartbeat:Connect(UpdateESP)
end

for _, plr in ipairs(Players:GetPlayers()) do CreateESP(plr) end
Players.PlayerAdded:Connect(CreateESP)

-- ========== AIMBOT (ПРАВАЯ КНОПКА) ==========
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

-- Функция плавного наведения
local function SmoothAim(target)
    if not target or not target.Character then return end
    
    local aimPart = target.Character:FindFirstChild(Settings.AimPart) or target.Character:FindFirstChild("Head")
    if not aimPart then return end
    
    local targetScreen = Camera:WorldToViewportPoint(aimPart.Position)
    local targetPos = Vector2.new(targetScreen.X, targetScreen.Y)
    local currentPos = Vector2.new(Mouse.X, Mouse.Y)
    local delta = (targetPos - currentPos) * (1 - Settings.Smoothness)
    
    -- Двигаем мышь
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

-- Также при зажатой левой (опционально)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 and Settings.Aimbot then
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

-- ========== УВЕДОМЛЕНИЕ ==========
local function Notify(msg)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "SWILL HUB",
            Text = msg,
            Duration = 3
        })
    end)
    print("[SWILL] " .. msg)
end

Notify("Загружен! Нажми INSERT для меню")
Notify("Aimbot: ПРАВАЯ кнопка мыши")
