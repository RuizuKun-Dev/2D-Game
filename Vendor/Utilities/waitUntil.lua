local function waitUntil(ancestor: Instance)
	return {
		IsAncestorOf = function(descendant: Instance)
			while not ancestor:IsAncestorOf(descendant) do
				descendant.AncestryChanged:Wait()
			end
		end,
		IsDescendantOf = function(descendant: Instance)
			while not descendant:IsDescendantOf(ancestor) do
				descendant.AncestryChanged:Wait()
			end
		end,
	}
end

return waitUntil
