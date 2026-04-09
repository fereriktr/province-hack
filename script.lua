-- SWILL: НЕВИДИМЫЙ WALLHACK (НЕ ТРОГАЕТ ИГРУ)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Используем только Drawing API (не создаёт GUI в игре)
local espObjects = {}

local function AddESP(player)
    if player == LocalPlayer then return end
    
    -- Создаём объекты для рисования
    local box = Drawing.new("Square")
    box.Visible = false
    box.Thickness = 2
    box.Color = 0xFF0000FF
    box.Filled = false
    box.Transparency = 0.5
    
    local name = Drawing.new("Text")
    name.Visible = false
    name.Size = 12
    name.Center = true
    name.Color = 0xFFFFFFFF
    
    local hpBar = Drawing.new("Line")
    hpBar.Visible = false
    hpBar.Thickness = 3
    hpBar.Color = 0x00FF00FF
    
    espObjects[player] = {box = box, name = name, hpBar = hpBar}
    
    local function update()
        if not player.Character then
            box.Visible = false
            name.Visible = false
            hpBar.Visible = false
            return
        end
        
        local root = player.Character:FindFirstChild("HumanoidRootPart") or player.Character:FindFirstChild("Head")
        if not root then
            box.Visible = false
            name.Visible = false
            hpBar.Visible = false
            return
        end
        
        local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
        if not onScreen then
            box.Visible = false
            name.Visible = false
            hpBar.Visible = false
            return
        end
        
        local dist = (Camera.CFrame.Position - root.Position).Magnitude
        local height = math.clamp(2000 / dist, 30, 100)
        local width = height * 0.6
        
        -- Рамка
        box.Size = Vector2.new(width, height)
        box.Position = Vector2.new(pos.X - width/2, pos.Y - height/2)
        box.Visible = true
        
        -- Имя
        name.Text = player.Name
        name.Position = Vector2.new(pos.X, pos.Y - height/2 - 10)
        name.Visible = true
        
        -- Полоска здоровья
        local hum = player.Character:FindFirstChild("Humanoid")
        if hum then
            local hpPercent = hum.Health / 100
            local hpWidth = width * hpPercent
            local hpColor = 0x00FF00FF
            if hpPercent < 0.5 then hpColor = 0xFFFF00FF end
            if hpPercent < 0.2 then hpColor = 0xFF0000FF end
            
            hpBar.From = Vector2.new(pos.X - width/2, pos.Y + height/2 + 2)
            hpBar.To = Vector2.new(pos.X - width/2 + hpWidth, pos.Y + height/2 + 2)
            hpBar.Color = hpColor
            hpBar.Visible = true
        end
    end
    
    player.CharacterAdded:Connect(update)
    player.CharacterRemoving:Connect(function()
        box.Visible = false
        name.Visible = false
        hpBar.Visible = false
    end)
    RunService.RenderStepped:Connect(update)
    update()
end

-- Запускаем ESP
for _, player in ipairs(Players:GetPlayers()) do
    AddESP(player)
end

Players.PlayerAdded:Connect(AddESP)

-- Чистка
Players.PlayerRemoving:Connect(function(player)
    if espObjects[player] then
        espObjects[player].box:Remove()
        espObjects[player].name:Remove()
        espObjects[player].hpBar:Remove()
        espObjects[player] = nil
    end
end)

print("========================================")
print("SWILL: WallHack активирован")
print("Рисование через Drawing API")
print("========================================")
