local GetPromiseLibrary = require(script.GetPromiseLibrary)
local RbxScriptConnection = require(script.RbxScriptConnection)
local Symbol = require(script.Symbol)
local FoundPromiseLibrary, Promise = GetPromiseLibrary()
local IndicesReference = Symbol("IndicesReference")
local LinkToInstanceIndex = Symbol("LinkToInstanceIndex")
local INVALID_METHOD_NAME =
	[[Object is a %s and as such expected `true?` for the method name and instead got %s. Traceback: %s]]
local METHOD_NOT_FOUND_ERROR = [[Object %s doesn't have method %s, are you sure you want to add it? Traceback: %s]]
local NOT_A_PROMISE = [[Invalid argument #1 to 'Janitor:AddPromise' (Promise expected, got %s (%s)) Traceback: %s]]
local Janitor = {}

Janitor.ClassName = "Janitor"
Janitor.CurrentlyCleaning = true
Janitor[IndicesReference] = nil
Janitor.__index = Janitor

local TypeDefaults = {
	["function"] = true,
	thread = true,
	RBXScriptConnection = "Disconnect",
}

function Janitor.new()
	return setmetatable({
		CurrentlyCleaning = false,
		[IndicesReference] = nil,
	}, Janitor)
end
function Janitor.Is(Object)
	return type(Object) == "table" and getmetatable(Object) == Janitor
end
function Janitor:Add(Object, MethodName, Index)
	if Index then
		self:Remove(Index)

		local This = self[IndicesReference]

		if not This then
			This = {}
			self[IndicesReference] = This
		end

		This[Index] = Object
	end

	local TypeOf = typeof(Object)
	local NewMethodName = MethodName or TypeDefaults[TypeOf] or "Destroy"

	if TypeOf == "function" or TypeOf == "thread" then
		if NewMethodName ~= true then
			warn(string.format(INVALID_METHOD_NAME, TypeOf, tostring(NewMethodName), debug.traceback(nil, 2)))
		end
	else
		if not (Object)[NewMethodName] then
			warn(
				string.format(
					METHOD_NOT_FOUND_ERROR,
					tostring(Object),
					tostring(NewMethodName),
					debug.traceback(nil, 2)
				)
			)
		end
	end

	self[Object] = NewMethodName

	return Object
end
function Janitor:AddPromise(PromiseObject)
	if FoundPromiseLibrary then
		if not Promise.is(PromiseObject) then
			error(string.format(NOT_A_PROMISE, typeof(PromiseObject), tostring(PromiseObject), debug.traceback(nil, 2)))
		end
		if PromiseObject:getStatus() == Promise.Status.Started then
			local Id = newproxy(false)
			local NewPromise = self:Add(
				Promise.new(function(Resolve, _, OnCancel)
					if OnCancel(function()
						PromiseObject:cancel()
					end) then
						return
					end

					Resolve(PromiseObject)
				end),
				"cancel",
				Id
			)

			NewPromise:finallyCall(self.Remove, self, Id)

			return NewPromise
		else
			return PromiseObject
		end
	else
		return PromiseObject
	end
end
function Janitor:Remove(Index)
	local This = self[IndicesReference]

	if This then
		local Object = This[Index]

		if Object then
			local MethodName = self[Object]

			if MethodName then
				if MethodName == true then
					if type(Object) == "function" then
						Object()
					else
						task.cancel(Object)
					end
				else
					local ObjectMethod = Object[MethodName]

					if ObjectMethod then
						ObjectMethod(Object)
					end
				end

				self[Object] = nil
			end

			This[Index] = nil
		end
	end

	return self
end
function Janitor:RemoveList(...)
	local This = self[IndicesReference]

	if This then
		local Length = select("#", ...)

		if Length == 1 then
			return self:Remove(...)
		else
			for Index = 1, Length do
				local Object = This[select(Index, ...)]

				if Object then
					local MethodName = self[Object]

					if MethodName then
						if MethodName == true then
							if type(Object) == "function" then
								Object()
							else
								task.cancel(Object)
							end
						else
							local ObjectMethod = Object[MethodName]

							if ObjectMethod then
								ObjectMethod(Object)
							end
						end

						self[Object] = nil
					end

					This[Index] = nil
				end
			end
		end
	end

	return self
end

function Janitor:Get(Index: any): any?
	local This = self[IndicesReference]
	return if This then This[Index] else nil
end

local function GetFenv(self)
	return function()
		for Object, MethodName in next, self do
			if Object ~= IndicesReference then
				return Object, MethodName
			end
		end
	end
end

function Janitor:Cleanup()
	if not self.CurrentlyCleaning then
		self.CurrentlyCleaning = nil

		local Get = GetFenv(self)
		local Object, MethodName = Get()

		while Object and MethodName do
			if MethodName == true then
				if type(Object) == "function" then
					Object()
				else
					task.cancel(Object)
				end
			else
				local ObjectMethod = Object[MethodName]

				if ObjectMethod then
					ObjectMethod(Object)
				end
			end

			self[Object] = nil
			Object, MethodName = Get()
		end

		local This = self[IndicesReference]

		if This then
			table.clear(This)

			self[IndicesReference] = {}
		end

		self.CurrentlyCleaning = false
	end
end
function Janitor:Destroy()
	self:Cleanup()
	table.clear(self)
	setmetatable(self, nil)
end

Janitor.__call = Janitor.Cleanup

function Janitor:LinkToInstance(Object, AllowMultiple)
	local IndexToUse = AllowMultiple and newproxy(false) or LinkToInstanceIndex

	return self:Add(
		Object.Destroying:Connect(function()
			self:Cleanup()
		end),
		"Disconnect",
		IndexToUse
	)
end
function Janitor:LegacyLinkToInstance(Object, AllowMultiple)
	local Connection
	local IndexToUse = AllowMultiple and newproxy(false) or LinkToInstanceIndex
	local IsNilParented = Object.Parent == nil
	local ManualDisconnect = setmetatable({}, RbxScriptConnection)

	local function ChangedFunction(_DoNotUse, NewParent)
		if ManualDisconnect.Connected then
			_DoNotUse = nil
			IsNilParented = NewParent == nil

			if IsNilParented then
				task.defer(function()
					if not ManualDisconnect.Connected then
						return
					elseif not Connection.Connected then
						self:Cleanup()
					else
						while IsNilParented and Connection.Connected and ManualDisconnect.Connected do
							task.wait()
						end

						if ManualDisconnect.Connected and IsNilParented then
							self:Cleanup()
						end
					end
				end)
			end
		end
	end

	Connection = Object.AncestryChanged:Connect(ChangedFunction)
	ManualDisconnect.Connection = Connection

	if IsNilParented then
		ChangedFunction(nil, Object.Parent)
	end

	Object = nil

	return self:Add(ManualDisconnect, "Disconnect", IndexToUse)
end
function Janitor:LinkToInstances(...)
	local ManualCleanup = Janitor.new()

	for _, Object in ipairs({ ... }) do
		ManualCleanup:Add(self:LinkToInstance(Object, true), "Disconnect")
	end

	return ManualCleanup
end
function Janitor:__tostring()
	return "Janitor"
end

table.freeze(Janitor)

return Janitor
