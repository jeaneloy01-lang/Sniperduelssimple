-- [[ LOWHIGH STORE - SIMPLE EDITION (Elite Hub Engine) ]] --
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/Revenant", true))()
local Window = Library.New("LOWHIGH STORE - SIMPLES", "Elite Hub")

-- CONFIGS (MIRA DO PREMIUM)
_G.AimbotEnabled = false
_G.FOV = 100
_G.Smoothness = 0.135 -- O segredo do Premium
_G.Prediction = 0.135

local Camera = workspace.CurrentCamera
local LocalPlayer = game.Players.LocalPlayer

-- TAB DE COMBAT
local Combat = Window.NewTab("Combat")
local AimSection = Combat.NewSection("Aimbot")

AimSection.NewToggle("Ativar Aimbot", function(state)
    _G.AimbotEnabled = state
end)

AimSection.NewSlider("FOV", 0, 500, function(v)
    _G.FOV = v
end)

AimSection.NewSlider("Suavidade", 0, 1, function(v)
    _G.Smoothness = v
end)

-- LÓGICA DE MIRA DO PREMIUM (O QUE NÃO BUGA)
local function GetClosestPlayer()
    local target = nil
    local dist = _G.FOV
    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            local pos, onScreen = Camera:WorldToScreenPoint(v.Character.HumanoidRootPart.Position)
            if onScreen then
                local magnitude = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if magnitude < dist then
                    target = v
                    dist = magnitude
                end
            end
        end
    end
    return target
end

game:GetService("RunService").RenderStepped:Connect(function()
    if _G.AimbotEnabled then
        local target = GetClosestPlayer()
        if target and target.Character then
            local aimPart = target.Character:FindFirstChild("UpperTorso") or target.Character:FindFirstChild("HumanoidRootPart")
            if aimPart then
                local prediction = aimPart.Position + (aimPart.AssemblyLinearVelocity * _G.Prediction)
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, prediction), _G.Smoothness)
            end
        end
    end
end)

-- TAB VISUALS (Mantenha seu ESP aqui)
local Visuals = Window.NewTab("Visuals")
