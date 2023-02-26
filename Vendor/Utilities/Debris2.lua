local Debris2 = {
	Instances = {},
}

local RunService = game:GetService("RunService")
local Heartbeat = RunService.Heartbeat

local Instances = Debris2.Instances

local Connections = {}

local ValidTypes = {
	["Instance"] = "Destroy",
	["table"] = {},
	["RBXScriptConnection"] = "Disconnect",
}

local METHODS = {
	"Destroy",
	"Disconnect",
}

local function removeItem(typeOf: string, object: Instance)
	if typeOf == "Instance" then
		pcall(object.Destroy, object)
	elseif typeOf == "RBXScriptConnection" then
		pcall(object.Disconnect, object)
	else
		for _, v: string in ipairs(METHODS) do -- _, v: method name
			if object[v] then
				pcall(object[v], v)
				break
			end
		end
	end
end

local function addDebris(object: Instance, lifeTime: number)
	local typeOf = typeof(object)

	assert(ValidTypes[typeof(object)], "not valid type")
	assert(typeof(lifeTime) == "number", "lifeTime must be a number")

	if not Instances[object] then
		table.insert(Instances, object)
	end

	Instances[object] = {
		["lifeTime"] = lifeTime,
		removalTime = tick() + lifeTime,
		Cancel = function()
			Connections[object]:Disconnect()
			table.remove(Instances, table.find(Instances, object))
			Instances[object] = nil
		end,
		["Instance"] = object,
	}

	local debris = Instances[object]

	Connections[object] = Heartbeat:Connect(function()
		if debris and tick() >= debris.removalTime then
			if debris.Destroyed then
				debris.Destroyed()
			end
			debris.Cancel()
			removeItem(typeOf, object)
		end
		debris = Instances[object]
	end)

	return Instances[object]
end

function Debris2:AddItem(item, lifeTime: number)
	return addDebris(item, lifeTime)
end

function Debris2:AddItems(arrayOfItems: Array, lifeTime: number)
	for _, item in ipairs(arrayOfItems) do
		addDebris(item, lifeTime)
	end
end

function Debris2.GetAllDebris(): Instances
	return Instances
end

function Debris2.GetDebris(item)
	return Instances[item]
end

return Debris2
