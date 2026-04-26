-- [[ LOWHIGH STORE - SIMPLE EDITION (Engine Premium) ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Stats = game:GetService("Stats")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- CONFIGS
_G.AimbotEnabled = false
_G.TeamCheck = false 
_G.WallCheck = false
_G.FOV = 100
_G.Smoothness = 0.135
_G.PredictionEnabled = true 
_G.BulletSpeed = 2500 

-- VISUALS
_G.ShowFOV = false
_G.ESP_Box = false        
_G.ESP_HealthBar = false
_G.ESP_Name = false      
_G.ESP_MaxDistance = 3000

-- [ INÍCIO DA INTERFACE RAGE UI ] --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LowHigh_Simple"
if gethui then ScreenGui.Parent = gethui() else ScreenGui.Parent = CoreGui end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 450, 0, 300)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame)

local Title = Instance.new("TextLabel")
Title.Text = "LOWHIGH STORE - SIMPLES"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- [ LÓGICA DE MIRA PREMIUM ] --
local function GetAimbotPart(char)
    return char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")
end

local function GetClosestPlayer()
    local Target, MaxDist = nil, _G.FOV
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            local AimPart = GetAimbotPart(v.Character)
            if not AimPart or (_G.TeamCheck and v.Team == LocalPlayer.Team) then continue end
            local SP, OnS = Camera:WorldToScreenPoint(AimPart.Position)
            if OnS then
                local Dist = (Vector2.new(SP.X, SP.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if Dist < MaxDist then Target = v; MaxDist = Dist end
            end
        end
    end
    return Target
end

RunService.RenderStepped:Connect(function()
    local target = GetClosestPlayer()
    if _G.AimbotEnabled and target and target.Character then
        local aimPart = GetAimbotPart(target.Character)
        if aimPart then
            local aimPos = aimPart.Position + (aimPart.AssemblyLinearVelocity * 0.135)
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, aimPos), _G.Smoothness)
        end
    end
end)

-- (Se quiser que a GUI suma, aperte Insert)
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then MainFrame.Visible = not MainFrame.Visible end
end)
