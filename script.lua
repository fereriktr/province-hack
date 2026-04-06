-- SWILL: ИСПРАВЛЕННЫЙ AIMBOT (БЕЗ ОТВОДА МЫШИ ВНИЗ)
-- Вставь ЭТУ ЧАСТЬ вместо твоего AIMBOT кода

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ========== НАСТРОЙКИ ==========
local Settings = {
    Aimbot = true,
    FOV = 250,
    AimPart = "Head",
    Smoothness = 0.2,
    NoRecoil = true  -- НОВАЯ ФУНКЦИЯ: убирает отдачу
}

-- ========== УБИРАЕМ ОТДАЧУ ==========
local function RemoveRecoil()
    if not Settings.NoRecoil then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    
    local hum = char:FindFirstChild("Humanoid")
    if hum then
        hum.CameraOffset = Vector3.new(0, 0, 0)
    end
    
    -- Убираем тряску оружия
    local tool = char:FindFirstChildWhichIsA("Tool")
    if tool then
        for _, v in ipairs(tool:GetDescendants()) do
            if v:IsA("AnimationTrack") then
                pcall(function() v:Stop() end)
            end
        end
    end
end

-- ========== ПОЛУЧЕНИЕ БЛИЖАЙШЕГО ВРАГА ==========
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

-- ========== НОВЫЙ AIMBOT (БЕЗ ВОЗВРАТА МЫШИ) ==========
local function SilentAim(target)
    if not target or not target.Character then return end
    
    local aimPart = target.Character:FindFirstChild(Settings.AimPart) or target.Character:FindFirstChild("Head")
    if not aimPart then return end
    
    -- Получаем позицию цели на экране
    local targetPos = Camera:WorldToViewportPoint(aimPart.Position)
    local targetVec = Vector2.new(targetPos.X, targetPos.Y)
    
    -- ТЕЛЕПОРТИРУЕМ МЫШЬ (без возврата)
    pcall(function()
        mousemoveabs(targetVec.X, targetVec.Y)
    end)
    
    -- Не возвращаем мышь обратно!
    -- Это решает проблему "отводится вниз"
end

-- Аим при выстреле (без возврата мыши)
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and Settings.Aimbot then
        local target = GetClosestEnemy()
        if target then
            SilentAim(target)
        end
    end
end)

-- ========== УБИРАЕМ ОТДАЧУ ПОСТОЯННО ==========
RunService.RenderStepped:Connect(RemoveRecoil)

-- ========== ИНДИКАТОР ==========
local gui = Instance.new("ScreenGui")
gui.Parent = game:GetService("CoreGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 30)
frame.Position = UDim2.new(0.5, -150, 0, 5)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BackgroundTransparency = 0.5
frame.Parent = gui

local text = Instance.new("TextLabel")
text.Size = UDim2.new(1, 0, 1, 0)
text.BackgroundTransparency = 1
text.Text = "SWILL: AIM FIXED | No Recoil ON"
text.TextColor3 = Color3.fromRGB(0, 255, 0)
text.TextSize = 12
text.Parent = frame

print("========================================")
print("SWILL: AIMBOT ИСПРАВЛЕН")
print("Проблема с отводом мыши вниз РЕШЕНА")
print("NoRecoil включен")
print("========================================")
