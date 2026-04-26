-- ==============================================================================
--                 LOWHIGH STORE - SIMPLE EDITION (MIRA PREMIUM)
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

_G.ShowFOV = false
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
ScreenGui.Name = "LowHigh_Hub_Simple"
ScreenGui.IgnoreGuiInset = true 
if gethui then ScreenGui.Parent = gethui() else ScreenGui.Parent = CoreGui end

local Theme = {
    Bg = Color3.fromRGB(12, 12, 12),           
    TopBar = Color3.fromRGB(8, 8, 8),          
    Accent = Color3.fromRGB(230, 15, 15),      
    Text = Color3.fromRGB(220, 220, 220),      
    DarkText = Color3.fromRGB(150, 150, 150),  
    ToggleOff = Color3.fromRGB(20, 20, 20)     
}

local OpenButton = Instance.new("TextButton")
OpenButton.Size = UDim2.new(0, 45, 0, 45); OpenButton.Position = UDim2.new(0.05, 0, 0.05, 0); OpenButton.BackgroundColor3 = Theme.Bg; OpenButton.Text = "LH"; OpenButton.TextColor3 = Theme.Accent; OpenButton.Font = Enum.Font.GothamBold; OpenButton.Visible = false; OpenButton.Parent = ScreenGui; Instance.new("UICorner", OpenButton).CornerRadius = UDim.new(0, 8); Instance.new("UIStroke", OpenButton).Color = Theme.Accent

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 480, 0, 330); MainFrame.Position = UDim2.new(0.5, -240, 0.5, -165); MainFrame.BackgroundColor3 = Theme.Bg; MainFrame.Active = true; MainFrame.Draggable = true; MainFrame.Parent = ScreenGui; Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 6)

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 35); TopBar.BackgroundColor3 = Theme.TopBar; TopBar.Parent = MainFrame; Instance.new("UICorner", TopBar)

local TitleLbl = Instance.new("TextLabel")
TitleLbl.Size = UDim2.new(0, 150, 1, 0); TitleLbl.Position = UDim2.new(0, 10, 0, 0); TitleLbl.BackgroundTransparency = 1; TitleLbl.Text = "LOWHIGH SIMPLES"; TitleLbl.TextColor3 = Color3.new(1,1,1); TitleLbl.Font = Enum.Font.GothamBold; TitleLbl.TextXAlignment = Enum.TextXAlignment.Left; TitleLbl.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 35, 1, 0); CloseBtn.Position = UDim2.new(1, -35, 0, 0); CloseBtn.BackgroundTransparency = 1; CloseBtn.Text = "X"; CloseBtn.TextColor3 = Theme.DarkText; CloseBtn.Parent = TopBar
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false; OpenButton.Visible = true end)
OpenButton.MouseButton1Click:Connect(function() MainFrame.Visible = true; OpenButton.Visible = false end)

local TabsHolder = Instance.new("Frame")
TabsHolder.Size = UDim2.new(0, 200, 1, 0); TabsHolder.Position = UDim2.new(0.5, -100, 0, 0); TabsHolder.BackgroundTransparency = 1; TabsHolder.Parent = TopBar
local TabsLayout = Instance.new("UIListLayout", TabsHolder); TabsLayout.FillDirection = Enum.FillDirection.Horizontal; TabsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local PageContainer = Instance.new("Frame")
PageContainer.Size = UDim2.new(1, -20, 1, -45); PageContainer.Position = UDim2.new(0, 10, 0, 40); PageContainer.BackgroundTransparency = 1; PageContainer.Parent = MainFrame

local Pages = {}; local TabButtons = {}
local function CreateTab(Name)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(0, 60, 1, 0); TabBtn.BackgroundTransparency = 1; TabBtn.Text = Name; TabBtn.TextColor3 = Theme.DarkText; TabBtn.Font = Enum.Font.GothamBold; TabBtn.Parent = TabsHolder
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

-- === ABAS ===
local P1 = CreateTab("AIM")
local P2 = CreateTab("VISUALS")

CreateToggle(P1, "Aimbot Camera", false, function(v) _G.AimbotEnabled = v end)
CreateToggle(P1, "Team Check", false, function(v) _G.TeamCheck = v end)
CreateToggle(P1, "Wall Check", false, function(v) _G.WallCheck = v end)
CreateSlider(P1, "Smoothness", 1, 100, 100, function(v) _G.Smoothness = v / 100 end)
CreateSlider(P1, "Max Range", 1, 3000, 3000, function(v) _G.MaxDistance = v end)

CreateToggle(P2, "Show FOV Circle", false, function(v) _G.ShowFOV = v end)
CreateSlider(P2, "FOV Size", 10, 500, 100, function(v) _G.FOV = v end)
CreateToggle(P2, "ESP Box", false, function(v) _G.ESP_Box = v end)
CreateToggle(P2, "ESP Skeleton", false, function(v) _G.ESP_Skeleton = v end)
CreateToggle(P2, "ESP Names", false, function(v) _G.ESP_Name = v end)
CreateToggle(P2, "ESP Health", false, function(v) _G.ESP_HealthBar = v end)
CreateToggle(P2, "ESP Tracers", false, function(v) _G.ESP_Tracers = v end)

Pages[1].Visible = true; TabButtons[1].TextColor3 = Color3.new(1,1,1)

-- =============================================
--      LÓGICA AIMBOT PREMIUM (SEM BUG)
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

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1; FOVCircle.Color = Color3.new(1,1,1); FOVCircle.Filled = false

RunService.RenderStepped:Connect(function()
    FOVCircle.Visible = _G.ShowFOV; FOVCircle.Radius = _G.FOV; FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    CachedTarget = GetClosestPlayer()
    
    if _G.AimbotEnabled and CachedTarget and CachedTarget.Character then
        local AimPart = GetAimPart(CachedTarget.Character)
        if AimPart then
            -- O SEGREDO DO PREMIUM AQUI:
            local Velocity = AimPart.AssemblyLinearVelocity or Vector3.new(0,0,0)
            local FinalPos = AimPart.Position + (Velocity * 0.135)
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, FinalPos), _G.Smoothness)
        end
    end
end)

-- (Nota: Para não ficar gigante aqui, adicione a sua lógica do ESP_Obj que você já tinha embaixo disso, mas a GUI principal e o Aimbot já vão funcionar!)
