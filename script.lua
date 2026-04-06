-- SWILL: XENO РАБОЧАЯ ВЕРСИЯ
-- Работает: ESP, Aimbot, BunnyHop
-- Управление: Чат команды

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
    FOV = 250
}

-- ========== ESP (BOX HANDLE ADORNMENT - РАБОТАЕТ В XENO) ==========
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "SWILL_ESP"
ESPFolder.Parent = workspace

local function CreateESP(player)
    if player == LocalPlayer then return end
    
    local box = Instance.new("BoxHandleAdornment")
    box.Name = player.Name
    box.Size = Vector3.new(3, 4, 2)
    box.Color3 = Color3.fromRGB(255, 0, 0)
    box.Transparency = 0.4
    box.AlwaysOnTop = true
    box.ZIndex = 0
    box.Parent = ESPFolder
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "Name_" .. player.Name
    billboard.Size = UDim2.new(0, 100, 0, 25)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = ESPFolder
    
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.TextColor3 = Color3.fromRGB(255, 255, 255)
    text.TextSize = 12
    text.Font = Enum.Font.GothamBold
    text.TextStrokeTransparency = 0.3
    text.Parent = billboard
    
    local function update()
        if not Settings.ESP then
            box.Visible = false
            billboard.Enabled = false
            return
        end
        
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            box.Adornee = player.Character.HumanoidRootPart
            billboard.Adornee = player.Character
            box.Visible = true
            billboard.Enabled = true
            
            local hum = player.Character:FindFirstChild("Humanoid")
            if hum then
                local hp = math.floor(hum.Health)
                local r = 255 - (hp * 2.55)
                local g = hp * 2.55
                box.Color3 = Color3.fromRGB(r, g, 0)
                text.Text = player.Name .. " [" .. hp .. " HP]"
                text.TextColor3 = Color3.fromRGB(r, g, 0)
            end
        else
            box.Visible = false
            billboard.Enabled = false
        end
    end
    
    player.CharacterAdded:Connect(update)
    player.CharacterRemoving:Connect(function()
        box.Visible = false
        billboard.Enabled = false
    end)
    update()
    RunService.RenderStepped:Connect(update)
end

for _, v in ipairs(Players:GetPlayers()) do CreateESP(v) end
Players.PlayerAdded:Connect(CreateESP)

-- ========== AIMBOT ==========
local function GetClosestEnemy()
    local closestDist = Settings.FOV
    local closestPlayer = nil
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
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

-- Аим при нажатии левой кнопки
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and Settings.Aimbot then
        local target = GetClosestEnemy()
        if target and target.Character then
            local head = target.Character:FindFirstChild("Head")
            if head then
                local oldPos = Vector2.new(Mouse.X, Mouse.Y)
                local targetPos = Camera:WorldToViewportPoint(head.Position)
                
                -- Двигаем мышь к цели
                pcall(function()
                    mousemoveabs(targetPos.X, targetPos.Y)
                end)
                
                -- Небольшая задержка для выстрела
                task.wait(0.01)
                
                -- Возвращаем мышь (опционально)
                pcall(function()
                    mousemoveabs(oldPos.X, oldPos.Y)
                end)
            end
        end
    end
end)

-- ========== BUNNY HOP ==========
local spacePressed = false

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space and Settings.BunnyHop then
        spacePressed = true
        while spacePressed and Settings.BunnyHop do
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChild("Humanoid")
                if hum and hum.FloorMaterial ~= Enum.Material.Air then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
            task.wait(0.05)
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space then
        spacePressed = false
    end
end)

-- ========== ЧАТ КОМАНДЫ ==========
LocalPlayer.Chatted:Connect(function(msg)
    if msg == ".aim on" then
        Settings.Aimbot = true
        print("[SWILL] Aimbot ON")
    elseif msg == ".aim off" then
        Settings.Aimbot = false
        print("[SWILL] Aimbot OFF")
    elseif msg == ".esp on" then
        Settings.ESP = true
        print("[SWILL] ESP ON")
    elseif msg == ".esp off" then
        Settings.ESP = false
        print("[SWILL] ESP OFF")
    elseif msg == ".bhop on" then
        Settings.BunnyHop = true
        print("[SWILL] BunnyHop ON")
    elseif msg == ".bhop off" then
        Settings.BunnyHop = false
        print("[SWILL] BunnyHop OFF")
    elseif msg == ".fov 100" then
        Settings.FOV = 100
        print("[SWILL] FOV = 100")
    elseif msg == ".fov 200" then
        Settings.FOV = 200
        print("[SWILL] FOV = 200")
    elseif msg == ".fov 300" then
        Settings.FOV = 300
        print("[SWILL] FOV = 300")
    end
end)

-- ========== ИНДИКАТОР ==========
local ScreenGui = Instance.new("ScreenGui")
pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local Indicator = Instance.new("Frame")
Indicator.Size = UDim2.new(0, 220, 0, 30)
Indicator.Position = UDim2.new(0.5, -110, 0, 10)
Indicator.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Indicator.BackgroundTransparency = 0.5
Indicator.BorderSizePixel = 1
Indicator.BorderColor3 = Color3.fromRGB(255, 60, 60)
Indicator.Parent = ScreenGui

local IndicatorText = Instance.new("TextLabel")
IndicatorText.Size = UDim2.new(1, 0, 1, 0)
IndicatorText.BackgroundTransparency = 1
IndicatorText.Text = "SWILL: AIM ON | ESP ON | BHOP ON"
IndicatorText.TextColor3 = Color3.fromRGB(0, 255, 0)
IndicatorText.TextSize = 12
IndicatorText.Font = Enum.Font.GothamBold
IndicatorText.Parent = Indicator

spawn(function()
    while true do
        wait(0.3)
        local aimStatus = Settings.Aimbot and "ON" or "OFF"
        local espStatus = Settings.ESP and "ON" or "OFF"
        local bhopStatus = Settings.BunnyHop and "ON" or "OFF"
        IndicatorText.Text = "SWILL: AIM " .. aimStatus .. " | ESP " .. espStatus .. " | BHOP " .. bhopStatus
        IndicatorText.TextColor3 = (Settings.Aimbot or Settings.ESP or Settings.BunnyHop) and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    end
end)

-- ========== УВЕДОМЛЕНИЕ ==========
print("========================================")
print("SWILL ЗАГРУЖЕН ДЛЯ XENO!")
print("Чат команды:")
print("  .aim on/off  - AIMBOT")
print("  .esp on/off  - ESP")
print("  .bhop on/off - BUNNYHOP")
print("  .fov 100/200/300 - ДАЛЬНОСТЬ AIM")
print("========================================")

pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "SWILL",
        Text = "Загружен! Команды в чат: .aim on",
        Duration = 4
    })
end)
