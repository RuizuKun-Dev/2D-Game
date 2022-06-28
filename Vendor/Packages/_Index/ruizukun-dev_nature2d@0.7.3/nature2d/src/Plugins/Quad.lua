return function(a, b, c, d)
	return {
		{ a, b, false },
		{ b, c, false },
		{ c, d, false },
		{ d, a, false },
		{ a, c, true },
		{ b, d, true },
	}
end
