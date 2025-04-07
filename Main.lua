
local moneyToKeep = 3850
local distToAtm = 2

local Settings = {
	fly = false,
	flyspeed = 100,
}

local Y_POS = 257

local Waypoints = {
	Vector3.new(-215.79, Y_POS, 390),
	Vector3.new(-219.49, Y_POS, 459.57),
	Vector3.new(-196.39, Y_POS, 457.82), -- ATM
	Vector3.new(-193.66, Y_POS, 556.77),
	Vector3.new(-103.93, Y_POS, 603.87),
	Vector3.new(172.84, Y_POS, 601.10),
	Vector3.new(170.51, Y_POS, 487.91), -- ATM
	Vector3.new(166.54, Y_POS, 451.00),
	Vector3.new(-109.29, Y_POS, 447.46), -- ATM
	Vector3.new(-105.32, Y_POS, 400.29),
	Vector3.new(-55.45, Y_POS, 348.64),
	Vector3.new(-55.25, Y_POS, 205.38),
	Vector3.new(-90.54, Y_POS, 157.49), -- ATM
	Vector3.new(-48.55, Y_POS, 110.28),
	Vector3.new(61.20, Y_POS, 13.36),
	Vector3.new(444.13, Y_POS, 8.96),
	Vector3.new(452.80, Y_POS, 33.89), -- ATM
	Vector3.new(351.39, Y_POS, -28.65),
	Vector3.new(320.61, Y_POS, -169.26),
	Vector3.new(181.84, Y_POS, -239.54), -- ATM
	Vector3.new(136.79, Y_POS, -194.92),
	Vector3.new(-40.27, Y_POS, -208.98),
	Vector3.new(-137.80, Y_POS, -242.11),
	Vector3.new(-197.05, Y_POS, -251.61), -- ATM
	Vector3.new(-212.53, Y_POS, -327.10),
	Vector3.new(-165.04, Y_POS, -363.87),
	Vector3.new(-59.59, Y_POS, -400.53),
	Vector3.new(-58.49, Y_POS, -488.82),
	Vector3.new(-137.88, Y_POS, -530.52), -- ATM
	Vector3.new(-58.91, Y_POS, -535.45),
	Vector3.new(53.14, Y_POS, -657.03),
	Vector3.new(143.29, Y_POS, -667.93),
	Vector3.new(180.52, Y_POS, -638.72), -- ATM
	Vector3.new(141.56, Y_POS, -668.77),
	Vector3.new(-189.94, Y_POS, -669.24),
	Vector3.new(-301.03, Y_POS, -554.05),
	Vector3.new(-369.79, Y_POS, -435.18),
	Vector3.new(-415.92, Y_POS, -325.62),
	Vector3.new(-452.67, Y_POS, -244.53),
	Vector3.new(-458.28, Y_POS, -221.67), -- ATM
	Vector3.new(-432.04, Y_POS, -134.83),
	Vector3.new(-391.47, Y_POS, -56.96),
	Vector3.new(-383.22, Y_POS, 45.81),
	Vector3.new(-507.25, Y_POS, 250.62),
	Vector3.new(-533.68, Y_POS, 301.05),
	Vector3.new(-540.32, Y_POS, 339.45), -- ATM
	Vector3.new(-483.84, Y_POS, 294.57),
	Vector3.new(-217.22, Y_POS, 297.57),
	Vector3.new(-215.79, Y_POS, 390)
}




local atm1, atm2, atm3, atm4, atm5, atm6, atm7, atm8, atm9, atm10, atm11 = 120, 68, 73, 130, 90, 86, 86, 85, 169, 135, 120

local ATMStops = {
	{position = Vector3.new(-196.39, Y_POS, 457.82), speed = atm1},
	{position = Vector3.new(170.51, Y_POS, 487.91), speed = atm2},
	{position = Vector3.new(-109.29, Y_POS, 447.46), speed = atm3},
	{position = Vector3.new(-90.54, Y_POS, 157.49), speed = atm4},
	{position = Vector3.new(452.80, Y_POS, 33.89), speed = atm5},
	{position = Vector3.new(181.84, Y_POS, -239.54), speed = atm6},
	{position = Vector3.new(-197.05, Y_POS, -251.61), speed = atm7},
	{position = Vector3.new(-137.88, Y_POS, -530.52), speed = atm8},
	{position = Vector3.new(180.52, Y_POS, -638.72), speed = atm9},
	{position = Vector3.new(-458.28, Y_POS, -221.67), speed = atm10},
	{position = Vector3.new(-540.32, Y_POS, 339.45), speed = atm11}
}




