-- SWILL: TRUE SILENT AIM для XENO + FLICK (БЕЗ ДВИЖЕНИЯ КАМЕРЫ И МЫШИ)
-- Мышь НЕ двигается. Камера НЕ двигается. Пули сами меняют траекторию.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ========== НАСТРОЙКИ ==========
local Settings = {
    Enabled = true,
    FOV = 360,
    AimPart = "Head",
    TeamCheck = true
}

-- ========== WALLHACK ==========
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "SWILL_ESP"
pcall(function() ESPFolder.Parent = game:GetService("CoreGui") end)
if not ESPFolder.Parent then
    ESPFolder.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local function AddESP(player)
    if player == LocalPlayer then return end
    local highlight = Instance.new("Highlight")
    highlight.Name = player.Name
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0.2
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.Enabled = true
    highlight.Parent = ESPFolder
    
    local function update()
        if player.Character then
            highlight.Adornee = player.Character
        else
            highlight.Adornee = nil
        end
    end
    player.CharacterAdded:Connect(update)
    player.CharacterRemoving:Connect(update)
    update()
end

for _, v in ipairs(Players:GetPlayers()) do AddESP(v) end
Players.PlayerAdded:Connect(AddESP)

-- ========== ПОЛУЧЕНИЕ БЛИЖАЙШЕГО ВРАГА ==========
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
        
        local targetPart = player.Character:FindFirstChild(Settings.AimPart) or player.Character:FindFirstChild("Head") or player.Character:FindFirstChild("HumanoidRootPart")
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

-- ========== TRUE SILENT AIM (ПОДМЕНА ЛУЧА) ==========
-- Сохраняем оригинальные функции
local originalFindPartOnRay = workspace.FindPartOnRay
local originalRaycast = workspace.Raycast
local originalWorldRootRaycast = game:GetService("Workspace").Raycast

-- Переменная для хранения цели
local currentTarget = nil
local currentTargetPart = nil

-- Обновляем цель каждый кадр
RunService.RenderStepped:Connect(function()
    if Settings.Enabled then
        local target = GetClosestEnemy()
        if target and target.Character then
            currentTarget = target
            currentTargetPart = target.Character:FindFirstChild(Settings.AimPart) or target.Character:FindFirstChild("Head") or target.Character:FindFirstChild("HumanoidRootPart")
        else
            currentTarget = nil
            currentTargetPart = nil
        end
    else
        currentTarget = nil
        currentTargetPart = nil
    end
end)

-- Перехват Raycast (главный метод)
local function hookedRaycast(origin, direction, ...)
    if Settings.Enabled and currentTargetPart then
        -- Вычисляем направление на цель
        local targetDirection = (currentTargetPart.Position - origin).Unit
        -- Подменяем направление луча на цель
        return originalRaycast(workspace, origin, targetDirection * 1000, ...)
    end
    return originalRaycast(workspace, origin, direction, ...)
end

-- Перехват FindPartOnRay
local function hookedFindPartOnRay(ray, ...)
    if Settings.Enabled and currentTargetPart then
        local targetDirection = (currentTargetPart.Position - ray.Origin).Unit
        local newRay = Ray.new(ray.Origin, targetDirection * 1000)
        return originalFindPartOnRay(workspace, newRay, ...)
    end
    return originalFindPartOnRay(workspace, ray, ...)
end

-- Применяем хуки (если функции существуют)
pcall(function()
    workspace.Raycast = hookedRaycast
end)
pcall(function()
    workspace.FindPartOnRay = hookedFindPartOnRay
end)

-- ========== АЛЬТЕРНАТИВНЫЙ МЕТОД ДЛЯ FLICK ==========
-- В Flick выстрелы часто идут через инструменты
local function HookWeapon(weapon)
    if not weapon then return end
    
    -- Ищем функцию выстрела
    for _, v in pairs(getgc(true)) do
        if type(v) == "function" then
            local info = debug.getinfo(v)
            if info and (info.name == "Fire" or info.name == "Shoot" or string.find(info.name or "", "shoot")) then
                local old = v
                debug.setupvalue(v, 1, function(...)
                    if Settings.Enabled and currentTargetPart then
                        local args = {...}
                        args[2] = currentTargetPart.Position
                        args[3] = currentTargetPart
                        return old(unpack(args))
                    end
                    return old(...)
                end)
            end
        end
    end
