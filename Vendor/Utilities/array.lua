export type array = {
	combine: (...Array) -> Array,
	deepCopy: (Array) -> Array,
	deepCompare: (Array, Array) -> boolean,
	dequeue: (array: Array) -> (any?),
	enqueue: (array: Array, value: any?) -> void,
	findDuplicates: (array: Array) -> Array,
	findFirstDuliplicate: (Array) -> any?,
	isEmpty: (Array) -> boolean,
	JSONCompare: (Array, Array) -> boolean,
	JSONCopy: (Array) -> Array,
	pop: (array: Array) -> any?,
	push: (array: Array, value: any?) -> void,
	random: (Array) -> any?,
	randoms: (Array, integer) -> any?,
	remove: (Array) -> (any & number)?,
	removeRandom: (Array) -> any?,
	shalowCompare: (Array, Array) -> boolean,
	shalowCopy: (Array) -> Array,
}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utilities = ReplicatedStorage.Utilities
local JSON = require(Utilities.JSON)

local Array = {}

function Array.combine(...): Array
	local combinedArray: Array = {}
	local index: integer = 1

	for listIndex = 1, select("#", ...) do
		local list: Array? = select(listIndex, ...)

		if list then
			for _, value: any in ipairs(list) do
				combinedArray[index] = value
				index += 1
			end
		end
	end

	return combinedArray
end

function Array.deepCopy(array: Array): Array
	local deepCopied = {}

	for i, v in ipairs(array) do
		if type(v) == "table" then
			deepCopied[i] = Array.deepCopy(v)
		else
			deepCopied[i] = v
		end
	end

	return deepCopied
end

function Array.enqueue(array: Array, value: any?)
	table.insert(array, 1, value)
end

function Array.dequeue(array: Array): any?
	return table.remove(array, #array)
end

function Array.findFirstDuliplicate(array: Array): any?
	table.sort(array)
	for i: integer, v: any in ipairs(array) do
		if table.find(array, v, i + 1) then
			return v
		end
	end
end

function Array.findDuplicates(array: Array): Array
	local duplicates: Array = {}

	table.sort(array)
	for i: integer, v: any in ipairs(array) do
		if table.find(array, v, i + 1) then
			table.insert(duplicates, v)
		end
	end

	return duplicates
end

function Array.isEmpty(array: Array): boolean
	return #array == 0
end

function Array.JSONCompare(array1: Array, array2: Array): boolean
	return JSON.Encode(array1) == JSON.Encode(array2)
end

function Array.JSONCopy(array: Array): Array
	return JSON.DeepCopy(array)
end

function Array.pop(array: Array): any?
	return table.remove(array, #array)
end

function Array.push(array: Array, value: any?)
	table.insert(array, #array + 1, value)
end

function Array.random(array: Array): any?
	if array and #array > 0 then
		return array[math.random(1, #array)]
	end
end

function Array.randoms(array: Array, entries: integer): any?
	local results = {}
	if array and #array > 0 then
		local deepCopy = Array.deepCopy(array)
		for _ = 1, entries do
			table.insert(results, Array.removeRandom(deepCopy))
		end
		return table.unpack(results)
	end
end

function Array.removeRandom(array: Array): any?
	local value: any = Array.random(array)
	local index: integer = table.find(array, value)
	return table.remove(array, index)
end

function Array.remove(array: Array, value: any?): (any & number)?
	local index: integer? = table.find(array, value)
	if index then
		return table.remove(array, index), index
	end
end

function Array.shallowCompare(array1: Array, array2: Array): boolean
	for i, v in ipairs(array1) do
		if array2[i] ~= v then
			return false
		end
	end
	return true
end

function Array.shalowCopy(array: Array): Array
	return table.pack(table.unpack(array))
end

function Array.clear(array: Array): Array
	for i = #array, 1, -1 do
		table.remove(array, i)
	end
	return array
end

return Array
