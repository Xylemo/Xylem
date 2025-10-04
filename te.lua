-- ===================== CONFIG =====================
local Y_POS = 257

local RespawnOne = {
	Vector3.new(-449.31, Y_POS, 290.23),
	Vector3.new(-262.46, Y_POS, 299.86),
	Vector3.new(-70.29, Y_POS, 313.01),
	Vector3.new(63.97, Y_POS, 449.49),
	Vector3.new(116.80, Y_POS, 452.92)
}

local ToBuy = {
	Vector3.new(112.38, Y_POS, 443.16),
	Vector3.new(-113.96, Y_POS, 299.66),
	Vector3.new(-221.33, Y_POS, 299.70),
	Vector3.new(-220.63, Y_POS, 189.18),
	Vector3.new(-129.87, Y_POS, 188.57),
	Vector3.new(-135.59, Y_POS, 157.38)
}

local ToFarm = {
	Vector3.new(-130.53, Y_POS, 189.29),
	Vector3.new(-220.83, Y_POS, 188.63),
	Vector3.new(-221.41, Y_POS, 298.65),
	Vector3.new(-94.18, Y_POS, 303.08),
	Vector3.new(172, Y_POS, 438.21),
	Vector3.new(172, Y_POS, 533.32)
}

local ToSafe = {
	Vector3.new(172, Y_POS, 459.82),
	Vector3.new(120.68, Y_POS, 461.03)
}

local DIST_ARRIVE = 0.5
local FLIGHT_SPEED = 50

-- ==================================================
local running = false

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Vehicles = workspace:FindFirstChild("Vehicles")

local Player = Players.LocalPlayer
local Character, HRP, Humanoid
local diedMonitor
local potWatcher
local lookingForRespawn = false
local cancelFlight = false
local runRoute
local debugMode = false

