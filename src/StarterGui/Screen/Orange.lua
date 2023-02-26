local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utilities = ReplicatedStorage.Utilities
local guiUtil = require(Utilities.guiUtil)

local viewport = workspace.CurrentCamera.ViewportSize
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
	viewport = workspace.CurrentCamera.ViewportSize
end)

local Orange = guiUtil.createUI("Frame", {
	Name = "Orange",
	Size = UDim2.fromOffset(viewport.X * 0.03, viewport.X * 0.03),
	BackgroundColor3 = Color3.fromRGB(255, 119, 0),
	BorderSizePixel = 0,
})

return Orange
