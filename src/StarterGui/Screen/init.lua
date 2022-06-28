local Apple = engine:Create("RigidBody", {
	Object = require(script.Apple),
	Collidable = true,
	Anchored = false,
})
Apple:SetState("Fruit", true)
Apple:SetState("Points", 1)
