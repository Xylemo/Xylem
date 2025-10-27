-- LocalScript → StarterPlayerScripts
-- Z toggles follow of "ForeverUnwise".
-- Starts at (X=0, Z=-10). "switch" flips both signs.
-- Target chat can set offsets:
--   "10"                -> Z = +10
--   "-10 5"             -> X = -10, Z = +5
--   "-10, 5" / "-10 then 5" / "x -10 z 5" -> also parsed
-- Also watches Workspace.Football and presses 'C' once when ball enters zone.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LOCAL = Players.LocalPlayer
local character = LOCAL.Character or LOCAL.CharacterAdded:Wait()
local myHum = character:WaitForChild("Humanoid")
local myHRP = character:WaitForChild("HumanoidRootPart")

-- ===== FOLLOW CONFIG =====
local TARGET_NAME = "ForeverUnwise"
local followEnabled = false
local arriveTolerance = 0.5

-- World-space offsets from target (X,Z), Y stays at your current height
local offsetX = -10
local offsetZ = 5 -- start on negative Z side

-- ===== FOOTBALL CONFIG =====
local FOOTBALL_NAME = "Football"
local zoneRadius = 35
local rearmOnLeave = true

local football
local inside = false

-- ===== HELPERS =====
local function getHRP(char) return char and char:FindFirstChild("HumanoidRootPart") end
local function getHum(char) return char and char:FindFirstChildOfClass("Humanoid") end
local function getTargetPlayer() return Players:FindFirstChild(TARGET_NAME) end

local function computeOffsetPos(targetHRP, myHRP)
	local tpos = targetHRP.Position
	return Vector3.new(tpos.X + offsetX, myHRP.Position.Y, tpos.Z + offsetZ)
end

-- ===== FOLLOW LOOP =====
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
		local hum, hrp = getHum(char), getHRP(char)
		if not (hum and hrp) then return end

		local goal = computeOffsetPos(targetHRP, hrp)
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

-- ===== CHAT COMMAND PARSING =====
local function extractNumbersAny(text)
	-- returns array of numbers (supports signs/decimals)
	local nums = {}
	for num in string.gmatch(text or "", "[-+]?%d+%.?%d*") do
		local n = tonumber(num)
		if n then table.insert(nums, n) end
	end
	return nums
end

local function parseExplicitXZ(text)
	-- Parses patterns like "x -10 z 5" in any order; returns x,z or nil
	local lx = string.lower(text or "")
	local x = string.match(lx, "x%s*([-+]?%d+%.?%d*)")
	local z = string.match(lx, "z%s*([-+]?%d+%.?%d*)")
	if x or z then
		return tonumber(x), tonumber(z)
	end
	return nil
end

local function handleMessageFromForever(msgText)
	if not msgText then return end
	local lowered = msgText:lower()

	-- flip both signs
	if lowered:find("switch") then
		offsetX, offsetZ = -offsetX, -offsetZ
		print(("[FOLLOW] Switched: offsetX=%g, offsetZ=%g"):format(offsetX, offsetZ))
		return
	end

	-- Try "x -10 z 5" style
	local exX, exZ = parseExplicitXZ(msgText)
	if exX or exZ then
		if exX then offsetX = exX end
		if exZ then offsetZ = exZ end
		print(("[FOLLOW] Set explicit offsets: X=%g, Z=%g"):format(offsetX, offsetZ))
		return
	end

	-- Try two numbers in order (e.g., "-10 5", "-10, 5", "-10 then 5")
	local nums = extractNumbersAny(msgText)
	if #nums >= 2 then
		offsetX, offsetZ = nums[1], nums[2]
		print(("[FOLLOW] Set offsets from pair: X=%g, Z=%g"):format(offsetX, offsetZ))
		return
	end

	-- Back-compat: single number -> Z offset
	if #nums == 1 then
		offsetZ = nums[1]
		print(("[FOLLOW] Set Z offset: Z=%g (X remains %g)"):format(offsetZ, offsetX))
		return
	end
end

-- ===== CHAT LISTENERS =====
local ok, TextChatService = pcall(function() return game:GetService("TextChatService") end)
if ok and TextChatService then
	local function onMsg(m)
		local src = m.TextSource
		if not src then return end
		local sp = Players:GetPlayerByUserId(src.UserId)
		if sp and sp.Name == TARGET_NAME then
			handleMessageFromForever(m.Text)
		end
	end
	if TextChatService.MessageReceived then
		TextChatService.MessageReceived:Connect(onMsg)
	end
end

-- Legacy Player.Chatted
local function hookLegacy(p)
	if p and p.Chatted then
		p.Chatted:Connect(function(msg)
			if p.Name == TARGET_NAME then
				handleMessageFromForever(msg)
			end
		end)
	end
end
local tp = getTargetPlayer()
if tp then hookLegacy(tp) end
Players.PlayerAdded:Connect(function(p)
	if p.Name == TARGET_NAME then hookLegacy(p) end
end)

-- ===== FOOTBALL WATCH / CLICK =====
local function getFootball()
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
	if football and football.Parent then
		local fpos = footballPos()
		if fpos and myHRP then
			local dist = (fpos - myHRP.Position).Magnitude
			if dist <= zoneRadius then
				if not inside then
					inside = true
					-- NOTE: keypress/keyrelease are executor-provided; keep as-is.
					keypress(0x43)    -- 'C'
					task.wait(0.1)
					keyrelease(0x43)
					print(("[CLICK] Football entered %.0f-stud zone (%.1f studs)"):format(zoneRadius, dist))
				end
			else
				if inside and rearmOnLeave then
					inside = false
				end
			end
		end
	else
		football = getFootball()
		inside = false
	end
end)
