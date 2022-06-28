local function scanValidity(table: table, cache: table?, path: Array?): (boolean, Array?, string?)
	if type(table) ~= "table" then
		return scanValidity({ input = table }, {}, {})
	end
	cache, path = cache or {}, path or { "root" }
	cache[table] = true
	local tblType
	do
		local key = next(table)
		if type(key) == "number" then
			tblType = "Array"
		else
			tblType = "Dictionary"
		end
	end
	local last = 0
	for key, value in next, table do
		path[#path + 1] = tostring(key)
		if type(key) == "number" then
			if tblType == "Dictionary" then
				return false, path, "cannot store mixed tables"
			elseif key % 1 ~= 0 then
				return false, path, "cannot store tables with non-integer indices"
			elseif key == math.huge or key == -math.huge then
				return false, path, "cannot store tables with (-)infinity indices"
			end
		elseif type(key) ~= "string" then
			return false, path, "dictionaries cannot have keys of type " .. typeof(key)
		elseif tblType == "Array" then
			return false, path, "cannot store mixed tables"
		end
		if tblType == "Array" then
			if last ~= key - 1 then
				return false, path, "array has non-sequential indices"
			end
			last = key
		end
		if type(value) == "userdata" or type(value) == "function" or type(value) == "thread" then
			return false, path, "cannot store value '" .. tostring(value) .. "' of type " .. typeof(value)
		end
		if type(value) == "table" then
			if cache[value] then
				return false, path, "cannot store cyclic tables"
			end
			local isValid, keyPath, reason = scanValidity(value, cache, path)
			if not isValid then
				return isValid, keyPath, reason
			end
		end
		path[#path] = nil
	end
	cache[table] = nil
	return true
end

return scanValidity
