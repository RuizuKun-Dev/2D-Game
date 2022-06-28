local Apple = engine:Create("RigidBody", {
	Object = require(script.Apple),
	Collidable = true,
	Anchored = false,
})
Apple:SetState("Fruit", true)
Apple:SetState("Points", 1)

local Pear = engine:Create("RigidBody", {
	Object = require(script.Pear),
	Collidable = true,
	Anchored = false,
})
Pear:SetState("Fruit", true)
Pear:SetState("Points", 2)
