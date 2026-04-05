-- SWILL: РАБОЧИЙ ВАРИАНТ (FIXED v3)
-- Открытие меню: INSERT
-- Перемещение окна: зажать ЛКМ на заголовке

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ========== ПРОВЕРКА НА ЭКЗЕКЬЮТОР ==========
local isSynapse = syn and syn.crypt or false
local isKrnl = krnl and krnl.new or false
local isFluxus = fluxus and fluxus.new or false
local isScriptWare = scriptware and scriptware.new or false

-- Функция движения мыши для разных экзекьюторов
local function moveMouse(deltaX, deltaY)
    if isSynapse then
        syn.input.mouse_move(deltaX, deltaY)
    elseif isKrnl or isFluxus then
        pcall(function() mousemoverel(deltaX, deltaY) end)
    elseif isScriptWare then
        pcall(function() input.MouseMove(deltaX, deltaY) end)
    else
        pcall(function() mousemoverel(deltaX, deltaY) end)
    end
end

-- ========== НАСТРОЙКИ ==========
local Settings = {
    MenuOpen = false,
    Aimbot = true,
    AimbotFOV = 200,
    AimbotSmoothness = 0.2,
    AimbotKey = "Button2",
    AimPart = "Head",
    Wallhack = true,
    ShowBox = true,
    ShowName = true,
    TeamCheck = true
}

-- ========== СОЗДАНИЕ GUI (СТАБИЛЬНО) ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SWILL_Menu"
ScreenGui.ResetOnSpawn = false

-- Пытаемся в CoreGui, если не выходит - в PlayerGui
local success, err = pcall(function()
    ScreenGui.Parent = CoreGui
end)
if not success then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Главное окно
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 400, 0, 450)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

-- Углы
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- Заголовок
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -50, 1, 0)
TitleText.Position = UDim2.new(0, 15, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "SWILL HUB v3.0"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextSize = 18
TitleText.Font = Enum.Font.GothamBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -40, 0, 2)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 18
CloseBtn.Font = Enum.Font.Gotham
CloseBtn.Parent = TitleBar
CloseBtn.MouseButton1Click:Connect(function()
    Settings.MenuOpen = false
    MainFrame.Visible = false
end)

-- Контент
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Size = UDim2.new(1, -20, 1, -60)
ContentFrame.Position = UDim2.new(0, 10, 0, 50)
ContentFrame.BackgroundTransparency = 1
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 300)
ContentFrame.ScrollBarThickness = 5
ContentFrame.Parent = MainFrame

