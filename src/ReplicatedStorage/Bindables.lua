export type Bindable = {
	Name: string,

	BindableEvent: BindableEvent,
	Event: RBXScriptSignal,
	Signal: Signal,
	Events: Dictionary,
	Fire: (...any) -> void,

	Wait: (string) -> (...any?),

	BindableFunction: BindableFunction,
	-- OnInvoke = BindableFunction.OnInvoke,
	Functions: Dictionary,
	Invoke: (...any) -> (...any),

	Connection: RBXScriptConnection?,
}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utilities = ReplicatedStorage.Utilities
local Signals = require(Utilities.Signals)

local function makeBindableEvent(name: string): BindableEvent
	local BindableEvent = Instance.new("BindableEvent")
	BindableEvent.Name = name .. ".BE"
	return BindableEvent
end

local function makeBindableFunction(name: string): BindableFunction
	local BindableFunction = Instance.new("BindableFunction")
	BindableFunction.Name = name .. ".BF"
	return BindableFunction
end

local Bindables = {}

function Bindables.create(name: string): Bindable
	if not Bindables[name] then
		local signal = Signals.create()

		local BindableEvent = makeBindableEvent(name)

		local BindableFunction = makeBindableFunction(name)

		local waitForEvent
		function waitForEvent(event: string): ...any?
			local result = table.pack(signal:Wait())
			if result[1] == event then
				return unpack(result, 2)
			end

			return waitForEvent(event)
		end

		local Bindable = {
			Name = name,

			BindableEvent = BindableEvent,
			Signal = signal,
			Event = BindableEvent.Event,
			Events = {},
			Fire = function(...)
				signal:Fire(...)
			end,

			Wait = waitForEvent,

			BindableFunction = BindableFunction,
			Functions = {},
			Invoke = function(...): any
				return BindableFunction:Invoke(...)
			end,
		}

		local functions = Bindable.Functions
		function BindableFunction.OnInvoke(instruction: string, ...): any
			local callback = functions[instruction]
			if callback then
				local errorMessage, stacktrace
				local results = table.pack(xpcall(callback, function(err)
					errorMessage = err
					stacktrace = debug.traceback()
				end, ...))
				if not results[1] then
					error(
						string.format(
							"Error Message: %s.\nFrom Instruction %q with BindableFunction %q\nStack trace:%s",
							tostring(errorMessage),
							tostring(instruction),
							tostring(name),
							tostring(stacktrace)
						)
					)
				end
				return unpack(results, 2)
			else
				warn(instruction, "is an Invalid Function for", BindableFunction, "BindableFunction")
			end
		end

		Bindables[name] = Bindable

		BindableEvent.Parent = script
		BindableFunction.Parent = script

		script:SetAttribute(name, true)
	else
		warn("BindableEvent", name, "already exists use Bindables.get instead")
	end
	return Bindables[name]
end

function Bindables.get(name: string): Bindable
	if not Bindables[name] then
		script:WaitForChild(name .. ".BE")
		script:WaitForChild(name .. ".BF")
	end
	return Bindables[name]
end

local function setEvents(Bindable: Bindable, newInstructions: Dictionary)
	local events = Bindable.Events

	for instruction: string, callback in pairs(newInstructions) do
		events[instruction] = callback
	end
end

function Bindables.handleEvents(Bindable: Bindable, newInstructions: Dictionary)
	setEvents(Bindable, newInstructions)

	if not Bindable.Connection then
		local events = Bindable.Events
		Bindable.Connection = Bindable.Signal:Connect(function(instruction: string, ...)
			local callback = events[instruction]
			if callback then
				local errorMessage, stacktrace
				local success = xpcall(callback, function(err)
					errorMessage = err
					stacktrace = debug.traceback()
				end, ...)
				if not success then
					error(
						string.format(
							"Error Message: %s.\nFrom Instruction %q with BindableEvent %q\nStack trace:%s",
							tostring(errorMessage),
							tostring(instruction),
							tostring(Bindable.Name),
							tostring(stacktrace)
						)
					)
				end
			else
				warn(instruction, "is an Invalid Event for", Bindable.Name, "BindableEvent")
			end
		end)
	end
end

local function setFunctions(Bindable: Bindable, newInstructions: Dictionary)
	local functions = Bindable.Functions

	for instruction: string, callback in pairs(newInstructions) do
		functions[instruction] = callback
	end
end

function Bindables.handleFunctions(Bindable: Bindable, newInstructions: Dictionary)
	setFunctions(Bindable, newInstructions)
end

return Bindables