local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")


local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local Camera = workspace.CurrentCamera
local Character, HRP, Humanoid
local tookDamage = false
local FLIGHT_SPEED = 75


local Props = workspace:WaitForChild("Map"):WaitForChild("Props")
local highestStep = 0
local GetStep = 0
local running = false
local TookDamage = false
local FlightVelocity = Vector3.zero
local Connection
local runRoute


local CounterTable = (function()
	for _, Obj in getgc and getgc(true) or {} do
		if (typeof(Obj) == 'table' and rawget(Obj, "event") and rawget(Obj, "func")) then
			return Obj
		end
	end
end)()

local CallRemote = function(remote, ...)
	if (not CounterTable) then return end
	if (remote.ClassName == 'RemoteEvent') then
		CounterTable.event += 1
		remote:FireServer(CounterTable.event, ...)
	end
	if (remote.ClassName == 'RemoteFunction') then
		CounterTable.func += 1
		remote:InvokeServer(CounterTable.func, ...)
	end
end



local diedMonitor

local function SetCharacter(char)
	Character = char
	HRP = char:WaitForChild("HumanoidRootPart")
	Humanoid = char:WaitForChild("Humanoid")
	Props = workspace:WaitForChild("Map"):WaitForChild("Props")

	tookDamage = false

	Humanoid.HealthChanged:Connect(function(newHealth)
		if running and newHealth < Humanoid.Health then
			tookDamage = true
		end
	end)

	if diedMonitor then
		diedMonitor:Disconnect()
	end

diedMonitor = RunService.Heartbeat:Connect(function()
	if running and Humanoid and Humanoid.Health <= 0 then
		print("Player health is 0. Pausing route.")
		running = false

		task.wait(7)
		CallRemote(ReplicatedStorage.Remotes.Send, "death_screen_request_respawn")

		task.spawn(function()
			repeat task.wait() until Player.Character and Player.Character:FindFirstChild("Humanoid") and Player.Character.Humanoid.Health > 0
			wait(1)
			SetCharacter(Player.Character)
			print("✅ Respawn detected. Restarting route.")
			running = true
			task.spawn(function()
				while running do
					runRoute()
				end
			end)
		end)

		diedMonitor:Disconnect()
	end
end)
end


local function getBestHackTool()
	local Player = game:GetService("Players").LocalPlayer
	local gui = Player:WaitForChild("PlayerGui")
	local skillsGui = gui:WaitForChild("Skills")

	local swiperCount = nil
	for _, descendant in ipairs(skillsGui:GetDescendants()) do
		if descendant:IsA("TextLabel") and descendant.Text:find("Swiper:") then
			local countStr = descendant.Text:match("Swiper:%s*(%d+)")
			if countStr then
				swiperCount = tonumber(countStr)
				break
			end
		end
	end

	if not swiperCount then
		warn("Could not find swiper skill.")
		return nil, nil
	end

	if swiperCount < 12 then
		return "Basic Hack Tool", "HackToolBasic"
	elseif swiperCount < 50 then
		return "Pro Hack Tool", "HackToolPro"
	elseif swiperCount < 90 then
		return "Ultimate Hack Tool", "HackToolUltimate"
	else
		return "Quantum Hack Tool", "HackToolQuantum"
	end
end


if Player.Character then SetCharacter(Player.Character) end
Player.CharacterAdded:Connect(SetCharacter)

