-- ==============================================================================
--                 LOWHIGH STORE - SIMPLE EDITION (FIXED & COMPLETE)
-- ==============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- === CONFIGURAÇÕES ===
_G.AimbotEnabled = true
_G.ESP_Enabled = true
_G.TeamCheck = false
_G.PredictionEnabled = true
_G.Sensitivity = 0.5
_G.FOV_Size = 150
_G.ShowFOV = true

-- === INTERFACE DO HUB ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LowHighHub"
if gethui then ScreenGui.Parent = gethui() else ScreenGui.Parent = CoreGui end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 200, 0, 250)
MainFrame.Position = UDim2.new(0.05, 0, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame)
Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(230, 15, 15)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "LOWHIGH STORE"
Title.TextColor3 = Color3.fromRGB(230, 15, 15)
Title.Font = Enum.Font.GothamBold
Title.BackgroundTransparency = 1
Title.Parent = MainFrame

local function CreateToggle(name, default, pos, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0.8, 0, 0, 30)
    Btn.Position = UDim2.new(0.1, 0, 0, pos)
    Btn.BackgroundColor3 = default and Color3.fromRGB(230, 15, 15) or Color3.fromRGB(30, 30, 30)
    Btn.Text = name
    Btn.TextColor3 = Color3.new(1,1,1)
    Btn.Font = Enum.Font.Gotham
    Btn.Parent = MainFrame
    Instance.new("UICorner", Btn)
    
    local state = default
    Btn.MouseButton1Click:Connect(function()
        state = not state
        Btn.BackgroundColor3 = state and Color3.fromRGB(230, 15, 15) or Color3.fromRGB(30, 30, 30)
        callback(state)
    end)
end

CreateToggle("Aimbot", true, 40, function(v) _G.AimbotEnabled = v end)
CreateToggle("Prediction", true, 80, function(v) _G.PredictionEnabled = v end)
CreateToggle("ESP", true, 120, function(v) _G.ESP_Enabled = v end)
CreateToggle("Team Check", false, 160, function(v) _G.TeamCheck = v end)
CreateToggle("Show FOV", true, 200, function(v) _G.ShowFOV = v end)

-- === LÓGICA DE MIRA (O QUE VOCÊ PEDIU) ===
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.new(1,1,1)
FOVCircle.Filled = false

local function GetAimPart(char)
    return char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")
end

local function GetClosestPlayer()
    local Target, MaxDist = nil, _G.FOV_Size
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            local AimPart = GetAimPart(v.Character)
            local IsTeammate = (LocalPlayer.Team ~= nil and v.Team ~= nil and LocalPlayer.Team == v.Team)
            if not AimPart or (_G.TeamCheck and IsTeammate) then continue end
            
            local SP, OnS = Camera:WorldToScreenPoint(AimPart.Position)
            if OnS then
                local Dist = (Vector2.new(SP.X, SP.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if Dist < MaxDist then Target = v; MaxDist = Dist end
            end
        end
    end
    return Target
end

-- === MOTOR ESP ===
local function CreateESP(p)
    local box = Drawing.new("Square")
    box.Thickness = 1
    box.Color = Color3.fromRGB(230, 15, 15)
    box.Transparency = 1
    box.Filled = false

    RunService.RenderStepped:Connect(function()
        if _G.ESP_Enabled and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character.Humanoid.Health > 0 then
            local HRP = p.Character.HumanoidRootPart
            local Pos, OnScreen = Camera:WorldToViewportPoint(HRP.Position)
            if OnScreen then
                local Size = (Camera.ViewportSize.Y / (Camera.CFrame.Position - HRP.Position).Magnitude) * 2.5
                box.Size = Vector2.new(Size * 1.5, Size * 2.5)
                box.Position = Vector2.new(Pos.X - box.Size.X / 2, Pos.Y - box.Size.Y / 2)
                box.Visible = true
                return
            end
        end
        box.Visible = false
    end)
end

for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then CreateESP(p) end end
Players.PlayerAdded:Connect(CreateESP)

-- === LOOP PRINCIPAL ===
RunService.RenderStepped:Connect(function()
    FOVCircle.Visible = _G.ShowFOV
    FOVCircle.Radius = _G.FOV_Size
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    if _G.AimbotEnabled then
        local Target = GetClosestPlayer()
        if Target and Target.Character then
            local AimPart = GetAimPart(Target.Character)
            if AimPart then
                local FinalPos = AimPart.Position
                if _G.PredictionEnabled then
                    FinalPos = FinalPos + (AimPart.AssemblyLinearVelocity * 0.135)
                end
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, FinalPos), _G.Sensitivity)
            end
        end
    end
end)
