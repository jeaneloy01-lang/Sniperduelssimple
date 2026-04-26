-- ==============================================================================
--                 ELITE HUB - CUSTOM EDITION (AIM & FULL ESP)
-- ==============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- =============================================
--                 CONFIGURAÇÕES Globais
-- =============================================
_G.AimbotEnabled = false
_G.TeamCheck = false 
_G.WallCheck = false
_G.PredictionEnabled = true
_G.FOV = 100
_G.Smoothness = 1
_G.MaxDistance = 3000

_G.ESP_Box = false        
_G.ESP_Skeleton = false
_G.ESP_HealthBar = false
_G.ESP_Name = false      
_G.ESP_Tracers = false
_G.ESP_MaxDistance = 3000

local ESP_Table = {}
local CachedTarget = nil
local ActiveSlider = nil 

-- =============================================
--                 RAGE UI SYSTEM
-- =============================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EliteHub_Custom"
ScreenGui.IgnoreGuiInset = true 
if gethui then ScreenGui.Parent = gethui() else ScreenGui.Parent = CoreGui end

local Theme = {
    Bg = Color3.fromRGB(12, 12, 12), TopBar = Color3.fromRGB(8, 8, 8),          
    Accent = Color3.fromRGB(230, 15, 15), Text = Color3.fromRGB(220, 220, 220),      
    DarkText = Color3.fromRGB(150, 150, 150), ToggleOff = Color3.fromRGB(20, 20, 20)     
}

local OpenButton = Instance.new("TextButton")
OpenButton.Size = UDim2.new(0, 45, 0, 45); OpenButton.Position = UDim2.new(0.05, 0, 0.05, 0); OpenButton.BackgroundColor3 = Theme.Bg; OpenButton.Text = "EH"; OpenButton.TextColor3 = Theme.Accent; OpenButton.Font = Enum.Font.GothamBold; OpenButton.Visible = false; OpenButton.Parent = ScreenGui; Instance.new("UICorner", OpenButton).CornerRadius = UDim.new(0, 8); Instance.new("UIStroke", OpenButton).Color = Theme.Accent

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 450, 0, 320); MainFrame.Position = UDim2.new(0.5, -225, 0.5, -160); MainFrame.BackgroundColor3 = Theme.Bg; MainFrame.Active = true; MainFrame.Draggable = true; MainFrame.Parent = ScreenGui; Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 6)

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 35); TopBar.BackgroundColor3 = Theme.TopBar; TopBar.Parent = MainFrame; Instance.new("UICorner", TopBar)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 35, 1, 0); CloseBtn.Position = UDim2.new(1, -35, 0, 0); CloseBtn.BackgroundTransparency = 1; CloseBtn.Text = "X"; CloseBtn.TextColor3 = Theme.DarkText; CloseBtn.Parent = TopBar
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false; OpenButton.Visible = true end)
OpenButton.MouseButton1Click:Connect(function() MainFrame.Visible = true; OpenButton.Visible = false end)

local TabsHolder = Instance.new("Frame")
TabsHolder.Size = UDim2.new(0, 150, 1, 0); TabsHolder.Position = UDim2.new(0.5, -75, 0, 0); TabsHolder.BackgroundTransparency = 1; TabsHolder.Parent = TopBar
Instance.new("UIListLayout", TabsHolder).FillDirection = Enum.FillDirection.Horizontal

local PageContainer = Instance.new("Frame")
PageContainer.Size = UDim2.new(1, -20, 1, -45); PageContainer.Position = UDim2.new(0, 10, 0, 40); PageContainer.BackgroundTransparency = 1; PageContainer.Parent = MainFrame