local function HackATM()
    local toolName, toolID = getBestHackTool()
	local closestATM, shortestDist = nil, math.huge
	for _, model in ipairs(Props:GetDescendants()) do
		if model:IsA("Model") and model.Name:lower() == "atm" then
			local primary = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
			if primary then
				local dist = (HRP.Position - primary.Position).Magnitude
				if dist < shortestDist then
					shortestDist, closestATM = dist, model
				end
			end
		end
	end
	if closestATM then
		highestStep += 1
        CallRemote(ReplicatedStorage.Remotes.Send, "request_begin_hacking", closestATM, toolID)
		task.wait(1)
		highestStep += 1
        CallRemote(ReplicatedStorage.Remotes.Send, "atm_win", closestATM)
	end
end

local function purchaseProHackToolUpToEleven()

    local toolName, toolID = getBestHackTool()

	local pg = Player:WaitForChild("PlayerGui")
	local inventoryUI = pg:WaitForChild("Items"):WaitForChild("ItemsHolder"):WaitForChild("ItemsScrollingFrame")

	local totalOwned = 0

	for _, itemFrame in ipairs(inventoryUI:GetChildren()) do
		if itemFrame:IsA("ImageButton") then
			local itemNameLabel = itemFrame:FindFirstChild("ItemName")
			if itemNameLabel and itemNameLabel:IsA("TextLabel") and itemNameLabel.Text == toolID then
				totalOwned += 1
			end
		end
	end

	local needed = 11 - totalOwned
	if needed <= 0 then
		print("Already have 11.")
		return true
	end

    local moneyLabel = pg.TopRightHud.Holder.Frame.MoneyTextLabel
	local moneyText = moneyLabel and moneyLabel.Text
	local moneyNumber = tonumber(moneyText:match("%d+")) or 0

	if moneyNumber < moneyToKeep then
		print("💸 Not enough money to buy tools. Need to withdraw.")
		return false -- triggers a withdraw
	end

	for i = 1, needed do
		print(`Buying #{i}`)
		CallRemote(ReplicatedStorage.Remotes.Get, "purchase_consumable", workspace.ConsumableShopZone_Illegal, toolID)
	end

    return true
end




local function flyTo(targetPos)
	local arrived = false
	local connection
	connection = RunService.Heartbeat:Connect(function(dt)
		if not running then
			HRP.Velocity = Vector3.zero
			connection:Disconnect()
			arrived = true
			return
		end
		local currentPos = HRP.Position
		local dist = (targetPos - currentPos).Magnitude
		if dist < distToAtm then
			HRP.Velocity = Vector3.zero
			connection:Disconnect()
			arrived = true
			return
		end
		local dir = (targetPos - currentPos).Unit
		HRP.Velocity = dir * FLIGHT_SPEED
		HRP.RotVelocity = Vector3.zero
		HRP.CFrame = HRP.CFrame:Lerp(
			CFrame.lookAt(currentPos, currentPos + dir),
			math.clamp(dt * 5, 0, 1)
		)
	end)
	while not arrived do task.wait() end
end

local function depositMoney()
	local pg = Player:WaitForChild("PlayerGui")
	local MoneyTextLabel = pg.TopRightHud.Holder.Frame.MoneyTextLabel
	local MoneyText = MoneyTextLabel and MoneyTextLabel.Text

	if not MoneyText then
		warn("❌ Could not read MoneyText")
		return
	end

	local cleaned = MoneyText:gsub("[^%d]", "")
	local MoneyNumber = tonumber(cleaned)

	if not MoneyNumber then
		warn("❌ Failed to parse money amount from text:", MoneyText)
		return
	end

	if MoneyNumber <= 0 then
		print("💰 No money to deposit.")
		return
	end

	print("💸 Depositing:", MoneyNumber)
	CallRemote(ReplicatedStorage.Remotes.Get, "transfer_funds", "hand", "bank", MoneyNumber)
end




