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

local Orange = engine:Create("RigidBody", {
	Object = require(script.Orange),
	Collidable = true,
	Anchored = false,
})
Orange:SetState("Fruit", true)
Orange:SetState("Points", 3)

local Mango = engine:Create("RigidBody", {
	Object = require(script.Mango),
	Collidable = true,
	Anchored = false,
})
Mango:SetState("Fruit", true)
Mango:SetState("Points", 4)
