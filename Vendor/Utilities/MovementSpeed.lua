local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Configurations = require(ReplicatedStorage.Configurations)

local MovementSpeed = {
	MovementBuff = 0,
	MovementDebuff = 0,
}

function MovementSpeed.calculateTotalMovementSpeed(): number
	return math.max(
		(Configurations.MovementSpeed.Hiders * (1 + MovementSpeed.MovementBuff)) * (1 - MovementSpeed.MovementDebuff),
		1
	)
end

return MovementSpeed