local function flyToFirst(targetPos)
	local arrived = false
	local connection

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	raycastParams.IgnoreWater = true

	local ignoreList = {}
	if Player.Character then
		for _, part in ipairs(Player.Character:GetDescendants()) do
			if part:IsA("BasePart") then
				table.insert(ignoreList, part)
			end
		end
	end
	local vegetationFolder = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Vegetation")
	if vegetationFolder then
		for _, obj in ipairs(vegetationFolder:GetDescendants()) do
			table.insert(ignoreList, obj)
		end
	end
	raycastParams.FilterDescendantsInstances = ignoreList

	local forwardCheckDistance = 9
    local speedgoback = 100
	local verticalRayStep = 2
	local maxVerticalHeight = 50
	local clearanceAbove = 5
	local descentCheckDepth = 10
	local minStopDistance = 4
	local descentDelay = 0.5

	local ascentTargetY = nil
	local lastAscentTime = 0

	connection = RunService.Heartbeat:Connect(function(dt)
		if not running or not HRP then
			HRP.Velocity = Vector3.zero
			if connection then connection:Disconnect() end
			arrived = true
			return
		end

		local pos = HRP.Position
		local toTarget = targetPos - pos
		local dist = toTarget.Magnitude
		local dir = toTarget.Unit

		if dist < minStopDistance then
			HRP.Velocity = Vector3.zero
			if connection then connection:Disconnect() end
			arrived = true
			return
		end

		local forwardPos = pos + Vector3.new(dir.X, 0, dir.Z).Unit * forwardCheckDistance

		if not ascentTargetY then
			for height = 0, maxVerticalHeight, verticalRayStep do
				local rayOrigin = forwardPos + Vector3.new(0, height, 0)
				local rayResult = workspace:Raycast(rayOrigin, Vector3.new(0, 1, 0), raycastParams)
				if rayResult then
					local partTop = rayResult.Instance.Position.Y + rayResult.Instance.Size.Y / 2
					ascentTargetY = partTop + clearanceAbove
					break
				end
			end
		end

		if ascentTargetY and pos.Y < ascentTargetY then
			local flatDir = Vector3.new(dir.X, 0, dir.Z).Unit * (speedgoback * 0.2)
			HRP.Velocity = Vector3.new(flatDir.X, speedgoback, flatDir.Z)
			return
		elseif ascentTargetY and pos.Y >= ascentTargetY then
			ascentTargetY = nil
			lastAscentTime = tick()
		end

local canDescendNow = tick() - lastAscentTime >= descentDelay
local backOffset = -dir.Unit * 3
local behindPos = pos + Vector3.new(backOffset.X, 0, backOffset.Z)
local rayBehind = workspace:Raycast(behindPos, Vector3.new(0, -descentCheckDepth, 0), raycastParams)
local downRay = workspace:Raycast(pos, Vector3.new(0, -descentCheckDepth, 0), raycastParams)

local isSafeToDescend = true 
if downRay and rayBehind then
	isSafeToDescend = (pos.Y - downRay.Position.Y) > 6 and (pos.Y - rayBehind.Position.Y) > 6
elseif downRay then
	isSafeToDescend = (pos.Y - downRay.Position.Y) > 6
elseif rayBehind then
	isSafeToDescend = (pos.Y - rayBehind.Position.Y) > 6
end

if canDescendNow and isSafeToDescend and pos.Y > targetPos.Y + 2 then
	local flatDir = Vector3.new(dir.X, 0, dir.Z).Unit
	HRP.Velocity = Vector3.new(flatDir.X, -speedgoback, flatDir.Z)
else
	HRP.Velocity = dir * speedgoback
end

		HRP.RotVelocity = Vector3.zero
		HRP.CFrame = HRP.CFrame:Lerp(CFrame.lookAt(pos, pos + dir), math.clamp(dt * 5, 0, 1))
	end)

	while not arrived do task.wait() end
end








local function isSamePosition(a, b)
	return (a - b).Magnitude < 0.1
end

runRoute = function()

