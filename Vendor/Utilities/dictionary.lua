export type Dictionary = { random: (Dictionary) -> any?, randoms: (Dictionary, integer) -> any? }

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utilities = ReplicatedStorage.Utilities
local Array = require(Utilities.array)

local Dictionary: dictionary = {}

function Dictionary.convertToArrayWithKey(dictionary: Dictionary): Array
	local array = {}
	for k, _ in pairs(dictionary) do
		table.insert(array, k)
	end
	return array
end

function Dictionary.convertToArrayWithValue(dictionary: Dictionary): Array
	local array = {}
	for _, v in pairs(dictionary) do
		table.insert(array, v)
	end
	return array
end

function Dictionary.convertToArrayWithKeyValue(dictionary: Dictionary): Array
	local array = {}
	for k, v in pairs(dictionary) do
		table.insert(array, { k, v })
	end
	return array
end

function Dictionary.isEmpty(dictionary: Dictionary): boolean
	return next(dictionary) == nil
end

function Dictionary.randomValue(dictionary: Dictionary): any?
	local array = Dictionary.convertToArrayWithKey(dictionary)

	return dictionary[Array.random(array)]
end

function Dictionary.randomKeys(dictionary: Dictionary, entries: integer): any?
	local array = Dictionary.convertToArrayWithKey(dictionary)

	return Array.randoms(array, entries)
end

function Dictionary.clear(dictionary: Dictionary): Dictionary
	for k, _ in pairs(dictionary) do
		if typeof(k) ~= "number" then
			dictionary[k] = nil
		end
	end
	return dictionary
end

return Dictionary
