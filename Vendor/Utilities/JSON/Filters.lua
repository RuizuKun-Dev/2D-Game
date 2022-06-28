local Filters = {}

-- Filters.Type = {
-- 	Attribute = "Attribute",
--	Display = "Display",
-- 	JSON = "JSON",
-- 	-- Network = "Network",
-- }

Filters.Attribute = {
	[typeof(BrickColor.random())] = true,
	[typeof(Color3.new())] = true,
	[typeof(ColorSequence.new(Color3.new()))] = true,
	[typeof(NumberRange.new(0))] = true,
	[typeof(NumberSequence.new(0))] = true,
	[typeof(Rect.new(Vector2.new(), Vector2.new()))] = true,
	[typeof(UDim.new())] = true,
	[typeof(UDim2.new())] = true,
	[typeof(Vector2.new())] = true,
	[typeof(Vector3.new())] = true,

	[typeof(true)] = true,
	[typeof(3.142)] = true,
	[typeof("string")] = "true",
}

Filters.Display = {
	[typeof(BrickColor.random())] = true,
	[typeof(Color3.new())] = true,
	[typeof(ColorSequence.new(Color3.new()))] = true,
	[typeof(NumberRange.new(0))] = true,
	[typeof(NumberSequence.new(0))] = true,
	[typeof(Rect.new(Vector2.new(), Vector2.new()))] = true,
	[typeof(UDim.new())] = true,
	[typeof(UDim2.new())] = true,
	[typeof(Vector2.new())] = true,
	[typeof(Vector3.new())] = true,

	[typeof(true)] = true,
	[typeof(3.142)] = true,
	[typeof("string")] = "true",

	[typeof(CFrame.new())] = true,
	[typeof(Instance.new("Configuration"))] = true,
}

Filters.JSON = {
	[typeof(true)] = true,
	[typeof(3.142)] = true,
	[typeof("string")] = "true",
}

--[[

Filters.Network = { -- INCOMPLETE
	[typeof(BrickColor.random())] = true,
	[typeof(CFrame.new())] = true,
	[typeof(Color3.new())] = true,
	[typeof(ColorSequence.new(Color3.new()))] = true,
	[typeof(ColorSequence.new(Color3.new()))] = true,
	[typeof(Instance.new("Configuration"))] = true,
	[typeof(NumberRange.new(0))] = true,
	[typeof(NumberSequence.new(0))] = true,
	[typeof(Rect.new(Vector2.new(), Vector2.new()))] = true,
	[typeof(UDim.new())] = true,
	[typeof(UDim2.new())] = true,
	[typeof(Vector2.new())] = true,
	[typeof(Vector3.new())] = true,
	[typeof(true)] = true,
	[typeof(3.142)] = true,
	[typeof("string")] = "true",
}

]]

return Filters
