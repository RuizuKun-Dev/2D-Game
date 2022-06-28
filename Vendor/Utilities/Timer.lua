local RunService = game:GetService("RunService")
local Heartbeat = RunService.Heartbeat

local Timer = { IS_CYCLICAL = true }
Timer.__index = Timer

type timer = {
	Name: string,
	Duration: number,

	_Change: BindableEvent,
	Changed: RBXScriptSignal,

	_Stop: BindableEvent,
	Stopped: RBXScriptSignal,
}

function Timer.create(name: string, duration: number): timer
	local Change = Instance.new("BindableEvent")
	local Stop = Instance.new("BindableEvent")
	local timer = {
		Name = name,
		Duration = duration,

		_Change = Change,
		Changed = Change.Event,

		_Stop = Stop,
		Stopped = Stop.Event,

		USING_METATABLE = true,
		-- Metatable = Timer,
	}
	Timer[name] = timer
	return setmetatable(timer, Timer)
end

function Timer:Start()
	local timer = self
	if not timer.Heartbeat then
		timer.Heartbeat = Heartbeat:Connect(function(dt)
			timer.Duration -= dt
			if timer.Duration < 0 then
				timer:Destroy()
				return
			end
			timer._Change:Fire(timer.Duration)
		end)
	end
end

function Timer:Destroy()
	local timer = self
	if timer.Heartbeat then
		timer.Heartbeat:Disconnect()
		timer._Stop:Fire()
	end
	timer._Stop:Destroy()
	timer._Change:Destroy()
	Timer[timer.Name] = nil
end

return Timer