local Pages = {}; local TabButtons = {}
local function CreateTab(Name)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(0, 50, 1, 0); TabBtn.BackgroundTransparency = 1; TabBtn.Text = Name; TabBtn.TextColor3 = Theme.DarkText; TabBtn.Font = Enum.Font.GothamBold; TabBtn.Parent = TabsHolder
    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, 0, 1, 0); Page.BackgroundTransparency = 1; Page.Visible = false; Page.ScrollBarThickness = 0; Page.Parent = PageContainer
    Instance.new("UIListLayout", Page).Padding = UDim.new(0, 5)
    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Visible = false end
        for _, b in pairs(TabButtons) do b.TextColor3 = Theme.DarkText end
        Page.Visible = true; TabBtn.TextColor3 = Color3.new(1,1,1)
    end)
    table.insert(Pages, Page); table.insert(TabButtons, TabBtn)
    return Page
end

local function CreateToggle(Parent, Name, Default, Callback)
    local Frame = Instance.new("Frame"); Frame.Size = UDim2.new(1, 0, 0, 25); Frame.BackgroundTransparency = 1; Frame.Parent = Parent
    local Label = Instance.new("TextLabel"); Label.Text = "  "..Name; Label.Size = UDim2.new(1, -30, 1, 0); Label.BackgroundTransparency = 1; Label.TextColor3 = Theme.Text; Label.TextXAlignment = Enum.TextXAlignment.Left; Label.Parent = Frame
    local Checkbox = Instance.new("TextButton"); Checkbox.Size = UDim2.new(0, 18, 0, 18); Checkbox.Position = UDim2.new(1, -20, 0.5, -9); Checkbox.BackgroundColor3 = Default and Theme.Accent or Theme.ToggleOff; Checkbox.Text = ""; Checkbox.Parent = Frame; Instance.new("UICorner", Checkbox).CornerRadius = UDim.new(0, 4)
    local CheckIcon = Instance.new("TextLabel"); CheckIcon.Size = UDim2.new(1, 0, 1, 0); CheckIcon.BackgroundTransparency = 1; CheckIcon.Text = "✓"; CheckIcon.TextColor3 = Color3.new(1,1,1); CheckIcon.Visible = Default; CheckIcon.Parent = Checkbox
    local State = Default
    Checkbox.MouseButton1Click:Connect(function() State = not State; Checkbox.BackgroundColor3 = State and Theme.Accent or Theme.ToggleOff; CheckIcon.Visible = State; Callback(State) end)
end

local function CreateSlider(Parent, Name, Min, Max, Default, Callback)
    local Frame = Instance.new("Frame"); Frame.Size = UDim2.new(1, 0, 0, 35); Frame.BackgroundTransparency = 1; Frame.Parent = Parent
    local Label = Instance.new("TextLabel"); Label.Text = Name; Label.Size = UDim2.new(0.7, 0, 0, 15); Label.BackgroundTransparency = 1; Label.TextColor3 = Theme.Text; Label.TextXAlignment = Enum.TextXAlignment.Left; Label.Parent = Frame
    local ValInput = Instance.new("TextBox"); ValInput.Text = tostring(Default); ValInput.Size = UDim2.new(0.3, 0, 0, 15); ValInput.Position = UDim2.new(0.7, 0, 0, 0); ValInput.BackgroundTransparency = 1; ValInput.TextColor3 = Theme.DarkText; ValInput.TextXAlignment = Enum.TextXAlignment.Right; ValInput.ClearTextOnFocus = false; ValInput.Parent = Frame
    local SliderBg = Instance.new("Frame"); SliderBg.Size = UDim2.new(1, 0, 0, 6); SliderBg.Position = UDim2.new(0, 0, 0, 20); SliderBg.BackgroundColor3 = Theme.ToggleOff; SliderBg.Parent = Frame; Instance.new("UICorner", SliderBg)
    local Fill = Instance.new("Frame"); Fill.Size = UDim2.new((Default - Min) / (Max - Min), 0, 1, 0); Fill.BackgroundColor3 = Theme.Accent; Fill.Parent = SliderBg; Instance.new("UICorner", Fill)
    local Trigger = Instance.new("TextButton"); Trigger.Size = UDim2.new(1, 0, 1, 0); Trigger.BackgroundTransparency = 1; Trigger.Text = ""; Trigger.Parent = SliderBg
    Trigger.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then ActiveSlider = {Bg = SliderBg, Fill = Fill, Min = Min, Max = Max, ValLabel = ValInput, Callback = Callback} end end)
    ValInput.FocusLost:Connect(function() local v = tonumber(ValInput.Text) if v then v = math.clamp(v, Min, Max) Fill.Size = UDim2.new((v-Min)/(Max-Min), 0, 1, 0) ValInput.Text = tostring(v) Callback(v) end end)