-- Remotes
local rfGet = ReplicatedStorage:FindFirstChild("Get", true)
local reSend = (ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Send"))
             or ReplicatedStorage:FindFirstChild("Send", true)

if not (rfGet and rfGet:IsA("RemoteFunction")) then warn("RemoteFunction 'Get' not found."); return end
if not (reSend and reSend:IsA("RemoteEvent")) then warn("RemoteEvent 'Send' not found."); return end

-- Optional counter table
local CounterTable = (function()
	for _, Obj in getgc and getgc(true) or {} do
		if typeof(Obj) == "table" and rawget(Obj, "event") and rawget(Obj, "func") then
			return Obj
		end
	end
end)()

-- wrapper
local function CallRemote(remote, ...)
	if not remote or typeof(remote) ~= "Instance" then return nil end

	if remote.ClassName == "RemoteEvent" then
		if CounterTable and type(CounterTable.event) == "number" then
			CounterTable.event += 1
			return remote:FireServer(CounterTable.event, ...)
		else
			return remote:FireServer(...)
		end
	elseif remote.ClassName == "RemoteFunction" then
		if CounterTable and type(CounterTable.func) == "number" then
			CounterTable.func += 1
			return remote:InvokeServer(CounterTable.func, ...)
		else
			return remote:InvokeServer(...)
		end
	end
end

local function findGuidByItemName(name)
	local pg = Player:FindFirstChild("PlayerGui")
	local inventoryUI = pg:FindFirstChild("Items"):FindFirstChild("ItemsHolder"):FindFirstChild("ItemsScrollingFrame")
	for _, child in ipairs(inventoryUI:GetChildren()) do
		local itemName = child:FindFirstChild("ItemName")
		if itemName and itemName:IsA("TextLabel") and itemName.Text == name then
			return child.Name
		end
	end
	return nil
end

local function walkTo(targetPos: Vector3, timeout: number?)
	timeout = timeout or 5
	local arrived = false
	local humanoid = Character:WaitForChild("Humanoid")
	if not humanoid then return false end
	if HRP then HRP.Anchored = false end

	humanoid:MoveTo(targetPos)

	local conn
	conn = humanoid.MoveToFinished:Connect(function(ok)
		arrived = ok
	end)

	local start = tick()
	while not arrived and tick() - start < timeout do
		task.wait()
	end

	if conn then conn:Disconnect() end
	if not arrived then
		humanoid:Move(Vector3.zero)
		warn(("walkTo timed out after %ds at position %s"):format(timeout, tostring(targetPos)))
	end

	return arrived
end

local function inVehicle()
	local humanoid = Character:WaitForChild("Humanoid")
	for _, d in ipairs(Vehicles:GetDescendants()) do
		if d:IsA("VehicleSeat") and d.Occupant == humanoid then
			return true
		end
	end
	return false
end

-- === Cooldown check ===
local function waitForVehicle()
	local nextSpawn = Player:GetAttribute("SpawnVehicleNext")
	if not nextSpawn then
		print("⚠️ No cooldown attribute found.")
		return
	end

	local now = os.time()
	local remaining = nextSpawn - now

	if remaining > 0 then
		print(("⏳ Waiting %d seconds until you can spawn again..."):format(remaining))
		task.wait(remaining)
		print("✅ Cooldown finished, you can spawn now.")
	else
		print("✅ Already off cooldown, you can spawn now.")
	end
end

local function spawnAndEnter()
	local vehicle = findGuidByItemName("BMX")
	if not vehicle then return end

	CallRemote(rfGet, "toggle_equip_item", vehicle)

	local input
	for _, d in ipairs(Vehicles:GetDescendants()) do
		if d:IsA("ProximityPrompt") and d.Enabled and d.ObjectText == Player.Name .. "'s car" then
			input = d
			break
		end
	end

	if input and not inVehicle() then
		walkTo(input.Parent.Parent.Position)
		task.wait(0.1)
		input:InputHoldBegin()
	end
end

local function flyTo(targetPos: Vector3)
	local arrived = false
	cancelFlight = false
	
	while not inVehicle() and not cancelFlight do
		print("Not in vehicle, trying to spawn and enter...")
		spawnAndEnter()
		task.wait(0.1)
	end
	

	local conn
	conn = RunService.Heartbeat:Connect(function(dt)
		if not HRP or cancelFlight then
			if conn then conn:Disconnect() end
			return
		end

		local cur = HRP.Position
		local d = (targetPos - cur).Magnitude
		if d <= DIST_ARRIVE then
			HRP.Velocity, HRP.RotVelocity = Vector3.zero, Vector3.zero
			if conn then conn:Disconnect() end
			arrived = true
			return
		end

		local dir = (targetPos - cur).Unit
		HRP.Velocity = dir * FLIGHT_SPEED
		HRP.RotVelocity = Vector3.zero
		HRP.CFrame = HRP.CFrame:Lerp(CFrame.lookAt(cur, cur + dir), math.clamp(dt * 5, 0, 1))
	end)

	while not arrived and not cancelFlight do
		task.wait()
	end

	if cancelFlight and conn then conn:Disconnect() end
	HRP.Velocity, HRP.RotVelocity = Vector3.zero, Vector3.zero
end

-- === Respawn logic with Humanoid.Died ===
local function SetCharacter(char)
	Character = char
	HRP = char:WaitForChild("HumanoidRootPart")
	Humanoid = char:WaitForChild("Humanoid")

	if diedMonitor then
		diedMonitor:Disconnect()
	end

	diedMonitor = RunService.Heartbeat:Connect(function()
		if not lookingForRespawn and Humanoid and Humanoid.Health <= 0 then
			print("Player health is 0. Pausing route.")
			lookingForRespawn = true
			cancelFlight = true
			running = false
	
			task.wait(7)
			CallRemote(ReplicatedStorage.Remotes.Send, "death_screen_request_respawn")
	
			task.spawn(function()
				repeat task.wait() until Player.Character and Player.Character:FindFirstChild("Humanoid") and Player.Character.Humanoid.Health > 0
				wait(1)
				SetCharacter(Player.Character)
				print("✅ Respawn detected. Restarting route.")
				wait(0.1)
				--Vector3.new(-449.31, Y_POS, 290.23)
				
				local targetPos = Vector3.new(-449.31, Y_POS, 290.23)
				local maxDistance = 15 -- acceptable distance in studs
				
				if (HRP.Position - targetPos).Magnitude <= maxDistance then
					print("Made It")
					waitForVehicle()
					for _, wp in ipairs(RespawnOne) do
						flyTo(wp)
					end
					HRP.Anchored = true
					running = true
					lookingForRespawn = false
					local ok1, res1 = pcall(function()
						return CallRemote(rfGet, "exit_seat")
					end)
					HRP.Anchored = false
					VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftShift, false, game)
					walkTo(Vector3.new(120.31, Y_POS, 481.83))
					VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftShift, false, game)
					runRoute()
				else
				CallRemote(ReplicatedStorage.Remotes.Send, "request_respawn")
				end
				lookingForRespawn = false
			end)
			diedMonitor:Disconnect()
		end
	end)
end

if Player.Character then SetCharacter(Player.Character) end
Player.CharacterAdded:Connect(SetCharacter)

-- === Farming helpers ===
local function FindPots()
	local housing = workspace:WaitForChild("Map"):WaitForChild("Tiles"):WaitForChild("PrestigeDealerAndHousing")
	local house
	for _, obj in ipairs(housing:GetDescendants()) do
		if obj:IsA("ObjectValue") and obj.Value == Player then
			house = obj.Parent.Parent
		end
	end
	if not house then return {} end
	local farming = house:FindFirstChild("FarmingPots")
	if not farming then return {} end
	local pots = {}
	for _, obj in ipairs(farming:GetDescendants()) do
		if obj.Name == "Pot" and #obj:GetChildren() > 0 then
			obj.Parent:FindFirstChild("PotPlaceholder"):FindFirstChild("BillboardGui").MaxDistance = 1000
			table.insert(pots, obj.Parent)
		end
	end
	return pots
end

local function equipTool(toolName)
	local backpack = Player:WaitForChild("Backpack")
	local Character = Player.Character or Player.CharacterAdded:Wait()

	local tool = backpack:FindFirstChild(toolName)
	if tool and tool:IsA("Tool") then
		tool.Parent = Character
		print("Equipped:", tool.Name)
	else
		print("Tool not found in backpack:", toolName)
	end
