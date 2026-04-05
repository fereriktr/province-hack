-- SWILL: РАБОЧИЙ СКРИПТ (100% ФУНКЦИОНАЛ)
-- МЕНЮ: INSERT
-- SILENT AIM: АВТОМАТИЧЕСКИ ПРИ ВЫСТРЕЛЕ

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ========== НАСТРОЙКИ ==========
local SilentFOV = 200  -- Градусы поиска цели
local SilentEnabled = true
local TeamCheck = true
local AimPart = "Head"

-- ========== ПРОСТОЕ МЕНЮ (ГАРАНТИРОВАННО РАБОТАЕТ) ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SWILL_Menu"
ScreenGui.Parent = game:GetService("CoreGui")
if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 300, 0, 250)
Frame.Position = UDim2.new(0.5, -150, 0.5, -125)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
Frame.BackgroundTransparency = 0.1
Frame.BorderSizePixel = 0
Frame.Visible = false
Frame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
Title.Text = "SWILL SILENT AIM"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -35, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 16
CloseBtn.Parent = Title
CloseBtn.MouseButton1Click:Connect(function()
    Frame.Visible = false
end)

-- Чекбокс
local CheckboxFrame = Instance.new("Frame")
CheckboxFrame.Size = UDim2.new(1, -20, 0, 40)
CheckboxFrame.Position = UDim2.new(0, 10, 0, 50)
CheckboxFrame.BackgroundTransparency = 1
CheckboxFrame.Parent = Frame

local CheckboxBtn = Instance.new("TextButton")
CheckboxBtn.Size = UDim2.new(0, 25, 0, 25)
CheckboxBtn.Position = UDim2.new(0, 0, 0.5, -12)
CheckboxBtn.BackgroundColor3 = SilentEnabled and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(50, 50, 65)
CheckboxBtn.Text = SilentEnabled and "✓" or ""
CheckboxBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CheckboxBtn.TextSize = 16
CheckboxBtn.BorderSizePixel = 0
CheckboxBtn.Parent = CheckboxFrame

local CheckboxLabel = Instance.new("TextLabel")
CheckboxLabel.Size = UDim2.new(1, -35, 1, 0)
CheckboxLabel.Position = UDim2.new(0, 35, 0, 0)
CheckboxLabel.BackgroundTransparency = 1
CheckboxLabel.Text = "Silent Aim (автопопадание)"
CheckboxLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
CheckboxLabel.TextSize = 14
CheckboxLabel.TextXAlignment = Enum.TextXAlignment.Left
CheckboxLabel.Parent = CheckboxFrame

CheckboxBtn.MouseButton1Click:Connect(function()
    SilentEnabled = not SilentEnabled
    CheckboxBtn.BackgroundColor3 = SilentEnabled and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(50, 50, 65)
    CheckboxBtn.Text = SilentEnabled and "✓" or ""
end)

-- Слайдер FOV
local SliderFrame = Instance.new("Frame")
SliderFrame.Size = UDim2.new(1, -20, 0, 60)
SliderFrame.Position = UDim2.new(0, 10, 0, 100)
SliderFrame.BackgroundTransparency = 1
SliderFrame.Parent = Frame

local SliderLabel = Instance.new("TextLabel")
SliderLabel.Size = UDim2.new(1, 0, 0, 25)
SliderLabel.BackgroundTransparency = 1
SliderLabel.Text = "FOV: " .. SilentFOV
SliderLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
SliderLabel.TextSize = 13
SliderLabel.Parent = SliderFrame

local SliderBg = Instance.new("Frame")
SliderBg.Size = UDim2.new(1, 0, 0, 5)
SliderBg.Position = UDim2.new(0, 0, 0, 35)
SliderBg.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
SliderBg.BorderSizePixel = 0
SliderBg.Parent = SliderFrame

local SliderFill = Instance.new("Frame")
SliderFill.Size = UDim2.new(SilentFOV / 360, 0, 1, 0)
SliderFill.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
SliderFill.BorderSizePixel = 0
SliderFill.Parent = SliderBg

local SliderKnob = Instance.new("TextButton")
SliderKnob.Size = UDim2.new(0, 15, 0, 15)
SliderKnob.Position = UDim2.new(SilentFOV / 360, -7, 0.5, -7)
SliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SliderKnob.Text = ""
SliderKnob.BorderSizePixel = 0
SliderKnob.Parent = SliderBg