--[[
	ATMStops = {
		{position = Vector3.new(-196.39, Y_POS, 457.82), speed = atm1},
		{position = Vector3.new(170.51, Y_POS, 487.91), speed = atm2},
		{position = Vector3.new(-109.29, Y_POS, 447.46), speed = atm3},
		{position = Vector3.new(-90.54, Y_POS, 157.49), speed = atm4},
		{position = Vector3.new(452.80, Y_POS, 33.89), speed = atm5},
		{position = Vector3.new(181.84, Y_POS, -239.54), speed = atm6},
		{position = Vector3.new(-197.05, Y_POS, -251.61), speed = atm7},
		{position = Vector3.new(-137.88, Y_POS, -530.52), speed = atm8},
		{position = Vector3.new(180.52, Y_POS, -638.72), speed = atm9},
		{position = Vector3.new(-458.28, Y_POS, -221.67), speed = atm10},
		{position = Vector3.new(-540.32, Y_POS, 339.45), speed = atm11}
	}

    --]]

    



	for index, target in ipairs(Waypoints) do
		if not running then return end

		if index == 1 then
			flyToFirst(target)

        local success = purchaseProHackToolUpToEleven()
        if not success then
        	print("➡️ Flying to ATM 1 to withdraw money.")

        	for atmIndex = 1, 3 do
        		local wp = Waypoints[atmIndex]
        		if atmIndex == 1 then
        			flyToFirst(wp)
        		else
        			flyTo(wp)
        		end
        	end

        	CallRemote(ReplicatedStorage.Remotes.Get, "transfer_funds", "bank", "hand", moneyToKeep)
        	task.wait(1)

        	print("↩️ Flying back to shop to buy tools.")

        	local shopWaypoint = Vector3.new(-215.79, Y_POS, 390)
        	for atmIndex = 3, 1, -1 do
        		local wp = Waypoints[atmIndex]
        		flyTo(wp)
        	end


        	purchaseProHackToolUpToEleven()
        end

		else
			flyTo(target)
		end

		if not running then return end

		local isATM = false
		for _, atm in ipairs(ATMStops) do
			if isSamePosition(target, atm.position) then
                depositMoney()
				isATM = true
				FLIGHT_SPEED = atm.speed

				local closestATM = nil
				local shortestDist = 25
				for _, model in ipairs(Props:GetDescendants()) do
					if model:IsA("Model") and model.Name:lower() == "atm" then
						local primary = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
						if primary then
							local dist = (primary.Position - HRP.Position).Magnitude
							if dist < shortestDist then
								shortestDist = dist
								closestATM = model
							end
						end
					end
				end

				if closestATM then
					local screenEnabled = false
					for _, part in ipairs(closestATM:GetDescendants()) do
						if part:IsA("BasePart") and part.Name == "Part" then
							local screen = part:FindFirstChild("Screen")
							if screen and screen:IsA("SurfaceGui") and screen.Enabled then
								screenEnabled = true
								break
							end
						end
					end

					if screenEnabled then
						print("ATM is hacked. Skipping to next.")
						break
					end
				end

				HRP.Anchored = true

                local isLastATM = isSamePosition(target, ATMStops[#ATMStops].position)
                if isLastATM then
	                CallRemote(ReplicatedStorage.Remotes.Get, "transfer_funds", "bank", "hand", moneyToKeep)
                end

				local holdStart = tick()
				HackATM()
				while running and tick() - holdStart < 1 and not tookDamage do
					task.wait()
				end
				tookDamage = false
				HRP.Anchored = false

				break
			end
		end

		if (index == #Waypoints) and not isATM then
			HRP.Anchored = true
			local holdStart = tick()
			while running and tick() - holdStart < 1 do
				task.wait()
			end
			HRP.Anchored = false
		end
	end

	if running then
		HRP.Anchored = true
		purchaseProHackToolUpToEleven()
		HRP.Anchored = false
	end

    
end



local Connection = nil

local Flight = function(delta)
	if UserInputService:GetFocusedTextBox() then return end
	local BaseVelocity = Vector3.new(0,0,0)
	if HRP then
		local car = HRP:GetRootPart()
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then

			BaseVelocity = BaseVelocity + (Camera.CFrame.LookVector * Settings.flyspeed)
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then
			BaseVelocity = BaseVelocity - (Camera.CFrame.RightVector * Settings.flyspeed)
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then
			BaseVelocity = BaseVelocity - (Camera.CFrame.LookVector * Settings.flyspeed)
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then
			BaseVelocity = BaseVelocity + (Camera.CFrame.RightVector * Settings.flyspeed)
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.E) then
			BaseVelocity = BaseVelocity + (Camera.CFrame.UpVector * Settings.flyspeed)
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.Q) then
			BaseVelocity = BaseVelocity - (Camera.CFrame.UpVector * Settings.flyspeed)
		end
		FlightVelocity = FlightVelocity:Lerp(
			BaseVelocity,
			math.clamp(delta, 0, 1)
		)
		local car = HRP:GetRootPart()
		car.RotVelocity = Vector3.new(0,0,0)
		car.Velocity = FlightVelocity + Vector3.new(0,2,0)
		car.CFrame = car.CFrame:Lerp(CFrame.lookAt(
			car.Position,
			car.Position - FlightVelocity - Camera.CFrame.LookVector
			) * CFrame.Angles(0,math.pi,0), math.clamp(delta * 400, 0, 1))
	end
end


local UILibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/Xylemo/Xylem/refs/heads/main/UI.lua"))()
local UI = UILibrary.Load("Encrypt's Hub")
local Main = UI.AddPage("rbxassetid://110773590348537", "Main", true)
local LocalPage = UI.AddPage("rbxassetid://140692356390682", "Local Player", false)


local atmFarmToggle = Main.AddTab("ATM Farm", "Automatically flies to and hacks ATMs.", "Left", function(state)
	print("ATM Farm toggled:", state)
	if state then
		running = true
		task.spawn(function()
			while running do
				runRoute()
				if running then
					print("Repeating route...")
				end
			end
		end)
	else
		running = false
		if HRP then
			HRP.Anchored = false
			HRP.Velocity = Vector3.zero
		end
	end
end)


local Flight = LocalPage.AddTab("Flight", "Works best against anti-cheat in vehicles.", "Left", function(state)
	if state then
        Connection = RunService.Heartbeat:Connect(Flight)
	else
        Connection:Disconnect()
        Connection = nil
        FlightVelocity = Vector3.new(0,0,0)
	end
end)

Flight.AddSlider({Min = 1, Max = 200, Def = Settings.flyspeed}, function(speed)
	Settings.flyspeed = speed
end)

local ESPEnabled = false
local BillboardFolder = Instance.new("Folder", game:GetService("CoreGui"))
BillboardFolder.Name = "PlayerESP"



local function addToolIcon(iconFrame, tool, isEquipped)
	if tool:IsA("Tool") and tool.TextureId and tool.TextureId ~= "" and tool.Name ~= "Fists" then
		local icon = Instance.new("ImageLabel")
		icon.Size = UDim2.new(0, 20, 0, 20)
		icon.BackgroundTransparency = 1
		icon.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		icon.Image = tool.TextureId
		icon.Parent = iconFrame



        local Round = Instance.new("UICorner")
		Round.Parent = icon

        if isEquipped then
        local Stroke = Instance.new("UIStroke")
		Stroke.Parent = icon
        Stroke.Color = Color3.fromRGB(140, 227, 125)
        end
        
	end
end



local function createOrUpdateBillboard(player)
	if player == Player then return end
	local char = player.Character
	if not char then return end
	local head = char:FindFirstChild("Head")
	if not head then return end

	local existing = BillboardFolder:FindFirstChild(player.Name)
	if existing then existing:Destroy() end

	local nameLength = #player.Name
	local minWidth, maxWidth = 60, 140
	local dynamicWidth = math.clamp(nameLength * 8, minWidth, maxWidth)

	local billboard = Instance.new("BillboardGui")
	billboard.Name = player.Name
	billboard.Size = UDim2.new(0, dynamicWidth, 0, 60)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.AlwaysOnTop = true
	billboard.Adornee = head
	billboard.Parent = BillboardFolder

	local iconFrame = Instance.new("Frame")
	iconFrame.Size = UDim2.new(1, 0, 0, 20)
	iconFrame.Position = UDim2.new(0, 0, 0, 0)
	iconFrame.BackgroundTransparency = 1
	iconFrame.Parent = billboard

	local iconLayout = Instance.new("UIListLayout")
	iconLayout.FillDirection = Enum.FillDirection.Horizontal
	iconLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	iconLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	iconLayout.SortOrder = Enum.SortOrder.LayoutOrder
	iconLayout.Padding = UDim.new(0, 2)
	iconLayout.Parent = iconFrame

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, 40)
	label.Position = UDim2.new(0, 0, 0, 20)
	label.BackgroundTransparency = 1
	label.Text = player.Name
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0.6
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Parent = billboard