end

local function startFarming()
	local pots = FindPots()
	for _, pot in ipairs(pots) do

		HRP.Anchored = false
		
		flyTo(Vector3.new(172, Y_POS, pot.PotPlaceholder.Position.Z))
		
		HRP.Anchored = true
		local ok3, res3 = pcall(function()
			return CallRemote(reSend, "harvest", pot)
		end)
	
		print(pot)
		local backpack = Player:WaitForChild("Backpack")
		local Character = Player.Character or Player.CharacterAdded:Wait()
		
		
		if (not Player.Character:FindFirstChild("RegularSoil") and not backpack:FindFirstChild("RegularSoil")) then
			local regularSoil = findGuidByItemName("RegularSoil")
			CallRemote(rfGet, "toggle_equip_item", regularSoil)
			print("Need Soil")
		end
		
		wait(0.01)
		
		equipTool("RegularSoil")
		local soil = Player.Character:FindFirstChild("RegularSoil")
		CallRemote(reSend, "add_to_pot", "soil", pot, soil)
		
		if (not Player.Character:FindFirstChild("SunflowerSeeds") and not backpack:FindFirstChild("SunflowerSeeds")) then
			local sunflowerSeeds = findGuidByItemName("SunflowerSeeds")
			CallRemote(rfGet, "toggle_equip_item", sunflowerSeeds)
			print("Need Seed")
		end
		
		wait(0.01)
		equipTool("SunflowerSeeds")
		local seeds = Player.Character:FindFirstChild("SunflowerSeeds")
		CallRemote(reSend, "add_to_pot", "seed", pot, seeds)
		
		HRP.Anchored = false
	end
end

local function buyFarm(amount)
	local Hardware = workspace:FindFirstChild("ShopZone_Hardware")
	for i = 1, amount do
		local ok1, res1 = pcall(function()
			return CallRemote(rfGet, "purchase_consumable", Hardware, "SunflowerSeeds")
		end)
		if not ok1 then warn("Failed to buy seeds:", res1) end

		local ok2, res2 = pcall(function()
			return CallRemote(rfGet, "purchase_consumable", Hardware, "RegularSoil")
		end)
		if not ok2 then warn("Failed to buy soil:", res2) end
	end
end

local function Despawn()
	local vehicle = findGuidByItemName("BMX")
	CallRemote(rfGet, "toggle_equip_item", vehicle)
end

-- === Route ===
runRoute = function()
	waitForVehicle()

	Despawn()
	task.wait(0.1)
	VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftShift, false, game)
	walkTo(Vector3.new(120.22, Y_POS, 478.11))
	walkTo(Vector3.new(114.64, Y_POS, 450.22))
	VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftShift, false, game)

	for _, wp in ipairs(ToBuy) do
		if not running then break end
		flyTo(wp)
	end

	HRP.Anchored = true
	if not debugMode then buyFarm(#FindPots()) end
	HRP.Anchored = false

	for _, wp in ipairs(ToFarm) do
		if not running then break end
		flyTo(wp)
	end

	if not debugMode then startFarming() end

	for _, wp in ipairs(ToSafe) do
		if not running then break end
		flyTo(wp)
	end

	local lastSafe = ToSafe[#ToSafe]
	flyTo(lastSafe)

	task.wait(0.1)
	CallRemote(rfGet, "exit_seat")

	VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftShift, false, game)
	walkTo(Vector3.new(120.31, Y_POS, 481.83))
	VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftShift, false, game)
end

-- === Pot watcher ===
local function watchPotForDone()
	local housing = workspace:WaitForChild("Map"):WaitForChild("Tiles"):WaitForChild("PrestigeDealerAndHousing")
	local house
	for _, obj in ipairs(housing:GetDescendants()) do
		if obj:IsA("ObjectValue") and obj.Value == Player then
			house = obj.Parent.Parent
		end
	end
	if not house then return end
	local farming = house:FindFirstChild("FarmingPots")
	if not farming then return end

	local targetPot
	for _, obj in ipairs(farming:GetDescendants()) do
		if obj.Name == "Pot" and #obj:GetChildren() > 0 then
			targetPot = obj
			break
		end
	end
	if not targetPot then return end

	local gui = targetPot.Parent:FindFirstChild("PotPlaceholder"):FindFirstChild("BillboardGui")
	if not gui then return end
	local label = gui:FindFirstChild("TextLabel")
	if not label or not label:IsA("TextLabel") then return end
	
	if label.Text == "Done" and running then
		task.spawn(runRoute)
	end
	
	if running then
		task.spawn(runRoute)
	end

	if potWatcher then potWatcher:Disconnect() end
	potWatcher = label:GetPropertyChangedSignal("Text"):Connect(function()
		if label.Text == "Done" and running then
			print("Pot finished growing — starting route")
			task.spawn(runRoute)
		end
	end)
	print("Now watching a pot's TextLabel for 'Done'")
end

-- === Keybind ===
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.G then
		HRP.Anchored = false
		running = not running
		print("Route running:", running)
		if running then
			watchPotForDone()
		end
	end
end)
