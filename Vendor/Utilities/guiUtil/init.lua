local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utilities = ReplicatedStorage.Utilities
local instanceUtil = require(Utilities.instanceUtil)

local guiUtil = {}

guiUtil.AnchorPoint = require(script.AnchorPoint)

guiUtil.Position = require(script.Position)

guiUtil.Size = require(script.Size)

guiUtil.Transparency = require(script.Transparency)

guiUtil.registerUI = require(script.registerUI)

guiUtil.createUI = instanceUtil.create

function guiUtil.setProperties(instance: Instance, properties)
	for property: string, value: any in pairs(properties) do
		instance[property] = value
	end
end

function guiUtil.updateCanvasSize(scrollingFrame: ScrollingFrame)
	local UIGridStyleLayout: UIGridStyleLayout = scrollingFrame:FindFirstChildWhichIsA("UIGridStyleLayout")
	scrollingFrame.CanvasSize = UDim2.fromOffset(0, UIGridStyleLayout.AbsoluteContentSize.Y)
	UIGridStyleLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		scrollingFrame.CanvasSize = UDim2.fromOffset(0, UIGridStyleLayout.AbsoluteContentSize.Y)
	end)
end

return guiUtil