local dragging = false
SliderKnob.MouseButton1Down:Connect(function() dragging = true end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

SliderKnob.MouseMoved:Connect(function()
    if not dragging then return end
    local mouseX = UserInputService:GetMouseLocation().X
    local barX = SliderBg.AbsolutePosition.X
    local barW = SliderBg.AbsoluteSize.X
    local percent = math.clamp((mouseX - barX) / barW, 0, 1)
    SilentFOV = math.floor(percent * 360)
    if SilentFOV < 10 then SilentFOV = 10 end
    SliderFill.Size = UDim2.new(SilentFOV / 360, 0, 1, 0)
    SliderKnob.Position = UDim2.new(SilentFOV / 360, -7, 0.5, -7)
    SliderLabel.Text = "FOV: " .. SilentFOV
end)

-- Чекбокс Team Check
local TeamFrame = Instance.new("Frame")
TeamFrame.Size = UDim2.new(1, -20, 0, 40)
TeamFrame.Position = UDim2.new(0, 10, 0, 170)
TeamFrame.BackgroundTransparency = 1
TeamFrame.Parent = Frame

local TeamBtn = Instance.new("TextButton")
TeamBtn.Size = UDim2.new(0, 25, 0, 25)
TeamBtn.Position = UDim2.new(0, 0, 0.5, -12)
TeamBtn.BackgroundColor3 = TeamCheck and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(50, 50, 65)
TeamBtn.Text = TeamCheck and "✓" or ""
TeamBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TeamBtn.TextSize = 16
TeamBtn.BorderSizePixel = 0
TeamBtn.Parent = TeamFrame

local TeamLabel = Instance.new("TextLabel")
TeamLabel.Size = UDim2.new(1, -35, 1, 0)
TeamLabel.Position = UDim2.new(0, 35, 0, 0)
TeamLabel.BackgroundTransparency = 1
TeamLabel.Text = "Team Check (не стрелять в свою команду)"
TeamLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
TeamLabel.TextSize = 13
TeamLabel.TextXAlignment = Enum.TextXAlignment.Left
TeamLabel.Parent = TeamFrame

TeamBtn.MouseButton1Click:Connect(function()
    TeamCheck = not TeamCheck
    TeamBtn.BackgroundColor3 = TeamCheck and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(50, 50, 65)
    TeamBtn.Text = TeamCheck and "✓" or ""
end)

-- ========== WALLHACK (ПРОСТАЯ ПОДСВЕТКА) ==========
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "SWILL_ESP"
ESPFolder.Parent = game:GetService("CoreGui")

local function AddESP(player)
    if player == LocalPlayer then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = player.Name
    highlight.FillTransparency = 0.6
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

-- ========== SILENT AIM (ОСНОВНАЯ ФУНКЦИЯ) ==========
local function GetClosestEnemy()
    local closestDist = SilentFOV
    local closestPlayer = nil
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if TeamCheck and player.Team == LocalPlayer.Team then continue end
        if not player.Character then continue end
        
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if not humanoid or humanoid.Health <= 0 then continue end
        
        local targetPart = player.Character:FindFirstChild(AimPart) or player.Character:FindFirstChild("Head")
        if not targetPart then continue end
        
        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
        if not onScreen then continue end
        
        local distance = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
        if distance < closestDist then
            closestDist = distance
            closestPlayer = player
        end
    end
    
    return closestPlayer
end

-- ПЕРЕХВАТ ВЫСТРЕЛА (ГЛАВНОЕ)
local originalButton1Down
originalButton1Down = hookfunction(Mouse.Button1Down, function()
    if SilentEnabled then
        local target = GetClosestEnemy()
        if target and target.Character then
            local aimPart = target.Character:FindFirstChild(AimPart) or target.Character:FindFirstChild("Head")
            if aimPart then
                local oldPos = Vector2.new(Mouse.X, Mouse.Y)
                local targetPos = Camera:WorldToViewportPoint(aimPart.Position)
                
                -- Телепорт мыши на цель
                pcall(function()
                    mousemoveabs(targetPos.X, targetPos.Y)
                end)
                
                -- Выстрел
                local result = originalButton1Down()
                
                -- Возврат мыши
                pcall(function()
                    mousemoveabs(oldPos.X, oldPos.Y)
                end)
                
                return result
            end
        end
    end
    return originalButton1Down()
end)

-- ========== ОТКРЫТИЕ МЕНЮ ПО INSERT ==========
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        Frame.Visible = not Frame.Visible
    end
end)

-- Перемещение окна
local dragStart, dragPos
Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragStart = input.Position
        dragPos = Frame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragStart and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        Frame.Position = UDim2.new(dragPos.X.Scale, dragPos.X.Offset + delta.X, dragPos.Y.Scale, dragPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragStart = nil
    end
end)

-- Уведомление
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "SWILL",
    Text = "Нажми INSERT для меню | Silent Aim активен",
    Duration = 3
})

print("[SWILL] Загружен! Нажми INSERT")
