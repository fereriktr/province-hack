-- SWILL: COUNTER BLOX - 2D ESP + AIMBOT + BUNNYHOP
-- МЕНЮ: INSERT

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ========== НАСТРОЙКИ ==========
local Settings = {
    Aimbot = true,
    ESP = true,
    BunnyHop = true,
    FOV = 200,
    TeamCheck = true
}

-- ========== 2D BOX ESP (ЧЕРЕЗ DRAWING API XENO) ==========
local ESPObjects = {}

local function Create2DBox(player)
    if player == LocalPlayer then return end
    
    local objects = {
        box = Drawing.new("Square"),
        name = Drawing.new("Text"),
        health = Drawing.new("Text"),
        healthBar = Drawing.new("Line")
    }
    
    objects.box.Visible = false
    objects.box.Thickness = 2
    objects.box.Color = 0xFF0000FF
    objects.box.Filled = false
    
    objects.name.Visible = false
    objects.name.Size = 14
    objects.name.Center = true
    objects.name.Color = 0xFFFFFFFF
    
    objects.health.Visible = false
    objects.health.Size = 11
    objects.health.Center = true
    objects.health.Color = 0xFFFFFFFF
    
    objects.healthBar.Visible = false
    objects.healthBar.Thickness = 3
    objects.healthBar.Color = 0x00FF00FF
    
    ESPObjects[player] = objects
    
    local function Update()
        if not Settings.ESP or not player.Character then
            objects.box.Visible = false
            objects.name.Visible = false
            objects.health.Visible = false
            objects.healthBar.Visible = false
            return
        end
        
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if not humanoid or humanoid.Health <= 0 then
            objects.box.Visible = false
            objects.name.Visible = false
            objects.health.Visible = false
            objects.healthBar.Visible = false
            return
        end
        
        local root = player.Character:FindFirstChild("HumanoidRootPart") or player.Character:FindFirstChild("Head")
        if not root then return end
        
        local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
        if not onScreen then
            objects.box.Visible = false
            objects.name.Visible = false
            objects.health.Visible = false
            objects.healthBar.Visible = false
            return
        end
        
        local dist = (Camera.CFrame.Position - root.Position).Magnitude
        local boxHeight = math.clamp(2000 / dist, 40, 120)
        local boxWidth = boxHeight * 0.65
        
        local x = pos.X - boxWidth / 2
        local y = pos.Y - boxHeight / 2
        
        -- Рамка
        objects.box.Size = Vector2.new(boxWidth, boxHeight)
        objects.box.Position = Vector2.new(x, y)
        objects.box.Visible = true
        
        -- Цвет рамки от здоровья
        local hp = humanoid.Health
        local r = 255 - (hp * 2.55)
        local g = hp * 2.55
        local color = r * 65536 + g * 256 + 0
        objects.box.Color = color
        
        -- Имя
        objects.name.Text = player.Name .. " [" .. math.floor(hp) .. "]"
        objects.name.Position = Vector2.new(pos.X, y - 15)
        objects.name.Visible = true
        objects.name.Color = color
        
        -- Полоска здоровья
        local hpPercent = hp / 100
        local barX = x
        local barY = y + boxHeight + 2
        objects.healthBar.From = Vector2.new(barX, barY)
        objects.healthBar.To = Vector2.new(barX + (boxWidth * hpPercent), barY)
        objects.healthBar.Visible = true
        objects.healthBar.Color = color
    end
    
    player.CharacterAdded:Connect(Update)
    player.CharacterRemoving:Connect(function()
        objects.box.Visible = false
        objects.name.Visible = false
        objects.health.Visible = false
        objects.healthBar.Visible = false
    end)
    RunService.RenderStepped:Connect(Update)
    Update()
end

-- Создаём ESP для всех игроков
for _, plr in ipairs(Players:GetPlayers()) do
    Create2DBox(plr)
end
Players.PlayerAdded:Connect(Create2DBox)

-- Очистка при удалении игрока
Players.PlayerRemoving:Connect(function(player)
    if ESPObjects[player] then
        for _, obj in pairs(ESPObjects[player]) do
            obj:Remove()
        end
        ESPObjects[player] = nil
    end
end)

-- ========== AIMBOT (ЧЕРЕЗ CFrame) ==========
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

-- Аим при выстреле (левая кнопка)
local lastShot = 0
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

-- ========== BUNNY HOP (АВТОПРЫЖОК) ==========
local function BunnyHop()
    local char = LocalPlayer.Character
    if not char then return end
    
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    if humanoid.FloorMaterial ~= Enum.Material.Air then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Space and Settings.BunnyHop then
        BunnyHop()
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
MainFrame.Size = UDim2.new(0, 300, 0, 200)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
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

local function CreateButton(text, y, getter, setter)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 130, 0, 35)
    btn.Position = UDim2.new(0.5, -65, 0, y)
    btn.BackgroundColor3 = getter() and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(50, 50, 65)
    btn.Text = text .. ": " .. (getter() and "ON" or "OFF")
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 14
    btn.Parent = MainFrame
    btn.MouseButton1Click:Connect(function()
        setter(not getter())
        btn.Text = text .. ": " .. (getter() and "ON" or "OFF")
        btn.BackgroundColor3 = getter() and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(50, 50, 65)
    end)
    return btn
end

CreateButton("AIMBOT", 45, function() return Settings.Aimbot end, function(v) Settings.Aimbot = v end)
CreateButton("2D ESP", 90, function() return Settings.ESP end, function(v) Settings.ESP = v end)
CreateButton("BUNNY HOP", 135, function() return Settings.BunnyHop end, function(v) Settings.BunnyHop = v end)

-- Открытие меню
UserInputService.InputBegan:Connect(function(input)
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
Indicator.Size = UDim2.new(0, 300, 0, 25)
Indicator.Position = UDim2.new(0.5, -150, 0, 5)
Indicator.BackgroundTransparency = 0.6
Indicator.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Indicator.Text = "SWILL: AIM ON | ESP ON | BHOP ON"
Indicator.TextColor3 = Color3.fromRGB(0, 255, 0)
Indicator.TextSize = 12
Indicator.Font = Enum.Font.GothamBold
Indicator.Parent = ScreenGui

spawn(function()
    while wait(0.3) do
        Indicator.Text = "SWILL: AIM " .. (Settings.Aimbot and "ON" or "OFF") .. " | ESP " .. (Settings.ESP and "ON" or "OFF") .. " | BHOP " .. (Settings.BunnyHop and "ON" or "OFF")
        local anyOn = Settings.Aimbot or Settings.ESP or Settings.BunnyHop
        Indicator.TextColor3 = anyOn and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    end
end)

-- ========== УВЕДОМЛЕНИЕ ==========
print("========================================")
print("SWILL ЗАГРУЖЕН ДЛЯ COUNTER BLOX")
print("2D ESP - прямоугольники на экране")
print("AIMBOT - автоматически при выстреле")
print("BUNNY HOP - зажми ПРОБЕЛ")
print("МЕНЮ - клавиша INSERT")
print("========================================")

pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "SWILL",
        Text = "Загружен! INSERT меню | 2D ESP + AIM + BHOP",
        Duration = 4
    })
end)
