local TestEnum = require(script.Parent.TestEnum)
local LifecycleHooks = {}

LifecycleHooks.__index = LifecycleHooks

function LifecycleHooks.new()
	local self = { _stack = {} }

	return setmetatable(self, LifecycleHooks)
end
function LifecycleHooks:getBeforeEachHooks()
	local key = TestEnum.NodeType.BeforeEach
	local hooks = {}

	for _, level in ipairs(self._stack) do
		for _, hook in ipairs(level[key]) do
			table.insert(hooks, hook)
		end
	end

	return hooks
end
function LifecycleHooks:getAfterEachHooks()
	local key = TestEnum.NodeType.AfterEach
	local hooks = {}

	for _, level in ipairs(self._stack) do
		for _, hook in ipairs(level[key]) do
			table.insert(hooks, 1, hook)
		end
	end

	return hooks
end
function LifecycleHooks:popHooks()
	table.remove(self._stack, #self._stack)
end
function LifecycleHooks:pushHooksFrom(planNode)
	assert(planNode ~= nil)
	table.insert(self._stack, {
		[TestEnum.NodeType.BeforeAll] = self:_getHooksOfType(planNode.children, TestEnum.NodeType.BeforeAll),
		[TestEnum.NodeType.AfterAll] = self:_getHooksOfType(planNode.children, TestEnum.NodeType.AfterAll),
		[TestEnum.NodeType.BeforeEach] = self:_getHooksOfType(planNode.children, TestEnum.NodeType.BeforeEach),
		[TestEnum.NodeType.AfterEach] = self:_getHooksOfType(planNode.children, TestEnum.NodeType.AfterEach),
	})
end
function LifecycleHooks:getBeforeAllHooks()
	return self._stack[#self._stack][TestEnum.NodeType.BeforeAll]
end
function LifecycleHooks:getAfterAllHooks()
	return self._stack[#self._stack][TestEnum.NodeType.AfterAll]
end
function LifecycleHooks:_getHooksOfType(nodes, key)
	local hooks = {}

	for _, node in ipairs(nodes) do
		if node.type == key then
			table.insert(hooks, node.callback)
		end
	end

	return hooks
end

return LifecycleHooks
