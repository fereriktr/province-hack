-- SWILL: 2D BOX ESP + AIMBOT для XENO (РАБОЧАЯ ВЕРСИЯ)
-- МЕНЮ: INSERT | АИМ: АВТОМАТИЧЕСКИ ПРИ ВЫСТРЕЛЕ

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ========== НАСТРОЙКИ ==========
local Settings = {
    Aimbot = true,
    BoxESP = true,
    FOV = 250,
    TeamCheck = true
}

-- ========== 2D BOX ESP (РИСУЕТСЯ НА ЭКРАНЕ) ==========
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "SWILL_2D_ESP"
pcall(function() ESPFolder.Parent = game:GetService("CoreGui") end)
if not ESPFolder.Parent then
    pcall(function() ESPFolder.Parent = LocalPlayer:WaitForChild("PlayerGui") end)
end

-- Функция для создания 2D бокса
local function Create2DBox(player)
    if player == LocalPlayer then return end
    
    local container = Instance.new("Frame")
    container.Name = player.Name
    container.Size = UDim2.new(0, 0, 0, 0)
    container.Position = UDim2.new(0, 0, 0, 0)
    container.BackgroundTransparency = 1
    container.Visible = true
    container.Parent = ESPFolder
    
    -- Рамка
    local box = Instance.new("Frame")
    box.Name = "Box"
    box.Size = UDim2.new(0, 80, 0, 100)
    box.BackgroundTransparency = 1
    box.BorderSizePixel = 2
    box.BorderColor3 = Color3.fromRGB(255, 0, 0)
    box.Parent = container
    
    -- Имя игрока
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "Name"
    nameLabel.Size = UDim2.new(0, 80, 0, 16)
    nameLabel.Position = UDim2.new(0, 0, 0, -16)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextSize = 11
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Center
    nameLabel.Parent = container
    
    -- Полоска здоровья
    local healthBar = Instance.new("Frame")
    healthBar.Name = "Health"
    healthBar.Size = UDim2.new(1, 0, 0, 4)
    healthBar.Position = UDim2.new(0, 0, 1, 2)
    healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    healthBar.BorderSizePixel = 0
    healthBar.Parent = box
    
    local healthBg = Instance.new("Frame")
    healthBg.Size = UDim2.new(1, 0, 1, 0)
    healthBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    healthBg.BorderSizePixel = 0
    healthBg.Parent = healthBar
    
    -- Обновление позиции и размеров
    local function Update()
        if not player.Character then
            container.Visible = false
            return
        end
        
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if not humanoid or humanoid.Health <= 0 then
            container.Visible = false
            return
        end
        
        local rootPart = player.Character:FindFirstChild("HumanoidRootPart") or player.Character:FindFirstChild("Head")
        if not rootPart then
            container.Visible = false
            return
        end
        
        -- Получаем позицию на экране
        local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
        if not onScreen then
            container.Visible = false
            return
        end
        
        -- Вычисляем размер бокса (дистанция влияет на размер)
        local dist = (Camera.CFrame.Position - rootPart.Position).Magnitude
        local boxHeight = math.clamp(3000 / dist, 40, 150)
        local boxWidth = boxHeight * 0.7
        
        -- Позиция бокса (центр - низ)
        local yOffset = boxHeight / 2 + 20
        local x = screenPos.X - boxWidth / 2
        local y = screenPos.Y - yOffset
        
        -- Обновляем рамку
        box.Size = UDim2.new(0, boxWidth, 0, boxHeight)
        box.Position = UDim2.new(0, x, 0, y)
        
        -- Обновляем имя
        nameLabel.Size = UDim2.new(0, boxWidth, 0, 16)
        nameLabel.Position = UDim2.new(0, 0, 0, -16)
        nameLabel.Text = player.Name .. " [" .. math.floor(humanoid.Health) .. "]"
        
        -- Обновляем здоровье
        local hpPercent = math.clamp(humanoid.Health / 100, 0, 1)
        healthBar.Size = UDim2.new(hpPercent, 0, 0, 4)
        
        -- Цвет в зависимости от здоровья
        local r = 255 - (humanoid.Health * 2.55)
        local g = humanoid.Health * 2.55
        box.BorderColor3 = Color3.fromRGB(r, g, 0)
        healthBar.BackgroundColor3 = Color3.fromRGB(r, g, 0)
        nameLabel.TextColor3 = Color3.fromRGB(r, g, 0)
        
        -- Цвет рамки для своей команды (опционально)
        if Settings.TeamCheck and player.Team == LocalPlayer.Team then
            box.BorderColor3 = Color3.fromRGB(0, 100, 255)
            nameLabel.TextColor3 = Color3.fromRGB(0, 100, 255)
        end
        
        container.Visible = Settings.BoxESP
    end
    
    player.CharacterAdded:Connect(Update)
    player.CharacterRemoving:Connect(function() container.Visible = false end)
    RunService.RenderStepped:Connect(Update)
    Update()
end

