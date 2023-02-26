local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utilities = ReplicatedStorage.Utilities
local guiUtil = require(Utilities.guiUtil)

local viewport = workspace.CurrentCamera.ViewportSize
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
	viewport = workspace.CurrentCamera.ViewportSize
end)

local Platform = guiUtil.createUI("Frame", {
	Name = "Platform",
	Position = UDim2.fromOffset(0, viewport.Y * 0.95),
	Size = UDim2.fromOffset(viewport.X * 1, viewport.Y * 0.05),
	BackgroundColor3 = Color3.new(1, 0, 0),
	BorderSizePixel = 0,
})

return Platform
