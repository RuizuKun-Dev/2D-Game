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

local function isAFruit(fruit): boolean
	return fruit:GetState("Fruit")
end
task.spawn(function()
	local rng = Random.new()

	local function spawnFruit(selectedFruit)
		local fruit = selectedFruit:Clone(true)
		local frame = fruit:GetFrame()
		frame.Parent = canvas
		fruit:SetPosition(rng:NextInteger(10, canvas.AbsoluteSize.X - frame.AbsoluteSize.X * 1.5, 0), 10)
	end

	local Fruits = {
		Apple,
		Pear,
		Orange,
		Mango,
	}

	local function spawnRandomFruit()
		local fruit = Fruits[rng:NextInteger(1, #Fruits)]
		spawnFruit(fruit)
	end

	while true do
		spawnRandomFruit()
		task.wait(rng:NextNumber(1, 2))
	end
end)
