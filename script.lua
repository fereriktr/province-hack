-- SWILL: SILENT AIM + WALLHACK (Roblox)
-- Стреляй куда угодно, пуля летит в врага
-- Открытие меню: INSERT

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ========== НАСТРОЙКИ ==========
local Settings = {
    MenuOpen = false,
    SilentAim = true,        -- Включен Silent Aim
    SilentFOV = 180,         -- Градусы (чем больше, тем шире зона)
    AimPart = "Head",        -- Head, HumanoidRootPart, Torso
    VisibleCheck = false,    -- Проверять видимость?
    TeamCheck = true,        -- Не стрелять в свою команду
    Wallhack = true,
    ShowESP = true
}

-- ========== GUI МЕНЮ ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SWILL_SilentAim"
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 380, 0, 400)
MainFrame.Position = UDim2.new(0.5, -190, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
MainFrame.BackgroundTransparency = 0.05
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -50, 1, 0)
TitleText.Position = UDim2.new(0, 15, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "SWILL | Silent Aim"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextSize = 18
TitleText.Font = Enum.Font.GothamBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -40, 0, 2)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 18
CloseBtn.Parent = TitleBar
CloseBtn.MouseButton1Click:Connect(function()
    Settings.MenuOpen = false
    MainFrame.Visible = false
end)

local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Size = UDim2.new(1, -20, 1, -60)
ContentFrame.Position = UDim2.new(0, 10, 0, 50)
ContentFrame.BackgroundTransparency = 1
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 350)
ContentFrame.ScrollBarThickness = 5
ContentFrame.Parent = MainFrame

