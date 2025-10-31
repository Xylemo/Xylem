
-- // UI Library Setup
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true

local Window = Library:CreateWindow({
	Title = "Nocturnal: Synthesis",
	Footer = "The Definitive Combination",
	Icon = 95816097006870,
	NotifySide = "Right",
	ShowCustomCursor = true,
})

-- // Services & Core Variables
local Players, Workspace, ReplicatedStorage, RunService, UserInputService, VirtualInputManager, TweenService = game:GetService("Players"), game:GetService("Workspace"), game:GetService("ReplicatedStorage"), game:GetService("RunService"), game:GetService("UserInputService"), game:GetService("VirtualInputManager"), game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local Character, Humanoid, HumanoidRootPart, Torso

local function InitializeCharacter()
    Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    Humanoid = Character:WaitForChild("Humanoid", 15)
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart", 15)
    Torso = Character:WaitForChild("Torso", 15) or Character:WaitForChild("UpperTorso", 15)
end
LocalPlayer.CharacterAdded:Connect(function() task.wait(0.5); InitializeCharacter() end)
InitializeCharacter()

-- // =================================================================================
-- // [DEFENSE] SENTINEL V2 - HYBRID EVASION SYSTEM (FROM OMEGA EDITION)
-- // =================================================================================
pcall(function()
    local mt = getrawmetatable(game)
    local old_namecall = mt.__namecall
    local old_index = mt.__index
    local ghost_properties = { WalkSpeed = 16, JumpPower = 50 }
    
    local Handshake = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CharacterSoundEvent")
    local OriginalFireServer = Handshake.FireServer

    -- // Whitelisted Payloads for Handshake
    local Whitelisted = {
        {668, 670, 671, 751, 791, 976}, {686, 788, 880, 811, 785, 787}, {764, 699, 671, 751, 774, 978}
    }
    local function TableEquality(t1, t2)
        if #t1 ~= #t2 then return false end
        for i = 1, #t1 do if t1[i] ~= t2[i] then return false end end
        return true
    end

    -- // Layer 1: Metamethod Proxying & Behavioral Ghosting
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        if not checkcaller() then
            -- // Network Packet Morphing & Throttling
            if method == "FireServer" and self == Handshake then
                if string.find(string.lower(tostring(args[1] or "")), "ac") or string.find(string.lower(tostring(args[1] or "")), "suspicious") then
                    return nil -- Silently drop suspicious remote calls
                end
            end
            -- // Nocturnal Handshake Filter
            if type(self) == "table" and rawlen(self) == 19 and type(rawget(self, 19)) == "userdata" then
                if not (TableEquality(Whitelisted[1], args) or TableEquality(Whitelisted[2], args) or TableEquality(Whitelisted[3], args)) then
                    return
                end
            end
        end
        return old_namecall(self, ...)
    end)
    
    mt.__index = newcclosure(function(self, key)
        -- // Behavioral Ghosting: Report legitimate values when inspected by anticheat
        if not checkcaller() and self == Humanoid and ghost_properties[key] then
            return ghost_properties[key] + (math.random() * 0.05 - 0.025) -- Return legit value + human-like noise
        end
        return old_index(self, key)
    end)
    setreadonly(mt, true)

    -- // Layer 2: Constant Patching & Memory Manipulation
    for _, v in next, getgc(true) do
        if type(v) == "table" and rawlen(v) == 19 and type(rawget(v, 19)) == "userdata" then
            for i = 2, 18 do v[i] = math.random(1e6, 1e8) end
        end
        if type(v) == "function" then
            local s, constants = pcall(debug.getconstants, v)
            if s and constants then
                for i, c in pairs(constants) do
                    if c == 99.2 or c == 0.334 or tostring(c):find("25m") then constants[i] = nil end
                end
            end
        end
    end

    -- // Layer 3: Anti-Freeze & Context Spoofing
    for _, v in getgc() do
        if typeof(v) == "function" and islclosure(v) and #getprotos(v) == 1 then
            if table.find(getconstants(getprotos(v)[1]), 4000002) or table.find(getconstants(getprotos(v)[1]), 4000001) then
                hookfunction(v, function() return end) -- Hook functions that might freeze the game
            end
        end
    end
    local old_debug_info = hookfunction(debug.info, function(level, stuff)
        if not checkcaller() and level == 2 and (stuff == "s" or stuff == "f" or stuff == "sn") then return "LocalScript" end
        return old_debug_info(level, stuff)
    end)

    -- // Layer 4: Active Handshake Spoofing
    RunService.RenderStepped:Connect(function()
        if Handshake and #Whitelisted == 3 then
            for i = 1, #Whitelisted do
                OriginalFireServer(Handshake, "\240\159\146\177\226\154\149\239\184\143", Whitelisted[i], nil)
                task.wait(0.5)
            end
        end
    end)

    Library:Notify({Title = "Sentinel V2", Content = "Hybrid Evasion Systems Active."})
end)

-- // =================================================================================
-- // MASTER CONFIGURATION
-- // =================================================================================
local Settings = {
    Arachne = { -- Catching
        Enabled = false, Mode = "Adaptive", InterceptRadius = 80, Humanization = 0.8,
        TPMagnet = false, TPMagnetRadius = 50,
        PullVector = false, PullVectorRadius = 60, PullVectorStrength = 200,
    },
    Janus = { -- QB Aimbot
        Enabled = false, ShowAnalytics = true, RiskBasedColor = true, ThrowKey = Enum.KeyCode.Q
    },
    Mercury = { -- Movement
        EnableCFrameFlow = false, FlowIntensity = 2,
        EnableWalkSpeed = false, WSSpeed = 25,
        EnableJumpPower = false, JP = 70,
        ClickTackle = false, TackleRadius = 15,
        QuickTP = false, TPKey = Enum.KeyCode.F, TPSpeed = 10,
    },
    Chimera = { -- Physics
        BlockExtender = false, Reach = 12,
        AntiJam = true, NoJumpCooldown = true,
        AntiOOB = true, DiveBoost = false, DiveVelocity = 75,
    },
    Automata = { -- Automatics
        AutoCatch = false, AutoCatchRadius = 20,
        AutoSwat = false, AutoSwatRadius = 20,
        AutoRush = false, AutoRushDelay = 0.1,
        AutoKick = false, KickPower = 100, KickAccuracy = 100,
    },
    Oculus = { -- Visuals
        HighlightFootball = false, FootballInfo = false, HighlightColor = Color3.fromRGB(0, 255, 255),
        NoTextures = false
    }
}
local Threads = {}

-- // =================================================================================
-- // UTILITY FUNCTIONS
-- // =================================================================================
local function GetClosestFootball() local c_ball, c_dist=nil,math.huge for _,v in pairs(Workspace:GetChildren())do if v.Name=="Football" and v:IsA("BasePart")then local dist=(v.Position-HumanoidRootPart.Position).Magnitude if dist<c_dist then c_ball,c_dist=v,dist end end end return c_ball,c_dist end
local function GetBallCarrier() for _,p in pairs(Players:GetPlayers())do if p.Team~=LocalPlayer.Team and p.Character and p.Character:FindFirstChildWhichIsA("Tool")then return p.Character end end end
local function CharacterHasFootball() return Character and Character:FindFirstChild("Football") end
local function GetClosestOpponentToPosition(pos,max_dist) local c_opp,c_dist=nil,max_dist for _,p in pairs(Players:GetPlayers())do if p.Team~=LocalPlayer.Team and p.Character and p.Character:FindFirstChild("HumanoidRootPart")then local dist=(p.Character.HumanoidRootPart.Position-pos).Magnitude if dist<c_dist then c_opp,c_dist=p,dist end end end return c_opp end
local function GetClosestTeammateToMouse() local m_pos, c_p, c_d = Vector2.new(Mouse.X, Mouse.Y), nil, math.huge for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer and p.Team == LocalPlayer.Team and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then local s_pos, onScreen = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position) if onScreen then local dist = (Vector2.new(s_pos.X, s_pos.Y) - m_pos).Magnitude if dist < c_d then c_p, c_d = p, dist end end end end return c_p end

-- // =================================================================================
-- // [SYSTEM] ARACHNE PRIME - ADVANCED CATCHING SUITE
-- // =================================================================================
local ArachneSystem={};function ArachneSystem:PredictBall(ball,time)local g=Vector3.new(0,-Workspace.Gravity,0)return ball.Position+ball.Velocity*time+0.5*g*time^2 end
function ArachneSystem:FindIntercept() local ball,dist=GetClosestFootball()if not ball or dist>Settings.Arachne.InterceptRadius then return end for t=0.1,2,0.1 do local future_pos=self:PredictBall(ball,t)local time_to_reach=(HumanoidRootPart.Position-future_pos).Magnitude/(Humanoid.WalkSpeed*1.5)if time_to_reach<t then return future_pos,ball end end end

RunService.Heartbeat:Connect(function()
    if not HumanoidRootPart or not HumanoidRootPart:IsDescendantOf(Workspace) then return end

    -- // Predictive Catching
    if Settings.Arachne.Enabled then
        local intercept_pos, ball = ArachneSystem:FindIntercept()
        if intercept_pos then 
            local is_clear = GetClosestOpponentToPosition(HumanoidRootPart.Position, 20) == nil 
            local mode = (Settings.Arachne.Mode == "Adaptive" and (is_clear and "Apex" or "Subtle")) or Settings.Arachne.Mode 
            if mode=="Apex" then 
                HumanoidRootPart.CFrame = CFrame.new(intercept_pos)
            elseif mode=="Subtle" then 
                local dir=(intercept_pos-HumanoidRootPart.Position).Unit 
                local human_dir=(dir+Vector3.new(math.sin(tick()*2)*(1-Settings.Arachne.Humanization),0,math.cos(tick()*2)*(1-Settings.Arachne.Humanization))).Unit 
                Humanoid:MoveTo(HumanoidRootPart.Position+human_dir*5)
            end 
        end
    end

    -- // TP Magnet
    if Settings.Arachne.TPMagnet then
        local ball, dist = GetClosestFootball()
        if ball and dist <= Settings.Arachne.TPMagnetRadius then
            local catchPart = Character:FindFirstChild("CatchRight") or Character:FindFirstChild("CatchLeft")
            if catchPart then
                firetouchinterest(catchPart, ball, 0)
                firetouchinterest(catchPart, ball, 1)
            end
            HumanoidRootPart.CFrame = CFrame.new(ball.Position - Vector3.new(0, 2, 0))
        end
    end

    -- // Pull Vector
    if Settings.Arachne.PullVector then
        local ball, dist = GetClosestFootball()
        if ball and dist <= Settings.Arachne.PullVectorRadius then
            if not HumanoidRootPart:FindFirstChild("PullVectorForce") then
                local bv = Instance.new("BodyVelocity")
                bv.Name = "PullVectorForce"
                bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bv.P = 5000
                bv.Parent = HumanoidRootPart
            end
            local pullForce = HumanoidRootPart:FindFirstChild("PullVectorForce")
            if pullForce then
                pullForce.Velocity = ((ball.Position) - HumanoidRootPart.Position).Unit * Settings.Arachne.PullVectorStrength
            end
        else
            if HumanoidRootPart:FindFirstChild("PullVectorForce") then
                HumanoidRootPart.PullVectorForce:Destroy()
            end
        end
    end
end)

-- // =================================================================================
-- // [SYSTEM] JANUS PRIME - QB AIMBOT
-- // =================================================================================
local JanusSystem={Target=nil,Trajectory={}};function JanusSystem:AnalyzeFieldAndSelectTarget()local best_target,best_score=nil,-math.huge for _,p in pairs(Players:GetPlayers())do if p.Team==LocalPlayer.Team and p~=LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart")then local hrp=p.Character.HumanoidRootPart local defender=GetClosestOpponentToPosition(hrp.Position,30)local separation=defender and(hrp.Position-defender.Character.HumanoidRootPart.Position).Magnitude or 100 local dist_from_qb=(hrp.Position-HumanoidRootPart.Position).Magnitude local score=separation*2-dist_from_qb*0.5 if score>best_score then best_target,best_score=p,score end end end self.Target=best_target end
function JanusSystem:Calculate4DThrowVector(target)local g=Workspace.Gravity local startPos=Character.Head.Position local targetHRP=target.Character.HumanoidRootPart local defender=GetClosestOpponentToPosition(targetHRP.Position,20)local lead_dir=defender and(targetHRP.Position-defender.Character.HumanoidRootPart.Position).Unit or targetHRP.CFrame.LookVector local dist=(targetHRP.Position-startPos).Magnitude local power=math.clamp(math.sqrt(dist*g)*1.15,60,95)local time_flight=dist/(power*0.8)local pred_target_pos=targetHRP.Position+(targetHRP.Velocity*time_flight)+(lead_dir*5)local displacement=pred_target_pos-startPos local init_vel=(displacement-0.5*Vector3.new(0,-g,0)*time_flight^2)/time_flight return startPos,init_vel.Unit,power,time_flight,init_vel end
local beam,att0,att1=Instance.new("Beam",Workspace.Terrain),Instance.new("Attachment",Workspace.Terrain),Instance.new("Attachment",Workspace.Terrain);beam.Enabled=false;beam.Attachment0,beam.Attachment1=att0,att1;beam.Width0,beam.Width1=0.4,0.4;beam.FaceCamera=true;beam.Segments=30
RunService.RenderStepped:Connect(function()if not Settings.Janus.Enabled or not CharacterHasFootball()then beam.Enabled=false;return end;JanusSystem.Target=GetClosestTeammateToMouse()if not JanusSystem.Target then beam.Enabled=false;return end local throw_data={JanusSystem:Calculate4DThrowVector(JanusSystem.Target)}if not throw_data[1]then beam.Enabled=false;return end if Settings.Janus.ShowAnalytics then beam.Enabled=true local startPos,_,_,time,vel=unpack(throw_data)local endPos=startPos+vel*time+0.5*Vector3.new(0,-Workspace.Gravity,0)*time^2;att0.WorldPosition,att1.WorldPosition=startPos,endPos;beam.CurveSize0=(startPos-endPos).Magnitude*0.5;beam.CurveSize1=-beam.CurveSize0 local defender=GetClosestOpponentToPosition(JanusSystem.Target.Character.HumanoidRootPart.Position,30)local separation=defender and(JanusSystem.Target.Character.HumanoidRootPart.Position-defender.Character.HumanoidRootPart.Position).Magnitude or math.huge if Settings.Janus.RiskBasedColor then if separation>15 then beam.Color=ColorSequence.new(Color3.new(0,1,0))elseif separation>7 then beam.Color=ColorSequence.new(Color3.new(1,1,0))else beam.Color=ColorSequence.new(Color3.new(1,0,0))end else beam.Color=ColorSequence.new(Settings.Oculus.HighlightColor)end else beam.Enabled=false end end)
UserInputService.InputBegan:Connect(function(input,gp)if gp or input.KeyCode~=Settings.Janus.ThrowKey or not Settings.Janus.Enabled or not CharacterHasFootball()then return end if JanusSystem.Target then local startPos,dir,power=unpack({JanusSystem:Calculate4DThrowVector(JanusSystem.Target)})local remote=Character.Football.Handle:FindFirstChild("RemoteEvent")if remote then remote:FireServer("Clicked",startPos,startPos+dir*1000,math.round(power))end end end)

-- // =================================================================================
-- // [SYSTEM] MERCURY - MOVEMENT & TACKLING
-- // =================================================================================
RunService.Heartbeat:Connect(function(dt)if not HumanoidRootPart or not HumanoidRootPart:IsDescendantOf(Workspace)then return end if Settings.Mercury.EnableCFrameFlow and Humanoid.MoveDirection.Magnitude>0 then local flow=math.noise(tick()*10)*Settings.Mercury.FlowIntensity HumanoidRootPart.CFrame=HumanoidRootPart.CFrame+Humanoid.MoveDirection*flow*dt end;if Settings.Mercury.EnableWalkSpeed then Humanoid.WalkSpeed=Settings.Mercury.WSSpeed else Humanoid.WalkSpeed = 16 end;if Settings.Mercury.EnableJumpPower then Humanoid.JumpPower=Settings.Mercury.JP else Humanoid.JumpPower = 50 end end)
UserInputService.InputBegan:Connect(function(input,gp)if gp then return end if Settings.Mercury.ClickTackle and input.UserInputType==Enum.UserInputType.MouseButton1 then local carrier=GetBallCarrier()if carrier and(carrier.HumanoidRootPart.Position-HumanoidRootPart.Position).Magnitude<=Settings.Mercury.TackleRadius then HumanoidRootPart.CFrame=carrier.HumanoidRootPart.CFrame end end if Settings.Mercury.QuickTP and input.KeyCode==Settings.Mercury.TPKey then HumanoidRootPart.CFrame=HumanoidRootPart.CFrame+Humanoid.MoveDirection*Settings.Mercury.TPSpeed end end)

