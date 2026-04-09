-- SWILL: РАБОЧИЙ WALLHACK (ЧЕРЕЗ BOXHANDLEADORNMENT)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Создаём папку в workspace (не в CoreGui)
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "SWILL_ESP"
ESPFolder.Parent = workspace

local espObjects = {}

local function AddESP(player)
    if player == LocalPlayer then return end
    
    -- Создаём рамку вокруг игрока
    local box = Instance.new("BoxHandleAdornment")
    box.Name = "ESP_" .. player.Name
    box.Size = Vector3.new(3, 4, 2)
    box.Color3 = Color3.fromRGB(255, 0, 0)
    box.Transparency = 0.3
    box.ZIndex = 0
    box.AlwaysOnTop = true
    box.Visible = true
    box.Parent = ESPFolder
    
    -- Создаём текстовую табличку
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "Name_" .. player.Name
    billboard.Size = UDim2.new(0, 100, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = ESPFolder
    
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.Text = player.Name
    text.TextColor3 = Color3.fromRGB(255, 255, 255)
    text.TextSize = 12
    text.Font = Enum.Font.GothamBold
    text.TextStrokeTransparency = 0.3
    text.Parent = billboard
    
    espObjects[player] = {box = box, billboard = billboard, text = text}
    
    local function update()
        if player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                box.Adornee = root
                billboard.Adornee = player.Character
                
                -- Меняем цвет в зависимости от здоровья
                local hum = player.Character:FindFirstChild("Humanoid")
                if hum then
                    local hp = hum.Health
                    local r = 255 - (hp * 2.55)
                    local g = hp * 2.55
                    box.Color3 = Color3.fromRGB(r, g, 0)
                    text.Text = player.Name .. " [" .. math.floor(hp) .. "]"
                    text.TextColor3 = Color3.fromRGB(r, g, 0)
                end
                
                box.Visible = true
                billboard.Enabled = true
            else
                box.Visible = false
                billboard.Enabled = false
            end
        else
            box.Visible = false
            billboard.Enabled = false
        end
    end
    
    player.CharacterAdded:Connect(update)
    player.CharacterRemoving:Connect(function()
        box.Visible = false
        billboard.Enabled = false
    end)
    RunService.RenderStepped:Connect(update)
    update()
end

-- Добавляем ESP всем игрокам
for _, player in ipairs(Players:GetPlayers()) do
    AddESP(player)
end

Players.PlayerAdded:Connect(AddESP)

-- Чистка
Players.PlayerRemoving:Connect(function(player)
    if espObjects[player] then
        espObjects[player].box:Destroy()
        espObjects[player].billboard:Destroy()
        espObjects[player] = nil
    end
end)

print("========================================")
print("SWILL: WallHack включён!")
print("Красные рамки вокруг врагов")
print("========================================")
