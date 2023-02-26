local RANDOM = {}

local rng = Random.new()

function RANDOM.integer(min: integer, max: integer): integer
	return rng:NextInteger(min, max)
end

function RANDOM.number(min: number?, max: number?): number
	return rng:NextNumber(min or 0, max or 1)
end

function RANDOM.getRandoms(min: number, max: number, amount: integer): any
	local numbers = {}
	for _ = 1, amount do
		table.insert(numbers, RANDOM.number(min, max))
	end
	return table.unpack(numbers)
end

function RANDOM.fromArray(array: Array): any?
	if #array > 0 then
		return array[RANDOM.integer(1, #array)]
	end
end

-- function random.fromDictionary(dictionary: Dictionary): any?

-- end

function RANDOM.CFrameFromPart(basePart: BasePart): CFrame
	local sizeX = basePart.Size.X / 2
	local sizeY = basePart.Size.Y / 2
	local sizeZ = basePart.Size.Z / 2

	local x = RANDOM.integer(-sizeX, sizeX)
	local y = RANDOM.integer(-sizeY, sizeY)
	local z = RANDOM.integer(-sizeZ, sizeZ)
	return basePart.CFrame * CFrame.new(x, y, z)
end

function RANDOM.Vector3FromPart(basePart: BasePart): Vector3
	return RANDOM.CFrameFromPart(basePart).Position
end

function RANDOM.Vector3(min: number, max: number): Vector3
	return Vector3.new(RANDOM.getRandoms(min, max, 3))
end

function RANDOM.NumberRange(min: number, max: number): NumberRange
	return NumberRange.new(RANDOM.number(min, max))
end

function RANDOM.weight(lootTable, random): any
	local totalWeight = 0

	for _, v in ipairs(lootTable) do
		for _: string, vv in pairs(v) do
			totalWeight += vv
		end
	end

	local number = (random:NextNumber() or rng:NextNumber()) * totalWeight

	for _, v in ipairs(lootTable) do
		for name: string, weight in pairs(v) do
			if number < weight then
				return name
			end
			number -= weight
		end
	end
end

return RANDOM
