-- SWILL: ПРОСТОЙ WALLHACK (ПОДСВЕТКА ВРАГОВ)
-- Работает в любой игре Roblox

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Создаём папку для подсветки
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "SWILL_Wallhack"
ESPFolder.Parent = workspace

-- Функция добавления подсветки игроку
local function AddHighlight(player)
    if player == LocalPlayer then return end
    
    -- Ждём появления персонажа
    local function onCharacterAdded(character)
        -- Удаляем старую подсветку если есть
        local oldHighlight = character:FindFirstChild("WallhackHighlight")
        if oldHighlight then oldHighlight:Destroy() end
        
        -- Создаём новую подсветку
        local highlight = Instance.new("Highlight")
        highlight.Name = "WallhackHighlight"
        highlight.FillColor = Color3.fromRGB(255, 0, 0)  -- Красный цвет
        highlight.FillTransparency = 0.5                 -- Полупрозрачный
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255) -- Белый контур
        highlight.OutlineTransparency = 0.3
        highlight.Parent = character
    end
    
    -- Если персонаж уже есть
    if player.Character then
        onCharacterAdded(player.Character)
    end
    
    -- Следим за появлением персонажа
    player.CharacterAdded:Connect(onCharacterAdded)
end

-- Добавляем подсветку всем игрокам
for _, player in ipairs(Players:GetPlayers()) do
    AddHighlight(player)
end

-- Добавляем подсветку новым игрокам
Players.PlayerAdded:Connect(AddHighlight)

print("========================================")
print("SWILL: WallHack включён!")
print("Все враги подсвечены красным через стены")
print("========================================")
