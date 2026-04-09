-- SWILL: BEAM GLOW ESP (ЛУЧЕВОЕ СВЕЧЕНИЕ)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Beams = {}

local function AddBeamGlow(player)
    if player == LocalPlayer then return end
    
    local function createBeam(character)
        local root = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head")
        if not root then return end
        
        local beam = Instance.new("Beam")
        beam.Name = "GlowBeam"
        beam.Width0 = 2
        beam.Width1 = 2
        beam.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0))
        beam.Transparency = NumberSequence.new(0.5)
        beam.Parent = root
        
        -- Луч от игрока вверх
        local attachment0 = Instance.new("Attachment")
        attachment0.Parent = root
        attachment0.Position = Vector3.new(0, 0, 0)
        
        local attachment1 = Instance.new("Attachment")
        attachment1.Parent = root
        attachment1.Position = Vector3.new(0, 5, 0)
        
        beam.Attachment0 = attachment0
        beam.Attachment1 = attachment1
        
        Beams[player] = beam
    end
    
    local function onCharacterAdded(character)
        local old = character:FindFirstChild("GlowBeam")
        if old then old:Destroy() end
        task.wait(0.1)
        createBeam(character)
    end
    
    if player.Character then
        onCharacterAdded(player.Character)
    end
    
    player.CharacterAdded:Connect(onCharacterAdded)
end

for _, player in ipairs(Players:GetPlayers()) do
    AddBeamGlow(player)
end

Players.PlayerAdded:Connect(AddBeamGlow)

print("SWILL: Beam Glow ESP включён!")
