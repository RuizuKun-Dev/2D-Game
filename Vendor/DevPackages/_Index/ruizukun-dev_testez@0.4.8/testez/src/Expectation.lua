local Expectation = {}
local SELF_KEYS = {
	to = true,
	be = true,
	been = true,
	have = true,
	was = true,
	at = true,
}
local NEGATION_KEYS = { never = true }

local function assertLevel(condition, message, level)
	message = message or "Assertion failed!"
	level = level or 1

	if not condition then
		error(message, level + 1)
	end
end
local function bindSelf(self, method)
	return function(firstArg, ...)
		if firstArg == self then
			return method(self, ...)
		else
			return method(self, firstArg, ...)
		end
	end
end
local function formatMessage(result, trueMessage, falseMessage)
	if result then
		return trueMessage
	else
		return falseMessage
	end
end

function Expectation.new(value)
	local self = {
		value = value,
		successCondition = true,
		condition = false,
		matchers = {},
		_boundMatchers = {},
	}

	setmetatable(self, Expectation)

	self.a = bindSelf(self, self.a)
	self.an = self.a
	self.ok = bindSelf(self, self.ok)
	self.equal = bindSelf(self, self.equal)
	self.throw = bindSelf(self, self.throw)
	self.near = bindSelf(self, self.near)

	return self
end
function Expectation.checkMatcherNameCollisions(name)
	if SELF_KEYS[name] or NEGATION_KEYS[name] or Expectation[name] then
		return false
	end

	return true
end
function Expectation:extend(matchers)
	self.matchers = matchers or {}

	for name, implementation in pairs(self.matchers) do
		self._boundMatchers[name] = bindSelf(self, function(_self, ...)
			local result = implementation(self.value, ...)
			local pass = result.pass == self.successCondition

			assertLevel(pass, result.message, 3)
			self:_resetModifiers()

			return self
		end)
	end

	return self
end
function Expectation.__index(self, key)
	if SELF_KEYS[key] then
		return self
	end
	if NEGATION_KEYS[key] then
		local newExpectation = Expectation.new(self.value):extend(self.matchers)

		newExpectation.successCondition = not self.successCondition

		return newExpectation
	end
	if self._boundMatchers[key] then
		return self._boundMatchers[key]
	end

	return Expectation[key]
end
function Expectation:_resetModifiers()
	self.successCondition = true
end
function Expectation:a(typeName)
	local result = (type(self.value) == typeName) == self.successCondition
	local message = formatMessage(
		self.successCondition,
		("Expected value of type %q, got value %q of type %s"):format(typeName, tostring(self.value), type(self.value)),
		("Expected value not of type %q, got value %q of type %s"):format(
			typeName,
			tostring(self.value),
			type(self.value)
		)
	)

	assertLevel(result, message, 3)
	self:_resetModifiers()

	return self
end

Expectation.an = Expectation.a

function Expectation:ok()
	local result = (self.value ~= nil) == self.successCondition
	local message = formatMessage(
		self.successCondition,
		("Expected value %q to be non-nil"):format(tostring(self.value)),
		("Expected value %q to be nil"):format(tostring(self.value))
	)

	assertLevel(result, message, 3)
	self:_resetModifiers()

	return self
end
function Expectation:equal(otherValue)
	local result = (self.value == otherValue) == self.successCondition
	local message = formatMessage(
		self.successCondition,
		("Expected value %q (%s), got %q (%s) instead"):format(
			tostring(otherValue),
			type(otherValue),
			tostring(self.value),
			type(self.value)
		),
		("Expected anything but value %q (%s)"):format(tostring(otherValue), type(otherValue))
	)

	assertLevel(result, message, 3)
	self:_resetModifiers()

	return self
end
function Expectation:near(otherValue, limit)
	assert(type(self.value) == "number", "Expectation value must be a number to use 'near'")
	assert(type(otherValue) == "number", "otherValue must be a number")
	assert(type(limit) == "number" or limit == nil, "limit must be a number or nil")

	limit = limit or 1e-7

	local result = (math.abs(self.value - otherValue) <= limit) == self.successCondition
	local message = formatMessage(
		self.successCondition,
		("Expected value to be near %f (within %f) but got %f instead"):format(otherValue, limit, self.value),
		([[Expected value to not be near %f (within %f) but got %f instead]]):format(otherValue, limit, self.value)
	)

	assertLevel(result, message, 3)
	self:_resetModifiers()

	return self
end
function Expectation:throw(messageSubstring)
	local ok, err = pcall(self.value)
	local result = ok ~= self.successCondition

	if messageSubstring and not ok then
		if self.successCondition then
			result = err:find(messageSubstring, 1, true) ~= nil
		else
			result = err:find(messageSubstring, 1, true) == nil
		end
	end

	local message

	if messageSubstring then
		message = formatMessage(
			self.successCondition,
			([[Expected function to throw an error containing %q, but it %s]]):format(
				messageSubstring,
				err and ("threw: %s"):format(err) or "did not throw."
			),
			([[Expected function to never throw an error containing %q, but it threw: %s]]):format(
				messageSubstring,
				tostring(err)
			)
		)
	else
		message = formatMessage(
			self.successCondition,
			"Expected function to throw an error, but it did not throw.",
			("Expected function to succeed, but it threw an error: %s"):format(tostring(err))
		)
	end

	assertLevel(result, message, 3)
	self:_resetModifiers()

	return self
end

return Expectation