local function addCheckbox(text, y, getter, setter)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 35)
    frame.Position = UDim2.new(0, 0, 0, y)
    frame.BackgroundTransparency = 1
    frame.Parent = ContentFrame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 22, 0, 22)
    btn.Position = UDim2.new(0, 5, 0.5, -11)
    btn.BackgroundColor3 = getter() and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(50, 50, 65)
    btn.Text = getter() and "✓" or ""
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 14
    btn.BorderSizePixel = 0
    btn.Parent = frame
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -40, 1, 0)
    lbl.Position = UDim2.new(0, 35, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame
    
    btn.MouseButton1Click:Connect(function()
        setter(not getter())
        btn.BackgroundColor3 = getter() and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(50, 50, 65)
        btn.Text = getter() and "✓" or ""
    end)
    ContentFrame.CanvasSize = UDim2.new(0, 0, 0, y + 50)
    return frame
end

local function addSlider(text, y, minVal, maxVal, getter, setter, isInt)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 55)
    frame.Position = UDim2.new(0, 0, 0, y)
    frame.BackgroundTransparency = 1
    frame.Parent = ContentFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. tostring(getter())
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextSize = 13
    label.Parent = frame
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, 0, 0, 4)
    sliderBg.Position = UDim2.new(0, 0, 0, 30)
    sliderBg.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = frame
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((getter() - minVal) / (maxVal - minVal), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    fill.BorderSizePixel = 0
    fill.Parent = sliderBg
    
    local knob = Instance.new("TextButton")
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.Position = UDim2.new((getter() - minVal) / (maxVal - minVal), -6, 0.5, -6)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.Text = ""
    knob.BorderSizePixel = 0
    knob.Parent = sliderBg
    
    local dragging = false
    knob.MouseButton1Down:Connect(function() dragging = true end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    
    knob.MouseMoved:Connect(function()
        if not dragging then return end
        local mouseX = UserInputService:GetMouseLocation().X
        local barX = sliderBg.AbsolutePosition.X
        local barW = sliderBg.AbsoluteSize.X
        local percent = math.clamp((mouseX - barX) / barW, 0, 1)
        local value = minVal + percent * (maxVal - minVal)
        if isInt then value = math.floor(value) end
        value = math.clamp(value, minVal, maxVal)
        setter(value)
        fill.Size = UDim2.new((getter() - minVal) / (maxVal - minVal), 0, 1, 0)
        knob.Position = UDim2.new((getter() - minVal) / (maxVal - minVal), -6, 0.5, -6)
        label.Text = text .. ": " .. tostring(getter())
    end)
    
    ContentFrame.CanvasSize = UDim2.new(0, 0, 0, y + 70)
    return frame
end

local y = 5
addCheckbox("Silent Aim (автопопадание)", y, function() return Settings.SilentAim end, function(v) Settings.SilentAim = v end)
y = y + 40
addSlider("FOV (градусы)", y, 10, 360, function() return Settings.SilentFOV end, function(v) Settings.SilentFOV = v end, true)
y = y + 60
addCheckbox("Wallhack (подсветка)", y, function() return Settings.Wallhack end, function(v) Settings.Wallhack = v end)
y = y + 40
addCheckbox("ESP (имя/здоровье)", y, function() return Settings.ShowESP end, function(v) Settings.ShowESP = v end)
y = y + 40
addCheckbox("Team Check", y, function() return Settings.TeamCheck end, function(v) Settings.TeamCheck = v end)
y = y + 40
addCheckbox("Visible Check", y, function() return Settings.VisibleCheck end, function(v) Settings.VisibleCheck = v end)

-- ========== WALLHACK + ESP ==========
local espFolder = Instance.new("Folder")
espFolder.Name = "SWILL_ESP"
pcall(function() espFolder.Parent = CoreGui end)

local function setupESP(player)
    if player == LocalPlayer then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "HL_" .. player.Name
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0.2
    highlight.FillColor = Color3.fromRGB(255, 60, 60)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.Enabled = Settings.Wallhack
    highlight.Parent = espFolder
    
    local bill = Instance.new("BillboardGui")
    bill.Name = "BB_" .. player.Name
    bill.Size = UDim2.new(0, 120, 0, 35)
    bill.StudsOffset = Vector3.new(0, 2.2, 0)
    bill.AlwaysOnTop = true
    bill.Enabled = Settings.ShowESP
    bill.Parent = espFolder
    
    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.new(1, 0, 1, 0)
    txt.BackgroundTransparency = 1
    txt.TextColor3 = Color3.fromRGB(255, 255, 255)
    txt.TextStrokeTransparency = 0.2
    txt.TextSize = 12
    txt.Font = Enum.Font.GothamBold
    txt.Parent = bill
    
    local function update()
        if not player.Character then
            highlight.Adornee = nil
            bill.Adornee = nil
            return
        end
        highlight.Adornee = player.Character
        bill.Adornee = player.Character
        
        local hum = player.Character:FindFirstChild("Humanoid")
        local hp = hum and math.floor(hum.Health) or 0
        txt.Text = player.Name .. " | " .. hp .. " HP"
        txt.TextColor3 = Color3.fromRGB(255 - (hp * 2.55), hp * 2.55, 0)
        
        highlight.Enabled = Settings.Wallhack
        bill.Enabled = Settings.ShowESP
    end
    
    player.CharacterAdded:Connect(update)
    player.CharacterRemoving:Connect(update)
    update()
    RunService.Heartbeat:Connect(update)
end

for _, plr in ipairs(Players:GetPlayers()) do setupESP(plr) end
Players.PlayerAdded:Connect(setupESP)

-- ========== SILENT AIM (ОСНОВНАЯ МАГИЯ) ==========
-- Функция получения ближайшего врага в FOV
local function getClosestEnemy()
    local closestDist = Settings.SilentFOV
    local closestEnemy = nil
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if Settings.TeamCheck and plr.Team == LocalPlayer.Team then continue end
        if not plr.Character then continue end
        
        local hum = plr.Character:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        
        local targetPart = plr.Character:FindFirstChild(Settings.AimPart) or plr.Character:FindFirstChild("Head") or plr.Character:FindFirstChild("HumanoidRootPart")
        if not targetPart then continue end
        
        -- Проверка видимости (опционально)
        if Settings.VisibleCheck then
            local ray = Ray.new(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position).Unit * 1000)
            local hit, pos = workspace:FindPartOnRay(ray, LocalPlayer.Character)
            if hit and not hit:IsDescendantOf(plr.Character) then
                continue
            end
        end
        
        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
        if not onScreen then continue end
        
        local dist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
        if dist < closestDist then
            closestDist = dist
            closestEnemy = plr
        end
    end
    return closestEnemy
end

-- ПЕРЕХВАТ ВЫСТРЕЛА (Silent Aim)
-- Метод 1: Через MouseButton1Click (для большинства игр)
local oldClick
oldClick = hookfunction(Mouse.Button1Click, function(self)
    if Settings.SilentAim then
        local target = getClosestEnemy()
        if target and target.Character then
            local aimPart = target.Character:FindFirstChild(Settings.AimPart) or target.Character:FindFirstChild("Head")
            if aimPart then
                -- Сохраняем текущую позицию мыши
                local oldPos = Vector2.new(Mouse.X, Mouse.Y)
                -- Получаем позицию цели на экране
                local targetScreen = Camera:WorldToViewportPoint(aimPart.Position)
                -- Телепортируем мышь на цель
                pcall(function() mousemoveabs(targetScreen.X, targetScreen.Y) end)
                -- Делаем выстрел
                local result = oldClick(self)
                -- Возвращаем мышь обратно
                pcall(function() mousemoveabs(oldPos.X, oldPos.Y) end)
                return result
            end
        end
    end
    return oldClick(self)
end)

-- Метод 2: Дополнительный перехват через InputBegan (для оружия с зажатием)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 and Settings.SilentAim then
        local target = getClosestEnemy()
        if target and target.Character then
            local aimPart = target.Character:FindFirstChild(Settings.AimPart) or target.Character:FindFirstChild("Head")
            if aimPart then
                local oldPos = Vector2.new(Mouse.X, Mouse.Y)
                local targetScreen = Camera:WorldToViewportPoint(aimPart.Position)
                pcall(function() mousemoveabs(targetScreen.X, targetScreen.Y) end)
                -- Небольшая задержка для регистрации выстрела
                task.wait(0.01)
                pcall(function() mousemoveabs(oldPos.X, oldPos.Y) end)
            end
        end
    end
end)

-- ========== ОТКРЫТИЕ МЕНЮ ==========
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        Settings.MenuOpen = not Settings.MenuOpen
        MainFrame.Visible = Settings.MenuOpen
    end
end)

-- Перемещение окна
local dragStart, dragPos
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragStart = input.Position
        dragPos = MainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragStart and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(dragPos.X.Scale, dragPos.X.Offset + delta.X, dragPos.Y.Scale, dragPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragStart = nil
    end
end)

-- ========== УВЕДОМЛЕНИЕ ==========
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "SWILL | Silent Aim",
    Text = "Нажми INSERT для меню. Теперь стреляй куда угодно - пуля летит в врага!",
    Duration = 4
})
print("[SWILL] Silent Aim загружен! FOV: " .. Settings.SilentFOV)
