local freeRunnerThread = nil

local function acquireRunnerThreadAndCallEventHandler(callback, ...: any)
	local acquiredRunnerThread = freeRunnerThread
	freeRunnerThread = nil
	callback(...)
	freeRunnerThread = acquiredRunnerThread
end

local function runEventHandlerInFreeThread(...: any)
	acquireRunnerThreadAndCallEventHandler(...)
	while true do
		acquireRunnerThreadAndCallEventHandler(coroutine.yield())
	end
end

export type Connection = {
	Connected: boolean,
	Disconnect: () -> void,
}

local Connections = {}
Connections.IS_CYCLICAL = true
Connections.__index = Connections

function Connections.create(signal: Signal, callback): Connection
	return setmetatable({
		Connected = true,
		_signal = signal,
		_callback = callback,
		_next = false,
		USING_METATABLE = true,
		-- Metatable = Connections
	}, Connections)
end

function Connections:Disconnect()
	if self.Connected then
		self.Connected = false
		if self._signal._handlerListHead == self then
			self._signal._handlerListHead = self._next
		else
			local prev = self._signal._handlerListHead
			while prev and prev._next ~= self do
				prev = prev._next
			end
			if prev then
				prev._next = self._next
			end
		end
	else
		warn("Attepmting to disconnect a connection twice")
	end
end

setmetatable(Connections, {
	__index = function(_, key)
		error(("Attempt to get Connection::%s (not a valid member)"):format(tostring(key)), 2)
	end,
	__newindex = function(_, key, _)
		error(("Attempt to set Connection::%s (not a valid member)"):format(tostring(key)), 2)
	end,
})
export type Signal = {
	Connect: () -> (Connection),
	DisconnectAll: () -> void,
	Fire: (...any?) -> void,
	Wait: () -> (...any?),
}

local Signals = {}
Connections.IS_CYCLICAL = true
Signals.__index = Signals

function Signals.create(): Signal
	return setmetatable({
		_handlerListHead = false,
		USING_METATABLE = true,
		-- Metatable = Signals
	}, Signals)
end

function Signals:Connect(callback): Connection
	local connection = Connections.create(self, callback)
	if self._handlerListHead then
		connection._next = self._handlerListHead
		self._handlerListHead = connection
	else
		self._handlerListHead = connection
	end
	return connection
end

function Signals:DisconnectAll()
	self._handlerListHead = false
end

function Signals:Destroy()
	self._handlerListHead = false
end

function Signals:Fire(...: any)
	local item = self._handlerListHead
	while item do
		if item.Connected then
			if not freeRunnerThread then
				freeRunnerThread = coroutine.create(runEventHandlerInFreeThread)
			end
			task.spawn(freeRunnerThread, item._callback, ...)
		end
		item = item._next
	end
end

function Signals:Wait(): ...any?
	local waitingCoroutine = coroutine.running()
	local connection
	connection = self:Connect(function(...)
		connection:Disconnect()
		task.spawn(waitingCoroutine, ...)
	end)
	return coroutine.yield()
end

setmetatable(Signals, {
	__index = function(_, key)
		error(("Attempt to get Signal::%s (not a valid member)"):format(tostring(key)), 2)
	end,
	__newindex = function(_, key, _)
		error(("Attempt to set Signal::%s (not a valid member)"):format(tostring(key)), 2)
	end,
})

return Signals
