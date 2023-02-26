local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utilities = ReplicatedStorage.Utilities
local guiUtil = require(Utilities.guiUtil)

local viewport = workspace.CurrentCamera.ViewportSize
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
	viewport = workspace.CurrentCamera.ViewportSize
end)

local Apple = guiUtil.createUI("Frame", {
	Name = "Apple",
	Size = UDim2.fromOffset(viewport.X * 0.01, viewport.X * 0.01),
	BackgroundColor3 = Color3.fromRGB(255, 0, 0),
	BorderSizePixel = 0,
})

return Apple