-- Создаём ESP для всех игроков
for _, plr in ipairs(Players:GetPlayers()) do
    Create2DBox(plr)
end
Players.PlayerAdded:Connect(Create2DBox)

-- ========== AIMBOT (ПРИ ВЫСТРЕЛЕ) ==========
local function GetClosestEnemy()
    local closestDist = Settings.FOV
    local closestPlayer = nil
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if Settings.TeamCheck and player.Team == LocalPlayer.Team then continue end
        if not player.Character then continue end
        
        local hum = player.Character:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        
        local head = player.Character:FindFirstChild("Head")
        if not head then continue end
        
        local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
        if not onScreen then continue end
        
        local dist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
        if dist < closestDist then
            closestDist = dist
            closestPlayer = player
        end
    end
    return closestPlayer
end

-- Аим через поворот камеры (без движения мыши)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 and Settings.Aimbot then
        local target = GetClosestEnemy()
        if target and target.Character then
            local head = target.Character:FindFirstChild("Head")
            if head then
                local oldCF = Camera.CFrame
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position)
                task.wait()
                Camera.CFrame = oldCF
            end
        end
    end
end)

-- ========== ПРОСТОЕ МЕНЮ ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SWILL_Menu"
pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 150)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -75)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 1
MainFrame.BorderColor3 = Color3.fromRGB(255, 60, 60)
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
Title.Text = "SWILL | COUNTER BLOX"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -35, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 16
CloseBtn.Parent = Title
CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

local AimBtn = Instance.new("TextButton")
AimBtn.Size = UDim2.new(0, 120, 0, 35)
AimBtn.Position = UDim2.new(0.5, -130, 0, 50)
AimBtn.BackgroundColor3 = Settings.Aimbot and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(50, 50, 65)
AimBtn.Text = "AIMBOT: " .. (Settings.Aimbot and "ON" or "OFF")
AimBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AimBtn.TextSize = 14
AimBtn.Parent = MainFrame
AimBtn.MouseButton1Click:Connect(function()
    Settings.Aimbot = not Settings.Aimbot
    AimBtn.Text = "AIMBOT: " .. (Settings.Aimbot and "ON" or "OFF")
    AimBtn.BackgroundColor3 = Settings.Aimbot and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(50, 50, 65)
end)

local ESPBtn = Instance.new("TextButton")
ESPBtn.Size = UDim2.new(0, 120, 0, 35)
ESPBtn.Position = UDim2.new(0.5, 10, 0, 50)
ESPBtn.BackgroundColor3 = Settings.BoxESP and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(50, 50, 65)
ESPBtn.Text = "2D BOX ESP: " .. (Settings.BoxESP and "ON" or "OFF")
ESPBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPBtn.TextSize = 14
ESPBtn.Parent = MainFrame
ESPBtn.MouseButton1Click:Connect(function()
    Settings.BoxESP = not Settings.BoxESP
    ESPBtn.Text = "2D BOX ESP: " .. (Settings.BoxESP and "ON" or "OFF")
    ESPBtn.BackgroundColor3 = Settings.BoxESP and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(50, 50, 65)
end)

local FOVLabel = Instance.new("TextLabel")
FOVLabel.Size = UDim2.new(0, 250, 0, 20)
FOVLabel.Position = UDim2.new(0.5, -125, 0, 100)
FOVLabel.BackgroundTransparency = 1
FOVLabel.Text = "FOV: " .. Settings.FOV
FOVLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
FOVLabel.TextSize = 12
FOVLabel.Parent = MainFrame

-- Открытие меню
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- Перемещение окна
local dragStart, dragPos
Title.InputBegan:Connect(function(input)
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
local Indicator = Instance.new("TextLabel")
Indicator.Size = UDim2.new(0, 250, 0, 25)
Indicator.Position = UDim2.new(0.5, -125, 0, 5)
Indicator.BackgroundTransparency = 0.6
Indicator.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Indicator.Text = "SWILL: AIM ON | 2D ESP ON"
Indicator.TextColor3 = Color3.fromRGB(0, 255, 0)
Indicator.TextSize = 12
Indicator.Font = Enum.Font.GothamBold
Indicator.Parent = ScreenGui

spawn(function()
    while wait(0.5) do
        Indicator.Text = "SWILL: AIM " .. (Settings.Aimbot and "ON" or "OFF") .. " | 2D ESP " .. (Settings.BoxESP and "ON" or "OFF")
        Indicator.TextColor3 = Settings.Aimbot and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    end
end)

-- ========== УВЕДОМЛЕНИЕ ==========
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "SWILL",
        Text = "Загружен! Нажми INSERT для меню | 2D Box ESP + Aimbot",
        Duration = 4
    })
end)

print("========================================")
print("SWILL ЗАГРУЖЕН!")
print("2D BOX ESP - прямоугольники вокруг игроков")
print("AIMBOT - автоматически при выстреле")
print("МЕНЮ - клавиша INSERT")
print("========================================")