-- // =================================================================================
-- // [SYSTEM] CHIMERA - PHYSICS ENGINE
-- // =================================================================================
local BlockPart = nil
RunService.Stepped:Connect(function()
    if not Character or not Character:IsDescendantOf(Workspace)then return end 
    Character.Head.CanCollide = not Settings.Chimera.AntiJam;
    if Settings.Chimera.NoJumpCooldown then Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping,true)end;
    if Settings.Chimera.AntiOOB and HumanoidRootPart.Position.Y<-50 then HumanoidRootPart.CFrame=CFrame.new(0,150,0)end

    if Settings.Chimera.BlockExtender and not BlockPart then
        BlockPart = Instance.new("Part")
        BlockPart.Name = "BlockExtender"
        BlockPart.CanCollide = true
        BlockPart.Anchored = false
        BlockPart.Transparency = 0.6
        BlockPart.Color = Color3.fromRGB(200, 200, 200)
        BlockPart.Material = Enum.Material.ForceField
        BlockPart.Size = Vector3.new(Settings.Chimera.Reach, 8, Settings.Chimera.Reach)
        local weld = Instance.new("WeldConstraint")
        weld.Parent = BlockPart
        weld.Part0 = BlockPart
        weld.Part1 = HumanoidRootPart
        BlockPart.Parent = Character
    elseif not Settings.Chimera.BlockExtender and BlockPart then
        BlockPart:Destroy()
        BlockPart = nil
    end

    if BlockPart then
        BlockPart.Size = Vector3.new(Settings.Chimera.Reach, 8, Settings.Chimera.Reach)
    end
end)
Humanoid.StateChanged:Connect(function(old,new)if new==Enum.HumanoidStateType.Diving and Settings.Chimera.DiveBoost then HumanoidRootPart.AssemblyLinearVelocity=HumanoidRootPart.CFrame.LookVector*Settings.Chimera.DiveVelocity end end)

-- // =================================================================================
-- // [SYSTEM] AUTOMATA - AUTOMATION SUITE
-- // =================================================================================
Threads.Automatics = task.spawn(function() while task.wait(0.1) do if not HumanoidRootPart or not HumanoidRootPart:IsDescendantOf(Workspace) then continue end local football,dist=GetClosestFootball()if Settings.Automata.AutoCatch and football and dist<=Settings.Automata.AutoCatchRadius then ReplicatedStorage.Remotes.CharacterSoundEvent:FireServer("PlayerActions","catch")end;if Settings.Automata.AutoSwat and football and dist<=Settings.Automata.AutoSwatRadius then VirtualInputManager:SendKeyEvent(true,Enum.KeyCode.R,false,game)VirtualInputManager:SendKeyEvent(false,Enum.KeyCode.R,false,game)end;if Settings.Automata.AutoRush then local carrier=GetBallCarrier()if carrier then task.wait(Settings.Automata.AutoRushDelay)Humanoid:MoveTo(carrier.HumanoidRootPart.Position)end end end end)
LocalPlayer.PlayerGui.ChildAdded:Connect(function(child)if child.Name=="KickerGui"and Settings.Automata.AutoKick then local cursor=child:WaitForChild("Meter",2):WaitForChild("Cursor",2)if not cursor then return end repeat task.wait()until cursor.Position.Y.Scale<0.01+((100-Settings.Automata.KickPower)*0.012)mouse1click()repeat task.wait()until cursor.Position.Y.Scale>0.9-((100-Settings.Automata.KickAccuracy)*0.001)mouse1click()end end)

-- // =================================================================================
-- // [SYSTEM] OCULUS - VISUAL INTELLIGENCE
-- // =================================================================================
local FootballBillboardGui,FootballSelectionBox;Threads.Visuals=task.spawn(function()while task.wait(0.1)do local football,dist=GetClosestFootball()if football then if Settings.Oculus.HighlightFootball and not FootballSelectionBox then FootballSelectionBox=Instance.new("SelectionBox",football)FootballSelectionBox.Adornee=football;FootballSelectionBox.LineThickness=0.05;FootballSelectionBox.Color3=Settings.Oculus.HighlightColor elseif not Settings.Oculus.HighlightFootball and FootballSelectionBox then FootballSelectionBox:Destroy()FootballSelectionBox=nil end;if Settings.Oculus.FootballInfo and not FootballBillboardGui then FootballBillboardGui=Instance.new("BillboardGui",football)FootballBillboardGui.Adornee=football;FootballBillboardGui.Size=UDim2.new(5,0,2,0)FootballBillboardGui.StudsOffset=Vector3.new(0,3,0)local textLabel=Instance.new("TextLabel",FootballBillboardGui)textLabel.Size=UDim2.new(1,0,1,0)textLabel.BackgroundTransparency=1;textLabel.TextColor3=Color3.new(1,1,1)textLabel.TextScaled=true;textLabel.Name="Info"elseif Settings.Oculus.FootballInfo and FootballBillboardGui then local speed=football.AssemblyLinearVelocity.Magnitude;FootballBillboardGui.Info.Text=string.format("Dist: %.1fst\nSpd: %.1f",dist,speed)elseif not Settings.Oculus.FootballInfo and FootballBillboardGui then FootballBillboardGui:Destroy()FootballBillboardGui=nil end else if FootballSelectionBox then FootballSelectionBox:Destroy()FootballSelectionBox=nil end;if FootballBillboardGui then FootballBillboardGui:Destroy()FootballBillboardGui=nil end end end end)

-- // =================================================================================
-- // UI CONSTRUCTION
-- // =================================================================================
local ArachneTab=Window:AddTab("Arachne","bug");local JanusTab=Window:AddTab("Janus","move");local MercuryTab=Window:AddTab("Mercury","flash_on");local ChimeraTab=Window:AddTab("Chimera","construction");local AutomataTab=Window:AddTab("Automata","smart_toy");local OculusTab=Window:AddTab("Oculus","visibility");local MiscTab=Window:AddTab("Misc","settings")

-- // ARACHNE TAB
local ArachneBox=ArachneTab:AddLeftGroupbox("Arachne - Predictive Catching");
ArachneBox:AddToggle("ArachneEnabled",{Text="Enable Predictive System",Default=Settings.Arachne.Enabled,Callback=function(v)Settings.Arachne.Enabled=v end});
ArachneBox:AddDropdown("ArachneMode",{Text="Mode",Values={"Adaptive","Subtle","Apex"},Default=Settings.Arachne.Mode,Callback=function(v)Settings.Arachne.Mode=v end});
ArachneBox:AddSlider("ArachneRadius",{Text="Intercept Radius",Default=Settings.Arachne.InterceptRadius,Min=30,Max=120,Callback=function(v)Settings.Arachne.InterceptRadius=v end});
ArachneBox:AddSlider("ArachneHumanization",{Text="Humanization Level",Default=Settings.Arachne.Humanization,Min=0.1,Max=1,Rounding=2,Callback=function(v)Settings.Arachne.Humanization=v end})

local AdvancedMagnetsBox = ArachneTab:AddRightGroupbox("Advanced Dedicated Magnets");
AdvancedMagnetsBox:AddToggle("TPMagnetToggle", {Text="Enable TP Magnet", Default=Settings.Arachne.TPMagnet, Callback=function(v)Settings.Arachne.TPMagnet=v end});
AdvancedMagnetsBox:AddSlider("TPMagnetRadius", {Text="TP Magnet Radius", Default=Settings.Arachne.TPMagnetRadius, Min=10, Max=100, Rounding=0, Callback=function(v)Settings.Arachne.TPMagnetRadius=v end});
AdvancedMagnetsBox:AddToggle("PullVectorToggle", {Text="Enable Pull Vector", Default=Settings.Arachne.PullVector, Callback=function(v)Settings.Arachne.PullVector=v; if not v and HumanoidRootPart and HumanoidRootPart:FindFirstChild("PullVectorForce") then HumanoidRootPart.PullVectorForce:Destroy() end end});
AdvancedMagnetsBox:AddSlider("PullVectorRadius", {Text="Pull Vector Radius", Default=Settings.Arachne.PullVectorRadius, Min=10, Max=100, Rounding=0, Callback=function(v)Settings.Arachne.PullVectorRadius=v end});
AdvancedMagnetsBox:AddSlider("PullVectorStrength", {Text="Pull Vector Strength", Default=Settings.Arachne.PullVectorStrength, Min=50, Max=500, Rounding=0, Callback=function(v)Settings.Arachne.PullVectorStrength=v end});

-- // JANUS TAB
local JanusBox=JanusTab:AddLeftGroupbox("Strategic QB AI");
JanusBox:AddToggle("JanusEnabled",{Text="Enable Janus System",Default=Settings.Janus.Enabled,Callback=function(v)Settings.Janus.Enabled=v end});
JanusBox:AddToggle("JanusAnalytics",{Text="Show Trajectory & Analytics",Default=Settings.Janus.ShowAnalytics,Callback=function(v)Settings.Janus.ShowAnalytics=v end});
JanusBox:AddToggle("JanusRiskColor",{Text="Risk-Based Trajectory Color",Default=Settings.Janus.RiskBasedColor,Callback=function(v)Settings.Janus.RiskBasedColor=v end});
JanusBox:AddLabel("Throw Key"):AddKeyPicker("JanusKey",{Default=Settings.Janus.ThrowKey,Callback=function(k)Settings.Janus.ThrowKey=k end})

-- // MERCURY TAB
local MercuryBox=MercuryTab:AddLeftGroupbox("Advanced Movement");
MercuryBox:AddToggle("MercuryFlow",{Text="Enable CFrame Flow",Default=Settings.Mercury.EnableCFrameFlow,Callback=function(v)Settings.Mercury.EnableCFrameFlow=v end});
MercuryBox:AddSlider("MercuryFlowIntensity",{Text="Flow Intensity",Default=Settings.Mercury.FlowIntensity,Min=1,Max=10,Callback=function(v)Settings.Mercury.FlowIntensity=v end});
MercuryBox:AddToggle("QuickTP",{Text="Quick TP",Default=Settings.Mercury.QuickTP,Callback=function(v)Settings.Mercury.QuickTP=v end});
MercuryBox:AddSlider("TPSpeed",{Text="TP Speed",Default=Settings.Mercury.TPSpeed,Min=5,Max=25,Callback=function(v)Settings.Mercury.TPSpeed=v end});
local BasicMoveBox=MercuryTab:AddRightGroupbox("Standard Movement");
BasicMoveBox:AddToggle("EnableWalkSpeed",{Text="Enable WalkSpeed",Default=Settings.Mercury.EnableWalkSpeed,Callback=function(v)Settings.Mercury.EnableWalkSpeed=v end});
BasicMoveBox:AddSlider("WSSpeed",{Text="Speed Value",Default=Settings.Mercury.WSSpeed,Min=16,Max=100,Callback=function(v)Settings.Mercury.WSSpeed=v end});
BasicMoveBox:AddToggle("EnableJumpPower",{Text="Enable JumpPower",Default=Settings.Mercury.EnableJumpPower,Callback=function(v)Settings.Mercury.EnableJumpPower=v end});
BasicMoveBox:AddSlider("JP",{Text="Jump Power",Default=Settings.Mercury.JP,Min=50,Max=150,Callback=function(v)Settings.Mercury.JP=v end})

-- // CHIMERA TAB
local ChimeraBox=ChimeraTab:AddLeftGroupbox("Core Physics");
ChimeraBox:AddToggle("AntiJam",{Text="Anti-Jam (No Player Collision)",Default=Settings.Chimera.AntiJam,Callback=function(v)Settings.Chimera.AntiJam=v end});
ChimeraBox:AddToggle("NoJumpCD",{Text="No Jump Cooldown",Default=Settings.Chimera.NoJumpCooldown,Callback=function(v)Settings.Chimera.NoJumpCooldown=v end});
ChimeraBox:AddToggle("AntiOOB",{Text="Anti Out-Of-Bounds",Default=Settings.Chimera.AntiOOB,Callback=function(v)Settings.Chimera.AntiOOB=v end});
ChimeraBox:AddToggle("DiveBoost",{Text="Enable Dive Boost",Default=Settings.Chimera.DiveBoost,Callback=function(v)Settings.Chimera.DiveBoost=v end});
ChimeraBox:AddSlider("DiveVelocity",{Text="Dive Velocity",Default=Settings.Chimera.DiveVelocity,Min=25,Max=200,Callback=function(v)Settings.Chimera.DiveVelocity=v end});
local TackleBox=ChimeraTab:AddRightGroupbox("Tackling & Blocking");
TackleBox:AddToggle("ClickTackle",{Text="Click Tackle",Default=Settings.Mercury.ClickTackle,Callback=function(v)Settings.Mercury.ClickTackle=v end});
TackleBox:AddSlider("TackleRadius",{Text="Tackle Radius",Default=Settings.Mercury.TackleRadius,Min=5,Max=50,Callback=function(v)Settings.Mercury.TackleRadius=v end})
TackleBox:AddToggle("BlockExtenderToggle", {Text="Enable Block Extender", Default=Settings.Chimera.BlockExtender, Callback=function(v)Settings.Chimera.BlockExtender=v end});
TackleBox:AddSlider("BlockExtenderReach", {Text="Block Reach", Default=Settings.Chimera.Reach, Min=5, Max=25, Callback=function(v)Settings.Chimera.Reach=v end});

-- // AUTOMATA TAB
local AutoBox=AutomataTab:AddLeftGroupbox("Field Automatics");
AutoBox:AddToggle("AutoCatch",{Text="Auto Catch",Default=Settings.Automata.AutoCatch,Callback=function(v)Settings.Automata.AutoCatch=v end});
AutoBox:AddSlider("AutoCatchRadius",{Text="Catch Radius",Default=Settings.Automata.AutoCatchRadius,Min=5,Max=50,Callback=function(v)Settings.Automata.AutoCatchRadius=v end});
AutoBox:AddToggle("AutoSwat",{Text="Auto Swat",Default=Settings.Automata.AutoSwat,Callback=function(v)Settings.Automata.AutoSwat=v end});
AutoBox:AddSlider("AutoSwatRadius",{Text="Swat Radius",Default=Settings.Automata.AutoSwatRadius,Min=5,Max=50,Callback=function(v)Settings.Automata.AutoSwatRadius=v end});
AutoBox:AddToggle("AutoRush",{Text="Auto Rush Carrier",Default=Settings.Automata.AutoRush,Callback=function(v)Settings.Automata.AutoRush=v end});
local AutoKickBox=AutomataTab:AddRightGroupbox("Kicking");
AutoKickBox:AddToggle("AutoKick",{Text="Auto Kick",Default=Settings.Automata.AutoKick,Callback=function(v)Settings.Automata.AutoKick=v end});
AutoKickBox:AddSlider("KickPower",{Text="Kick Power %",Default=Settings.Automata.KickPower,Min=80,Max=100,Rounding=0,Callback=function(v)Settings.Automata.KickPower=v end});
AutoKickBox:AddSlider("KickAccuracy",{Text="Kick Accuracy %",Default=Settings.Automata.KickAccuracy,Min=80,Max=100,Rounding=0,Callback=function(v)Settings.Automata.KickAccuracy=v end})

