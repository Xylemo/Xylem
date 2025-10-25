-- LocalScript → StarterPlayer → StarterPlayerScripts
-- Z toggles follow of "ForeverUnwise" (stay N studs toward Z=0).
-- Also watches Workspace.Football: when it ENTERS a radius, click ONCE (no repeats until it leaves and re-enters).

-- ====== Services ======
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

-- ====== Config ======
local TARGET_NAME = "ForeverUnwise"
local followEnabled = false
local followDistance = 10       -- default distance "in front" toward Z=0
local arriveTolerance = 0.5     -- MoveTo reissue threshold

local FOOTBALL_NAME = "Football"
local zoneRadius = 20           -- trigger distance for football click
local rearmOnLeave = true       -- allow another click when it leaves then re-enters

-- ====== Local refs ======
local LOCAL = Players.LocalPlayer
local character = LOCAL.Character or LOCAL.CharacterAdded:Wait()
local myHum = character:WaitForChild("Humanoid")
local myHRP = character:WaitForChild("HumanoidRootPart")

-- ====== Helpers ======
local function getHRP(char) return char and char:FindFirstChild("HumanoidRootPart") end
local function getHum(char) return char and char:FindFirstChildOfClass("Humanoid") end
local function getTargetPlayer() return Players:FindFirstChild(TARGET_NAME) end

-- Compute point in front along Z toward 0, without crossing 0. Lock X to target; keep our current Y.
local function computeFrontPos(targetHRP, myHRP, distance)
	local tpos = targetHRP.Position
	local z = tpos.Z
	if z == 0 then
		return Vector3.new(tpos.X, myHRP.Position.Y, 0)
	end
	local dir = (z > 0) and 1 or -1
	local newZ = z - dir * math.min(distance, math.abs(z))
	return Vector3.new(tpos.X, myHRP.Position.Y, newZ)
end

-- ====== FOLLOW LOOP (RenderStepped) ======
local followConn
local function startFollowing()
	if followConn then followConn:Disconnect() end
	followConn = RunService.RenderStepped:Connect(function()
		if not followEnabled then return end

		local target = getTargetPlayer()
		if not (target and target.Character) then return end
		local targetHRP = getHRP(target.Character)
		if not targetHRP then return end

		local char = LOCAL.Character
		if not char then return end
		local hum = getHum(char)
		local hrp = getHRP(char)
		if not (hum and hrp) then return end

		local goal = computeFrontPos(targetHRP, hrp, followDistance)
		if (hrp.Position - goal).Magnitude > arriveTolerance then
			hum:MoveTo(goal)
		end
	end)
end

local function stopFollowing()
	if followConn then followConn:Disconnect() end
	followConn = nil
end

-- Toggle with Z
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.Z then
		followEnabled = not followEnabled
		if followEnabled then startFollowing() else stopFollowing() end
	end
end)

-- Keep behavior stable across target join/leave
Players.PlayerAdded:Connect(function(p)
	if p.Name == TARGET_NAME and followEnabled then
		startFollowing()
	end
end)
Players.PlayerRemoving:Connect(function(p)
	if p.Name == TARGET_NAME then
		stopFollowing()
	end
end)

-- ====== CHAT LISTENERS: ForeverUnwise can say a number to set distance ======
local function tryParseDistanceFromText(text)
	local numStr = string.match(text or "", "[-%d]+")
	local n = tonumber(numStr)
	if n and n >= 0 then return n end
	return nil
end

do
	local ok, TextChatService = pcall(function() return game:GetService("TextChatService") end)
	if ok and TextChatService then
		local function handleMessage(message)
			if not message then return end
			local src = message.TextSource
			if not src then return end
			local sp = Players:GetPlayerByUserId(src.UserId)
			if not (sp and sp.Name == TARGET_NAME) then return end
			local dist = tryParseDistanceFromText(message.Text)
			if dist then followDistance = dist end
		end

		if TextChatService.MessageReceived then
			TextChatService.MessageReceived:Connect(handleMessage)
		end

		local function connectChannel(ch)
			if ch and ch:IsA("TextChannel") and ch.MessageReceived then
				ch.MessageReceived:Connect(handleMessage)
			end
		end
		for _, ch in ipairs(TextChatService:GetChildren()) do connectChannel(ch) end
		TextChatService.ChildAdded:Connect(connectChannel)
	end
end

local function hookLegacyChattedFor(player)
	if player and player.Chatted then
		player.Chatted:Connect(function(message)
			if player.Name ~= TARGET_NAME then return end
			local dist = tryParseDistanceFromText(message)
			if dist then followDistance = dist end
		end)
	end
end
do
	local tp = getTargetPlayer()
	if tp then hookLegacyChattedFor(tp) end
	Players.PlayerAdded:Connect(function(p)
		if p.Name == TARGET_NAME then hookLegacyChattedFor(p) end
	end)
end

-- ====== FOOTBALL WATCH (enter radius → one click) ======
local football -- current reference
local inside = false

local function getFootball()
	-- find Workspace.Football (BasePart or Model with PrimaryPart)
	local f = Workspace:FindFirstChild(FOOTBALL_NAME)
	if not f then return nil end
	if f:IsA("BasePart") then return f end
	if f:IsA("Model") then
		return f.PrimaryPart or f:FindFirstChildWhichIsA("BasePart")
	end
	return nil
end

local function footballPos()
	if not football then return nil end
	if football:IsA("BasePart") then return football.Position end
	return nil
end

-- If football spawns/destroys, keep reference fresh
Workspace.ChildAdded:Connect(function(child)
	if child.Name == FOOTBALL_NAME then
		football = getFootball()
		inside = false
	end
end)
Workspace.ChildRemoved:Connect(function(child)
	if child.Name == FOOTBALL_NAME then
		football = nil
		inside = false
	end
end)

football = getFootball()

RunService.RenderStepped:Connect(function()
	if not football or not football.Parent then
		football = getFootball()
		inside = false
	else
		local fpos = footballPos()
		if fpos and myHRP then
			local dist = (fpos - myHRP.Position).Magnitude
			if dist <= zoneRadius then
				if not inside then
					inside = true
					mouse1click()
					print(("[CLICK] %s entered %.0f-stud zone (%.1f studs)")
				end
			else
				if inside and rearmOnLeave then
					inside = false
				end
			end
		end
	end
end)
