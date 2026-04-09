-- SWILL: GLOW ОБВОДКА ПЕРСОНАЖА (ПО КОНТУРУ)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function AddGlowOutline(player)
    if player == LocalPlayer then return end
    
    local function onCharacterAdded(character)
        -- Удаляем старую обводку
        local oldGlow = character:FindFirstChild("GlowOutline")
        if oldGlow then oldGlow:Destroy() end
        
        -- Создаём свечение через Highlight
        local glow = Instance.new("Highlight")
        glow.Name = "GlowOutline"
        glow.FillTransparency = 1  -- Полностью прозрачная заливка (не видна)
        glow.OutlineTransparency = 0  -- Непрозрачный контур
        glow.OutlineColor = Color3.fromRGB(255, 0, 0)  -- Красный контур
        glow.FillColor = Color3.fromRGB(255, 0, 0)
        glow.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop  -- Видно через стены
        glow.Parent = character
        
        -- Обновляем цвет контура от здоровья
        local hum = character:WaitForChild("Humanoid")
        hum.HealthChanged:Connect(function()
            local hp = hum.Health
            local r = 255
            local g = math.min(255, hp * 2.55)
            local b = math.min(255, hp * 2.55)
            glow.OutlineColor = Color3.fromRGB(r, g, b)
        end)
    end
    
    if player.Character then
        onCharacterAdded(player.Character)
    end
    
    player.CharacterAdded:Connect(onCharacterAdded)
end

-- Добавляем обводку всем игрокам
for _, player in ipairs(Players:GetPlayers()) do
    AddGlowOutline(player)
end

Players.PlayerAdded:Connect(AddGlowOutline)

print("========================================")
print("SWILL: Glow обводка персонажа включена")
print("Красный контур вокруг врагов через стены")
print("========================================")