if char then
	for _, tool in ipairs(char:GetChildren()) do
		addToolIcon(iconFrame, tool, true)
	end
end

if player:FindFirstChild("Backpack") then
	for _, tool in ipairs(player.Backpack:GetChildren()) do
		addToolIcon(iconFrame, tool, false)
	end
end

end


local function updateBillboards()
	for _, p in ipairs(Players:GetPlayers()) do
		createOrUpdateBillboard(p)
	end
end

local function toggleESP(state)
	ESPEnabled = state
	BillboardFolder:ClearAllChildren()
	if state then
		updateBillboards()
	end
end

Players.PlayerAdded:Connect(function(p)
	if ESPEnabled then
		p.CharacterAdded:Connect(function()
			wait(1)
			createOrUpdateBillboard(p)
		end)
	end
end)

for _, p in ipairs(Players:GetPlayers()) do
	if p ~= Player then
		p.CharacterAdded:Connect(function()
			if ESPEnabled then
				wait(1)
				createOrUpdateBillboard(p)
			end
		end)
	end
end

RunService.Heartbeat:Connect(function()
	if not ESPEnabled then return end

	for _, gui in ipairs(BillboardFolder:GetChildren()) do
		local player = Players:FindFirstChild(gui.Name)
		if not player then continue end

		local iconFrame = gui:FindFirstChildOfClass("Frame")
		if not iconFrame then continue end

		for _, child in ipairs(iconFrame:GetChildren()) do
			if child:IsA("ImageLabel") then
				child:Destroy()
			end
		end

		local backpack = player:FindFirstChild("Backpack")
		local char = player.Character

		if backpack and char then
			local backpackTools = backpack:GetChildren()
			local equippedTools = char:GetChildren()

			for _, tool in ipairs(equippedTools) do
				addToolIcon(iconFrame, tool, true)
			end

			for _, tool in ipairs(backpackTools) do
				if not table.find(equippedTools, tool) then
					addToolIcon(iconFrame, tool, false)
				end
			end
		end
	end
end)


