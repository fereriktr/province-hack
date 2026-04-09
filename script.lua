-- SWILL: WALLHACK БЕЗ ДЕТЕКТА (НЕ ТРОГАЕТ ИГРОВЫЕ СКРИПТЫ)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ========== WALLHACK ЧЕРЕЗ ESP (НЕ ТРОГАЕТ ПЕРСОНАЖЕЙ) ==========
local ESPObjects = {}

local function CreateWallhack(player)
    if player == LocalPlayer then return end
    
    -- Используем Drawing (рисуем на экране, не трогаем игру)
    local box = Drawing.new("Square")
    box.Visible = false
    box.Thickness = 2
    box.Color = 0xFF0000FF
    box.Filled = false
    
    local name = Drawing.new("Text")
    name.Visible = false
    name.Size = 14
    name.Center = true
    name.Color = 0xFFFFFFFF
    
    ESPObjects[player] = {box = box, name = name}
    
    -- Обновление позиции
    local function update()
        if not player.Character then
            box.Visible = false
            name.Visible = false
            return
        end
        
        local root = player.Character:FindFirstChild("HumanoidRootPart") or player.Character:FindFirstChild("Head")
        if not root then
            box.Visible = false
            name.Visible = false
            return
        end
        
        local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
        if not onScreen then
            box.Visible = false
            name.Visible = false
            return
        end
        
        -- Размер рамки от расстояния
        local dist = (Camera.CFrame.Position - root.Position).Magnitude
        local size = math.clamp(3000 / dist, 40, 120)
        
        box.Size = Vector2.new(size * 0.7, size)
        box.Position = Vector2.new(pos.X - (size * 0.35), pos.Y - size / 2)
        box.Visible = true
        
        name.Text = player.Name
        name.Position = Vector2.new(pos.X, pos.Y - size / 2 - 10)
        name.Visible = true
    end
    
    player.CharacterAdded:Connect(update)
    player.CharacterRemoving:Connect(function()
        box.Visible = false
        name.Visible = false
    end)
    RunService.RenderStepped:Connect(update)
    update()
end

-- Запускаем для всех игроков
for _, player in ipairs(Players:GetPlayers()) do
    CreateWallhack(player)
end

Players.PlayerAdded:Connect(CreateWallhack)

-- Чистка при удалении игрока
Players.PlayerRemoving:Connect(function(player)
    if ESPObjects[player] then
        ESPObjects[player].box:Remove()
        ESPObjects[player].name:Remove()
        ESPObjects[player] = nil
    end
end)

print("========================================")
print("SWILL: WallHack загружен (без детекта)")
print("Красные рамки вокруг врагов")
print("========================================")
