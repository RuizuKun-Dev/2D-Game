local TestPlan = require(script.Parent.TestPlan)
local TestPlanner = {}

function TestPlanner.createPlan(modulesList, testNamePattern, extraEnvironment)
	local plan = TestPlan.new(testNamePattern, extraEnvironment)

	table.sort(modulesList, function(a, b)
		return a.pathStringForSorting < b.pathStringForSorting
	end)

	for _, module in ipairs(modulesList) do
		plan:addRoot(module.path, module.method)
	end

	return plan
end

return TestPlanner
