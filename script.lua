-- SWILL: РАБОЧАЯ ВЕРСИЯ ДЛЯ XENO (ВСЁ В ОДНОМ)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ========== НАСТРОЙКИ ==========
local AimbotOn = true
local ESPOn = true
local BHopOn = true

-- ========== ESP (ПОДСВЕТКА) ==========
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "ESP"
ESPFolder.Parent = workspace

local function AddESP(plr)
    if plr == LocalPlayer then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = plr.Name
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0.3
    highlight.Parent = ESPFolder
    
    local function update()
        if plr.Character then
            highlight.Adornee = plr.Character
            highlight.Enabled = ESPOn
        else
            highlight.Adornee = nil
        end
    end
    
    plr.CharacterAdded:Connect(update)
    plr.CharacterRemoving:Connect(function() highlight.Adornee = nil end)
    update()
end

for _, plr in ipairs(Players:GetPlayers()) do AddESP(plr) end
Players.PlayerAdded:Connect(AddESP)

-- ========== AIMBOT ==========
local function GetClosest()
    local closest = nil
    local closestDist = 200
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

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and AimbotOn then
        local target = GetClosest()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local head = target.Character.Head
            local oldCF = Camera.CFrame
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position)
            task.wait()
            Camera.CFrame = oldCF
        end
    end
end)

-- ========== BUNNYHOP ==========
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space and BHopOn then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum and hum.FloorMaterial ~= Enum.Material.Air then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)

-- ========== ЧАТ КОМАНДЫ ==========
LocalPlayer.Chatted:Connect(function(msg)
    if msg == ".aim on" then AimbotOn = true print("AIM ON") end
    if msg == ".aim off" then AimbotOn = false print("AIM OFF") end
    if msg == ".esp on" then ESPOn = true print("ESP ON") end
    if msg == ".esp off" then ESPOn = false print("ESP OFF") end
    if msg == ".bhop on" then BHopOn = true print("BHOP ON") end
    if msg == ".bhop off" then BHopOn = false print("BHOP OFF") end
end)

-- ========== ИНДИКАТОР ==========
local ScreenGui = Instance.new("ScreenGui")
pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local Text = Instance.new("TextLabel")
Text.Size = UDim2.new(0, 250, 0, 30)
Text.Position = UDim2.new(0.5, -125, 0, 5)
Text.BackgroundTransparency = 0.7
Text.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Text.Text = "SWILL: AIM ON | ESP ON | BHOP ON"
Text.TextColor3 = Color3.fromRGB(0, 255, 0)
Text.TextSize = 12
Text.Parent = ScreenGui

spawn(function()
    while wait(0.5) do
        Text.Text = "SWILL: AIM " .. (AimbotOn and "ON" or "OFF") .. " | ESP " .. (ESPOn and "ON" or "OFF") .. " | BHOP " .. (BHopOn and "ON" or "OFF")
    end
end)

-- ========== КОМАНДЫ В КОНСОЛЬ ==========
print("========================================")
print("SWILL ЗАГРУЖЕН!")
print("Чат команды:")
print("  .aim on/off  - AIMBOT")
print("  .esp on/off  - ESP подсветка")
print("  .bhop on/off - BUNNYHOP")
print("========================================")
