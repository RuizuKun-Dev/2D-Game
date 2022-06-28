local tweenUtil = {}

tweenUtil.EasingStyle = {
	Linear = Enum.EasingStyle.Linear,
	Sine = Enum.EasingStyle.Sine,
	Back = Enum.EasingStyle.Back,
	Quad = Enum.EasingStyle.Quad,
	Quart = Enum.EasingStyle.Quart,
	Quint = Enum.EasingStyle.Quint,
	Bounce = Enum.EasingStyle.Bounce,
	Elastic = Enum.EasingStyle.Elastic,
	Exponential = Enum.EasingStyle.Exponential,
	Circular = Enum.EasingStyle.Circular,
	Cubic = Enum.EasingStyle.Cubic,
}

tweenUtil.EasingDirection = {
	In = Enum.EasingDirection.In,
	Out = Enum.EasingDirection.Out,
	InOut = Enum.EasingDirection.InOut,
}

return tweenUtil
