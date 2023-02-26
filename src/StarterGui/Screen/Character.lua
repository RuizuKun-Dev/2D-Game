local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utilities = ReplicatedStorage.Utilities
local guiUtil = require(Utilities.guiUtil)

local viewport = workspace.CurrentCamera.ViewportSize
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
	viewport = workspace.CurrentCamera.ViewportSize
end)

local Character = guiUtil.createUI("Frame", {
	Name = "Player",
	Position = UDim2.fromOffset(10, viewport.Y * 0.85),
	Size = UDim2.fromOffset(viewport.X * 0.05, viewport.Y * 0.1),
	BackgroundColor3 = Color3.new(0, 0, 0),
	BorderSizePixel = 0,
})

return Character
