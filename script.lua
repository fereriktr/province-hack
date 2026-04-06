-- SWILL: XENO РАБОЧАЯ ВЕРСИЯ (без хуков)
-- Работает через CFrame и RemoteEvent

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ========== НАСТРОЙКИ ==========
local Settings = {
    Aimbot = true,
    ESP = true,
    FOV = 180,
    AimPart = "Head"
}

-- ========== ESP (BoxHandleAdornment - работает везде) ==========
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "SWILL_ESP"
ESPFolder.Parent = workspace

local function AddESP(player)
    if player == LocalPlayer then return end
    
    local box = Instance.new("BoxHandleAdornment")
    box.Name = player.Name
    box.Size = Vector3.new(3, 4, 2)
    box.Color3 = Color3.fromRGB(255, 0, 0)
    box.Transparency = 0.4
    box.ZIndex = 0
    box.AlwaysOnTop = true
    box.Parent = ESPFolder
    
    local function update()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            box.Adornee = player.Character.HumanoidRootPart
            box.Visible = Settings.ESP
        else
            box.Visible = false
        end
    end
    
    player.CharacterAdded:Connect(update)
    player.CharacterRemoving:Connect(function() box.Visible = false end)
    update()
    RunService.RenderStepped:Connect(update)
end

for _, v in ipairs(Players:GetPlayers()) do AddESP(v) end
Players.PlayerAdded:Connect(AddESP)

-- ========== AIMBOT (через CFrame - без движения мыши) ==========
local function GetClosestEnemy()
    local closestDist = Settings.FOV
    local closestPlayer = nil
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not player.Character then continue end
        
        local hum = player.Character:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        
        local targetPart = player.Character:FindFirstChild(Settings.AimPart) or player.Character:FindFirstChild("Head")
        if not targetPart then continue end
        
        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
        if not onScreen then continue end
        
        local dist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
        if dist < closestDist then
            closestDist = dist
            closestPlayer = player
        end
    end
    return closestPlayer
end

-- Аим при выстреле (поворот камеры)
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and Settings.Aimbot then
        local target = GetClosestEnemy()
        if target and target.Character then
            local aimPart = target.Character:FindFirstChild(Settings.AimPart) or target.Character:FindFirstChild("Head")
            if aimPart then
                -- Сохраняем старую позицию камеры
                local oldCF = Camera.CFrame
                -- Поворачиваем камеру на цель
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, aimPart.Position)
                -- Ждём 1 кадр
                task.wait()
                -- Возвращаем камеру
                Camera.CFrame = oldCF
            end
        end
    end
end)

-- ========== УПРОЩЁННОЕ МЕНЮ ==========
local ScreenGui = Instance.new("ScreenGui")
pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 120)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -60)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BackgroundTransparency = 0.1
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
Title.Text = "SWILL CONTROLS"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Parent = MainFrame

local AimBtn = Instance.new("TextButton")
AimBtn.Size = UDim2.new(0, 100, 0, 30)
AimBtn.Position = UDim2.new(0.5, -110, 0, 40)
AimBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
AimBtn.Text = "AIM: ON"
AimBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AimBtn.Parent = MainFrame

local ESPBtn = Instance.new("TextButton")
ESPBtn.Size = UDim2.new(0, 100, 0, 30)
ESPBtn.Position = UDim2.new(0.5, 10, 0, 40)
ESPBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
ESPBtn.Text = "ESP: ON"
ESPBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPBtn.Parent = MainFrame

AimBtn.MouseButton1Click:Connect(function()
    Settings.Aimbot = not Settings.Aimbot
    AimBtn.Text = "AIM: " .. (Settings.Aimbot and "ON" or "OFF")
    AimBtn.BackgroundColor3 = Settings.Aimbot and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(50, 50, 65)
end)

ESPBtn.MouseButton1Click:Connect(function()
    Settings.ESP = not Settings.ESP
    ESPBtn.Text = "ESP: " .. (Settings.ESP and "ON" or "OFF")
    ESPBtn.BackgroundColor3 = Settings.ESP and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(50, 50, 65)
end)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- ========== ИНДИКАТОР ==========
local Indicator = Instance.new("TextLabel")
Indicator.Size = UDim2.new(0, 250, 0, 25)
Indicator.Position = UDim2.new(0.5, -125, 0, 5)
Indicator.BackgroundTransparency = 0.7
Indicator.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Indicator.Text = "SWILL: AIM ON | ESP ON"
Indicator.TextColor3 = Color3.fromRGB(0, 255, 0)
Indicator.TextSize = 12
Indicator.Parent = ScreenGui

spawn(function()
    while true do
        wait(0.5)
        Indicator.Text = "SWILL: AIM " .. (Settings.Aimbot and "ON" or "OFF") .. " | ESP " .. (Settings.ESP and "ON" or "OFF")
        Indicator.TextColor3 = Settings.Aimbot and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    end
end)

-- ========== УВЕДОМЛЕНИЕ ==========
print("=== SWILL LOADED ===")
print("INSERT - открыть меню")
print("Aimbot работает при стрельбе (поворот камеры)")
print("ESP - красные кубы вокруг врагов")
