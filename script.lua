-- SWILL: COUNTER BLOX - ПРОСТАЯ РАБОЧАЯ ВЕРСИЯ
-- ВСТАВЬ И НАЖМИ EXECUTE

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ========== ВКЛЮЧИТЬ/ВЫКЛЮЧИТЬ ФУНКЦИИ ==========
local AIMBOT_ENABLED = true   -- Включить аим
local ESP_ENABLED = true       -- Включить подсветку
local FOV = 300                -- Зона поиска (300 = почти весь экран)

-- ========== ПОДСВЕТКА ВРАГОВ (ESP) ==========
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "ESP"
ESPFolder.Parent = game:GetService("CoreGui")

local function AddESP(plr)
    if plr == LocalPlayer then return end
    
    local box = Instance.new("BoxHandleAdornment")
    box.Name = plr.Name
    box.Size = Vector3.new(3, 5, 3)
    box.Color3 = Color3.fromRGB(255, 0, 0)
    box.Transparency = 0.5
    box.ZIndex = 10
    box.AlwaysOnTop = true
    box.Parent = ESPFolder
    
    local function update()
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            box.Adornee = plr.Character.HumanoidRootPart
            box.Visible = ESP_ENABLED
        else
            box.Visible = false
        end
    end
    
    plr.CharacterAdded:Connect(update)
    plr.CharacterRemoving:Connect(function() box.Visible = false end)
    update()
end

for _, plr in ipairs(Players:GetPlayers()) do AddESP(plr) end
Players.PlayerAdded:Connect(AddESP)

-- ========== AIMBOT ==========
local function GetClosest()
    local closest = nil
    local closestDist = FOV
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if not plr.Character then continue end
        
        local hum = plr.Character:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        
        local head = plr.Character:FindFirstChild("Head")
        if not head then continue end
        
        local pos, on = Camera:WorldToViewportPoint(head.Position)
        if not on then continue end
        
        local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
        if dist < closestDist then
            closestDist = dist
            closest = plr
        end
    end
    return closest
end

-- Аим при выстреле
local oldClick = Mouse.Button1Down
Mouse.Button1Down = function()
    if AIMBOT_ENABLED then
        local target = GetClosest()
        if target and target.Character then
            local head = target.Character:FindFirstChild("Head")
            if head then
                local oldX, oldY = Mouse.X, Mouse.Y
                local pos = Camera:WorldToViewportPoint(head.Position)
                mousemoveabs(pos.X, pos.Y)
                oldClick()
                mousemoveabs(oldX, oldY)
                return
            end
        end
    end
    oldClick()
end

-- ========== ЧАТ КОМАНДЫ ==========
LocalPlayer.Chatted:Connect(function(msg)
    if msg == ".aim on" then
        AIMBOT_ENABLED = true
        print("[SWILL] Aimbot ON")
    elseif msg == ".aim off" then
        AIMBOT_ENABLED = false
        print("[SWILL] Aimbot OFF")
    elseif msg == ".esp on" then
        ESP_ENABLED = true
        print("[SWILL] ESP ON")
    elseif msg == ".esp off" then
        ESP_ENABLED = false
        print("[SWILL] ESP OFF")
    end
end)

-- ========== ИНДИКАТОР ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game:GetService("CoreGui")

local Text = Instance.new("TextLabel")
Text.Size = UDim2.new(0, 200, 0, 30)
Text.Position = UDim2.new(0.5, -100, 0, 10)
Text.BackgroundTransparency = 1
Text.Text = "SWILL | AIM: ON | ESP: ON"
Text.TextColor3 = Color3.fromRGB(0, 255, 0)
Text.TextSize = 14
Text.Font = Enum.Font.GothamBold
Text.Parent = ScreenGui

spawn(function()
    while wait(1) do
        Text.Text = "SWILL | AIM: " .. (AIMBOT_ENABLED and "ON" or "OFF") .. " | ESP: " .. (ESP_ENABLED and "ON" or "OFF")
        Text.TextColor3 = AIMBOT_ENABLED and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    end
end)

print("======================================")
print("SWILL загружен для Counter Blox!")
print("Aimbot: просто стреляй - попадает в голову")
print("ESP: красные кубы вокруг врагов")
print("Чат команды:")
print("  .aim on  - включить аим")
print("  .aim off - выключить аим")
print("  .esp on  - включить подсветку")
print("  .esp off - выключить подсветку")
print("======================================")