local ESP = LocalPage.AddTab("ESP", "Toggle visibility of players", "Right", function(state)
	toggleESP(state)
end)




--[[
local Farm = Main.AddTab("Farm Points", "Testing", "Right", function(state)
	if state then
	end
end)

Farm.AddSlider({Min = 20, Max = 200, Def = atm1, Text = "ATM 1 Speed"}, function(val) atm1 = val end)
Farm.AddSlider({Min = 20, Max = 200, Def = atm2, Text = "ATM 2 Speed"}, function(val) atm2 = val end)
Farm.AddSlider({Min = 20, Max = 200, Def = atm3, Text = "ATM 3 Speed"}, function(val) atm3 = val end)
Farm.AddSlider({Min = 20, Max = 200, Def = atm4, Text = "ATM 4 Speed"}, function(val) atm4 = val end)
Farm.AddSlider({Min = 20, Max = 200, Def = atm5, Text = "ATM 5 Speed"}, function(val) atm5 = val end)
Farm.AddSlider({Min = 20, Max = 200, Def = atm6, Text = "ATM 6 Speed"}, function(val) atm6 = val end)
Farm.AddSlider({Min = 20, Max = 200, Def = atm7, Text = "ATM 7 Speed"}, function(val) atm7 = val end)
Farm.AddSlider({Min = 20, Max = 200, Def = atm8, Text = "ATM 8 Speed"}, function(val) atm8 = val end)
Farm.AddSlider({Min = 20, Max = 200, Def = atm9, Text = "ATM 9 Speed"}, function(val) atm9 = val end)
Farm.AddSlider({Min = 20, Max = 200, Def = atm10, Text = "ATM 10 Speed"}, function(val) atm10 = val end)
Farm.AddSlider({Min = 20, Max = 200, Def = atm11, Text = "ATM 11 Speed"}, function(val) atm11 = val end)

--]]
