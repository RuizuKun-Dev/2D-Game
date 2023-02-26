-- #selene: allow(unused_variable)

local Types = require(script.Parent.Parent.Types)
local Quadtree = {}

Quadtree.__index = Quadtree

local function GetDivisions(position, size)
	return {
		position,
		position + Vector2.new(size.X / 2, 0),
		position + Vector2.new(0, size.Y / 2),
		position + Vector2.new(size.X / 2, size.Y / 2),
	}
end
local function RangeOverlapsNode(node, range)
	local ap1 = range.position
	local as1 = range.size
	local sum = ap1 + as1
	local ap2 = node.position
	local as2 = node.size
	local sum2 = ap2 + as2

	return (ap1.x < sum2.x and sum.x > ap2.x) and (ap1.y < sum2.y and sum.y > ap2.y)
end
local function RangeHasPoint(range, obj)
	local p = obj.center

	return (
		(p.X > range.position.X)
		and (p.X < (range.position.X + range.size.X))
		and (p.Y > range.position.Y)
		and (p.Y < (range.position.Y + range.size.Y))
	)
end
local function merge(array1, array2)
	if #array2 > 0 then
		for _, v in ipairs(array2) do
			table.insert(array1, v)
		end
	end

	return array1
end

function Quadtree.new(_position, _size, _capacity)
	return setmetatable({
		position = _position,
		size = _size,
		capacity = _capacity,
		objects = {},
		divided = false,
	}, Quadtree)
end
function Quadtree:Insert(body)
	if not self:HasObject(body.center) then
		return
	end
	if #self.objects < self.capacity then
		self.objects[#self.objects + 1] = body
	else
		if not self.divided then
			self:SubDivide()

			self.divided = true
		end

		self.topLeft:Insert(body)
		self.topRight:Insert(body)
		self.bottomLeft:Insert(body)
		self.bottomRight:Insert(body)
	end
end
function Quadtree:HasObject(p)
	return (
		(p.X > self.position.X)
		and (p.X < (self.position.X + self.size.X))
		and (p.Y > self.position.Y)
		and (p.Y < (self.position.Y + self.size.Y))
	)
end
function Quadtree:SubDivide()
	local divisions = GetDivisions(self.position, self.size)

	self.topLeft = Quadtree.new(divisions[1], self.size / 2, self.capacity)
	self.topRight = Quadtree.new(divisions[2], self.size / 2, self.capacity)
	self.bottomLeft = Quadtree.new(divisions[3], self.size / 2, self.capacity)
	self.bottomRight = Quadtree.new(divisions[4], self.size / 2, self.capacity)
end
function Quadtree:Search(range, objects)
	if not objects then
		objects = {}
	end
	if not RangeOverlapsNode(self, range) then
		return objects
	end

	for _, obj in ipairs(self.objects) do
		if RangeHasPoint(range, obj) then
			objects[#objects + 1] = obj
		end
	end

	if self.divided then
		self.topLeft:Search(range, objects)
		self.topRight:Search(range, objects)
		self.bottomLeft:Search(range, objects)
		self.bottomRight:Search(range, objects)
	end

	return objects
end

return Quadtree
