-- #selene: allow(unused_variable)

local line = require(script.Parent.Parent.Utilities.Line)
local Globals = require(script.Parent.Parent.Constants.Globals)
local throwTypeError = require(script.Parent.Parent.Debugging.TypeErrors)
local throwException = require(script.Parent.Parent.Debugging.Exceptions)
local Janitor = require(script.Parent.Parent.Utilities.Janitor)
local Types = require(script.Parent.Parent.Types)
local https = game:GetService("HttpService")
local Constraint = {}

Constraint.__index = Constraint

function Constraint.new(p1, p2, canvas, config, engine, parent)
	local self = setmetatable({
		id = https:GenerateGUID(false),
		_janitor = nil,
		engine = engine,
		Parent = parent,
		frame = nil,
		canvas = canvas,
		point1 = p1,
		point2 = p2,
		restLength = config.restLength or (p2.pos - p1.pos).Magnitude,
		render = config.render,
		thickness = config.thickness or Globals.constraint.thickness,
		support = config.support,
		_TYPE = config.TYPE,
		k = 0.1,
		color = nil,
	}, Constraint)
	local janitor = Janitor.new()

	janitor:Add(self, "Destroy")
	janitor:Add(self.point1, "Destroy")
	janitor:Add(self.point2, "Destroy")

	if self.Parent then
		janitor:Add(self.Parent, "Destroy")
	end

	self._janitor = janitor
	self.point1.Parent = self
	self.point2.Parent = self

	self.point1._janitor:Add(self.point1.Parent, "Destroy")
	self.point2._janitor:Add(self.point2.Parent, "Destroy")

	return self
end
function Constraint:Constrain()
	local cur = (self.point2.pos - self.point1.pos).Magnitude
	local force

	if self._TYPE == "ROPE" then
		local restLength = self.restLength

		if cur < self.thickness then
			restLength = self.thickness
		end
		if cur > self.restLength or self.restLength < self.thickness then
			local offset = ((restLength - cur) / restLength) / 2

			force = self.point2.pos - self.point1.pos

			force *= offset
		end
	elseif self._TYPE == "ROD" then
		local offset = self.restLength - cur
		local dif = self.point2.pos - self.point1.pos

		dif = dif.Unit
		force = (dif * offset) / 2
	elseif self._TYPE == "SPRING" then
		force = self.point2.pos - self.point1.pos

		local mag = force.Magnitude - self.restLength

		force = force.Unit

		force *= -1 * self.k * mag
	else
		return
	end
	if force then
		if not self.point1.snap then
			self.point1.pos -= force
		end
		if not self.point2.snap then
			self.point2.pos += force
		end
	end
end
function Constraint:Render()
	if self.render and not self.support then
		if not self.canvas.frame then
			throwException("error", "CANVAS_FRAME_NOT_FOUND")
		end

		local thickness = self.thickness or Globals.constraint.thickness
		local color = self.color or Globals.constraint.color
		local image = self._TYPE == "SPRING" and "rbxassetid://8404350124" or nil

		if not self.frame then
			self.frame = line(self.point1.pos, self.point2.pos, self.canvas.frame, thickness, color, nil, image)

			self._janitor:Add(self.frame, "Destroy")
		end

		line(self.point1.pos, self.point2.pos, self.canvas.frame, thickness, color, self.frame, image)
	end
end
function Constraint:SetLength(newLength)
	throwTypeError("length", newLength, 1, "number")

	if newLength <= 0 then
		throwException("error", "INVALID_CONSTRAINT_LENGTH")
	end

	self.restLength = newLength
end
function Constraint:GetLength()
	return (self.point2.pos - self.point1.pos).Magnitude
end
function Constraint:Stroke(color)
	throwTypeError("color", color, 1, "Color3")

	self.color = color
end
function Constraint:Destroy()
	self._janitor:Cleanup()

	if not self.Parent then
		for i, c in ipairs(self.engine.constraints) do
			if c.id == self.id then
				table.remove(self.engine.constraints, i)
				self.engine.ObjectRemoved:Fire(self)

				break
			end
		end
	end

	self.point1 = nil
	self.point2 = nil
end
function Constraint:GetPoints()
	return self.point1, self.point2
end
function Constraint:GetFrame()
	return self.frame
end
function Constraint:SetSpringConstant(k)
	throwTypeError("springConstant", k, 1, "number")

	self.k = k
end
function Constraint:GetId()
	return self.id
end
function Constraint:GetParent()
	return self.Parent
end

return Constraint