end

UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then ActiveSlider = nil end end)
RunService.Heartbeat:Connect(function() if ActiveSlider then local Pct = math.clamp((Mouse.X - ActiveSlider.Bg.AbsolutePosition.X) / ActiveSlider.Bg.AbsoluteSize.X, 0, 1); local Val = math.floor(ActiveSlider.Min + ((ActiveSlider.Max - ActiveSlider.Min) * Pct)); ActiveSlider.Fill.Size = UDim2.new(Pct, 0, 1, 0); ActiveSlider.ValLabel.Text = tostring(Val); ActiveSlider.Callback(Val) end end)

-- ABAS
local P1 = CreateTab("AIM")
local P2 = CreateTab("ESP")

CreateToggle(P1, "Aimbot Enabled", false, function(v) _G.AimbotEnabled = v end)
CreateToggle(P1, "Team Check", false, function(v) _G.TeamCheck = v end)
CreateToggle(P1, "Wall Check", false, function(v) _G.WallCheck = v end)
CreateToggle(P1, "Enable Prediction", true, function(v) _G.PredictionEnabled = v end)
CreateSlider(P1, "FOV Radius", 10, 500, 100, function(v) _G.FOV = v end)
CreateSlider(P1, "Max Distance", 1, 3000, 3000, function(v) _G.MaxDistance = v end)
CreateSlider(P1, "Smoothness", 1, 100, 100, function(v) _G.Smoothness = v / 100 end)

CreateToggle(P2, "Box", false, function(v) _G.ESP_Box = v end)
CreateToggle(P2, "Skeleton", false, function(v) _G.ESP_Skeleton = v end)
CreateToggle(P2, "Names", false, function(v) _G.ESP_Name = v end)
CreateToggle(P2, "HealthBar", false, function(v) _G.ESP_HealthBar = v end)
CreateToggle(P2, "Tracers", false, function(v) _G.ESP_Tracers = v end)
CreateSlider(P2, "ESP Max Distance", 1, 3000, 3000, function(v) _G.ESP_MaxDistance = v end)

Pages[1].Visible = true; TabButtons[1].TextColor3 = Color3.new(1,1,1)

-- =============================================
--                 LÓGICA CORE
-- =============================================
local function GetAimPart(char)
    return char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")
end

