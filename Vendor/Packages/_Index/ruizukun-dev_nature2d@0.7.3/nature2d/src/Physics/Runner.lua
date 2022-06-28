-- #selene: allow(unused_variable)

local Types = require(script.Parent.Parent.Types)
local Quadtree = require(script.Parent.Parent.Utilities.Quadtree)

local function SearchTable(t, a, lambda)
	for _, v in ipairs(t) do
		if lambda(a, v) then
			return v
		end
	end

	return nil
end

local Runner = {}

function Runner.CollisionResponse(body, other, isColliding, Collision, dt, oldCollidingWith, iteration)
	if not isColliding then
		return
	end
	if iteration == 1 and body.Touched._handlerListHead and body.Touched._handlerListHead.Connected then
		if not SearchTable(oldCollidingWith, other, function(a, b)
			return a.id == b.id
		end) then
			body.Touched:Fire(other.id, Collision)
		end
	end

	local penetration = Collision.axis * Collision.depth
	local p1 = Collision.edge.point1
	local p2 = Collision.edge.point2
	local t

	if math.abs(p1.pos.X - p2.pos.X) > math.abs(p1.pos.Y - p2.pos.Y) then
		t = (Collision.vertex.pos.X - penetration.X - p1.pos.X) / (p2.pos.X - p1.pos.X)
	else
		t = (Collision.vertex.pos.Y - penetration.Y - p1.pos.Y) / (p2.pos.Y - p1.pos.Y)
	end

	local factor = 1 / (t ^ 2 + (1 - t) ^ 2)
	local bodyMass = Collision.edge.Parent.mass
	local m = t * bodyMass + (1 - t) * bodyMass
	local cMass = 1 / (m + Collision.vertex.Parent.Parent.mass)
	local r1 = Collision.vertex.Parent.Parent.mass * cMass
	local r2 = m * cMass

	if not Collision.edge.Parent.anchored then
		p1.pos -= penetration * ((1 - t) * factor * r1)
		p2.pos -= penetration * (t * factor * r1)
	end
	if not Collision.vertex.Parent.Parent.anchored then
		Collision.vertex.pos += penetration * r2
	end
end
function Runner.Update(self, dt)
	local tree

	if self.quadtrees then
		tree = Quadtree.new(self.canvas.topLeft, self.canvas.size, 4)

		for _, body in ipairs(self.bodies) do
			if body.collidable then
				tree:Insert(body)
			end
		end
	else
		if self.iterations.collision ~= 1 then
			self.iterations.collision = 1
		end
	end

	for _, body in ipairs(self.bodies) do
		body:Update(dt)

		local OldCollidingWith = body.Collisions.Other
		local CollidingWith = {}

		if body.collidable then
			local filtered = self.bodies

			if self.quadtrees then
				local abs = body.custom and body.size or body.frame.AbsoluteSize
				local side = abs.X > abs.Y and abs.X or abs.Y
				local range = {
					position = body.center - Vector2.new(side * 1.5, side * 1.5),
					size = Vector2.new(side * 3, side * 3),
				}

				filtered = tree:Search(range, {})
			end

			for _, other in ipairs(filtered) do
				if body.id ~= other.id and other.collidable and not table.find(body.filtered, other.id) then
					local result, isColliding, Collision, didCollide

					for i = 1, self.iterations.collision do
						result = body:DetectCollision(other)
						isColliding = result[1]
						Collision = result[2]

						if i == 1 and not isColliding then
							break
						end

						didCollide = true

						Runner.CollisionResponse(body, other, isColliding, Collision, dt, OldCollidingWith, i)
					end

					if didCollide then
						body.Collisions.Body = true
						other.Collisions.Body = true

						table.insert(CollidingWith, other)
					else
						body.Collisions.Body = false
						other.Collisions.Body = false

						if body.TouchEnded._handlerListHead and body.TouchEnded._handlerListHead.Connected then
							if
								SearchTable(OldCollidingWith, other, function(a, b)
									return a.id == b.id
								end)
							then
								body.TouchEnded:Fire(other.id)
							end
						end
					end
				end
			end
		end

		body.Collisions.Other = CollidingWith
	end

	if #self.points > 0 then
		for _, point in ipairs(self.points) do
			point:Update(dt)
		end
	end
	if #self.constraints > 0 then
		for _, constraint in ipairs(self.constraints) do
			if constraint._TYPE ~= "SPRING" then
				for i = 1, self.iterations.constraint do
					constraint:Constrain()
				end
			else
				constraint:Constrain()
			end
		end
	end

	self.Updated:Fire()
end
function Runner.Render(self)
	for _, body in ipairs(self.bodies) do
		body:Render()
	end
	for _, point in ipairs(self.points) do
		point:Render()
	end
	for _, constraint in ipairs(self.constraints) do
		constraint:Render()
	end
end

return Runner
