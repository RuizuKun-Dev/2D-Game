local TestEnum = require(script.Parent.TestEnum)
local TestResults = require(script.Parent.TestResults)
local Context = require(script.Parent.Context)
local ExpectationContext = require(script.Parent.ExpectationContext)
local TestSession = {}

TestSession.__index = TestSession

function TestSession.new(plan)
	local self = {
		results = TestResults.new(plan),
		nodeStack = {},
		contextStack = {},
		expectationContextStack = {},
		hasFocusNodes = false,
	}

	setmetatable(self, TestSession)

	return self
end
function TestSession:calculateTotals()
	local results = self.results

	results.successCount = 0
	results.failureCount = 0
	results.skippedCount = 0

	results:visitAllNodes(function(node)
		local status = node.status
		local nodeType = node.planNode.type

		if nodeType == TestEnum.NodeType.It then
			if status == TestEnum.TestStatus.Success then
				results.successCount = results.successCount + 1
			elseif status == TestEnum.TestStatus.Failure then
				results.failureCount = results.failureCount + 1
			elseif status == TestEnum.TestStatus.Skipped then
				results.skippedCount = results.skippedCount + 1
			end
		end
	end)
end
function TestSession:gatherErrors()
	local results = self.results

	results.errors = {}

	results:visitAllNodes(function(node)
		if #node.errors > 0 then
			for _, message in ipairs(node.errors) do
				table.insert(results.errors, message)
			end
		end
	end)
end
function TestSession:finalize()
	if #self.nodeStack ~= 0 then
		error("Cannot finalize TestResults with nodes still on the stack!", 2)
	end

	self:calculateTotals()
	self:gatherErrors()

	return self.results
end
function TestSession:pushNode(planNode)
	local node = TestResults.createNode(planNode)
	local lastNode = self.nodeStack[#self.nodeStack] or self.results

	table.insert(lastNode.children, node)
	table.insert(self.nodeStack, node)

	local lastContext = self.contextStack[#self.contextStack]
	local context = Context.new(lastContext)

	table.insert(self.contextStack, context)

	local lastExpectationContext = self.expectationContextStack[#self.expectationContextStack]
	local expectationContext = ExpectationContext.new(lastExpectationContext)

	table.insert(self.expectationContextStack, expectationContext)
end
function TestSession:popNode()
	assert(#self.nodeStack > 0, "Tried to pop from an empty node stack!")
	table.remove(self.nodeStack, #self.nodeStack)
	table.remove(self.contextStack, #self.contextStack)
	table.remove(self.expectationContextStack, #self.expectationContextStack)
end
function TestSession:getContext()
	assert(#self.contextStack > 0, "Tried to get context from an empty stack!")

	return self.contextStack[#self.contextStack]
end
function TestSession:getExpectationContext()
	assert(#self.expectationContextStack > 0, "Tried to get expectationContext from an empty stack!")

	return self.expectationContextStack[#self.expectationContextStack]
end
function TestSession:shouldSkip()
	if self.hasFocusNodes then
		for i = #self.nodeStack, 1, -1 do
			local node = self.nodeStack[i]

			if node.planNode.modifier == TestEnum.NodeModifier.Skip then
				return true
			end
			if node.planNode.modifier == TestEnum.NodeModifier.Focus then
				return false
			end
		end

		return true
	else
		for i = #self.nodeStack, 1, -1 do
			local node = self.nodeStack[i]

			if node.planNode.modifier == TestEnum.NodeModifier.Skip then
				return true
			end
		end
	end

	return false
end
function TestSession:setSuccess()
	assert(#self.nodeStack > 0, "Attempting to set success status on empty stack")

	self.nodeStack[#self.nodeStack].status = TestEnum.TestStatus.Success
end
function TestSession:setSkipped()
	assert(#self.nodeStack > 0, "Attempting to set skipped status on empty stack")

	self.nodeStack[#self.nodeStack].status = TestEnum.TestStatus.Skipped
end
function TestSession:setError(message)
	assert(#self.nodeStack > 0, "Attempting to set error status on empty stack")

	local last = self.nodeStack[#self.nodeStack]

	last.status = TestEnum.TestStatus.Failure

	table.insert(last.errors, message)
end
function TestSession:addDummyError(phrase, message)
	self:pushNode({
		type = TestEnum.NodeType.It,
		phrase = phrase,
	})
	self:setError(message)
	self:popNode()

	self.nodeStack[#self.nodeStack].status = TestEnum.TestStatus.Failure
end
function TestSession:setStatusFromChildren()
	assert(#self.nodeStack > 0, "Attempting to set status from children on empty stack")

	local last = self.nodeStack[#self.nodeStack]
	local status = TestEnum.TestStatus.Success
	local skipped = true

	for _, child in ipairs(last.children) do
		if child.status ~= TestEnum.TestStatus.Skipped then
			skipped = false

			if child.status == TestEnum.TestStatus.Failure then
				status = TestEnum.TestStatus.Failure
			end
		end
	end

	if skipped then
		status = TestEnum.TestStatus.Skipped
	end

	last.status = status
end

return TestSession
