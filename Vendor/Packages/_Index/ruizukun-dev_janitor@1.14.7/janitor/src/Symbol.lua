local function Symbol(Name)
	local self = newproxy(true)
	local Metatable = getmetatable(self)

	function Metatable.__tostring()
		return Name
	end

	return self
end

return Symbol
