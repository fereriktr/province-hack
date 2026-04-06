-- SWILL: COUNTER BLOX (РАБОЧАЯ ВЕРСИЯ)
-- АИМ: ЛЕВАЯ КНОПКА (автоматически при стрельбе)
-- ESP: КРАСНЫЕ РАМКИ
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
    FOV = 200,
    AimPart = "Head",
    ESP = true
}

-- ========== ПРОСТОЕ МЕНЮ ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SWILL_CB"
ScreenGui.Parent = game:GetService("CoreGui")
if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 300, 0, 200)
Frame.Position = UDim2.new(0.5, -150, 0.5, -100)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
Frame.BackgroundTransparency = 0.1
Frame.Visible = false
Frame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
Title.Text = "SWILL | COUNTER BLOX"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -35, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 16
CloseBtn.Parent = Title
CloseBtn.MouseButton1Click:Connect(function()
    Frame.Visible = false
end)

local function AddCheckbox(text, y, getter, setter)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 120, 0, 30)
    btn.Position = UDim2.new(0.5, -60, 0, y)
    btn.BackgroundColor3 = getter() and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(50, 50, 65)
    btn.Text = text .. (getter() and " [ON]" or " [OFF]")
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 14
    btn.Parent = Frame
    btn.MouseButton1Click:Connect(function()
        setter(not getter())
        btn.Text = text .. (getter() and " [ON]" or " [OFF]")
        btn.BackgroundColor3 = getter() and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(50, 50, 65)
    end)
end

AddCheckbox("Aimbot (авто)", 50, function() return Settings.Aimbot end, function(v) Settings.Aimbot = v end)
AddCheckbox("ESP (рамки)", 100, function() return Settings.ESP end, function(v) Settings.ESP = v end)

-- ========== ESP (РАМКИ ВОКРУГ ИГРОКОВ) ==========
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "SWILL_ESP"
pcall(function() ESPFolder.Parent = game:GetService("CoreGui") end)
if not ESPFolder.Parent then
    ESPFolder.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local function CreateESP(player)
    if player == LocalPlayer then return end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = player.Name
    billboard.Size = UDim2.new(0, 150, 0, 120)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = ESPFolder
    
    local box = Instance.new("Frame")
    box.Size = UDim2.new(0, 60, 0, 80)
    box.Position = UDim2.new(0.5, -30, 0.5, -40)
    box.BackgroundTransparency = 1
    box.BorderSizePixel = 2
    box.BorderColor3 = Color3.fromRGB(255, 0, 0)
    box.Parent = billboard
    
    local name = Instance.new("TextLabel")
    name.Size = UDim2.new(1, 0, 0, 20)
    name.Position = UDim2.new(0, 0, 0, -20)
    name.BackgroundTransparency = 1
    name.Text = player.Name
    name.TextColor3 = Color3.fromRGB(255, 255, 255)
    name.TextSize = 11
    name.Font = Enum.Font.GothamBold
    name.Parent = billboard
    
    local health = Instance.new("Frame")
    health.Size = UDim2.new(0, 60, 0, 4)
    health.Position = UDim2.new(0.5, -30, 1, 2)
    health.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    health.BorderSizePixel = 0
    health.Parent = billboard
    
    local function Update()
        if not player.Character then
            billboard.Adornee = nil
            return
        end
        billboard.Adornee = player.Character
        billboard.Enabled = Settings.ESP
        
        local hum = player.Character:FindFirstChild("Humanoid")
        if hum then
            local hp = hum.Health
            local percent = math.clamp(hp / 100, 0, 1)
            health.Size = UDim2.new(percent, 0, 0, 4)
            health.BackgroundColor3 = Color3.fromRGB(255 - (hp * 2.55), hp * 2.55, 0)
            name.Text = player.Name .. " [" .. math.floor(hp) .. "]"
            
            local color = Color3.fromRGB(255 - (hp * 2.55), hp * 2.55, 0)
            box.BorderColor3 = color
        end
    end
    
    player.CharacterAdded:Connect(Update)
    player.CharacterRemoving:Connect(Update)
    Update()
    RunService.RenderStepped:Connect(Update)
end

for _, v in ipairs(Players:GetPlayers()) do CreateESP(v) end
Players.PlayerAdded:Connect(CreateESP)

-- ========== AIMBOT (АВТОМАТИЧЕСКИ ПРИ СТРЕЛЬБЕ) ==========
local function GetTarget()
    local bestDist = Settings.FOV
    local bestTarget = nil
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, v in ipairs(Players:GetPlayers()) do
        if v == LocalPlayer then continue end
        if not v.Character then continue end
        
        local hum = v.Character:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        
        local part = v.Character:FindFirstChild(Settings.AimPart) or v.Character:FindFirstChild("Head")
        if not part then continue end
        
        local pos, on = Camera:WorldToViewportPoint(part.Position)
        if not on then continue end
        
        local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
        if dist < bestDist then
            bestDist = dist
            bestTarget = v
        end
    end
    return bestTarget
end

-- Аим при нажатии ЛЕВОЙ кнопки (выстрел)
local oldClick
oldClick = hookfunction(Mouse.Button1Down, function()
    if Settings.Aimbot then
        local target = GetTarget()
        if target and target.Character then
            local part = target.Character:FindFirstChild(Settings.AimPart) or target.Character:FindFirstChild("Head")
            if part then
                local oldPos = Vector2.new(Mouse.X, Mouse.Y)
                local targetPos = Camera:WorldToViewportPoint(part.Position)
                pcall(function() mousemoveabs(targetPos.X, targetPos.Y) end)
                local res = oldClick()
                pcall(function() mousemoveabs(oldPos.X, oldPos.Y) end)
                return res
            end
        end
    end
    return oldClick()
end)

-- ========== ОТКРЫТИЕ МЕНЮ ==========
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        Frame.Visible = not Frame.Visible
    end
end)

-- Перемещение окна
local dragStart, dragPos
Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragStart = input.Position
        dragPos = Frame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragStart and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        Frame.Position = UDim2.new(dragPos.X.Scale, dragPos.X.Offset + delta.X, dragPos.Y.Scale, dragPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragStart = nil
    end
end)

-- ========== УВЕДОМЛЕНИЕ ==========
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "SWILL | COUNTER BLOX",
        Text = "Загружен! Нажми INSERT для меню",
        Duration = 3
    })
end)

print("[SWILL] Counter Blox загружен!")
print("[SWILL] Aimbot: просто стреляй - пули летят в голову")
print("[SWILL] ESP: красные рамки вокруг врагов")
print("[SWILL] Меню: INSERT")