local function GetClosestPlayer()
    local Target, MaxDist = nil, _G.FOV
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            local AimPart = GetAimPart(v.Character)
            local IsTeammate = (LocalPlayer.Team ~= nil and v.Team ~= nil and LocalPlayer.Team == v.Team)
            if not AimPart or (_G.TeamCheck and IsTeammate) then continue end
            
            local RealDist = (Camera.CFrame.Position - AimPart.Position).Magnitude
            if RealDist > _G.MaxDistance then continue end
            
            local SP, OnS = Camera:WorldToScreenPoint(AimPart.Position)
            if OnS then
                local Dist = (Vector2.new(SP.X, SP.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if Dist < MaxDist then
                    if _G.WallCheck then
                        local Res = workspace:Raycast(Camera.CFrame.Position, AimPart.Position - Camera.CFrame.Position, RaycastParams.new())
                        if Res and Res.Instance:IsDescendantOf(v.Character) then Target = v; MaxDist = Dist end
                    else Target = v; MaxDist = Dist end
                end
            end
        end
    end
    return Target
end

-- MOTOR ESP COMPLETO (SKELETON ORIGINAL CORRIGIDO PARA R15/R6)
local function CreateESPObj(p)
    local drawings = {
        corners = {}, skeleton = {},
        name = Drawing.new("Text"), 
        hpOutline = Drawing.new("Square"), hpBar = Drawing.new("Square"),
        tracer = Drawing.new("Line")
    }
    for i = 1, 8 do local l = Drawing.new("Line"); l.Thickness = 1.5; l.Color = Color3.new(1,1,1); drawings.corners[i] = l end
    for i = 1, 15 do local l = Drawing.new("Line"); l.Thickness = 1.5; l.Color = Color3.new(1,1,1); drawings.skeleton[i] = l end
    drawings.name.Size = 16; drawings.name.Center = true; drawings.name.Outline = true; drawings.name.Color = Color3.new(1,1,1)
    drawings.hpOutline.Filled = true; drawings.hpOutline.Color = Color3.new(0,0,0); drawings.hpOutline.Transparency = 0.5
    drawings.hpBar.Filled = true; drawings.hpBar.Color = Color3.new(0,1,0)
    drawings.tracer.Thickness = 1; drawings.tracer.Color = Color3.new(1,1,1)

    RunService.RenderStepped:Connect(function()
        local char = p.Character
        if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
            local dist = (Camera.CFrame.Position - char.HumanoidRootPart.Position).Magnitude
            local IsTeammate = (LocalPlayer.Team ~= nil and p.Team ~= nil and LocalPlayer.Team == p.Team)
            
            if dist <= _G.ESP_MaxDistance and not (_G.TeamCheck and IsTeammate) then
                local HRP = char.HumanoidRootPart
                local TopPos, TopVis = Camera:WorldToViewportPoint(HRP.Position + Vector3.new(0, 2.5, 0))
                local BotPos, BotVis = Camera:WorldToViewportPoint(HRP.Position - Vector3.new(0, 3, 0))
                
                if TopVis and BotVis then
                    local Height = math.abs(TopPos.Y - BotPos.Y)
                    local Width = Height * 0.6
                    local TL = Vector2.new(TopPos.X - Width/2, TopPos.Y)
                    local TR = Vector2.new(TopPos.X + Width/2, TopPos.Y)
                    local BL = Vector2.new(TopPos.X - Width/2, BotPos.Y)
                    local BR = Vector2.new(TopPos.X + Width/2, BotPos.Y)
                    local Sz = Height * 0.15

                    -- BOX CORNERS
                    if _G.ESP_Box then
                        drawings.corners[1].From = TL; drawings.corners[1].To = TL + Vector2.new(Sz, 0)
                        drawings.corners[2].From = TL; drawings.corners[2].To = TL + Vector2.new(0, Sz)
                        drawings.corners[3].From = TR; drawings.corners[3].To = TR + Vector2.new(-Sz, 0)
                        drawings.corners[4].From = TR; drawings.corners[4].To = TR + Vector2.new(0, Sz)
                        drawings.corners[5].From = BL; drawings.corners[5].To = BL + Vector2.new(Sz, 0)
                        drawings.corners[6].From = BL; drawings.corners[6].To = BL + Vector2.new(0, -Sz)
                        drawings.corners[7].From = BR; drawings.corners[7].To = BR + Vector2.new(-Sz, 0)
                        drawings.corners[8].From = BR; drawings.corners[8].To = BR + Vector2.new(0, -Sz)
                        for _, l in pairs(drawings.corners) do l.Visible = true end
                    else for _, l in pairs(drawings.corners) do l.Visible = false end end

                    -- SKELETON ORIGINAL (Com suporte para R15 invisível para não dar erro)
                    if _G.ESP_Skeleton then
                        local H = char:FindFirstChild("Head")
                        local T = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
                        local LA = char:FindFirstChild("Left Arm") or char:FindFirstChild("LeftUpperArm")
                        local RA = char:FindFirstChild("Right Arm") or char:FindFirstChild("RightUpperArm")
                        local LL = char:FindFirstChild("Left Leg") or char:FindFirstChild("LeftUpperLeg")
                        local RL = char:FindFirstChild("Right Leg") or char:FindFirstChild("RightUpperLeg")
                        
                        if H and T and LA and RA and LL and RL then
                            local pts = {
                                H.Position, 
                                (T.CFrame * CFrame.new(0,1,0)).Position, 
                                (T.CFrame * CFrame.new(0,-1,0)).Position, 
                                (T.CFrame * CFrame.new(-1,0.5,0)).Position, 
                                (LA.CFrame * CFrame.new(0,-1,0)).Position, 
                                (T.CFrame * CFrame.new(1,0.5,0)).Position, 
                                (RA.CFrame * CFrame.new(0,-1,0)).Position, 
                                (T.CFrame * CFrame.new(-0.5,-1,0)).Position, 
                                (LL.CFrame * CFrame.new(0,-1,0)).Position, 
                                (T.CFrame * CFrame.new(0.5,-1,0)).Position, 
                                (RL.CFrame * CFrame.new(0,-1,0)).Position
                            }
                            local sp = {}; for i=1, 11 do local p, v = Camera:WorldToViewportPoint(pts[i]); sp[i] = {Vector2.new(p.X, p.Y), v and p.Z > 0} end
                            local conns = {{1,2},{2,3},{2,4},{4,5},{2,6},{6,7},{3,8},{8,9},{3,10},{10,11}}
                            for i=1,10 do 
                                local l = drawings.skeleton[i]; local c = conns[i]
                                if sp[c[1]][2] and sp[c[2]][2] then 
                                    l.From = sp[c[1]][1]; l.To = sp[c[2]][1]; l.Visible = true 
                                else 
                                    l.Visible = false 
                                end 
                            end
                        else
                            for _, l in pairs(drawings.skeleton) do l.Visible = false end
                        end
                    else for _, l in pairs(drawings.skeleton) do l.Visible = false end end

                    if _G.ESP_Name then drawings.name.Visible = true; drawings.name.Text = p.Name; drawings.name.Position = Vector2.new(TopPos.X, TopPos.Y - 20) else drawings.name.Visible = false end
                    
                    if _G.ESP_HealthBar then
                        local pct = char.Humanoid.Health / char.Humanoid.MaxHealth
                        drawings.hpOutline.Visible = true; drawings.hpOutline.Size = Vector2.new(4, Height); drawings.hpOutline.Position = TL + Vector2.new(-6, 0)
                        drawings.hpBar.Visible = true; drawings.hpBar.Size = Vector2.new(2, Height * pct); drawings.hpBar.Position = TL + Vector2.new(-5, Height * (1 - pct))
                    else drawings.hpOutline.Visible = false; drawings.hpBar.Visible = false end

                    if _G.ESP_Tracers then drawings.tracer.Visible = true; drawings.tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y); drawings.tracer.To = Vector2.new(TopPos.X, BotPos.Y) else drawings.tracer.Visible = false end
                    return
                end
            end
        end
        for _, v in pairs(drawings) do if type(v) == "table" then for _, l in pairs(v) do l.Visible = false end else v.Visible = false end end
    end)
end

Players.PlayerAdded:Connect(CreateESPObj)
for _, v in pairs(Players:GetPlayers()) do if v ~= LocalPlayer then CreateESPObj(v) end end

-- MAIN LOOP
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1; FOVCircle.Color = Color3.new(1,1,1); FOVCircle.Filled = false

RunService.RenderStepped:Connect(function()
    FOVCircle.Visible = true; FOVCircle.Radius = _G.FOV; FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    CachedTarget = GetClosestPlayer()
    
    if _G.AimbotEnabled and CachedTarget and CachedTarget.Character then
        local AimPart = GetAimPart(CachedTarget.Character)
        if AimPart then
            local TargetPos = AimPart.Position
            if _G.PredictionEnabled then
                TargetPos = AimPart.Position + (AimPart.AssemblyLinearVelocity * 0.135)
            end
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, TargetPos), _G.Smoothness)
        end
    end
end)
