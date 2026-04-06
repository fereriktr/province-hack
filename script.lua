-- SWILL: УЛУЧШЕННЫЙ AIMBOT + ESP + BHOP
-- Работает в XENO, Counter Blox

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ========== НАСТРОЙКИ ==========
local Settings = {
    Aimbot = true,
    ESP = true,
    BunnyHop = true,
    AimPart = "Head",  -- Head, HumanoidRootPart
    FOV = 200,
    Smoothness = 0.3,  -- Плавность (0.1 = быстро, 0.9 = медленно)
    VisibleCheck = false
}

-- ========== УЛУЧШЕННЫЙ AIMBOT ==========
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
        
        -- Проверка видимости
        if Settings.VisibleCheck then
            local ray = Ray.new(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position).Unit * 500)
            local hit = workspace:FindPartOnRay(ray, LocalPlayer.Character)
            if hit and not hit:IsDescendantOf(player.Character) then
                continue
            end
        end
        
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

-- Плавное наведение мыши
local function SmoothAim(targetPos)
    local currentPos = Vector2.new(Mouse.X, Mouse.Y)
    local delta = (targetPos - currentPos) * (1 - Settings.Smoothness)
    
    -- Ограничиваем максимальное движение за один кадр
    local maxDelta = 50
    delta = Vector2.new(
        math.clamp(delta.X, -maxDelta, maxDelta),
        math.clamp(delta.Y, -maxDelta, maxDelta)
    )
    
    pcall(function()
        mousemoverel(delta.X, delta.Y)
    end)
end

-- Аим при стрельбе
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and Settings.Aimbot then
        local target = GetClosestEnemy()
        if target and target.Character then
            local aimPart = target.Character:FindFirstChild(Settings.AimPart) or target.Character:FindFirstChild("Head")
            if aimPart then
                local targetScreen = Camera:WorldToViewportPoint(aimPart.Position)
                local targetVec = Vector2.new(targetScreen.X, targetScreen.Y)
                SmoothAim(targetVec)
            end
        end
    end
end)

-- Постоянный аим (если зажата левая кнопка)
UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and Settings.Aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        local target = GetClosestEnemy()
        if target and target.Character then
            local aimPart = target.Character:FindFirstChild(Settings.AimPart) or target.Character:FindFirstChild("Head")
            if aimPart then
                local targetScreen = Camera:WorldToViewportPoint(aimPart.Position)
                local targetVec = Vector2.new(targetScreen.X, targetScreen.Y)
                SmoothAim(targetVec)
            end
        end
    end
end)

-- ========== ESP (ПОДСВЕТКА) ==========
local function UpdateESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local highlight = player.Character:FindFirstChild("SWILL_Highlight")
            if not highlight and Settings.ESP then
                highlight = Instance.new("Highlight")
                highlight.Name = "SWILL_Highlight"
                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                highlight.FillTransparency = 0.4
                highlight.OutlineTransparency = 0.2
                highlight.Parent = player.Character
            elseif highlight and not Settings.ESP then
                highlight:Destroy()
            elseif highlight and Settings.ESP then
                -- Меняем цвет в зависимости от здоровья
                local hum = player.Character:FindFirstChild("Humanoid")
                if hum then
                    local hp = hum.Health
                    local r = 255 - (hp * 2.55)
                    local g = hp * 2.55
                    highlight.FillColor = Color3.fromRGB(r, g, 0)
                end
            end
        end
    end
end

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
        print("[SWILL] AIM ON")
    elseif msg == ".aim off" then
        Settings.Aimbot = false
        print("[SWILL] AIM OFF")
    elseif msg == ".esp on" then
        Settings.ESP = true
        UpdateESP()
        print("[SWILL] ESP ON")
    elseif msg == ".esp off" then
        Settings.ESP = false
        UpdateESP()
        print("[SWILL] ESP OFF")
    elseif msg == ".bhop on" then
        Settings.BunnyHop = true
        print("[SWILL] BHOP ON")
    elseif msg == ".bhop off" then
        Settings.BunnyHop = false
        print("[SWILL] BHOP OFF")
    elseif msg:match(".fov") then
        local fov = tonumber(msg:match("%d+"))
        if fov and fov >= 50 and fov <= 360 then
            Settings.FOV = fov
            print("[SWILL] FOV = " .. fov)
        end
    elseif msg == ".body" then
        Settings.AimPart = "HumanoidRootPart"
        print("[SWILL] AIM BODY")
    elseif msg == ".head" then
        Settings.AimPart = "Head"
        print("[SWILL] AIM HEAD")
    elseif msg == ".fast" then
        Settings.Smoothness = 0.1
        print("[SWILL] FAST AIM")
    elseif msg == ".smooth" then
        Settings.Smoothness = 0.5
        print("[SWILL] SMOOTH AIM")
    end
end)

-- ========== ОБНОВЛЕНИЕ ESP ==========
RunService.RenderStepped:Connect(UpdateESP)

-- ========== ИНДИКАТОР ==========
local gui = Instance.new("ScreenGui")
gui.Name = "SWILL_Indicator"
gui.Parent = game:GetService("CoreGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 350, 0, 35)
frame.Position = UDim2.new(0.5, -175, 0, 5)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BackgroundTransparency = 0.6
frame.BorderSizePixel = 1
frame.BorderColor3 = Color3.fromRGB(255, 60, 60)
frame.Parent = gui

local text = Instance.new("TextLabel")
text.Size = UDim2.new(1, 0, 1, 0)
text.BackgroundTransparency = 1
text.Text = "SWILL"
text.TextColor3 = Color3.fromRGB(0, 255, 0)
text.TextSize = 12
text.Parent = frame

spawn(function()
    while true do
        wait(0.2)
        local aimPartText = Settings.AimPart == "Head" and "HEAD" or "BODY"
        text.Text = string.format("SWILL | AIM: %s | FOV: %d | %s | ESP: %s | BHOP: %s",
            Settings.Aimbot and "ON" or "OFF",
            Settings.FOV,
            aimPartText,
            Settings.ESP and "ON" or "OFF",
            Settings.BunnyHop and "ON" or "OFF"
        )
        text.TextColor3 = Settings.Aimbot and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    end
end)

-- ========== СТАРТ ==========
print("========================================")
print("SWILL УЛУЧШЕННЫЙ ЗАГРУЖЕН!")
print("")
print("КОМАНДЫ В ЧАТ:")
print("  .aim on/off    - Аимбот")
print("  .esp on/off    - Подсветка")
print("  .bhop on/off   - Автопрыжок")
print("  .fov 150       - Зона поиска (50-360)")
print("  .head          - Стрелять в голову")
print("  .body          - Стрелять в тело")
print("  .fast          - Быстрое наведение")
print("  .smooth        - Плавное наведение")
print("")
print("РЕКОМЕНДУЮ: .fov 200 .head .fast")
print("========================================")
