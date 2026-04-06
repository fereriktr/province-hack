-- SWILL: ПРОСТЕЙШАЯ ВЕРСИЯ (РАБОТАЕТ 100%)
-- Всё управление через чат команды

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ========== НАСТРОЙКИ ==========
local Aimbot = true
local ESP = true
local BunnyHop = true

-- ========== ESP (ПРОСТАЯ ПОДСВЕТКА) ==========
local function UpdateESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local highlight = player.Character:FindFirstChild("SWILL_Highlight")
            if not highlight and ESP then
                highlight = Instance.new("Highlight")
                highlight.Name = "SWILL_Highlight"
                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                highlight.FillTransparency = 0.5
                highlight.Parent = player.Character
            elseif highlight and not ESP then
                highlight:Destroy()
            end
        end
    end
end

-- ========== AIMBOT ==========
local function GetTarget()
    local closest = nil
    local closestDist = 300
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local head = player.Character:FindFirstChild("Head")
            if head then
                local pos, on = Camera:WorldToViewportPoint(head.Position)
                if on then
                    local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closest = player
                    end
                end
            end
        end
    end
    return closest
end

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and Aimbot then
        local target = GetTarget()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local head = target.Character.Head
            local oldPos = Vector2.new(Mouse.X, Mouse.Y)
            local newPos = Camera:WorldToViewportPoint(head.Position)
            pcall(function() mousemoveabs(newPos.X, newPos.Y) end)
            task.wait()
            pcall(function() mousemoveabs(oldPos.X, oldPos.Y) end)
        end
    end
end)

-- ========== BUNNY HOP ==========
local jumping = false
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space and BunnyHop then
        jumping = true
        while jumping and BunnyHop do
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
        jumping = false
    end
end)

-- ========== ЧАТ КОМАНДЫ ==========
LocalPlayer.Chatted:Connect(function(msg)
    if msg == ".aim on" then
        Aimbot = true
        print("[SWILL] AIM ON")
    elseif msg == ".aim off" then
        Aimbot = false
        print("[SWILL] AIM OFF")
    elseif msg == ".esp on" then
        ESP = true
        UpdateESP()
        print("[SWILL] ESP ON")
    elseif msg == ".esp off" then
        ESP = false
        UpdateESP()
        print("[SWILL] ESP OFF")
    elseif msg == ".bhop on" then
        BunnyHop = true
        print("[SWILL] BHOP ON")
    elseif msg == ".bhop off" then
        BunnyHop = false
        print("[SWILL] BHOP OFF")
    end
end)

-- ========== ОБНОВЛЕНИЕ ESP ==========
RunService.RenderStepped:Connect(UpdateESP)

-- ========== ИНДИКАТОР ==========
local gui = Instance.new("ScreenGui")
gui.Name = "SWILL_Indicator"
gui.Parent = game:GetService("CoreGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 30)
frame.Position = UDim2.new(0.5, -100, 0, 5)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BackgroundTransparency = 0.5
frame.Parent = gui

local text = Instance.new("TextLabel")
text.Size = UDim2.new(1, 0, 1, 0)
text.BackgroundTransparency = 1
text.Text = "SWILL: AIM ON | ESP ON | BHOP ON"
text.TextColor3 = Color3.fromRGB(0, 255, 0)
text.TextSize = 12
text.Parent = frame

spawn(function()
    while true do
        wait(0.5)
        text.Text = "SWILL: AIM " .. (Aimbot and "ON" or "OFF") .. " | ESP " .. (ESP and "ON" or "OFF") .. " | BHOP " .. (BunnyHop and "ON" or "OFF")
    end
end)

-- ========== СТАРТ ==========
print("========================================")
print("SWILL ЗАГРУЖЕН!")
print("КОМАНДЫ В ЧАТ (напиши .aim on)")
print(".aim on/off - Аимбот")
print(".esp on/off - Подсветка врагов")
print(".bhop on/off - Автопрыжок")
print("========================================")