end

-- Отслеживаем появление оружия
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            HookWeapon(tool)
        end
    end
end)

if LocalPlayer.Character then
    for _, tool in ipairs(LocalPlayer.Character:GetChildren()) do
        if tool:IsA("Tool") then
            HookWeapon(tool)
        end
    end
end

-- ========== ДОПОЛНИТЕЛЬНО: БЛОКИРОВКА ОТДАЧИ ==========
local function NoRecoil()
    local char = LocalPlayer.Character
    if not char then return end
    
    -- Блокируем отдачу камеры
    local hum = char:FindFirstChild("Humanoid")
    if hum then
        hum.CameraOffset = Vector3.new(0, 0, 0)
    end
    
    -- Блокируем тряску оружия
    local tool = char:FindFirstChildWhichIsA("Tool")
    if tool then
        for _, v in ipairs(tool:GetDescendants()) do
            if v:IsA("AnimationTrack") then
                pcall(function() v:Stop() end)
            end
        end
    end
end

RunService.RenderStepped:Connect(NoRecoil)

-- ========== ЧАТ-КОМАНДЫ ==========
local function SendChat(msg)
    pcall(function()
        game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage", {
            Text = "[SWILL] " .. msg,
            Color = Color3.fromRGB(255, 80, 80)
        })
    end)
    print("[SWILL] " .. msg)
end

local function HandleCommand(cmd)
    cmd = string.lower(cmd)
    if cmd == ";aim on" then
        Settings.Enabled = true
        SendChat("Silent Aim ВКЛЮЧЕН (луч подменён, мышь не двигается)")
    elseif cmd == ";aim off" then
        Settings.Enabled = false
        SendChat("Silent Aim ВЫКЛЮЧЕН")
    elseif cmd:match(";fov") then
        local fov = tonumber(cmd:match("(%d+)"))
        if fov and fov >= 10 and fov <= 360 then
            Settings.FOV = fov
            SendChat("FOV: " .. fov)
        end
    elseif cmd == ";help" then
        SendChat("Команды: ;aim on/off, ;fov 180 | Мышь и камера НЕ двигаются")
    end
end

pcall(function() LocalPlayer.Chatted:Connect(HandleCommand) end)

-- ========== ИНДИКАТОР ==========
local indicator = Instance.new("TextLabel")
indicator.Size = UDim2.new(0, 250, 0, 35)
indicator.Position = UDim2.new(0.5, -125, 0, 10)
indicator.BackgroundTransparency = 0.7
indicator.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
indicator.TextColor3 = Color3.fromRGB(255, 255, 255)
indicator.TextSize = 14
indicator.Font = Enum.Font.GothamBold
indicator.Text = "SWILL: ЗАГРУЗКА..."
pcall(function() indicator.Parent = LocalPlayer.PlayerGui end)

spawn(function()
    while wait(0.3) do
        if Settings.Enabled then
            local target = GetClosestEnemy()
            if target then
                indicator.Text = "🎯 SWILL: " .. target.Name .. " | FOV: " .. Settings.FOV
                indicator.TextColor3 = Color3.fromRGB(0, 255, 0)
            else
                indicator.Text = "❌ SWILL: НЕТ ЦЕЛИ | FOV: " .. Settings.FOV
                indicator.TextColor3 = Color3.fromRGB(255, 100, 100)
            end
        else
            indicator.Text = "⚠️ SWILL: ВЫКЛЮЧЕН (;aim on)"
            indicator.TextColor3 = Color3.fromRGB(255, 255, 0)
        end
    end
end)

-- ========== ЗАПУСК ==========
SendChat("=== SWILL TRUE SILENT AIM (XENO + Flick) ===")
SendChat("Мышь и камера НЕ двигаются вообще!")
SendChat("Пули математически перехватываются и летят в голову")
SendChat("Статус: ВКЛЮЧЕН | FOV: " .. Settings.FOV)
SendChat("Команды: ;aim on/off, ;fov 180")
SendChat("============================================")

print("=== SWILL TRUE SILENT AIM LOADED ===")
print("Метод: подмена Raycast - мышь не двигается")
