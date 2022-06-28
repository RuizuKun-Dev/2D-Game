local freeRunnerThread = nil

local function acquireRunnerThreadAndCallEventHandler(fn, ...)
    local acquiredRunnerThread = freeRunnerThread

    freeRunnerThread = nil

    fn(...)

    freeRunnerThread = acquiredRunnerThread
end
local function runEventHandlerInFreeThread(...)
    acquireRunnerThreadAndCallEventHandler(...)

    while true do
        acquireRunnerThreadAndCallEventHandler(coroutine.yield())
    end
end

local Connection = {}

Connection.__index = Connection

function Connection.new(signal, fn)
    return setmetatable({
        Connected = true,
        _signal = signal,
        _fn = fn,
        _next = false,
    }, Connection)
end
function Connection:Disconnect()
    if not self.Connected then
        return
    end

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
end

Connection.Destroy = Connection.Disconnect

setmetatable(Connection, {
    __index = function(_tb, key)
        if key ~= '_handlerListHead' then
            error(('Attempt to get Connection::%s (not a valid member)'):format(tostring(key)), 2)
        end
    end,
    __newindex = function(_tb, key, _value)
        error(('Attempt to set Connection::%s (not a valid member)'):format(tostring(key)), 2)
    end,
})

local Signal = {}

Signal.__index = Signal

function Signal.new()
    local self = setmetatable({
        _handlerListHead = false,
        _proxyHandler = nil,
    }, Signal)

    return self
end
function Signal.Wrap(rbxScriptSignal)
    assert(typeof(rbxScriptSignal) == 'RBXScriptSignal', 'Argument #1 to Signal.Wrap must be a RBXScriptSignal; got ' .. typeof(rbxScriptSignal))

    local signal = Signal.new()

    signal._proxyHandler = rbxScriptSignal:Connect(function(...)
        signal:Fire(...)
    end)

    return signal
end
function Signal.Is(obj)
    return type(obj) == 'table' and getmetatable(obj) == Signal
end
function Signal:Connect(fn)
    local connection = Connection.new(self, fn)

    if self._handlerListHead then
        connection._next = self._handlerListHead
        self._handlerListHead = connection
    else
        self._handlerListHead = connection
    end

    return connection
end
function Signal:GetConnections()
    local items = {}
    local item = self._handlerListHead

    while item do
        table.insert(items, item)

        item = item._next
    end

    return items
end
function Signal:DisconnectAll()
    local item = self._handlerListHead

    while item do
        item.Connected = false
        item = item._next
    end

    self._handlerListHead = false
end
function Signal:Fire(...)
    local item = self._handlerListHead

    while item do
        if item.Connected then
            if not freeRunnerThread then
                freeRunnerThread = coroutine.create(runEventHandlerInFreeThread)
            end

            task.spawn(freeRunnerThread, item._fn, ...)
        end

        item = item._next
    end
end
function Signal:FireDeferred(...)
    local item = self._handlerListHead

    while item do
        task.defer(item._fn, ...)

        item = item._next
    end
end
function Signal:Wait()
    local waitingCoroutine = coroutine.running()
    local cn

    cn = self:Connect(function(...)
        cn:Disconnect()
        task.spawn(waitingCoroutine, ...)
    end)

    return coroutine.yield()
end
function Signal:Destroy()
    self:DisconnectAll()

    local proxyHandler = rawget(self, '_proxyHandler')

    if proxyHandler then
        proxyHandler:Disconnect()
    end
end

setmetatable(Signal, {
    __index = function(_tb, key)
        if key ~= 'Connected' then
            error(('Attempt to get Signal::%s (not a valid member)'):format(tostring(key)), 2)
        end
    end,
    __newindex = function(_tb, key, _value)
        error(('Attempt to set Signal::%s (not a valid member)'):format(tostring(key)), 2)
    end,
})

return Signal
