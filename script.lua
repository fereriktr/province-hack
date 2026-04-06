-- SWILL: TRUE SILENT AIM для XENO + FLICK (БЕЗ ДЕРГАНЬЯ)
-- Мышь НЕ двигается вообще. Пули сами летят в голову.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ========== НАСТРОЙКИ ==========
local Settings = {
    Enabled = true,
    FOV = 360,  -- Максимальный FOV для теста
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

-- ========== TRUE SILENT AIM (БЕЗ ДВИЖЕНИЯ МЫШИ) ==========
-- Метод: Перехватываем направление выстрела и подменяем луч

local originalRaycast = workspace.FindPartOnRay or workspace.Raycast

-- Для игр с инструментами (оружие)
local function GetCurrentWeapon()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChildWhichIsA("Tool")
end

-- Подмена направления выстрела
local function SilentShoot(target)
    if not target or not target.Character then return false end
    
    local aimPart = target.Character:FindFirstChild(Settings.AimPart) or target.Character:FindFirstChild("Head")
    if not aimPart then return false end
    
    local weapon = GetCurrentWeapon()
    if not weapon then return false end
    
    -- Сохраняем текущее направление камеры
    local originalCF = Camera.CFrame
    
    -- Временно поворачиваем камеру на цель (без визуального эффекта)
    Camera.CFrame = CFrame.new(originalCF.Position, aimPart.Position)
    
    -- Делаем выстрел
    local success = false
    pcall(function()
        -- Эмулируем нажатие ЛКМ
        local mouse = LocalPlayer:GetMouse()
        mouse.Button1Down()
        task.wait(0.01)
        mouse.Button1Up()
        success = true
    end)
    
    -- Возвращаем камеру
    Camera.CFrame = originalCF
    
    return success
end

-- Перехват выстрела
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 and Settings.Enabled then
        local target = GetClosestEnemy()
        if target then
            SilentShoot(target)
        end
    end
end)

-- ========== АЛЬТЕРНАТИВНЫЙ МЕТОД (если верхний не работает) ==========
-- Через RemoteEvent (для некоторых игр)
local function AlternativeSilentAim()
    local target = GetClosestEnemy()
    if not target then return end
    
    local aimPart = target.Character:FindFirstChild(Settings.AimPart) or target.Character:FindFirstChild("Head")
    if not aimPart then return end
    
    -- Ищем remote для выстрела
    local playerGui = LocalPlayer.PlayerGui
    local remotes = {}
    
    local function findRemotes(obj)
        for _, v in ipairs(obj:GetChildren()) do
            if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                table.insert(remotes, v)
            end
            findRemotes(v)
        end
    end
    
    pcall(function() findRemotes(playerGui) end)
    pcall(function() findRemotes(LocalPlayer.Character) end)
    pcall(function() findRemotes(game:GetService("ReplicatedStorage")) end)
    
    -- Пытаемся найти remote выстрела
    for _, remote in ipairs(remotes) do
        if remote.Name:lower():match("shoot") or remote.Name:lower():match("fire") or remote.Name:lower():match("damage") then
            pcall(function()
                remote:FireServer(aimPart.Position, aimPart)
            end)
        end
    end
end

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
        SendChat("Silent Aim ВКЛЮЧЕН (без дерганья)")
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
        SendChat("Команды: ;aim on/off, ;fov 180")
    end
end

pcall(function() LocalPlayer.Chatted:Connect(HandleCommand) end)

-- ========== ИНДИКАТОР (видишь ли ты врагов) ==========
local indicator = Instance.new("TextLabel")
indicator.Size = UDim2.new(0, 200, 0, 30)
indicator.Position = UDim2.new(0.5, -100, 0, 10)
indicator.BackgroundTransparency = 1
indicator.Text = "SWILL: ИЩУ ВРАГОВ..."
indicator.TextColor3 = Color3.fromRGB(255, 255, 255)
indicator.TextSize = 14
indicator.Font = Enum.Font.GothamBold
pcall(function() indicator.Parent = LocalPlayer.PlayerGui end)

-- Обновление индикатора
spawn(function()
    while wait(0.5) do
        if Settings.Enabled then
            local target = GetClosestEnemy()
            if target then
                indicator.Text = "SWILL: ЦЕЛЬ - " .. target.Name .. " (FOV: " .. Settings.FOV .. ")"
                indicator.TextColor3 = Color3.fromRGB(0, 255, 0)
            else
                indicator.Text = "SWILL: ВРАГОВ НЕТ В FOV (" .. Settings.FOV .. ")"
                indicator.TextColor3 = Color3.fromRGB(255, 100, 100)
            end
        else
            indicator.Text = "SWILL: ВЫКЛЮЧЕН (;aim on)"
            indicator.TextColor3 = Color3.fromRGB(255, 255, 0)
        end
    end
end)

-- ========== ЗАПУСК ==========
SendChat("=== SWILL TRUE SILENT AIM для XENO + Flick ===")
SendChat("Мышь НЕ двигается! Пули сами летят в голову.")
SendChat("Статус: ВКЛЮЧЕН | FOV: " .. Settings.FOV)
SendChat("Команды: ;aim on/off, ;fov 180")
SendChat("=============================================")

print("=== SWILL TRUE SILENT AIM LOADED ===")
print("Без дерганья мыши!")
