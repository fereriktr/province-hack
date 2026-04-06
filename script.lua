-- SWILL: XENO + FLICK (АЛЬТЕРНАТИВНЫЙ МЕТОД)
-- Использует mousemoveabs + быстрый выстрел

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local Settings = { Enabled = true, FOV = 180, AimPart = "Head" }

-- Wallhack (быстрый)
local folder = Instance.new("Folder")
folder.Name = "SWILL_ESP"
pcall(function() folder.Parent = game:GetService("CoreGui") end)
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        local h = Instance.new("Highlight")
        h.Name = p.Name
        h.FillColor = Color3.fromRGB(255,0,0)
        h.FillTransparency = 0.5
        h.Parent = folder
        p.CharacterAdded:Connect(function() h.Adornee = p.Character end)
        p.CharacterRemoving:Connect(function() h.Adornee = nil end)
        if p.Character then h.Adornee = p.Character end
    end
end

-- Получение цели
local function GetTarget()
    local best, bestDist = nil, Settings.FOV
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        if not p.Character then continue end
        local hum = p.Character:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        local part = p.Character:FindFirstChild(Settings.AimPart) or p.Character:FindFirstChild("Head")
        if not part then continue end
        local pos, on = Camera:WorldToViewportPoint(part.Position)
        if not on then continue end
        local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
        if dist < bestDist then bestDist, best = dist, p end
    end
    return best
end

-- Аим при клике
UserInputService.InputBegan:Connect(function(inp, proc)
    if proc then return end
    if inp.UserInputType == Enum.UserInputType.MouseButton1 and Settings.Enabled then
        local target = GetTarget()
        if target and target.Character then
            local part = target.Character:FindFirstChild(Settings.AimPart) or target.Character:FindFirstChild("Head")
            if part then
                local oldX, oldY = Mouse.X, Mouse.Y
                local screen = Camera:WorldToViewportPoint(part.Position)
                pcall(function() mousemoveabs(screen.X, screen.Y) end)
                task.wait(0.01)
                pcall(function() Mouse.Button1Down() end)
                task.wait(0.01)
                pcall(function() Mouse.Button1Up() end)
                task.wait(0.01)
                pcall(function() mousemoveabs(oldX, oldY) end)
            end
        end
    end
end)

-- Чат команды
LocalPlayer.Chatted:Connect(function(msg)
    if msg == ";aim on" then Settings.Enabled = true print("[SWILL] ON") end
    if msg == ";aim off" then Settings.Enabled = false print("[SWILL] OFF") end
    if msg:match(";fov") then local f = tonumber(msg:match("%d+")) if f then Settings.FOV = f end end
end)

print("[SWILL] XENO + Flick загружен! ;aim on/off, ;fov 180")