-- // OCULUS TAB
local OculusBox=OculusTab:AddLeftGroupbox("Football ESP");
OculusBox:AddToggle("HighlightFootball",{Text="Highlight Football",Default=Settings.Oculus.HighlightFootball,Callback=function(v)Settings.Oculus.HighlightFootball=v end});
OculusBox:AddToggle("FootballInfo",{Text="Football Info Card",Default=Settings.Oculus.FootballInfo,Callback=function(v)Settings.Oculus.FootballInfo=v end});
OculusBox:AddLabel("ESP Color"):AddColorPicker("ESPColor",{Default=Settings.Oculus.HighlightColor,Callback=function(v)Settings.Oculus.HighlightColor=v;if FootballSelectionBox then FootballSelectionBox.Color3=v end end});
local WorldBox=OculusTab:AddRightGroupbox("World");
WorldBox:AddToggle("NoTextures",{Text="No Textures (Performance)",Callback=function(v)Settings.Oculus.NoTextures=v;for _,d in pairs(Workspace:GetDescendants())do if d:IsA("BasePart")then d.Material=v and Enum.Material.Plastic or Enum.Material.Grass end end end});
WorldBox:AddButton("FPS Boost",function()game:GetService("Lighting").GlobalShadows=false;settings().Rendering.QualityLevel=Enum.QualityLevel.Level01;Library:Notify({Title="Oculus",Content="Basic FPS Boost Applied."})end)

-- // MISC TAB
local MenuBox=MiscTab:AddLeftGroupbox("Menu");
MenuBox:AddLabel("Menu Bind"):AddKeyPicker("MenuKeybind",{Default="RightShift",NoUI=true,Text="Menu keybind"});
MenuBox:AddButton("Unload",function()Library:Unload()end);
Library.ToggleKeybind = Options.MenuKeybind
SaveManager:SetLibrary(Library);
SaveManager:SetFolder("Nocturnal_Synthesis");
SaveManager:BuildConfigSection(MiscTab);
SaveManager:LoadAutoloadConfig()

local OmegaScript = {
    Status = {},
    PristineFunctions = {},
    InternalCache = setmetatable({}, {__mode = "kv"}),
    RemoteInterceptionRules = {},
    ConsoleInterceptionRules = { print = {}, warn = {}, error = {} },
    ActiveStealthFeatures = {},
    RemoteCallCounts = {},
}

do
    OmegaScript.PristineFunctions.getrawmetatable = getrawmetatable
    OmegaScript.PristineFunctions.setrawmetatable = setrawmetatable
    OmegaScript.PristineFunctions.rawget = rawget
    OmegaScript.PristineFunctions.rawset = rawset
    OmegaScript.PristineFunctions.rawequal = rawequal
    OmegaScript.PristineFunctions.type = type
    OmegaScript.PristineFunctions.typeof = typeof
    OmegaScript.PristineFunctions.pcall = pcall
    OmegaScript.PristineFunctions.xpcall = xpcall
    OmegaScript.PristineFunctions._print = print
    OmegaScript.PristineFunctions._warn = warn
    OmegaScript.PristineFunctions._error = error
    OmegaScript.PristineFunctions.assert = assert
    OmegaScript.PristineFunctions.select = select
    OmegaScript.PristineFunctions.unpack = unpack or table.unpack
    OmegaScript.PristineFunctions.pack = table.pack or function(...) return {n = select("#", ...), ...} end
    OmegaScript.PristineFunctions.ipairs = ipairs
    OmegaScript.PristineFunctions.pairs = pairs
    OmegaScript.PristineFunctions.next = next
    OmegaScript.PristineFunctions.tostring = tostring
    OmegaScript.PristineFunctions.tonumber = tonumber
    OmegaScript.PristineFunctions.coroutine_create = coroutine.create
    OmegaScript.PristineFunctions.coroutine_resume = coroutine.resume
    OmegaScript.PristineFunctions.coroutine_yield = coroutine.yield
    OmegaScript.PristineFunctions.coroutine_status = coroutine.status
    OmegaScript.PristineFunctions.coroutine_running = coroutine.running
    OmegaScript.PristineFunctions.coroutine_isyieldable = coroutine.isyieldable
    OmegaScript.PristineFunctions.string_byte = string.byte
    OmegaScript.PristineFunctions.string_char = string.char
    OmegaScript.PristineFunctions.string_find = string.find
    OmegaScript.PristineFunctions.string_format = string.format
    OmegaScript.PristineFunctions.string_gmatch = string.gmatch
    OmegaScript.PristineFunctions.string_gsub = string.gsub
    OmegaScript.PristineFunctions.string_len = string.len
    OmegaScript.PristineFunctions.string_lower = string.lower
    OmegaScript.PristineFunctions.string_match = string.match
    OmegaScript.PristineFunctions.string_rep = string.rep
    OmegaScript.PristineFunctions.string_reverse = string.reverse
    OmegaScript.PristineFunctions.string_sub = string.sub
    OmegaScript.PristineFunctions.string_upper = string.upper
    OmegaScript.PristineFunctions.table_concat = table.concat
    OmegaScript.PristineFunctions.table_insert = table.insert
    OmegaScript.PristineFunctions.table_remove = table.remove
    OmegaScript.PristineFunctions.table_sort = table.sort
    OmegaScript.PristineFunctions.table_create = table.create
    OmegaScript.PristineFunctions.math_abs = math.abs
    OmegaScript.PristineFunctions.math_random = math.random
    OmegaScript.PristineFunctions.math_floor = math.floor
    OmegaScript.PristineFunctions.math_max = math.max
    OmegaScript.PristineFunctions.math_min = math.min
    OmegaScript.PristineFunctions.tick = tick
    OmegaScript.PristineFunctions.wait = task and task.wait or wait
    OmegaScript.PristineFunctions.delay = task and task.delay or delay
    OmegaScript.PristineFunctions.spawn = task and task.spawn or spawn
    OmegaScript.PristineFunctions.setreadonly = setreadonly
    OmegaScript.PristineFunctions.isreadonly = isreadonly
    OmegaScript.PristineFunctions.getfenv = getfenv
    OmegaScript.PristineFunctions.setfenv = setfenv
    OmegaScript.PristineFunctions.getmetatable = getmetatable
    OmegaScript.PristineFunctions.setmetatable = setmetatable
    OmegaScript.PristineFunctions.debug_getinfo = debug and debug.getinfo
    OmegaScript.PristineFunctions.debug_getlocal = debug and debug.getlocal
    OmegaScript.PristineFunctions.debug_getmetatable = debug and debug.getmetatable
    OmegaScript.PristineFunctions.debug_getupvalue = debug and debug.getupvalue
    OmegaScript.PristineFunctions.debug_setlocal = debug and debug.setlocal
    OmegaScript.PristineFunctions.debug_setmetatable = debug and debug.setmetatable
    OmegaScript.PristineFunctions.debug_setupvalue = debug and debug.setupvalue
    OmegaScript.PristineFunctions.debug_traceback = debug and debug.traceback
    OmegaScript.PristineFunctions.debug_info = debug and debug.info
    OmegaScript.PristineFunctions.hookfunction = hookfunction
    OmegaScript.PristineFunctions.newcclosure = newcclosure
    OmegaScript.PristineFunctions.getgc = getgc
    OmegaScript.PristineFunctions.getreg = getreg
    OmegaScript.PristineFunctions.getconnections = getconnections
    OmegaScript.PristineFunctions.getthreadidentity = getthreadidentity
    OmegaScript.PristineFunctions.setthreadidentity = setthreadidentity
    OmegaScript.PristineFunctions.getnamecallmethod = getnamecallmethod
    OmegaScript.PristineFunctions.hookmetamethod = hookmetamethod
    OmegaScript.PristineFunctions.writefile = writefile
    OmegaScript.PristineFunctions.readfile = readfile
    OmegaScript.PristineFunctions.cloneref = cloneref
    OmegaScript.PristineFunctions.queue_on_teleport = queue_on_teleport or game and game.Players and game.Players.LocalPlayer and game.Players.LocalPlayer.OnTeleport
    if workspace and workspace.FilteringEnabled then
        OmegaScript.PristineFunctions.is_server = game:GetService("RunService"):IsServer()
    else
        OmegaScript.PristineFunctions.is_server = false 
    end
end
local _P = OmegaScript.PristineFunctions

local Config = {
    MasterDebugMode = false,
    EnableScriptSelfLogs = false, 
    Enable_AdonisBypass_GCScanV1 = true,
    Enable_AdonisBypass_GCScanV2 = true,
    Enable_AdonisBypass_CameraConnections = true,
    Enable_AdonisBypass_KickYield = true,
    Enable_AdonisBypass_GameMetatableHook = true,
    Enable_Debugging_TableHooks = false,
    Enable_DataExtraction_FF2Dumper = false,
    Enable_NetworkInfo_ReportSpoofed = true,
    Enable_NetworkInfo_FetchActualIP = false,
    Enable_GameSpecific_Bypasses = true,

    AdvancedFeatures = {
        Enable_IV1_MetatableGuardianship = true,
        Enable_IV2_StrategicThreadIdentity = true,
        Enable_IV3_ReducedGCDetectability = true,
        Enable_IV4_MemorySignatureEvasion = true, 
        Enable_IV5_EnvironmentManipulationDetection = true,

        Enable_III1_SelectiveHookActivation = true,
        Enable_III2_SubtleHeuristicEvasion = true,
        Enable_III3_CoreFunctionIntegrity = true,
        Enable_III4_AdvancedRemoteInterception = true,
        Enable_III5_DynamicInstanceCloaking = true,
        Enable_III6_CriticalHookSelfRepair = true,
        Enable_III7_MonitoringToolDetection = true,
        Enable_III8_StealthModeActivation = true, 
        Enable_III9_SuspiciousAPICallLogging = true,

        Enable_II1_FunctionCallInterception = true,
        Enable_II3_TargetedClientStateSpoofing = true,
        Enable_II5_ContextAwareBypassActivation = true,
        Enable_II6_GlobalOverwriteProtection = true, 

        Enable_ConsoleManager = true,
        Enable_ConsoleLogSpoofing = true,
        Enable_ConsoleOutputFiltering = true,
        Enable_ConsoleDetectionBypass = true, 
        Enable_AntiConsoleRead = true,

        Enable_SpoofingModule = true,
        Enable_PlayerStatsSpoofing = true,
        Enable_ClientTickSpoofing = true,
        Enable_TypeofSpoofing = true,
        Enable_InputEventSpoofing = true,

        Enable_ResilienceModule = true,
        Enable_WatchdogThread = true,
        Enable_DynamicFeatureDisabling = true,

        Enable_NetworkInterceptionModule = true,
        Enable_HttpServiceInterception = true,
        Enable_RemoteCreationMonitoring = true,

        Enable_EnvironmentHardening = true,

        Debug_Advanced_IV = false,
        Debug_Advanced_III = false,
        Debug_Advanced_II = false,
        Debug_ConsoleManager = false,
        Debug_Spoofing = false,
        Debug_Resilience = false,
        Debug_NetworkInterception = false,
        Debug_Environment = false,
    },

    Console_DefaultSpoofMessage = "[OS Filtered Log]",
    Console_MaxFilterRules = 50,
    RemoteCallFrequencyLimit = 10, 
    RemoteCallFrequencyWindow = 1, 
    StealthModeActivationThreshold = 3, 
    WatchdogInterval = 30,
    MaxErrorsPerFeature = 5,

    AdonisBypass_V1_Debug = false,
    AdonisBypass_V2_Debug = false,
    AdonisBypass_V2_HeartbeatInterval = 1,
    AdonisBypass_V2_MaxDelayTolerance = 5,
    DataExtraction_FF2_WriteFileName = "snipe_ids.txt",
    DataExtraction_FF2_APICallDelay = 0.4,
    NetworkInfo_SpoofedIP = "192.168.1.100",
    NetworkInfo_SpoofedMAC = "00:1A:2B:3C:4D:5E",
    NotificationIcon = "rbxassetid://125704683916878",
    NotificationDuration = 10,
    SelfRepairIntervalSeconds = 20,
}

local function GetAdvCfg(featureName)
    local advSettings = Config.AdvancedFeatures
    if advSettings and advSettings[featureName] ~= nil then
        return advSettings[featureName]
    end
    return false
end

local function IsModuleDebug(moduleInternalDebugFlag, advancedCategory)
    if Config.MasterDebugMode then
        if advancedCategory and GetAdvCfg("Debug_Advanced_" .. advancedCategory) then
            return true
        elseif moduleInternalDebugFlag ~= nil then
            return moduleInternalDebugFlag
        end
        return true 
    end
    return false
end

OmegaScript.Services = {}
do
    local servicesToLoad = {
        "Players", "ReplicatedStorage", "ReplicatedFirst", "StarterPlayer",
        "LogService", "RunService", "StarterGui", "HttpService", "CoreGui", "Workspace",
        "UserInputService", "ContextActionService", "ScriptContext"
    }
    for _, serviceName in _P.ipairs(servicesToLoad) do
        local success, service = _P.pcall(function() return game:GetService(serviceName) end)
        if success and service then
            OmegaScript.Services[serviceName] = service
        else
            OmegaScript.PristineFunctions._warn("[OmegaScript.Services] Failed to load service:", serviceName, service)
        end
    end
    if OmegaScript.Services.Players then
        OmegaScript.Services.LocalPlayer = OmegaScript.Services.Players.LocalPlayer
        if not OmegaScript.Services.LocalPlayer then
            local playerSignal
            playerSignal = OmegaScript.Services.Players:GetPropertyChangedSignal("LocalPlayer"):Connect(function()
                OmegaScript.Services.LocalPlayer = OmegaScript.Services.Players.LocalPlayer
                if OmegaScript.Services.LocalPlayer and playerSignal then playerSignal:Disconnect() end
            end)
        end
    end
end

