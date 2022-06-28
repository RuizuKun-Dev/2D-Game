local score_txt = guiUtil.createUI("TextLabel", {
	Name = "Score",
	Text = 0,
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.fromScale(1, 0.05),
	Size = UDim2.fromScale(0.1, 0.05),
	TextScaled = true,
	BorderSizePixel = 0,
}, canvas)
guiUtil.createUI("TextLabel", {
	Name = "How to left",
	Text = "A < Left",
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.fromScale(0.3, 0.1),
	Size = UDim2.fromScale(0.2, 0.05),
	TextScaled = true,
	BorderSizePixel = 0,
}, canvas)

guiUtil.createUI("TextLabel", {
	Name = "How to right",
	Text = "D > Right",
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.fromScale(0.7, 0.1),
	Size = UDim2.fromScale(0.2, 0.05),
	TextScaled = true,
	BorderSizePixel = 0,
}, canvas)

guiUtil.createUI("TextLabel", {
	Name = "How to score",
	Text = "Collect fruits for points",
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.fromScale(0.5, 0.3),
	Size = UDim2.fromScale(0.2, 0.1),
	TextScaled = true,
	BorderSizePixel = 0,
}, canvas)
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

local platform = engine:Create("RigidBody", {
	Object = Platform,
	Collidable = true,
	Anchored = true,
})

local function isAFruit(fruit): boolean
	return fruit:GetState("Fruit")
end

platform.Touched:Connect(function(id: string)
	local fruit = engine:GetBodyById(id)

	if isAFruit(fruit) then
		fruit:Destroy()
	end
end)
local player = engine:Create("RigidBody", {
	Object = Character,
	Collidable = true,
	Anchored = false,
})

player:CanRotate(false)
player:SetMaxForce(20)

player:SetState("Points", 0)

local Points = 0

player.Touched:Connect(function(id: string)
	local fruit = engine:GetBodyById(id)

	if isAFruit(fruit) then
		Points += fruit:GetState("Points")
		fruit:Destroy()
	end

	score_txt.Text = Points
end)

local isMoving = { Left = false, Jump = false, Right = false }

UserInputService.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.A then
		isMoving.Left = true
	elseif input.KeyCode == Enum.KeyCode.D then
		isMoving.Right = true
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.A then
		isMoving.Left = false
	elseif input.KeyCode == Enum.KeyCode.D then
		isMoving.Right = false
	end
end)

local MOVEMENT = {
	MOVEFORCE = 5,
}

MOVEMENT.LEFT = Vector2.new(-MOVEMENT.MOVEFORCE, 0)
MOVEMENT.RIGHT = Vector2.new(MOVEMENT.MOVEFORCE, 0)

engine.Updated:Connect(function()
	if isMoving.Left then
		player:ApplyForce(MOVEMENT.LEFT)
	elseif isMoving.Right then
		player:ApplyForce(MOVEMENT.RIGHT)
	end
end)

engine:Start()
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
