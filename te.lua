local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Player = Players.LocalPlayer

-- Function to check cooldown
local function getVehicleCooldown()
	local nextSpawn = Player:GetAttribute("SpawnVehicleNext")
	if not nextSpawn then
		print("No cooldown attribute found.")
		return
	end

	local now = os.time()
	local remaining = nextSpawn - now

	if remaining > 0 then
		print(("⏳ %d seconds until you can spawn again."):format(remaining))
	else
		print("✅ You can spawn a vehicle now.")
	end
end

-- Bind to H key
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.J then
		getVehicleCooldown()
	end
end)