-- Функция создания чекбокса
local function createCheckbox(text, yPos, getter, setter)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 35)
    frame.Position = UDim2.new(0, 0, 0, yPos)
    frame.BackgroundTransparency = 1
    frame.Parent = ContentFrame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 22, 0, 22)
    btn.Position = UDim2.new(0, 5, 0.5, -11)
    btn.BackgroundColor3 = getter() and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(50, 50, 65)
    btn.Text = getter() and "✓" or ""
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 14
    btn.BorderSizePixel = 0
    btn.Parent = frame
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -40, 1, 0)
    lbl.Position = UDim2.new(0, 35, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame
    
    btn.MouseButton1Click:Connect(function()
        setter(not getter())
        btn.BackgroundColor3 = getter() and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(50, 50, 65)
        btn.Text = getter() and "✓" or ""
    end)
    
    ContentFrame.CanvasSize = UDim2.new(0, 0, 0, yPos + 50)
    return frame
end

-- Функция создания слайдера
local function createSlider(text, yPos, minVal, maxVal, getter, setter, isInt)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 55)
    frame.Position = UDim2.new(0, 0, 0, yPos)
    frame.BackgroundTransparency = 1
    frame.Parent = ContentFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. tostring(getter())
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextSize = 13
    label.Parent = frame
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, 0, 0, 4)
    sliderBg.Position = UDim2.new(0, 0, 0, 30)
    sliderBg.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = frame
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((getter() - minVal) / (maxVal - minVal), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    fill.BorderSizePixel = 0
    fill.Parent = sliderBg
    
    local knob = Instance.new("TextButton")
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.Position = UDim2.new((getter() - minVal) / (maxVal - minVal), -6, 0.5, -6)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.Text = ""
    knob.BorderSizePixel = 0
    knob.Parent = sliderBg
    
    local dragging = false
    knob.MouseButton1Down:Connect(function() dragging = true end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    
    local function updateSlider()
        if not dragging then return end
        local mouseX = UserInputService:GetMouseLocation().X
        local barX = sliderBg.AbsolutePosition.X
        local barW = sliderBg.AbsoluteSize.X
        local percent = math.clamp((mouseX - barX) / barW, 0, 1)
        local value = minVal + percent * (maxVal - minVal)
        if isInt then value = math.floor(value) end
        value = math.clamp(value, minVal, maxVal)
        setter(value)
        fill.Size = UDim2.new((getter() - minVal) / (maxVal - minVal), 0, 1, 0)
        knob.Position = UDim2.new((getter() - minVal) / (maxVal - minVal), -6, 0.5, -6)
        label.Text = text .. ": " .. tostring(getter())
    end
    
    knob.MouseMoved:Connect(updateSlider)
    RunService.RenderStepped:Connect(function()
        if dragging then updateSlider() end
    end)
    
    ContentFrame.CanvasSize = UDim2.new(0, 0, 0, yPos + 70)
    return frame
end

-- Добавляем элементы меню
local y = 5
createCheckbox("Aimbot (ПКМ)", y, function() return Settings.Aimbot end, function(v) Settings.Aimbot = v end)
y = y + 40
createSlider("FOV (градусы)", y, 10, 360, function() return Settings.AimbotFOV end, function(v) Settings.AimbotFOV = v end, true)
y = y + 60
createSlider("Плавность", y, 0, 0.9, function() return Settings.AimbotSmoothness end, function(v) Settings.AimbotSmoothness = v end, false)
y = y + 60
createCheckbox("Wallhack (подсветка)", y, function() return Settings.Wallhack end, function(v) Settings.Wallhack = v end)
y = y + 40
createCheckbox("Box ESP", y, function() return Settings.ShowBox end, function(v) Settings.ShowBox = v end)
y = y + 40
createCheckbox("Name + Health", y, function() return Settings.ShowName end, function(v) Settings.ShowName = v end)
y = y + 40
createCheckbox("Team Check (не атаковать свою команду)", y, function() return Settings.TeamCheck end, function(v) Settings.TeamCheck = v end)

-- ========== WALLHACK (ПОДСВЕТКА ЧЕРЕЗ СТЕНЫ) ==========
local espFolder = Instance.new("Folder")
espFolder.Name = "SWILL_ESP"
espFolder.Parent = CoreGui

local function setupESP(player)
    if player == LocalPlayer then return end
    
    -- Основная подсветка
    local highlight = Instance.new("Highlight")
    highlight.Name = "HL_" .. player.Name
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0.2
    highlight.FillColor = Color3.fromRGB(255, 50, 50)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.Enabled = Settings.Wallhack
    highlight.Parent = espFolder
    
    -- Billboard для имени и здоровья
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "BB_" .. player.Name
    billboard.Size = UDim2.new(0, 150, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Enabled = Settings.ShowName
    billboard.Parent = espFolder
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextStrokeTransparency = 0.2
    textLabel.TextSize = 13
    textLabel.Font = Enum.Font.GothamBold
    textLabel.Parent = billboard
    
    local boxFrame = Instance.new("Frame")
    boxFrame.Size = UDim2.new(0, 80, 0, 100)
    boxFrame.Position = UDim2.new(0.5, -40, 0.5, -50)
    boxFrame.BackgroundTransparency = 1
    boxFrame.BorderSizePixel = 2
    boxFrame.BorderColor3 = Color3.fromRGB(255, 0, 0)
    boxFrame.Visible = Settings.ShowBox
    boxFrame.Parent = billboard
    
    local function updateESP()
        if not player.Character then
            highlight.Adornee = nil
            billboard.Adornee = nil
            return
        end
        
        highlight.Adornee = player.Character
        billboard.Adornee = player.Character
        
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if humanoid then
            local hp = math.floor(humanoid.Health)
            local healthColor = Color3.fromRGB(255 - (hp * 2.55), hp * 2.55, 0)
            textLabel.Text = player.Name .. " | " .. hp .. " HP"
            textLabel.TextColor3 = healthColor
            
            -- Полоска здоровья
            local healthBar = billboard:FindFirstChild("HealthBar")
            if not healthBar then
                healthBar = Instance.new("Frame")
                healthBar.Name = "HealthBar"
                healthBar.Size = UDim2.new(0, 80, 0, 6)
                healthBar.Position = UDim2.new(0.5, -40, 1, 2)
                healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                healthBar.BorderSizePixel = 0
                healthBar.Parent = billboard
            end
            healthBar.Size = UDim2.new(hp / 100, 0, 0, 6)
            healthBar.BackgroundColor3 = healthColor
        end
        
        highlight.Enabled = Settings.Wallhack
        billboard.Enabled = Settings.ShowName
        boxFrame.Visible = Settings.ShowBox
    end
    
    player.CharacterAdded:Connect(updateESP)
    player.CharacterRemoving:Connect(updateESP)
    updateESP()
    
    -- Постоянное обновление
    RunService.Heartbeat:Connect(updateESP)
end

for _, plr in ipairs(Players:GetPlayers()) do
    setupESP(plr)
end
Players.PlayerAdded:Connect(setupESP)

-- ========== AIMBOT (РАБОТАЕТ С ПРАВОЙ КНОПКОЙ) ==========
local function getClosestTarget()
    local closestDistance = Settings.AimbotFOV
    local closestPlayer = nil
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if Settings.TeamCheck and plr.Team == LocalPlayer.Team then continue end
        if not plr.Character then continue end
        
        local humanoid = plr.Character:FindFirstChild("Humanoid")
        if not humanoid or humanoid.Health <= 0 then continue end
        
        local targetPart = plr.Character:FindFirstChild(Settings.AimPart) or plr.Character:FindFirstChild("Head") or plr.Character:FindFirstChild("HumanoidRootPart")
        if not targetPart then continue end
        
        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
        if not onScreen then continue end
        
        local distance = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
        if distance < closestDistance then
            closestDistance = distance
            closestPlayer = plr
        end
    end
    
    return closestPlayer
end

-- Аим при зажатой правой кнопке
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 and Settings.Aimbot then
        local target = getClosestTarget()
        if target and target.Character then
            local aimPart = target.Character:FindFirstChild(Settings.AimPart) or target.Character:FindFirstChild("Head")
            if aimPart then
                local targetScreen = Camera:WorldToViewportPoint(aimPart.Position)
                local targetVec = Vector2.new(targetScreen.X, targetScreen.Y)
                local currentPos = Vector2.new(Mouse.X, Mouse.Y)
                local delta = (targetVec - currentPos) * (1 - Settings.AimbotSmoothness)
                moveMouse(delta.X, delta.Y)
            end
        end
    end
end)

-- ========== ОТКРЫТИЕ МЕНЮ ПО INSERT ==========
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
local function notify(msg)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "SWILL HUB",
        Text = msg,
        Duration = 3
    })
    print("[SWILL] " .. msg)
end

notify("Загружен! Нажмите INSERT для меню. Aimbot: ПКМ")