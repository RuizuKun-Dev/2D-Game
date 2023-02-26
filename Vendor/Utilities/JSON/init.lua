local HttpService = game:GetService("HttpService")

export type JSON = {
	Decode: (string: string) -> table,
	DeepCopy: (table: table) -> table,
	Encode: (table: table) -> string,
	Filter: (table: table, filterType: string, cache: table?) -> string,
	GenerateGUID: (wrapInCurlyBraces: boolean) -> string,
	Length: (table: table) -> integer,
	-- Repair: (dictionary: table) -> table,
	Valid: (table: table) -> (boolean, string?, string?),
}

local JSON = {}

function JSON.Decode(string: string): table
	return HttpService:JSONDecode(string)
end

function JSON.DeepCopy(table: table): table
	return JSON.Decode(JSON.Encode(table))
end

function JSON.Encode(table: table): string
	return HttpService:JSONEncode(table)
end

local Filters = require(script.Filters)
function JSON.Filter(table: table, filterType: string, cache: table?): table?
	cache = cache or {}
	local new = {}
	local filter = Filters[filterType]

	cache[table] = true

	for k, v in pairs(table) do
		if typeof(v) == "table" then
			if not cache[v] then
				new[k] = JSON.Filter(v, filterType, cache)
			else
				new[k] = "Cyclic Table: " .. tostring(v)
			end
		elseif filter[typeof(k)] and filter[typeof(v)] then
			new[k] = v
		end
	end

	cache[table] = nil

	return new
end

function JSON.GenerateGUID(wrapInCurlyBraces: boolean): string
	return HttpService:GenerateGUID(wrapInCurlyBraces)
end

function JSON.Length(table: table): integer
	return #JSON.Encode(table)
end

-- function JSON.Repair(dictionary: table): table
-- 	local isValid: boolean, path: Array, problem: string = JSON.Valid(dictionary)
-- 	if not isValid then
-- 		warn(problem, path)
-- 		local index = dictionary
-- 		for i: integer = 2, #path do
-- 			local key = path[i]
-- 			if i == #path then
-- 				index[key] = nil
-- 			else
-- 				index = index[key]
-- 			end
-- 		end
-- 		return JSON.Repair(dictionary)
-- 	end

-- 	return dictionary
-- end

local scanValidity = require(script.scanValidity)

function JSON.Valid(table: table): (boolean, Array?, string?)
	return scanValidity(table)
end

return JSON
