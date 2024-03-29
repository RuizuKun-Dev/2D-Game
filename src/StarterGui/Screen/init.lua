local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utilities = ReplicatedStorage.Utilities
local guiUtil = require(Utilities.guiUtil)
local Nature2D = require(Utilities.Nature2D)

local SoundService = game:GetService("SoundService")
local SoundSystem = require(SoundService.SoundSystem)

local UserInputService = game:GetService("UserInputService")

local screen: ScreenGui = guiUtil.createUI(
	"ScreenGui",
	{ Name = "Screen", IgnoreGuiInset = true, ResetOnSpawn = false }
)

local canvas: Frame = guiUtil.createUI("Frame", { Name = "Canvas", Size = UDim2.fromScale(1, 1) }, screen)

local timer_txt = guiUtil.createUI("TextLabel", {
	Name = "Timer",
	Text = 0,
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.fromScale(1, 0.05),
	Size = UDim2.fromScale(0.1, 0.05),
	TextScaled = true,
	BorderSizePixel = 0,
}, canvas)

local score_txt = guiUtil.createUI("TextLabel", {
	Name = "Score",
	Text = 0,
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.fromScale(1, 0.1),
	Size = UDim2.fromScale(0.1, 0.05),
	TextScaled = true,
	BorderSizePixel = 0,
}, canvas)

local streak_txt = guiUtil.createUI("TextLabel", {
	Name = "Streak",
	Text = 0,
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.fromScale(1, 0.15),
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

local Character = require(script.Character)
Character.Parent = canvas

local Platform = require(script.Platform)
Platform.Parent = canvas

local engine = Nature2D.init(screen)
engine.canvas.frame = canvas

local Apple = engine:Create("RigidBody", {
	Object = require(script.Apple),
	Collidable = true,
	Anchored = true,
})
Apple:SetState("Points", 4)

local Pear = engine:Create("RigidBody", {
	Object = require(script.Pear),
	Collidable = true,
	Anchored = true,
})
Pear:SetState("Points", 3)

local Orange = engine:Create("RigidBody", {
	Object = require(script.Orange),
	Collidable = true,
	Anchored = true,
})
Orange:SetState("Points", 2)

local Mango = engine:Create("RigidBody", {
	Object = require(script.Mango),
	Collidable = true,
	Anchored = true,
})
Mango:SetState("Points", 1)

local platform = engine:Create("RigidBody", {
	Object = Platform,
	Collidable = true,
	Anchored = true,
})

local function isAFruit(fruit): boolean
	return fruit:GetState("Fruit")
end

local Streaks = 0

platform.Touched:Connect(function(id: string)
	local fruit = engine:GetBodyById(id)

	if isAFruit(fruit) then
		fruit:Destroy()
		Streaks = 0
	end

	streak_txt.Text = "Combo: " .. Streaks
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
		fruit:Destroy()
		Points += fruit:GetState("Points")
		Streaks += 1
		SoundSystem.PlaySFX("Pop", SoundService)
	end

	score_txt.Text = "Points: " .. Points
	streak_txt.Text = "Combo: " .. Streaks
end)

local isMoving = { Left = false, Jump = false, Right = false }

local function detectPlayerInput()
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
end
detectPlayerInput()

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

task.delay(1, function()
	local rng = Random.new()

	local function spawnFruit(selectedFruit)
		local fruit = selectedFruit:Clone(true)
		local frame = fruit:GetFrame()
		frame.Parent = canvas
		fruit:SetState("Fruit", true)
		fruit:SetPosition(
			rng:NextInteger(frame.AbsoluteSize.X * 2, canvas.AbsoluteSize.X - frame.AbsoluteSize.X * 2, 0),
			frame.AbsoluteSize.Y
		)
		fruit:Unanchor()
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

	task.spawn(function()
		local startTime = os.time()
		while true do
			timer_txt.Text = "Timer: " .. os.time() - startTime
			task.wait(1)
		end
	end)

	while true do
		spawnRandomFruit()
		task.wait(rng:NextNumber(1, 2))
	end
end)

return screen
