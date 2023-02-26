local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utilities = ReplicatedStorage.Utilities
local guiUtil = require(Utilities.guiUtil)

local viewport = workspace.CurrentCamera.ViewportSize
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
	viewport = workspace.CurrentCamera.ViewportSize
end)

local Pear = guiUtil.createUI("Frame", {
	Name = "Pear",
	Size = UDim2.fromOffset(viewport.X * 0.02, viewport.X * 0.02),
	BackgroundColor3 = Color3.fromRGB(132, 255, 0),
	BorderSizePixel = 0,
})

return Pear
