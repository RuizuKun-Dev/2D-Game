local Globals = require(script.Parent.Parent.Constants.Globals)

local function draw(hyp, origin, thickness, parent, color, l, image)
	local line = l or (image and Instance.new("ImageLabel") or Instance.new("Frame"))

	line.Name = "Constraint"
	line.AnchorPoint = Vector2.new(0.5, 0.5)
	line.Size = UDim2.new(0, hyp, 0, (thickness or Globals.constraint.thickness) + (image and 15 or 0))
	line.BackgroundTransparency = image and 1 or 0
	line.BorderSizePixel = 0
	line.Position = UDim2.fromOffset(origin.X, origin.Y)
	line.ZIndex = 1

	if image then
		line.Image = image
		line.ImageColor3 = color or Globals.constraint.color
	else
		line.BackgroundColor3 = color or Globals.constraint.color
	end

	line.Parent = parent

	return line
end

return function(origin, endpoint, parent, thickness, color, l, image)
	local hyp = (endpoint - origin).Magnitude
	local line = draw(hyp, origin, thickness, parent, color, l, image)
	local mid = (origin + endpoint) / 2
	local theta = math.atan2((origin - endpoint).Y, (origin - endpoint).X)

	line.Position = UDim2.fromOffset(mid.x, mid.y)
	line.Rotation = math.deg(theta)

	return line
end