OmegaScript.Utils = {}
do
    local StarterGui = OmegaScript.Services.StarterGui
    local LogService = OmegaScript.Services.LogService

    function OmegaScript.Utils.Log(source, ...)
        if not Config.EnableScriptSelfLogs then return end
        local args = {...}
        local msg = "[" .. (_P.tostring(source) or "OmegaScript") .. "] "
        for i = 1, #args do
            msg = msg .. _P.tostring(args[i]) .. (i == #args and "" or " ")
        end
        _P._print(msg)
    end

    function OmegaScript.Utils.Warn(source, ...)
        if not Config.EnableScriptSelfLogs then return end
        local args = {...}
        local msg = "WARNING: [" .. (_P.tostring(source) or "OmegaScript") .. "] "
        for i = 1, #args do
            msg = msg .. _P.tostring(args[i]) .. (i == #args and "" or " ")
        end
        _P._warn(msg)
    end

    function OmegaScript.Utils.Notify(title, text, icon, duration)
        if StarterGui and StarterGui.SetCore then
            _P.pcall(function()
                StarterGui:SetCore("SendNotification", {
                    Title = title or "OmegaScript",
                    Text = text or "Notification",
                    Icon = icon or Config.NotificationIcon,
                    Duration = duration or Config.NotificationDuration
                })
            end)
        else
            OmegaScript.Utils.Warn("Notify", "StarterGui not available for notification:", title, text)
        end
    end

    local cloneRefFunc = _P.cloneref or function(obj) return obj end
    OmegaScript.Utils.RequireService = function(serviceInstance)
        return cloneRefFunc(serviceInstance)
    end

    function OmegaScript.Utils.BlockInstance(instance)
        if _P.typeof(instance) == "Instance" then
            local oldName = instance.Name
            instance.Name = "BlockedInstance_" .. _P.math_random(0, 500000)
            if LogService then
                instance.Parent = LogService
            end
            instance:Destroy()
            OmegaScript.Utils.Log("BlockInstance", "Blocked and destroyed:", oldName, "(now", instance.Name, ")")
        else
            OmegaScript.Utils.Warn("BlockInstance", "Attempted to block non-instance:", _P.typeof(instance))
        end
    end

    function OmegaScript.Utils.GenerateRandomString(length)
        local res = ""
        for i = 1, length or 10 do
            res = res .. _P.string_char(_P.math_random(97, 122)) 
        end
        return res
    end

    OmegaScript.Utils.InternalErrorCounts = OmegaScript.Utils.InternalErrorCounts or {}
    function OmegaScript.Utils.TrackError(featureName, errorMessage)
        OmegaScript.Utils.InternalErrorCounts[featureName] = (OmegaScript.Utils.InternalErrorCounts[featureName] or 0) + 1
        OmegaScript.Utils.Warn("ErrorTracking", "Feature '", featureName, "' reported error: ", errorMessage)
        if OmegaScript.Utils.InternalErrorCounts[featureName] >= Config.MaxErrorsPerFeature then
            if OmegaScript.Resilience and OmegaScript.Resilience.DynamicallyDisableFeature then
                OmegaScript.Resilience.DynamicallyDisableFeature(featureName)
            end
        end
    end
end

OmegaScript.ConsoleManager = OmegaScript.ConsoleManager or {}
do
    local _ConsoleManagerDebug = function(...) if IsModuleDebug(nil, "ConsoleManager") then OmegaScript.Utils.Log("ConsoleManager", ...) end end
    local OriginalPrint, OriginalWarn, OriginalError

    local function ProcessConsoleOutput(outputType, originalFunc, ...)
        if not GetAdvCfg("Enable_ConsoleManager") then return originalFunc(...) end
        local args = {...}
        local message = _P.table_concat(args, " ")
        local processed = false
        local ruleSet = OmegaScript.ConsoleInterceptionRules[outputType] or {}

        for _, rule in _P.ipairs(ruleSet) do
            if _P.string_find(message, rule.pattern) then
                if rule.action == "spoof" then
                    originalFunc(rule.replacement or Config.Console_DefaultSpoofMessage)
                    processed = true
                    break
                elseif rule.action == "suppress" then
                    processed = true
                    break
                elseif rule.action == "callback" and rule.callback then
                    local cbSuccess, cbResult = _P.pcall(rule.callback, message, args)
                    if cbSuccess and cbResult == "block" then processed = true; break end
                    if cbSuccess and _P.type(cbResult) == "string" then originalFunc(cbResult); processed = true; break end
                end
            end
        end

        if not processed then
            return originalFunc(...)
        end
    end

    function OmegaScript.ConsoleManager.AddRule(outputType, pattern, action, replacementOrCallback)
        if not GetAdvCfg("Enable_ConsoleManager") then return end
        local ruleSet = OmegaScript.ConsoleInterceptionRules[outputType]
        if not ruleSet or #ruleSet >= Config.Console_MaxFilterRules then
            OmegaScript.Utils.Warn("ConsoleManager", "Cannot add rule: type invalid or max rules reached for", outputType)
            return
        end
        local rule = { pattern = pattern, action = action }
        if action == "spoof" then rule.replacement = replacementOrCallback
        elseif action == "callback" then rule.callback = replacementOrCallback end
        _P.table_insert(ruleSet, rule)
        _ConsoleManagerDebug("Added console rule for", outputType, ": pattern '", pattern, "', action '", action, "'")
    end

    function OmegaScript.ConsoleManager.HookConsoleFunctions()
        if not GetAdvCfg("Enable_ConsoleManager") then return end
        OriginalPrint = _P._print
        OriginalWarn = _P._warn
        OriginalError = _P._error

        print = function(...) return ProcessConsoleOutput("print", OriginalPrint, ...) end
        warn = function(...) return ProcessConsoleOutput("warn", OriginalWarn, ...) end
        if type(error) == "function" then 
             error = function(...) return ProcessConsoleOutput("error", OriginalError, ...) end
        end
        _ConsoleManagerDebug("Console functions hooked.")
    end
    
    function OmegaScript.ConsoleManager.BypassConsoleDetection()
        if not GetAdvCfg("Enable_ConsoleDetectionBypass") then return end
        _ConsoleManagerDebug("Attempting to bypass console detection mechanisms (conceptual).")
    end

    function OmegaScript.ConsoleManager.PreventConsoleReads()
        if not GetAdvCfg("Enable_AntiConsoleRead") then return end
        _ConsoleManagerDebug("Attempting to prevent external console reads (conceptual).")
    end
    
    _ConsoleManagerDebug("ConsoleManager module initialized.")
end


OmegaScript.AdvancedMemory = OmegaScript.AdvancedMemory or {}
do
    local _AdvMemDebug = function(...) if IsModuleDebug(nil, "IV") then OmegaScript.Utils.Log("AdvMem", ...) end end
    local _HookedMetatables = OmegaScript.InternalCache._HookedMetatables or {}
    OmegaScript.InternalCache._HookedMetatables = _HookedMetatables
    local _ProtectedEnvironments = OmegaScript.InternalCache._ProtectedEnvironments or {}
    OmegaScript.InternalCache._ProtectedEnvironments = _ProtectedEnvironments

    function OmegaScript.AdvancedMemory.GuardMetamethod(target, method_name, user_hook_logic)
        if not GetAdvCfg("Enable_IV1_MetatableGuardianship") then
             OmegaScript.Utils.Warn("GuardMetamethod", "Called while disabled. Hook not applied by guard.")
            return false
        end
        
        local mt = _P.debug_getmetatable(target) or _P.getmetatable(target)
        if not mt then
            _AdvMemDebug("Failed to get metatable for target:", target, "Type:", _P.typeof(target))
            return false
        end

        local original_method = mt[method_name]
        local guard_id = (_P.typeof(target) == "Instance" and target:GetFullName() or _P.tostring(target)) .. ":" .. method_name

        local success_ro_off, err_ro_off = _P.pcall(_P.setreadonly, mt, false)
        if not success_ro_off then _AdvMemDebug("Could not make metatable writable for guard setup:", guard_id, "Error:", err_ro_off); return false end

        local our_new_hook = _P.newcclosure(function(...)
            if _HookedMetatables[guard_id] and _HookedMetatables[guard_id].guard_active then
                 local current_mt_method = ( _P.debug_getmetatable(target) or _P.getmetatable(target) )[method_name]
                 if current_mt_method ~= our_new_hook then
                    _AdvMemDebug("WARNING: Guarded hook for", guard_id, "was tampered with! Attempting repair.")
                    if OmegaScript.AntiDetection and OmegaScript.AntiDetection.RunSelfRepairCycle then
                        OmegaScript.AntiDetection.RunSelfRepairCycle("metamethod_tamper", guard_id)
                    end
                    if original_method then return original_method(...) end
                    return 
                 end
            end
            return user_hook_logic(original_method, ...)
        end)
        
        mt[method_name] = our_new_hook
        _P.pcall(_P.setreadonly, mt, true)

        _HookedMetatables[guard_id] = {
            target = target, method_name = method_name, original_func = original_method,
            current_hook = our_new_hook, user_hook_logic = user_hook_logic, guard_active = true
        }
        _AdvMemDebug("Metamethod guard established for:", guard_id)
        return true
    end

    function OmegaScript.AdvancedMemory.VerifyAndRepairGuardedHooks()
        if not GetAdvCfg("Enable_IV1_MetatableGuardianship") then return end
        _AdvMemDebug("Verifying guarded metatable hooks...")
        for id, data in _P.pairs(_HookedMetatables) do
            if data.guard_active then
                local mt = _P.debug_getmetatable(data.target) or _P.getmetatable(data.target)
                if mt and mt[data.method_name] ~= data.current_hook then
                    _AdvMemDebug("Tampering detected on guarded hook:", id, ". Attempting repair.")
                    local success_ro_off = _P.pcall(_P.setreadonly, mt, false)
                    if success_ro_off then
                        mt[data.method_name] = data.current_hook
                        _P.pcall(_P.setreadonly, mt, true)
                        _AdvMemDebug("Guarded hook repaired:", id)
                    else
                        _AdvMemDebug("Failed to make metatable writable for repair:", id)
                    end
                end
            end
        end
    end

    function OmegaScript.AdvancedMemory.ExecuteWithIdentity(identity, func, ...)
        if not GetAdvCfg("Enable_IV2_StrategicThreadIdentity") then return func(...) end
        if not _P.getthreadidentity or not _P.setthreadidentity then
            _AdvMemDebug("Thread identity functions not available. Executing normally.")
            return func(...)
        end
        
        local old_identity = _P.getthreadidentity()
        _P.setthreadidentity(identity)
        local results_pack = {_P.pcall(func, ...)}
        _P.setthreadidentity(old_identity)

        if not results_pack[1] then
            _AdvMemDebug("Error during execution with identity", identity, ":", results_pack[2])
            _P.error(results_pack[2]) 
        end
        return _P.unpack(results_pack, 2, results_pack.n or (#results_pack -1))
    end

    function OmegaScript.AdvancedMemory.EvadeMemorySignatureScans()
        if not GetAdvCfg("Enable_IV4_MemorySignatureEvasion") then return end
        _AdvMemDebug("Applying memory signature evasion techniques (conceptual).")
    end

    function OmegaScript.AdvancedMemory.CreateSandboxedEnvironment(luaString, permittedGlobals)
        if not _P.loadstring then return nil, "loadstring not available" end
        local func, err = _P.loadstring(luaString)
        if not func then return nil, "loadstring failed: " .. (_P.tostring(err) or "unknown error") end

        local env = {}
        for k,v in _P.pairs(permittedGlobals or {}) do env[k] = v end
        for k,v in _P.pairs(_P.getfenv(0)) do 
            if not env[k] and (_P.type(v) ~= "function" or k:sub(1,1) == "_" or k == "assert" or k == "select" or k == "type" or k == "next" or k == "pairs" or k == "ipairs" or k == "tostring" or k == "tonumber") then
                env[k] = v
            end
        end
        _P.setfenv(func, env)
        return func
    end
    
    _AdvMemDebug("AdvancedMemory module initialized.")
end


OmegaScript.AntiDetection = OmegaScript.AntiDetection or {}
do
    local _AntiDetectDebug = function(...) if IsModuleDebug(nil, "III") then OmegaScript.Utils.Log("AntiDetect", ...) end end
    local _ActiveHookGroups = OmegaScript.InternalCache.ActiveHookGroups or {}
    OmegaScript.InternalCache.ActiveHookGroups = _ActiveHookGroups
    local _MonitoringDetectionLevel = 0 
    local _SuspiciousCallLog = OmegaScript.InternalCache._SuspiciousCallLog or {}
    OmegaScript.InternalCache._SuspiciousCallLog = _SuspiciousCallLog

    function OmegaScript.AntiDetection.SetHookGroupActive(groupName, isActive)
        if not GetAdvCfg("Enable_III1_SelectiveHookActivation") then return end
        _AntiDetectDebug("Setting hook group:", groupName, "to active:", isActive)
        _ActiveHookGroups[groupName] = isActive
    end
    function OmegaScript.AntiDetection.IsHookGroupActive(groupName)
        if not GetAdvCfg("Enable_III1_SelectiveHookActivation") then return true end
        return _ActiveHookGroups[groupName] == true
    end

    function OmegaScript.AntiDetection.SubtleDelay(maxDelayMs)
        if not GetAdvCfg("Enable_III2_SubtleHeuristicEvasion") then return end
        local delay = (_P.math_random() * (maxDelayMs or 50)) / 1000
        if OmegaScript.Services.RunService and OmegaScript.Services.RunService.Heartbeat then
            local start_time = _P.tick()
            while _P.tick() - start_time < delay do
                if not OmegaScript.Services.RunService.Heartbeat:Wait() then _P.wait(0.01) end
            end
        else
            _P.wait(delay)
        end
    end

    local _FunctionsToMonitor = {} 
    function OmegaScript.AntiDetection.AddCoreFunctionToMonitor(data)
        _P.table_insert(_FunctionsToMonitor, data)
    end
    
    OmegaScript.AntiDetection.AddCoreFunctionToMonitor({name = "getrawmetatable", original_capture = _P.getrawmetatable, globalKey = "getrawmetatable"})
    OmegaScript.AntiDetection.AddCoreFunctionToMonitor({name = "hookfunction", original_capture = _P.hookfunction, globalKey = "hookfunction"})
    if _P.debug_getinfo then
         OmegaScript.AntiDetection.AddCoreFunctionToMonitor({name = "debug_getinfo", original_capture = _P.debug_getinfo, lib = debug, key = "getinfo"})
    end
     if _P.HttpService and _P.HttpService.RequestAsync then
        OmegaScript.AntiDetection.AddCoreFunctionToMonitor({name = "HttpService.RequestAsync", original_capture = _P.HttpService.RequestAsync, lib = _P.HttpService, key = "RequestAsync"})
    end

    function OmegaScript.AntiDetection.VerifyAndRestoreCoreFunctions()
        if not GetAdvCfg("Enable_III3_CoreFunctionIntegrity") then return end
        _AntiDetectDebug("Verifying core function integrity...")
        local restoredCount = 0
        for _, funcData in _P.ipairs(_FunctionsToMonitor) do
            if not funcData.original_capture then continue end
            local currentFunc
            if funcData.lib and funcData.key then currentFunc = funcData.lib[funcData.key]
            elseif funcData.globalKey then currentFunc = (_G or _P.getfenv(0))[funcData.globalKey] end

            if currentFunc ~= funcData.original_capture then
                _AntiDetectDebug("Tampering detected in:", funcData.name, ". Attempting restore.")
                local success = false
                if funcData.lib and funcData.key then
                    local mt = _P.debug_getmetatable(funcData.lib) or _P.getmetatable(funcData.lib)
                    local ro = mt and _P.isreadonly(mt)
                    if mt then _P.pcall(_P.setreadonly, mt, false) end
                    local s,e = _P.pcall(function() funcData.lib[funcData.key] = funcData.original_capture end)
                    success = s
                    if mt and ro then _P.pcall(_P.setreadonly, mt, true) end
                elseif funcData.globalKey then
                     local s,e = _P.pcall(function() (_G or _P.getfenv(0))[funcData.globalKey] = funcData.original_capture end)
                     success = s
                end
                if success then restoredCount = restoredCount + 1; _AntiDetectDebug(funcData.name, "restored.")
                else _AntiDetectDebug("Failed to restore", funcData.name) end
            end
        end
        if restoredCount > 0 then
            OmegaScript.Utils.Notify("Integrity Alert", restoredCount .. " core function(s) possibly restored.", Config.NotificationIcon, 5)
        end
        return restoredCount
    end
    
    function OmegaScript.AntiDetection.RegisterRemoteInterceptor(remoteIdentifier, priority, handlerFunction, duration)
        if not GetAdvCfg("Enable_III4_AdvancedRemoteInterception") then return end
        OmegaScript.RemoteInterceptionRules[remoteIdentifier] = OmegaScript.RemoteInterceptionRules[remoteIdentifier] or {}
        local rule = {priority = priority, handler = handlerFunction, registeredAt = _P.tick()}
        if duration then rule.duration = duration end
        _P.table_insert(OmegaScript.RemoteInterceptionRules[remoteIdentifier], rule)
        _P.table_sort(OmegaScript.RemoteInterceptionRules[remoteIdentifier], function(a,b) return a.priority < b.priority end)
        _AntiDetectDebug("Registered interceptor for remote:", remoteIdentifier, "with priority", priority, duration and ("duration " .. duration) or "")
    end

    function OmegaScript.AntiDetection.CheckRemoteCallFrequency(remoteIdentifier, callMethod)
        local key = _P.tostring(remoteIdentifier) .. ":" .. callMethod
        local now = _P.tick()
        OmegaScript.RemoteCallCounts[key] = OmegaScript.RemoteCallCounts[key] or {times = {}, count = 0}
        
        _P.table_insert(OmegaScript.RemoteCallCounts[key].times, now)
        OmegaScript.RemoteCallCounts[key].count = OmegaScript.RemoteCallCounts[key].count + 1
        
        local windowStart = now - Config.RemoteCallFrequencyWindow
        local validTimes = {}
        for _, t in _P.ipairs(OmegaScript.RemoteCallCounts[key].times) do
            if t >= windowStart then _P.table_insert(validTimes, t) end
        end
        OmegaScript.RemoteCallCounts[key].times = validTimes
        OmegaScript.RemoteCallCounts[key].count = #validTimes
        
        if OmegaScript.RemoteCallCounts[key].count > Config.RemoteCallFrequencyLimit then
            _AntiDetectDebug("Excessive call frequency detected for:", key, "(", OmegaScript.RemoteCallCounts[key].count, "calls in", Config.RemoteCallFrequencyWindow, "s)")
            return true 
        end
        return false
    end

    function OmegaScript.AntiDetection.ProcessRemoteCall(remoteIdentifier, callMethod, args, originalCaller)
        local rules = OmegaScript.RemoteInterceptionRules[remoteIdentifier] or OmegaScript.RemoteInterceptionRules["*"]
        local callData = { args = args, block = false, returnValue = nil, calledOriginal = false, continueProcessing = true }

        if OmegaScript.AntiDetection.CheckRemoteCallFrequency(remoteIdentifier, callMethod) then
            callData.block = true 
            callData.returnValue = (callMethod == "InvokeServer") and nil or nil 
             OmegaScript.Utils.Notify("Anti-Detection", "Remote call blocked due to high frequency: " .. remoteIdentifier, Config.NotificationIcon, 3)
            return callData
        end

        if rules and (callMethod == "FireServer" or callMethod == "InvokeServer") then
            local currentTime = _P.tick()
            local activeRules = {}
            for i = #rules, 1, -1 do 
                local rule = rules[i]
                if rule.duration and (currentTime - rule.registeredAt > rule.duration) then
                    _P.table_remove(rules, i)
                    _AntiDetectDebug("Expired remote interceptor rule for", remoteIdentifier)
                else
                    _P.table_insert(activeRules, 1, rule) 
                end
            end
            
            for _, rule in _P.ipairs(activeRules) do
                if not callData.continueProcessing then break end
                callData.continueProcessing = false 

                local status, result = _P.pcall(rule.handler, callData, originalCaller)
                if not status then
                    _AntiDetectDebug("Error in remote interceptor for", remoteIdentifier, ":", result)
                    OmegaScript.Utils.TrackError("RemoteInterceptor:".._P.tostring(remoteIdentifier), result)
                else
                    if callData.block then break end 
                end
            end
        end

        if not callData.block and not callData.calledOriginal then
            local status_call, result_call
            if _P.type(originalCaller) == "function" then
                 status_call, result_call = _P.pcall(originalCaller, _P.unpack(callData.args))
            else 
                status_call = false; result_call = "OriginalCaller is not a function"
            end

            if not status_call then
                callData.returnValue = (callMethod == "InvokeServer") and nil or nil  
                _AntiDetectDebug("Error calling original remote via originalCaller for", remoteIdentifier, ":", result_call)
            else
                callData.returnValue = result_call
            end
        end
        return callData
    end


    local _CloakedInstances = OmegaScript.InternalCache.CloakedInstances or {}
    OmegaScript.InternalCache.CloakedInstances = _CloakedInstances
    function OmegaScript.AntiDetection.CloakInstance(instance, durationSeconds, newParentOverride)
        if not GetAdvCfg("Enable_III5_DynamicInstanceCloaking") or not instance or not instance.Parent then return end
        
        local originalParent = instance.Parent
        _CloakedInstances[instance] = {parent = originalParent, cloakedAt = _P.tick(), duration = durationSeconds}
        
        local targetParent = newParentOverride
        if newParentOverride == nil and OmegaScript.Services.CoreGui then
            local cloakFolder = OmegaScript.Services.CoreGui:FindFirstChild("OmegaCloakZone")
            if not cloakFolder then
                cloakFolder = Instance.new("Folder")
                cloakFolder.Name = "OmegaCloakZone"
                if OmegaScript.Services.CoreGui then cloakFolder.Parent = OmegaScript.Services.CoreGui
                else cloakFolder.Parent = nil 
                end
            end
            targetParent = cloakFolder
        elseif _P.tostring(newParentOverride) == "NIL_PARENT" then
            targetParent = nil
        end

        _AntiDetectDebug("Cloaking instance:", instance:GetFullName(), "to parent:", targetParent, "for", durationSeconds or "indefinite", "s")
        _P.pcall(function() instance.Parent = targetParent end)

        if durationSeconds and durationSeconds > 0 then
            _P.delay(durationSeconds, function()
                OmegaScript.AntiDetection.UncloakInstance(instance)
            end)
        end
    end

    function OmegaScript.AntiDetection.UncloakInstance(instance)
        if not GetAdvCfg("Enable_III5_DynamicInstanceCloaking") or not _CloakedInstances[instance] then return end
        local cloakData = _CloakedInstances[instance]
        _AntiDetectDebug("Uncloaking instance:", instance:GetFullName(), "back to:", cloakData.parent and cloakData.parent:GetFullName() or "nil")
        _P.pcall(function() instance.Parent = cloakData.parent end)
        _CloakedInstances[instance] = nil
    end

    function OmegaScript.AntiDetection.RunSelfRepairCycle(triggerSource, details)
        if not GetAdvCfg("Enable_III6_CriticalHookSelfRepair") then return end
        _AntiDetectDebug("Running self-repair cycle... Triggered by:", triggerSource or "timer", details or "")
        
        local repairsDone = 0
        if OmegaScript.AdvancedMemory and OmegaScript.AdvancedMemory.VerifyAndRepairGuardedHooks then
            repairsDone = repairsDone + (OmegaScript.AdvancedMemory.VerifyAndRepairGuardedHooks() or 0)
        end
        repairsDone = repairsDone + (OmegaScript.AntiDetection.VerifyAndRestoreCoreFunctions() or 0)
        
        if OmegaScript.ConsoleManager and OmegaScript.ConsoleManager.HookConsoleFunctions then
             OmegaScript.ConsoleManager.HookConsoleFunctions() 
        end

        if repairsDone >0 or (IsModuleDebug(nil, "III") and triggerSource ~= "timer") then
            OmegaScript.Utils.Notify("OmegaScript", "Self-Repair Cycle Triggered. " .. repairsDone .. " potential repairs." , Config.NotificationIcon, 3)
        end
    end

    function OmegaScript.AntiDetection.DetectMonitoringTools()
        if not GetAdvCfg("Enable_III7_MonitoringToolDetection") then return 0 end
        local detectionScore = 0
        
        if _P.getgc then
            for _, obj in _P.getgc(true) do
                if _P.type(obj) == "function" then
                    local info = _P.debug_getinfo and _P.debug_getinfo(obj, "S")
                    if info and info.source then
                        if _P.string_find(info.source, "AntiCheat") or _P.string_find(info.source, "Logger") or _P.string_find(info.source, "Analyzer") then
                            detectionScore = detectionScore + 1; break
                        end
                    end
                elseif _P.type(obj) == "table" and _P.rawget(obj, "_isAntiCheat") then
                     detectionScore = detectionScore + 2; break
                end
            end
        end
        if detectionScore > 0 then _AntiDetectDebug("Monitoring tool heuristic score:", detectionScore) end
        _MonitoringDetectionLevel = detectionScore
        return detectionScore
    end

    function OmegaScript.AntiDetection.EnterStealthMode(level)
        if not GetAdvCfg("Enable_III8_StealthModeActivation") then return end
        _AntiDetectDebug("Entering stealth mode, level:", level)
        OmegaScript.ActiveStealthFeatures["ReducedActivity"] = true
        if OmegaScript.Spoofing then OmegaScript.Spoofing.SetSpoofingIntensity(level) end
        Config.EnableScriptSelfLogs = false 
        OmegaScript.Utils.Notify("Stealth Mode", "Enhanced anti-detection measures activated.", Config.NotificationIcon, 7)
    end
    
    function OmegaScript.AntiDetection.LogSuspiciousAPICall(apiName, context)
        if not GetAdvCfg("Enable_III9_SuspiciousAPICallLogging") then return end
        local callInfo = { api = apiName, context = context, time = _P.tick(), count = 1 }
        local entryKey = apiName .. ":" .. (_P.tostring(context) or "unknown")
        
        if _SuspiciousCallLog[entryKey] then
            _SuspiciousCallLog[entryKey].count = _SuspiciousCallLog[entryKey].count + 1
            _SuspiciousCallLog[entryKey].time = _P.tick()
        else
            _SuspiciousCallLog[entryKey] = callInfo
        end
        _AntiDetectDebug("Logged suspicious API call:", apiName, "Context:", context)
    end

    function OmegaScript.AntiDetection.InitEnvironmentManipulationDetection()
        if not GetAdvCfg("Enable_IV5_EnvironmentManipulationDetection") then return end
        _AntiDetectDebug("Initializing environment manipulation detection (conceptual).")
    end
    
    _AntiDetectDebug("AntiDetection module initialized.")
end


OmegaScript.EnhancedBypasses = OmegaScript.EnhancedBypasses or {}
do
    local _EnhBypassDebug = function(...) if IsModuleDebug(nil, "II") then OmegaScript.Utils.Log("EnhBypasses", ...) end end
    local _ContextActivations = OmegaScript.InternalCache.ContextActivations or {}
    OmegaScript.InternalCache.ContextActivations = _ContextActivations
    local _BypassContextMap = OmegaScript.InternalCache.BypassContextMap or {}
    OmegaScript.InternalCache.BypassContextMap = _BypassContextMap
    local _ProtectedGlobals = OmegaScript.InternalCache._ProtectedGlobals or {}
    OmegaScript.InternalCache._ProtectedGlobals = _ProtectedGlobals

    function OmegaScript.EnhancedBypasses.InterceptFunctionCall(targetFunc, interceptorFunc)
        if not GetAdvCfg("Enable_II1_FunctionCallInterception") then return targetFunc end
        if not _P.newcclosure then return targetFunc end

        return _P.newcclosure(function(...)
            return interceptorFunc(targetFunc, {...})
        end)
    end

    function OmegaScript.EnhancedBypasses.SetupDebugGetinfoSpoof()
        if not GetAdvCfg("Enable_II3_TargetedClientStateSpoofing") then return end
        if not _P.debug_getinfo or not _P.hookfunction or not debug or not debug.getinfo then
            _EnhBypassDebug("debug.getinfo spoofing cannot be set up - missing functions.")
            return
        end
        
        local function getinfo_spoof_logic(actual_getinfo_func, levelOrFunc, fields)
             local targetInfo, err = _P.pcall(actual_getinfo_func, levelOrFunc, fields or "sln")
             if not targetInfo then return actual_getinfo_func(levelOrFunc, fields) end

             local isSensitiveTarget = false
             if _P.type(levelOrFunc) == "function" and targetInfo.name then
                 local lowerName = _P.string_lower(targetInfo.name)
                 if _P.string_find(lowerName, "anticheat") or _P.string_find(lowerName, "ac_check") or _P.string_find(lowerName, "detector") then
                     isSensitiveTarget = true
                 end
             elseif _P.type(levelOrFunc) == "number" and targetInfo.source and (_P.string_find(targetInfo.source, "AntiCheatScript") or _P.string_find(targetInfo.source, "@ClientAntiCheat")) then
                 isSensitiveTarget = true
             end

             if isSensitiveTarget or OmegaScript.ActiveStealthFeatures["FullDebugSpoof"] then
                 _EnhBypassDebug("Spoofing debug.getinfo for target:", targetInfo.name or targetInfo.source or levelOrFunc)
                 local spoofedInfo = {}
                 local fieldStr = fields or "slnfL" 
                 for i=1, #fieldStr do
                    local fieldChar = fieldStr:sub(i,i)
                    if fieldChar == "s" then spoofedInfo.source = "@Protected Core Script" ; spoofedInfo.short_src = "[Protected]"
                    elseif fieldChar == "l" then spoofedInfo.currentline = -1 ; spoofedInfo.linedefined = -1; spoofedInfo.lastlinedefined = -1
                    elseif fieldChar == "n" then spoofedInfo.name = OmegaScript.Utils.GenerateRandomString(8) ; spoofedInfo.namewhat = "global"
                    elseif fieldChar == "u" then spoofedInfo.nups = 0; spoofedInfo.nparams = 0; spoofedInfo.isvararg = false
                    elseif fieldChar == "f" then spoofedInfo.func = function() end
                    elseif fieldChar == "L" then spoofedInfo.activelines = {}
                    elseif targetInfo[fieldChar] then spoofedInfo[fieldChar] = targetInfo[fieldChar] 
                    end
                 end
                 return spoofedInfo
             end
             return actual_getinfo_func(levelOrFunc, fields)
        end
        
        if debug and debug.getinfo then
            local success = OmegaScript.AdvancedMemory.GuardMetamethod(debug, "getinfo", 
                function(original_getinfo, ...) return getinfo_spoof_logic(original_getinfo, ...) end
            )
            if success then
                 _EnhBypassDebug("debug.getinfo spoofing hook established via GuardMetamethod.")
                 OmegaScript.Status.DebugGetinfoSpoofed = true
            else
                 _EnhBypassDebug("Failed to guard debug.getinfo, attempting direct hook.")
                 local current_debug_getinfo = debug.getinfo
                 debug.getinfo = _P.hookfunction(current_debug_getinfo, function(...) return getinfo_spoof_logic(current_debug_getinfo, ...) end)
                 _EnhBypassDebug("debug.getinfo direct spoofing hook established.")
                 OmegaScript.Status.DebugGetinfoSpoofed = true
            end
        else
            _EnhBypassDebug("debug.getinfo or debug table not found for spoofing.")
        end
    end

    function OmegaScript.EnhancedBypasses.RegisterContext(contextName, activationCheckFunc)
        if not GetAdvCfg("Enable_II5_ContextAwareBypassActivation") then return end
        _ContextActivations[contextName] = activationCheckFunc
        _EnhBypassDebug("Registered context:", contextName)
    end
    function OmegaScript.EnhancedBypasses.AssignBypassToContext(bypassName, contextName)
        if not GetAdvCfg("Enable_II5_ContextAwareBypassActivation") then return end
        _BypassContextMap[bypassName] = contextName
    end
    function OmegaScript.EnhancedBypasses.IsBypassActive(bypassName)
        if not GetAdvCfg("Enable_II5_ContextAwareBypassActivation") then return true end
        
        local contextName = _BypassContextMap[bypassName]
        if contextName then
            local activationFunc = _ContextActivations[contextName]
            if activationFunc then
                local isActive, err = _P.pcall(activationFunc)
                if not isActive then 
                    if err then _EnhBypassDebug("Error checking context", contextName, "for bypass", bypassName, ":", err) end
                    return false 
                end
                return true
            end
            return false 
        end
        return true 
    end
    
    function OmegaScript.EnhancedBypasses.ProtectGlobalVariable(varName, expectedValue)
        if not GetAdvCfg("Enable_II6_GlobalOverwriteProtection") then return end
        local env = _G or _P.getfenv(0)
        _ProtectedGlobals[varName] = { original = env[varName], expected = expectedValue or env[varName] }
        _EnhBypassDebug("Now protecting global variable:", varName)

    end

    function OmegaScript.EnhancedBypasses.VerifyProtectedGlobals()
        if not GetAdvCfg("Enable_II6_GlobalOverwriteProtection") then return 0 end
        local restoredCount = 0
        local env = _G or _P.getfenv(0)
        for varName, data in _P.pairs(_ProtectedGlobals) do
            if env[varName] ~= data.expected then
                _EnhBypassDebug("Tampering detected in global variable:", varName, ". Expected:", data.expected, "Got:", env[varName], ". Restoring.")
                env[varName] = data.original 
                restoredCount = restoredCount + 1
                 OmegaScript.Utils.Notify("Global Protection", "Restored tampered global: " .. varName, Config.NotificationIcon, 4)
            end
        end
        return restoredCount
    end

    _EnhBypassDebug("EnhancedBypasses module initialized.")
end

OmegaScript.AntiCheatBypasses = {}
do
    local _ACBypassDebug = function(...) if IsModuleDebug(nil) then OmegaScript.Utils.Log("ACBypasses", ...) end end
    local _getthreadidentity = _P.getthreadidentity
    local _setthreadidentity = _P.setthreadidentity
    local _getinfo = _P.debug_getinfo or _P.debug_info 
    local _hookfunction = _P.hookfunction
    local _newcclosure = _P.newcclosure
    local _getgc = _P.getgc
    local _rawget = _P.rawget
    local _rawset = _P.rawset
    local _typeof = _P.typeof
    local _coroutine_yield = _P.coroutine_yield
    local _coroutine_running = _P.coroutine_running
    local _getconnections = _P.getconnections
    local _getrenv = getrenv or function() return _G or _P.getfenv(0) end

    function OmegaScript.AntiCheatBypasses.InitAdonisBypassV1()
        if not Config.Enable_AdonisBypass_GCScanV1 then return end
        local DEBUG_V1 = IsModuleDebug(Config.AdonisBypass_V1_Debug)
        if DEBUG_V1 then _ACBypassDebug("[V1] Initializing...") end

        if not _getgc or not _hookfunction or not _newcclosure or not _getrenv or not _getinfo then
            OmegaScript.Utils.Warn("ACBypassV1", "Missing core functions. Cannot initialize.")
            return
        end

        local HookedThisModule = {}
        local DetectedFunc, KillFunc

        _setthreadidentity(2)
        for i, v in _getgc(true) do
            if _typeof(v) == "table" then
                local currentDetected = _rawget(v, "Detected")
                local currentKill = _rawget(v, "Kill")

                if _typeof(currentDetected) == "function" and not DetectedFunc then
                    DetectedFunc = currentDetected
                    local oldDetected; oldDetected = _hookfunction(DetectedFunc, function(Action, Info, NoCrash)
                        if Action ~= "_" then
                            if DEBUG_V1 then OmegaScript.Utils.Warn("ACBypassV1", "Adonis AntiCheat flagged Method: ", Action, " Info: ", Info) end
                        end
                        return true
                    end)
                   _P.table_insert(HookedThisModule, {Original = DetectedFunc, Hook = oldDetected, Type = "DetectedFunc"})
                end

                if _rawget(v, "Variables") and _rawget(v, "Process") and _typeof(currentKill) == "function" and not KillFunc then
                    KillFunc = currentKill
                    local oldKill; oldKill = _hookfunction(KillFunc, function(Info)
                        if DEBUG_V1 then OmegaScript.Utils.Warn("ACBypassV1", "Adonis AntiCheat tried to kill (fallback): ", Info) end
                        return _coroutine_yield()
                    end)
                    _P.table_insert(HookedThisModule, {Original = KillFunc, Hook = oldKill, Type = "KillFunc"})
                end
            end
            if DetectedFunc and KillFunc then break end
        end
        _setthreadidentity(7)

        local renv = _getrenv()
        if DetectedFunc and renv.debug and renv.debug.info then
            if DEBUG_V1 then _ACBypassDebug("[V1] Hooked Detected function. Attempting to hook debug.info for it.") end
            local success = OmegaScript.AdvancedMemory.GuardMetamethod(renv.debug, "info", function(original_info_func, ...)
                local LevelOrFunc, Info = ...
                if LevelOrFunc == DetectedFunc then
                    if DEBUG_V1 then OmegaScript.Utils.Warn("ACBypassV1", "Adonis debug.info call bypassed for DetectedFunc.") end
                    return _coroutine_yield(_coroutine_running())
                end
                return original_info_func(...)
            end)
            if not success then 
                 _ACBypassDebug("[V1] Failed to GuardMetamethod for debug.info, direct hook (less safe).")
                 local orig_di = renv.debug.info
                 renv.debug.info = _hookfunction(orig_di, function(...) local L,I = ...; if L == DetectedFunc then return _coroutine_yield(_coroutine_running()) end return orig_di(...) end)
            end

        elseif DEBUG_V1 then
            OmegaScript.Utils.Warn("ACBypassV1", "Could not find Adonis 'Detected' function or _getrenv().debug.info.")
        end
        if DEBUG_V1 then _ACBypassDebug("[V1] Initialization complete.") end
        OmegaScript.Status.AdonisBypassV1Initialized = true
    end

    function OmegaScript.AntiCheatBypasses.InitAdonisBypassV2()
        if not Config.Enable_AdonisBypass_GCScanV2 then return end
        local DEBUG_V2 = IsModuleDebug(Config.AdonisBypass_V2_Debug)
        if DEBUG_V2 then _ACBypassDebug("[V2] Initializing...") end

        if not _getgc or not _hookfunction or not _newcclosure or not _getrenv or not _getinfo or not OmegaScript.Services.RunService then
            OmegaScript.Utils.Warn("ACBypassV2", "Missing core functions or RunService. Cannot initialize.")
            return
        end
        
        local _HookedThisModuleV2 = {}
        local _DetectedFuncV2, _KillFuncV2
        local _lastBeat = _P.tick()
        local _heartbeatInterval = Config.AdonisBypass_V2_HeartbeatInterval
        local _maxDelayTolerance = Config.AdonisBypass_V2_MaxDelayTolerance

        _setthreadidentity(2)

        local function checkStatusV2()
            local currentTime = _P.tick()
            local timeDifference = currentTime - _lastBeat
            if timeDifference > _maxDelayTolerance then
                if DEBUG_V2 then OmegaScript.Utils.Warn("ACBypassV2", "Delay detected: ", timeDifference, "s. Potential desync.") end
                _lastBeat = currentTime
                return false
            end
            return true
        end
        local function updateHeartbeatV2()
            _lastBeat = _P.tick()
            if DEBUG_V2 then OmegaScript.Utils.Log("ACBypassV2", "Heartbeat updated: ", _lastBeat) end
        end

        for i, v in _getgc(true) do
            if _typeof(v) == "table" then
                local currentDetected = _rawget(v, "Detected")
                local currentKill = _rawget(v, "Kill")

                if _typeof(currentDetected) == "function" and not _DetectedFuncV2 then
                    _DetectedFuncV2 = currentDetected
                    local oldDt; oldDt = _hookfunction(_DetectedFuncV2, function(Action, Info, NoCrash)
                        if not checkStatusV2() then
                            if DEBUG_V2 then OmegaScript.Utils.Warn("ACBypassV2", "Resyncing due to status check fail before DetectedFunc call...") end
                            updateHeartbeatV2()
                        end
                        if Action ~= "_" then
                            if DEBUG_V2 then OmegaScript.Utils.Warn("ACBypassV2", "Flag Method: ", Action, " Info: ", Info) end
                        end
                        return true
                    end)
                    _P.table_insert(_HookedThisModuleV2, {Original = _DetectedFuncV2, Hook = oldDt, Type = "DetectedFuncV2"})
                end

                if _rawget(v, "Variables") and _rawget(v, "Process") and _typeof(currentKill) == "function" and not _KillFuncV2 then
                    _KillFuncV2 = currentKill
                    local oldKl; oldKl = _hookfunction(_KillFuncV2, function(Info)
                        if DEBUG_V2 then OmegaScript.Utils.Warn("ACBypassV2", "Kill Attempt: ", Info) end
                        return _coroutine_yield()
                    end)
                    _P.table_insert(_HookedThisModuleV2, {Original = _KillFuncV2, Hook = oldKl, Type = "KillFuncV2"})
                end
            end
            if _DetectedFuncV2 and _KillFuncV2 then break end
        end
        
        local renv_v2 = _getrenv()
        if _DetectedFuncV2 and renv_v2.debug and renv_v2.debug.info then
             if DEBUG_V2 then _ACBypassDebug("[V2] Hooked _DetectedFuncV2. Attempting to hook debug.info for it.") end
             local success_v2_guard = OmegaScript.AdvancedMemory.GuardMetamethod(renv_v2.debug, "info", function(original_info_func_v2, ...)
                local LevelOrFunc, Info = ...
                if LevelOrFunc == _DetectedFuncV2 then
                    if DEBUG_V2 then OmegaScript.Utils.Warn("ACBypassV2", "debug.info call bypassed for _DetectedFuncV2.") end
                    return _coroutine_yield(_coroutine_running())
                end
                return original_info_func_v2(...)
            end)
             if not success_v2_guard then
                _ACBypassDebug("[V2] Failed to GuardMetamethod for debug.info (V2), direct hook.")
                local orig_di_v2 = renv_v2.debug.info
                renv_v2.debug.info = _hookfunction(orig_di_v2, function(...) local L,I = ...; if L == _DetectedFuncV2 then return _coroutine_yield(_coroutine_running()) end return orig_di_v2(...) end)
             end
        elseif DEBUG_V2 then
            OmegaScript.Utils.Warn("ACBypassV2", "Could not find Adonis '_DetectedFuncV2' or _getrenv().debug.info.")
        end
        _setthreadidentity(7)

        _P.spawn(function()
            while Config.Enable_AdonisBypass_GCScanV2 and OmegaScript.Services.RunService and OmegaScript.Services.RunService.Heartbeat do
                _P.wait(Config.AdonisBypass_V2_HeartbeatInterval) 
                if not OmegaScript.Services.RunService or not OmegaScript.Services.RunService.Heartbeat then break end
                
                _heartbeatInterval = Config.AdonisBypass_V2_HeartbeatInterval
                _maxDelayTolerance = Config.AdonisBypass_V2_MaxDelayTolerance
                if not checkStatusV2() then
                    if DEBUG_V2 then OmegaScript.Utils.Warn("ACBypassV2", "Heartbeat: Reestablishing due to status check fail...") end
                    updateHeartbeatV2()
                end
                local status = OmegaScript.Services.RunService.Heartbeat:Wait()
                if not status then _P.wait(0.03) end 
            end
            if DEBUG_V2 then _ACBypassDebug("[V2] Heartbeat monitoring stopped.") end
        end)
        if DEBUG_V2 then _ACBypassDebug("[V2] Initialization complete.") end
        OmegaScript.Status.AdonisBypassV2Initialized = true
    end

    function OmegaScript.AntiCheatBypasses.DisableCameraConnections()
        if not Config.Enable_AdonisBypass_CameraConnections then return end
        local DEBUG_CAM = IsModuleDebug(nil)
        if DEBUG_CAM then _ACBypassDebug("[Camera] Disabling camera connections...") end
        local currentCamera = OmegaScript.Services.Workspace and OmegaScript.Services.Workspace.CurrentCamera
        if not currentCamera then
            OmegaScript.Utils.Warn("ACBCamera", "CurrentCamera not found.")
            return
        end
        if not _getconnections then OmegaScript.Utils.Warn("ACBCamera", "getconnections not available."); return end

        _setthreadidentity(7)
        local changedDisabled = 0
        local cframeDisabled = 0
        _P.pcall(function()
            for _, con in _P.next, _getconnections(currentCamera.Changed) do
                _P.wait(); con:Disable(); changedDisabled = changedDisabled + 1
            end
        end)
        _P.pcall(function()
            for _, con in _P.next, _getconnections(currentCamera:GetPropertyChangedSignal("CFrame")) do
                _P.wait(); con:Disable(); cframeDisabled = cframeDisabled + 1
            end
        end)
        _setthreadidentity(2) 
        if DEBUG_CAM then _ACBypassDebug("[Camera] Camera connection disabling attempted. Changed:", changedDisabled, "CFrame:", cframeDisabled) end
        OmegaScript.Status.CameraConnectionsDisabled = (changedDisabled + cframeDisabled > 0)
    end

    function OmegaScript.AntiCheatBypasses.InitAdonisKickYield()
        if not Config.Enable_AdonisBypass_KickYield then return end
        local DEBUG_KICK = IsModuleDebug(nil)
        if DEBUG_KICK then _ACBypassDebug("[KickYield] Initializing Adonis Kick Yield Bypass...") end
        if not _getgc or not _rawget or not _rawset or not _P.setreadonly or not _P.isreadonly then
             OmegaScript.Utils.Warn("ACBKickYield", "Missing core functions. Cannot initialize.")
             return
        end

        local foundAndBypassed = false
        _setthreadidentity(2)
        for Key, Object in _P.pairs(_getgc(true)) do
            if _typeof(Object) == "table" then
                local originalReadOnly = _P.isreadonly(Object)
                _P.setreadonly(Object, false)
                local indexInstance = _rawget(Object, "indexInstance")
                if _typeof(indexInstance) == "table" and _typeof(indexInstance[1]) == "string" and _P.string_lower(indexInstance[1]) == "kick" then
                    local innerTableReadOnly = _P.isreadonly(indexInstance)
                    _P.setreadonly(indexInstance, false)
                    _rawset(Object, "Table", {"kick", function() 
                        if DEBUG_KICK then OmegaScript.Utils.Warn("ACBKickYield", "Intercepted Adonis 'kick' command. Yielding.") end
                        _coroutine_yield() 
                    end})
                    _P.setreadonly(indexInstance, innerTableReadOnly)
                    OmegaScript.Utils.Notify("Adonis Bypass", "Kick event handler modified (Yield).", Config.NotificationIcon, 10)
                    foundAndBypassed = true
                end
                _P.setreadonly(Object, originalReadOnly)
                if foundAndBypassed then break end
            end
        end
        _setthreadidentity(7)

        OmegaScript.Status.AdonisKickBypassed = foundAndBypassed
        if DEBUG_KICK then 
            if foundAndBypassed then _ACBypassDebug("[KickYield] Successfully bypassed Adonis kick via 'indexInstance' method.")
            else OmegaScript.Utils.Warn("ACBKickYield", "Could not find matching 'indexInstance' for kick bypass.") end
        end
    end
    
    function OmegaScript.AntiCheatBypasses.InitAdonisGameMetatableHook()
        if not Config.Enable_AdonisBypass_GameMetatableHook or not _P.getrawmetatable then return end
        local DEBUG_GMT = IsModuleDebug(nil)
        if DEBUG_GMT then _ACBypassDebug("[GameMT] Initializing Guarded Game Metatable __namecall Hook...") end

        local function guarded_namecall_hook_logic(original_game_mt_namecall, self, ...)
            local NamecallMethod = _P.getnamecallmethod and _P.getnamecallmethod() or "unknown"
            local argsFromCall = {...}
            
            local remoteIdentifier 
            if NamecallMethod == "FireServer" or NamecallMethod == "InvokeServer" then
                 remoteIdentifier = #argsFromCall > 0 and _P.tostring(argsFromCall[1]) or _P.tostring(self)
            else
                remoteIdentifier = _P.tostring(self)
            end

            local callData = OmegaScript.AntiDetection.ProcessRemoteCall(
                remoteIdentifier, NamecallMethod, argsFromCall,
                function(...) 
                    if original_game_mt_namecall then return original_game_mt_namecall(self, ...) end
                    if DEBUG_GMT then OmegaScript.Utils.Warn("ACBGameMT", "Original namecall func for", remoteIdentifier, "is nil in guarded hook.") end
                    return 
                end
            )

            if callData.block then
                if DEBUG_GMT then OmegaScript.Utils.Warn("ACBGameMT", "Call to ", _P.tostring(remoteIdentifier), " blocked by interceptor.") end
                return callData.returnValue
            end
            
            local ADONIS_DETECTION_STRINGS = { 'CHECKER_1', 'CHECKER', 'OneMoreTime', 'checkingSPEED','PERMAIDBAN', 'BANREMOTE', 'FORCEFIELD', 'TeleportDetect', 'AdonisAntiCheat', 'ServerScriptStorage.MainModule:ProcessFunction' }
            if NamecallMethod == 'FireServer' and _P.type(remoteIdentifier) == "string" then
                 for _, pattern in _P.ipairs(ADONIS_DETECTION_STRINGS) do
                     if _P.string_find(_P.string_lower(remoteIdentifier), _P.string_lower(pattern)) then
                        if DEBUG_GMT then OmegaScript.Utils.Warn("ACBGameMT", "Blocked FireServer (default rule): ", remoteIdentifier) end
                        return 
                     end
                 end
            end
            
            if NamecallMethod == "Kick" and _P.tostring(self) == "LocalPlayer" then
                if DEBUG_GMT then OmegaScript.Utils.Warn("ACBGameMT", "Intercepted LocalPlayer:Kick(). Yielding.") end
                return _coroutine_yield()
            end
            
            return callData.returnValue
        end

        if OmegaScript.AdvancedMemory.GuardMetamethod then
            local success = OmegaScript.AdvancedMemory.GuardMetamethod(game, "__namecall", guarded_namecall_hook_logic)
            if success then
                OmegaScript.Status.AdonisGameMTBypassed = true
                OmegaScript.Utils.Notify("Game Bypass", "Game __namecall guarded.", Config.NotificationIcon, 10)
                if DEBUG_GMT then _ACBypassDebug("[GameMT] Game Metatable __namecall Hook guarded successfully.") end
            else
                if DEBUG_GMT then OmegaScript.Utils.Warn("ACBGameMT", "Failed to guard Game Metatable __namecall Hook.") end
                 OmegaScript.Status.AdonisGameMTBypassed = false
            end
        else
            if DEBUG_GMT then OmegaScript.Utils.Warn("ACBGameMT", "GuardMetamethod not available for Game __namecall.") end
            OmegaScript.Status.AdonisGameMTBypassed = false
        end
    end
    if IsModuleDebug(nil) then OmegaScript.Utils.Log("AntiCheatBypasses module initialized.") end
end

OmegaScript.DebuggingTools = {}
do
    local _DebugToolsDebug = function(...) if IsModuleDebug(nil) then OmegaScript.Utils.Log("DebugTools", ...) end end
    function OmegaScript.DebuggingTools.SetupTableHooks()
        if not Config.Enable_Debugging_TableHooks then return end
        _DebugToolsDebug("Setting up table LOUD hooks (__tostring, __call)...")
        if not _P.getgc or not _P.getrawmetatable or not _P.setreadonly or not _P.isreadonly or not _P.newcclosure or not _P.hookfunction then
            OmegaScript.Utils.Warn("DebugTools", "Missing core functions. Cannot setup table hooks.")
            return
        end

        _P.setthreadidentity(2)
        for i, v in _getgc(true) do
            if _P.typeof(v) == "table" then
                local mt = _P.getrawmetatable(v)
                if mt and mt.__call then
                    local mtReadOnly = _P.isreadonly(mt)
                    _P.setreadonly(mt, false)
                    if mt.__tostring then mt.__tostring = nil end

                    local oldCall = mt.__call
                    mt.__call = _P.newcclosure(function(...)
                        local args = {...}
                        local argStrings = {}
                        for _, argVal in _P.ipairs(args) do _P.table_insert(argStrings, _P.tostring(argVal)) end
                        _DebugToolsDebug("Table __call:", _P.tostring(v), "Args:", _P.table_concat(argStrings, ", "))
                        return oldCall(...)
                    end)
                    _P.setreadonly(mt, mtReadOnly)
                end
            end
        end
        _P.setthreadidentity(7)
        _DebugToolsDebug("Table LOUD hooks setup attempted.")
        OmegaScript.Status.TableHooksAttempted = true
    end
    if IsModuleDebug(nil) then OmegaScript.Utils.Log("DebuggingTools module initialized.") end
end

OmegaScript.DataExtraction = {}
do
    local _DataExDebug = function(...) if IsModuleDebug(nil) then OmegaScript.Utils.Log("DataEx", ...) end end
    function OmegaScript.DataExtraction.DumpFF2GlobalStats()
        if not Config.Enable_DataExtraction_FF2Dumper then 
            OmegaScript.Utils.Log("FF2Dumper", "Dumper is disabled in config.")
            OmegaScript.Utils.Notify("FF2 Dumper", "Dumper is disabled in config.", Config.NotificationIcon, 5)
            return
        end
        local ReplicatedStorage = OmegaScript.Services.ReplicatedStorage
        local Players = OmegaScript.Services.Players
        if not ReplicatedStorage or not Players then
            OmegaScript.Utils.Warn("FF2Dumper", "Required services (ReplicatedStorage, Players) not available.")
            return
        end
        _DataExDebug("Initializing FF2 Global Stats Dumper...")

        local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes", 10)
        if not RemotesFolder then OmegaScript.Utils.Warn("FF2Dumper", "'Remotes' folder not found."); return end
        local StatsTransferRemote = RemotesFolder:WaitForChild("StatsTransfer", 10)
        if not StatsTransferRemote then OmegaScript.Utils.Warn("FF2Dumper", "'StatsTransfer' remote not found."); return end

        local statsData, errorMsg
        local successInvoke, invokeResult = _P.pcall(function() return StatsTransferRemote:InvokeServer("global", "all") end)
        if successInvoke then statsData = invokeResult[1]; errorMsg = invokeResult[2]
        else errorMsg = invokeResult end

        if not successInvoke or _P.typeof(statsData) ~= "table" then
            OmegaScript.Utils.Warn("FF2Dumper", "Failed to fetch statsData! Error:", errorMsg or "pcall failed/invalid data")
            OmegaScript.Utils.Notify("FF2 Dumper", "Failed to fetch stats. Check console/logs.", Config.NotificationIcon, 7)
            return
        end
        OmegaScript.Utils.Notify("FF2 Dumper", "Fetched global stats data. Processing...", Config.NotificationIcon, 5)

        local globalIdsString = ""
        local globalIdsCounter = 0

        local function getIdFromNameFF2(name)
            local userIdSuccess, userIdResult
            for attempt = 1, 3 do
                userIdSuccess, userIdResult = _P.pcall(Players.GetUserIdFromNameAsync, Players, name)
                if userIdSuccess then return userIdResult end
                if _P.typeof(userIdResult) == "string" and _P.string_find(userIdResult, "throttled") then
                    if IsModuleDebug(nil) then OmegaScript.Utils.Warn("FF2Dumper", "Throttled for ", name, ". Waiting 10s...") end
                    _P.wait(10)
                else
                    if IsModuleDebug(nil) then OmegaScript.Utils.Warn("FF2Dumper", "Failed GetUserIdFromNameAsync for ", name, ": ", userIdResult) end
                    _P.wait(1)
                end
            end
            return nil
        end

        for footballPosition, globals in _P.pairs(statsData) do
            if IsModuleDebug(nil) then _DataExDebug("Dumping position ", _P.tostring(footballPosition), " with ", #globals, " globals") end
            for leaderboardPosition, global in _P.ipairs(globals) do
                local other = global.other
                if not other or _P.typeof(other.name) ~= "string" then if IsModuleDebug(nil) then OmegaScript.Utils.Warn("FF2Dumper", "Skipping user, no 'other' or invalid name.") end; continue end
                if IsModuleDebug(nil) then _DataExDebug("Processing ", other.name, " (#", leaderboardPosition, " at ", footballPosition, ")") end

                local userId = getIdFromNameFF2(other.name)
                if userId then
                    globalIdsString = globalIdsString == "" and _P.tostring(userId) or globalIdsString .. " " .. _P.tostring(userId)
                    globalIdsCounter = globalIdsCounter + 1
                    _P.wait(Config.DataExtraction_FF2_APICallDelay)
                elseif IsModuleDebug(nil) then OmegaScript.Utils.Warn("FF2Dumper", "Null UserId for:", other.name)
                end
            end
        end

        if globalIdsCounter > 0 and _P.writefile then
            local writeSuccess = _P.pcall(_P.writefile, Config.DataExtraction_FF2_WriteFileName, globalIdsString)
            if writeSuccess then
                OmegaScript.Utils.Notify("FF2 Dumper", _P.string_format("Wrote %i IDs to %s.", globalIdsCounter, Config.DataExtraction_FF2_WriteFileName), Config.NotificationIcon, 10)
            else 
                OmegaScript.Utils.Warn("FF2Dumper", "Failed to write UserIDs to file.")
                OmegaScript.Utils.Notify("FF2 Dumper", "Failed to write IDs to file.", Config.NotificationIcon, 7)
            end
        elseif globalIdsCounter == 0 then 
            OmegaScript.Utils.Warn("FF2Dumper", "No UserIDs collected.")
            OmegaScript.Utils.Notify("FF2 Dumper", "No UserIDs collected.", Config.NotificationIcon, 7)
        elseif not _P.writefile then 
            OmegaScript.Utils.Warn("FF2Dumper", "'writefile' function not available.")
            OmegaScript.Utils.Notify("FF2 Dumper", "'writefile' not available.", Config.NotificationIcon, 7)
        end
        OmegaScript.Status.FF2DumperRan = true
    end
    if IsModuleDebug(nil) then OmegaScript.Utils.Log("DataExtraction module initialized.") end
end

OmegaScript.NetworkInfo = {}
do
    local _NetInfoDebug = function(...) if IsModuleDebug(nil) then OmegaScript.Utils.Log("NetInfo", ...) end end
    function OmegaScript.NetworkInfo.ReportSpoofedDetails()
        if not Config.Enable_NetworkInfo_ReportSpoofed then 
            OmegaScript.Utils.Warn("NetworkInfo", "ReportSpoofedDetails is disabled in config.")
            OmegaScript.Utils.Notify("Network Info", "Reporting spoofed details is disabled.", Config.NotificationIcon, 5)
            return
        end
        OmegaScript.Utils.Notify("Network Info", "Reporting Spoofed IP: " .. Config.NetworkInfo_SpoofedIP .. ", MAC: " .. Config.NetworkInfo_SpoofedMAC, Config.NotificationIcon, 7)
        OmegaScript.Status.SpoofedDetailsReported = true
    end

    function OmegaScript.NetworkInfo.FetchAndDisplayActualIP()
        if not Config.Enable_NetworkInfo_FetchActualIP then
            OmegaScript.Utils.Warn("NetworkInfo", "FetchAndDisplayActualIP is disabled in config.")
            OmegaScript.Utils.Notify("Network Info", "Fetching actual IP is disabled.", Config.NotificationIcon, 5)
            return
        end
        local HttpService = OmegaScript.Services.HttpService
        if not HttpService then OmegaScript.Utils.Warn("NetworkInfo", "HttpService not available."); return end
        _NetInfoDebug("Fetching actual public IP address...")

        local success, responseStr = _P.pcall(function() return HttpService:GetAsync("https://ipwhois.app/json/", true) end)
        if success and responseStr then
            local dataSuccess, jsonData = _P.pcall(HttpService.JSONDecode, HttpService, responseStr)
            if dataSuccess and jsonData and jsonData.success ~= false then
                 local ipInfo = _P.string_format("IP: %s, City: %s, Country: %s", jsonData.ip or "N/A", jsonData.city or "N/A", jsonData.country or "N/A")
                OmegaScript.Utils.Notify("Network Info", "Actual IP Info: " .. ipInfo, Config.NotificationIcon, 10)
                _NetInfoDebug("Actual Public IP Information (via ipwhois.app): ", jsonData)
            else 
                OmegaScript.Utils.Warn("NetworkInfo", "Failed to parse IP data or API error:", responseStr)
                OmegaScript.Utils.Notify("Network Info", "Failed to parse IP. Check logs.", Config.NotificationIcon, 7)
            end
        else 
            OmegaScript.Utils.Warn("NetworkInfo", "Failed to GET IP address:", responseStr)
            OmegaScript.Utils.Notify("Network Info", "Failed to GET IP. Check logs.", Config.NotificationIcon, 7)
        end
        OmegaScript.Status.ActualIPFetched = true
    end
    if IsModuleDebug(nil) then OmegaScript.Utils.Log("NetworkInfo module initialized.") end
end

OmegaScript.GameSpecificLogic = {}
do
    local _GameSpecificDebug = function(...) if IsModuleDebug(nil) then OmegaScript.Utils.Log("GameSpecific", ...) end end
    local BlockInstance = OmegaScript.Utils.BlockInstance
    local Notify = OmegaScript.Utils.Notify
    
    local function DestroyGrabLocalScriptGS()
        local ReplicatedFirst = OmegaScript.Services.ReplicatedFirst
        if ReplicatedFirst then
             local clientFolder = ReplicatedFirst:FindFirstChild("Client")
             if clientFolder then
                local grabLocal = clientFolder:FindFirstChild("GrabLocal")
                if grabLocal then 
                    BlockInstance(grabLocal)
                    Notify("Game Bypass", "Destroyed GrabLocal script.", Config.NotificationIcon, 5)
                end
             end
        end
    end

    local function BypassMobileClientAntiCheatGS()
        local StarterPlayer = OmegaScript.Services.StarterPlayer
        if StarterPlayer then
            local StarterPlayerScripts = StarterPlayer:FindFirstChildOfClass("StarterPlayerScripts") or StarterPlayer
            if StarterPlayerScripts then
                local clientAC = StarterPlayerScripts:FindFirstChild("ClientAnticheat")
                if clientAC then
                    local mobileAC = clientAC:FindFirstChild("AntiMobileExploits")
                    if mobileAC then BlockInstance(mobileAC) end
                    BlockInstance(clientAC)
                    Notify("Game Bypass", "Mobile Client Anti-Cheat bypassed.", Config.NotificationIcon, 5)
                end
            end
        end
    end
    
    function OmegaScript.GameSpecificLogic.ApplyBypasses()
        if not Config.Enable_GameSpecific_Bypasses then return end
        if not game or not _P.type(game.PlaceId) == "number" then OmegaScript.Utils.Warn("GameSpecific", "PlaceId not available."); return end
        _GameSpecificDebug("Current PlaceId:", game.PlaceId)

        DestroyGrabLocalScriptGS()
        BypassMobileClientAntiCheatGS()

        local placeId = game.PlaceId
        if placeId == 9431156611 then
            Notify("Slap Royale", "Applying specific bypasses...", Config.NotificationIcon, 3)
            local remotesToBlock = {"Ban", "WalkSpeedChanged", "WS", "WS2"}
            OmegaScript.AntiDetection.RegisterRemoteInterceptor("*", 1,
                function(callData, originalCaller)
                    local remoteName = callData.args and callData.args[1] and _P.tostring(callData.args[1])
                    if remoteName and (_P.table_find(remotesToBlock, remoteName) or _P.table_find(remotesToBlock, _P.tostring(callData.args[0]))) then
                        if IsModuleDebug(nil) then _GameSpecificDebug("[SR] Intercepted & Blocking Remote:", remoteName) end
                        callData.block = true
                        return
                    end
                end
            )
        elseif placeId == 11520107397 or placeId == 9015014224 or placeId == 6403373529 or placeId == 124596094333302 then
            Notify("Slap Battles et al.", "Applying specific bypasses...", Config.NotificationIcon, 3)
            local remotesToBlockSB = {"Ban", "WalkSpeedChanged", "AdminGUI", "GRAB", "SpecialGloveAccess"}
             OmegaScript.AntiDetection.RegisterRemoteInterceptor("*", 1,
                function(callData, originalCaller)
                    local remoteName = callData.args and callData.args[1] and _P.tostring(callData.args[1])
                    if remoteName and (_P.table_find(remotesToBlockSB, remoteName) or _P.table_find(remotesToBlockSB, _P.tostring(callData.args[0]))) then
                        if IsModuleDebug(nil) then _GameSpecificDebug("[SB] Intercepted & Blocking Remote:", remoteName) end
                        callData.block = true
                        return
                    end
                end
            )
        else
            if IsModuleDebug(nil) then _GameSpecificDebug("No specific remote interception rules for PlaceId:", placeId) end
        end
         OmegaScript.Status.GameSpecificBypassesApplied = true
    end
    if IsModuleDebug(nil) then OmegaScript.Utils.Log("GameSpecificLogic module initialized.") end
end

OmegaScript.Spoofing = OmegaScript.Spoofing or {}
do
    local _SpoofDebug = function(...) if IsModuleDebug(Config.AdvancedFeatures.Debug_Spoofing, "Spoofing") then OmegaScript.Utils.Log("Spoofing", ...) end end
    local _originalType = _P.type
    local _originalTypeof = _P.typeof
    local _typeSpoofRules = {} 
    local _currentSpoofIntensity = 0

    function OmegaScript.Spoofing.SetSpoofingIntensity(level)
        _currentSpoofIntensity = level
        _SpoofDebug("Spoofing intensity set to", level)
    end

    function OmegaScript.Spoofing.SpoofPlayerStats(player, statName, value)
        if not GetAdvCfg("Enable_PlayerStatsSpoofing") or _currentSpoofIntensity < 1 then return end
        _SpoofDebug("Attempting to spoof stat (client-side visual):", statName, "for", player.Name, "to", value, "(conceptual)")
    end

    function OmegaScript.Spoofing.ReportDesyncedClientTick(desyncAmountMs)
        if not GetAdvCfg("Enable_ClientTickSpoofing") or _currentSpoofIntensity < 2 then return end
        local actualTick = _P.tick()
        local reportedTick = actualTick - (desyncAmountMs / 1000)
        _SpoofDebug("Actual tick:", actualTick, "Reporting tick:", reportedTick, "(conceptual)")
        return reportedTick
    end

    function OmegaScript.Spoofing.AddTypeSpoofRule(targetObjectOrTypeStr, spoofedTypeStr)
        if not GetAdvCfg("Enable_TypeofSpoofing") then return end
         _typeSpoofRules[targetObjectOrTypeStr] = spoofedTypeStr
        _SpoofDebug("Added type spoof rule for", targetObjectOrTypeStr, "to report as", spoofedTypeStr)
    end
    
    local function spoofedType(obj)
        if GetAdvCfg("Enable_TypeofSpoofing") and _currentSpoofIntensity > 0 then
            if _typeSpoofRules[obj] then return _typeSpoofRules[obj] end
            local actualOriginalType = _originalType(obj)
            if _typeSpoofRules[actualOriginalType] then return _typeSpoofRules[actualOriginalType] end
        end
        return _originalType(obj)
    end

    local function spoofedTypeof(obj)
         if GetAdvCfg("Enable_TypeofSpoofing") and _currentSpoofIntensity > 0 then
            if _typeSpoofRules[obj] then return _typeSpoofRules[obj] end
            local actualOriginalTypeof = _originalTypeof(obj)
            if _typeSpoofRules[actualOriginalTypeof] then return _typeSpoofRules[actualOriginalTypeof] end
         end
         return _originalTypeof(obj)
    end

    function OmegaScript.Spoofing.InitializeTypeHooks()
        if not GetAdvCfg("Enable_TypeofSpoofing") then return end
        if rawget(_G, "type") == _originalType then type = spoofedType end
        if rawget(_G, "typeof") == _originalTypeof then typeof = spoofedTypeof end
         OmegaScript.AdvancedMemory.GuardMetamethod(_G, "type", function() return spoofedType end)
         OmegaScript.AdvancedMemory.GuardMetamethod(_G, "typeof", function() return spoofedTypeof end)
        _SpoofDebug("Type/Typeof hooks initialized for spoofing.")
    end

    function OmegaScript.Spoofing.ModifyInputEvent(eventData)
        if not GetAdvCfg("Enable_InputEventSpoofing") or _currentSpoofIntensity < 1 then return eventData end
        _SpoofDebug("Modifying input event (conceptual):", eventData)
        return eventData
    end
    
    if GetAdvCfg("Enable_SpoofingModule") then _SpoofDebug("Spoofing module initialized.") end
end

OmegaScript.Resilience = OmegaScript.Resilience or {}
do
    local _ResilienceDebug = function(...) if IsModuleDebug(Config.AdvancedFeatures.Debug_Resilience, "Resilience") then OmegaScript.Utils.Log("Resilience", ...) end end
    local _DisabledFeatures = OmegaScript.InternalCache._DisabledFeatures or {}
    OmegaScript.InternalCache._DisabledFeatures = _DisabledFeatures
    local _WatchdogConnection

    function OmegaScript.Resilience.DynamicallyDisableFeature(featureName)
        if not GetAdvCfg("Enable_DynamicFeatureDisabling") then return end
        _DisabledFeatures[featureName] = true
        OmegaScript.Utils.Notify("Resilience Action", "'" .. featureName .. "' has been dynamically disabled due to recurrent errors.", Config.NotificationIcon, 10)
        _ResilienceDebug("Feature dynamically disabled:", featureName)
        
        local configKey = "Enable_" .. featureName
        if Config[configKey] ~= nil then Config[configKey] = false
        elseif Config.AdvancedFeatures[configKey] ~= nil then Config.AdvancedFeatures[configKey] = false
        end
    end

    function OmegaScript.Resilience.IsFeatureEnabled(featureName)
        if _DisabledFeatures[featureName] then return false end
        
        local configKey = "Enable_" .. featureName
        if Config[configKey] ~= nil then return Config[configKey]
        elseif Config.AdvancedFeatures[configKey] ~= nil then return Config.AdvancedFeatures[configKey]
        end
        return true 
    end

    function OmegaScript.Resilience.WatchdogMonitor()
        if not GetAdvCfg("Enable_WatchdogThread") then return end
        _ResilienceDebug("Watchdog monitor starting...")
        if OmegaScript.Services.RunService and OmegaScript.Services.RunService.Heartbeat then
            _WatchdogConnection = OmegaScript.Services.RunService.Heartbeat:Connect(function(step)
                 if _P.math_fmod(_P.tick(), Config.WatchdogInterval) < step then 
                    _ResilienceDebug("Watchdog check running...")
                    local criticalFunctionsOK = OmegaScript.AntiDetection.VerifyAndRestoreCoreFunctions()
                    local protectedGlobalsOK = OmegaScript.EnhancedBypasses.VerifyProtectedGlobals()
                    if (criticalFunctionsOK or 0) > 0 or (protectedGlobalsOK or 0) > 0 then
                        OmegaScript.Utils.Notify("Watchdog", "Detected and attempted to restore system integrity.", Config.NotificationIcon, 5)
                    end
                 end
            end)
        else
            OmegaScript.Utils.Warn("Resilience", "RunService.Heartbeat not available for Watchdog.")
        end
    end
    
    if GetAdvCfg("Enable_ResilienceModule") then _ResilienceDebug("Resilience module initialized.") end
end

OmegaScript.NetworkInterception = OmegaScript.NetworkInterception or {}
do
    local _NetInterceptDebug = function(...) if IsModuleDebug(Config.AdvancedFeatures.Debug_NetworkInterception, "NetworkInterception") then OmegaScript.Utils.Log("NetIntercept", ...) end end
    local _originalRequestAsync

    function OmegaScript.NetworkInterception.InterceptHttpServiceRequests()
        if not GetAdvCfg("Enable_HttpServiceInterception") then return end
        local HttpService = OmegaScript.Services.HttpService
        if not HttpService or not HttpService.RequestAsync then
            OmegaScript.Utils.Warn("NetIntercept", "HttpService or RequestAsync not available.")
            return
        end
        _originalRequestAsync = HttpService.RequestAsync
        
        local function customRequestAsync(self, requestOptions)
            _NetInterceptDebug("Intercepted HttpService.RequestAsync to:", requestOptions and requestOptions.Url)
            
            return _originalRequestAsync(self, requestOptions)
        end

        local success = OmegaScript.AdvancedMemory.GuardMetamethod(HttpService, "RequestAsync", 
            function(origFunc, self, ...) return customRequestAsync(self, ...) end
        )
        if not success then
             _NetInterceptDebug("Failed to Guard RequestAsync, direct hook.")
            HttpService.RequestAsync = function(self, ...) return customRequestAsync(self, ...) end
        end
        _NetInterceptDebug("HttpService.RequestAsync interception active.")
    end

    function OmegaScript.NetworkInterception.MonitorRemoteCreation()
        if not GetAdvCfg("Enable_RemoteCreationMonitoring") then return end
        _NetInterceptDebug("Monitoring RemoteEvent/Function creation (conceptual).")
    end
    
    if GetAdvCfg("Enable_NetworkInterceptionModule") then _NetInterceptDebug("NetworkInterception module initialized.") end
end

OmegaScript.Environment = OmegaScript.Environment or {}
do
    local _EnvDebug = function(...) if IsModuleDebug(Config.AdvancedFeatures.Debug_Environment, "Environment") then OmegaScript.Utils.Log("Environment", ...) end end
    local _KnownGlobals = {}

    function OmegaScript.Environment.SecureCommonGlobals()
        if not GetAdvCfg("Enable_EnvironmentHardening") then return end
        _EnvDebug("Securing common globals (conceptual).")
    end
    
    function OmegaScript.Environment.DetectUnexpectedGlobalChanges()
        if not GetAdvCfg("Enable_EnvironmentHardening") then return end
        local currentGlobals = _G or _P.getfenv(0)
        if #_KnownGlobals == 0 then 
            for k,_ in _P.pairs(currentGlobals) do _P.table_insert(_KnownGlobals, k) end
            return
        end
        
        for k, _ in _P.pairs(currentGlobals) do
            if not _P.table_find(_KnownGlobals, k) then
                _EnvDebug("Detected new unexpected global variable:", k)
                 OmegaScript.Utils.Notify("Environment Alert", "Unexpected global found: " .. k, Config.NotificationIcon, 5)
                _P.table_insert(_KnownGlobals, k) 
            end
        end
    end
    if GetAdvCfg("Enable_EnvironmentHardening") then _EnvDebug("Environment module initialized.") end
end


local function RunOmegaScript()
    local startTime = _P.tick()
    OmegaScript.Utils.Log("Core", _P.string_format("OmegaScript V4.5 Initializing at %s...", _P.tostring(startTime)))

    if GetAdvCfg("Enable_ConsoleManager") then
        OmegaScript.ConsoleManager.HookConsoleFunctions()
        OmegaScript.ConsoleManager.BypassConsoleDetection()
        OmegaScript.ConsoleManager.PreventConsoleReads()
        OmegaScript.ConsoleManager.AddRule("print", "security_check_xyz", "spoof", "[OS Spoofed Security Ok]")
        OmegaScript.ConsoleManager.AddRule("warn", "potential_exploit_detected", "suppress")
    end

    if GetAdvCfg("Enable_III3_CoreFunctionIntegrity") then
        OmegaScript.AntiDetection.VerifyAndRestoreCoreFunctions()
    end
    if GetAdvCfg("Enable_IV5_EnvironmentManipulationDetection") then
        OmegaScript.AntiDetection.InitEnvironmentManipulationDetection()
    end
     if GetAdvCfg("Enable_EnvironmentHardening") then
        OmegaScript.Environment.SecureCommonGlobals()
    end

    if GetAdvCfg("Enable_II5_ContextAwareBypassActivation") then
        OmegaScript.EnhancedBypasses.RegisterContext("AlwaysActive", function() return true end)
        OmegaScript.EnhancedBypasses.RegisterContext("IsSlapRoyale", function() return game and game.PlaceId == 9431156611 end)
        OmegaScript.EnhancedBypasses.RegisterContext("IsSlapBattlesEtc", function()
            local pid = game and game.PlaceId
            return pid == 11520107397 or pid == 9015014224 or pid == 6403373529 or pid == 124596094333302
        end)
        OmegaScript.EnhancedBypasses.AssignBypassToContext("GameSpecificLogic.ApplyBypasses", "AlwaysActive")
    end
    
    if OmegaScript.Resilience.IsFeatureEnabled("AdonisBypassV1") and Config.Enable_AdonisBypass_GCScanV1 then OmegaScript.AntiCheatBypasses.InitAdonisBypassV1() end
    if OmegaScript.Resilience.IsFeatureEnabled("AdonisBypassV2") and Config.Enable_AdonisBypass_GCScanV2 then OmegaScript.AntiCheatBypasses.InitAdonisBypassV2() end
    if OmegaScript.Resilience.IsFeatureEnabled("DisableCameraConnections") and Config.Enable_AdonisBypass_CameraConnections then OmegaScript.AntiCheatBypasses.DisableCameraConnections() end
    if OmegaScript.Resilience.IsFeatureEnabled("AdonisKickYield") and Config.Enable_AdonisBypass_KickYield then OmegaScript.AntiCheatBypasses.InitAdonisKickYield() end
    if OmegaScript.Resilience.IsFeatureEnabled("AdonisGameMetatableHook") and Config.Enable_AdonisBypass_GameMetatableHook then OmegaScript.AntiCheatBypasses.InitAdonisGameMetatableHook() end

    if GetAdvCfg("Enable_II3_TargetedClientStateSpoofing") then OmegaScript.EnhancedBypasses.SetupDebugGetinfoSpoof() end
    if GetAdvCfg("Enable_IV4_MemorySignatureEvasion") then OmegaScript.AdvancedMemory.EvadeMemorySignatureScans() end
    if GetAdvCfg("Enable_SpoofingModule") and GetAdvCfg("Enable_TypeofSpoofing") then OmegaScript.Spoofing.InitializeTypeHooks() end

    if Config.Enable_Debugging_TableHooks then OmegaScript.DebuggingTools.SetupTableHooks() end
    
    if OmegaScript.Resilience.IsFeatureEnabled("DumpFF2GlobalStats") and Config.Enable_DataExtraction_FF2Dumper then OmegaScript.DataExtraction.DumpFF2GlobalStats() end
    if Config.Enable_NetworkInfo_ReportSpoofed then OmegaScript.NetworkInfo.ReportSpoofedDetails() end
    if Config.Enable_NetworkInfo_FetchActualIP then OmegaScript.NetworkInfo.FetchAndDisplayActualIP() end
    if GetAdvCfg("Enable_NetworkInterceptionModule") and GetAdvCfg("Enable_HttpServiceInterception") then OmegaScript.NetworkInterception.InterceptHttpServiceRequests() end
    if GetAdvCfg("Enable_NetworkInterceptionModule") and GetAdvCfg("Enable_RemoteCreationMonitoring") then OmegaScript.NetworkInterception.MonitorRemoteCreation() end


    if OmegaScript.Resilience.IsFeatureEnabled("GameSpecificBypasses") and Config.Enable_GameSpecific_Bypasses then OmegaScript.GameSpecificLogic.ApplyBypasses() end

    if GetAdvCfg("Enable_III7_MonitoringToolDetection") then 
        local score = OmegaScript.AntiDetection.DetectMonitoringTools()
        if score >= Config.StealthModeActivationThreshold and GetAdvCfg("Enable_III8_StealthModeActivation") then
            OmegaScript.AntiDetection.EnterStealthMode(score)
        end
    end

    if GetAdvCfg("Enable_III6_CriticalHookSelfRepair") and OmegaScript.Services.RunService then
        _P.spawn(function()
            while GetAdvCfg("Enable_III6_CriticalHookSelfRepair") and _P.wait(Config.SelfRepairIntervalSeconds) do
                local currentInterval = Config.SelfRepairIntervalSeconds
                if currentInterval <=0 then break end
                OmegaScript.AntiDetection.RunSelfRepairCycle("timer")
                 if GetAdvCfg("Enable_EnvironmentHardening") then OmegaScript.Environment.DetectUnexpectedGlobalChanges() end
            end
            OmegaScript.Utils.Log("Core", "Self-repair cycle stopped.")
        end)
    end

    if GetAdvCfg("Enable_ResilienceModule") and GetAdvCfg("Enable_WatchdogThread") then
        OmegaScript.Resilience.WatchdogMonitor()
    end
    
    OmegaScript.AntiDetection.SubtleDelay(100)
    local endTime = _P.tick()
    local initTime = endTime - startTime
    OmegaScript.Utils.Notify("OmegaScript V4.5 Initialized", _P.string_format("All enabled modules loaded in %.2fs.", initTime), Config.NotificationIcon, 15)
    OmegaScript.Utils.Log("Core", _P.string_format("OmegaScript V4.5 Initialization complete in %.2fs.", initTime), OmegaScript.Status)

    return OmegaScript
end

local runSuccess, runErrorOrOmega = _P.xpcall(RunOmegaScript, function(err)
    local errorMessage = "[OmegaScript Critical] Initialization Error: " .. _P.tostring(err)
    OmegaScript.PristineFunctions._error(errorMessage .. "\n" .. (_P.debug_traceback and _P.debug_traceback("", 2) or "No traceback"))
    if OmegaScript and OmegaScript.Utils and OmegaScript.Utils.Notify then
        _P.pcall(OmegaScript.Utils.Notify, "OmegaScript Error", "Critical init error. See dev console/logs.", Config.NotificationIcon, 30)
    end
    return errorMessage
end)

if runSuccess then
    OmegaScript.Utils.Log("Core", "Main execution_V4.5 completed successfully.")
    if _G then _G.OmegaScriptInstance_V4_5 = runErrorOrOmega
    else _P.getfenv(0).OmegaScriptInstance_V4_5 = runErrorOrOmega
    end
else
     OmegaScript.PristineFunctions._warn("[OmegaScript V4.5] Main execution failed:", _P.tostring(runErrorOrOmega))
end

if runSuccess then
    return runErrorOrOmega
end
