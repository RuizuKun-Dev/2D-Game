--| LICENSE: https://gist.github.com/RuizuKun-Dev/768981cc6d68f996a041a4fa1761ea02#file-license-txt

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utilities = ReplicatedStorage.Utilities
local instanceUtil = require(Utilities.instanceUtil)
local JSON = require(Utilities.JSON)
local t = require(Utilities.t) -- github.com/osyrisrblx/t

local CollectionService = game:GetService("CollectionService")

export type attributeUtil = {
	ClearAllAttributes: (instance: Instance) -> void,
	FindFirstChildWithAttribute: (parent: Instance, attribute: string, recursive: boolean?) -> Instance?,
	GetAttribute: (instance: Instance, key: string) -> (any),
	GetAttributes: (instance: Instance) -> (Dictionary),
	GetChildrenWithAttribute: (Instance, string) -> Array<Instance>,
	GetDescendantsWithAttribute: (Instance, string) -> Array<Instance>,
	IsSpecialType: (value: any) -> (boolean),
	IsSupportedType: (value: any) -> (boolean),
	SetAttribute: (instance: Instance, key: string, value: any) -> void,
	SetAttributes: (instance: Instance, attributes: { [string]: any }) -> void,
	WaitForChildWithAttribute: (parent: Instance, attribute: string, timeOut: number?) -> Instance?,
}

local attributeUtil = {}

export type SUPPORTED_TYPES = {
	BrickColor: boolean,
	Color: boolean,
	ColorSequence: boolean,
	NumberRange: boolean,
	NumberSequence: boolean,
	Rect: boolean,
	UDim: boolean,
	UDim2: boolean,
	Vector2: boolean,
	Vector3: boolean,
	boolean: boolean,
	number: boolean,
	string: boolean,
}

local SUPPORTED_TYPES: SUPPORTED_TYPES = {
	[typeof(BrickColor.random())] = true,
	[typeof(Color3.new())] = true,
	[typeof(ColorSequence.new(Color3.new()))] = true,
	[typeof(NumberRange.new(0))] = true,
	[typeof(NumberSequence.new(0))] = true,
	[typeof(Rect.new(Vector2.new(), Vector2.new()))] = true,
	[typeof(UDim.new())] = true,
	[typeof(UDim2.new())] = true,
	[typeof(Vector2.new())] = true,
	[typeof(Vector3.new())] = true,
	[typeof(true)] = true,
	[typeof(3.142)] = true,
	[typeof("string")] = "true",
	[typeof(nil)] = true,
}

export type SPECIAL_TYPES = {
	CFrame: CFrame,
	Instance: Instance,
	table: table,
}

local SPECIAL_TYPES: SPECIAL_TYPES = {
	[typeof(CFrame.new())] = true,
	[typeof(Instance.new("Configuration"))] = true,
	[typeof(table)] = true,
}

function attributeUtil.IsSupportedType(value: any): boolean
	return SUPPORTED_TYPES[typeof(value)]
end
local IsSupportedType = attributeUtil.IsSupportedType

function attributeUtil.IsSpecialType(value: any): boolean
	return SPECIAL_TYPES[typeof(value)]
end
local IsSpecialType = attributeUtil.IsSpecialType

local ClearAllAttributes_Check = t.tuple(t.Instance)
function attributeUtil.ClearAllAttributes(instance: Instance)
	assert(ClearAllAttributes_Check(instance))

	for key: string, _ in pairs(instance:GetAttributes()) do
		if key ~= "GUID" then
			instance:SetAttribute(key, nil)
		end
	end
end

local FindFirstChildWithAttribute_Check = t.tuple(t.Instance, t.string, t.optional(t.boolean))
function attributeUtil.FindFirstChildWithAttribute(
	parent: Instance,
	attribute: string,
	recursive: boolean?
): Instance | nil
	assert(FindFirstChildWithAttribute_Check(parent, attribute, recursive))

	if recursive then
		for _, descendant: Instance in ipairs(parent:GetDescendants()) do
			if descendant:GetAttribute(attribute) then
				return descendant
			end
		end
	else
		for _, child: Instance in ipairs(parent:GetChildren()) do
			if child:GetAttribute(attribute) then
				return child
			end
		end
	end

	return nil
end

local Codec = {}

function Codec.Decode(value: string): CFrame | Instance | table
	local success, decoded = pcall(JSON.Decode, value)

	if success then
		if typeof(decoded) == "table" then
			if decoded[1] == "CFrame:" then
				return CFrame.new(table.unpack(decoded[2])) :: CFrame
			elseif decoded[1] == "Instance:" then
				return CollectionService:GetTagged(decoded[2])[1] :: Instance
			elseif (decoded[1]):sub(1, 6) == "Table:" then
				return decoded[2] :: table
			end
		end
	end
end

local GetAttribute_Check = t.tuple(t.Instance, t.string)
function attributeUtil.GetAttribute(instance: Instance, key: string): any
	assert(GetAttribute_Check(instance, key))

	local value = instance:GetAttribute(key)

	return Codec.Decode(value) or value
end
local GetAttribute = attributeUtil.GetAttribute

local GetAttributes_Check = t.tuple(t.Instance)
function attributeUtil.GetAttributes(instance: Instance): Dictionary
	assert(GetAttributes_Check(instance))

	local attributes = instance:GetAttributes()

	for key: string, value: any in pairs(attributes) do
		attributes[key] = Codec.Decode(value) or value
	end

	return attributes
end

function Codec.Encode(value: CFrame | Instance | table): string
	if typeof(value) == "CFrame" then
		local cframe: CFrame = value
		return JSON.Encode({ "CFrame:", { cframe:GetComponents() } })
	elseif typeof(value) == "Instance" then
		local instance = value
		return JSON.Encode({ "Instance:", instance:GetAttribute("GUID") })
	elseif typeof(value) == "table" then
		local table: table = value
		return JSON.Encode({ "Table:" .. string.sub(tostring(table), 7), JSON.Filter(table, "JSON") })
	end
end

local GetChildrenWithAttribute_Check = t.tuple(t.Instance, t.string)
function attributeUtil.GetChildrenWithAttribute(parent: Instance, attribute: string): Array
	assert(GetChildrenWithAttribute_Check(parent, attribute))

	local cache = {}
	for _, child: Instance in ipairs(parent:GetChildren()) do
		if GetAttribute(child, attribute) ~= nil then
			table.insert(cache, child)
		end
	end
	return cache
end

local GetDescendantsWithAttribute_Check = t.tuple(t.Instance, t.string)
function attributeUtil.GetDescendantsWithAttribute(ancestor: Instance, attribute: string): Array
	assert(GetDescendantsWithAttribute_Check(ancestor, attribute))

	local cache = {}
	for _, descendant: Instance in ipairs(ancestor:GetDescendants()) do
		if GetAttribute(descendant, attribute) ~= nil then
			table.insert(cache, descendant)
		end
	end
	return cache
end

local SetAttribute_Check = t.tuple(t.Instance, t.union(t.string, t.integer), t.optional(t.any))
function attributeUtil.SetAttribute(instance: Instance, key: string, value: any)
	assert(SetAttribute_Check(instance, key, value))

	key = string.gsub(tostring(key):gsub("%f[%w]%l", string.upper), "[^%w_]+", "")

	if IsSupportedType(value) then
		instance:SetAttribute(key, value)
	elseif IsSpecialType(value) then
		instance:SetAttribute(key, Codec.Encode(value))
	end
end
local SetAttribute = attributeUtil.SetAttribute

local SetAttributes_Check = t.tuple(t.Instance, t.table)
function attributeUtil.SetAttributes(instance: Instance, attributes: Dictionary)
	assert(SetAttributes_Check(instance, attributes))

	for key: string, value: any in pairs(attributes) do
		SetAttribute(instance, key, value)
	end
end

local WaitForChildWithAttribute_Check = t.tuple(t.Instance, t.string, t.optional(t.number))
function attributeUtil.WaitForChildWithAttribute(parent: Instance, attribute: string, timeOut: number?): Instance | nil
	assert(WaitForChildWithAttribute_Check(parent, attribute, timeOut))

	local START_TIME = os.clock()
	local YIELD_UNTIL = (timeOut and timeOut + START_TIME or math.huge)

	local function yieldTooLongWarning()
		local CURRENT_TIME = os.clock()
		if CURRENT_TIME - START_TIME >= 5 then
			warn("Infinite yield possible on WaitForChildWithAttribute:", parent.Name, attribute)
			yieldTooLongWarning = nil
		end
	end

	local CURRENT_TIME = os.clock()
	while YIELD_UNTIL >= CURRENT_TIME do
		for _, child: Instance in ipairs(parent:GetChildren()) do
			if child:GetAttribute(attribute) then
				return child
			end
		end
		if yieldTooLongWarning then
			yieldTooLongWarning()
		end
		task.wait()
		CURRENT_TIME = os.clock()
	end

	return nil
end

local Display_Check = t.tuple(t.Instance, t.table)
function attributeUtil.Display(instance: Instance, dictionary: Dictionary)
	assert(Display_Check(instance, dictionary))

	for key: string, value: any in pairs(JSON.Filter(dictionary, "Display")) do
		if typeof(key) == "number" or typeof(key) == "string" then
			if typeof(value) == "table" then
				local configuration = instance:FindFirstChild(key) or Instance.new("Folder")
				configuration.Name = key
				configuration.Parent = instance
				attributeUtil.Display(configuration, value)
			else
				SetAttribute(instance, key, value)
			end
		end
	end
end

do
	local cache = {}

	local function isClone(instance: Instance): boolean
		return not cache[instance] and instance:GetAttribute("GUID")
	end

	local function setGUID(instance: Instance)
		local GUID = JSON.GenerateGUID(false)
		if isClone(instance) then
			local guid = instance:GetAttribute("GUID")
			CollectionService:RemoveTag(instance, guid)
		end

		instance:SetAttribute("GUID", GUID)
		CollectionService:AddTag(instance, GUID)
		cache[instance] = GUID
	end

	instanceUtil.doForAllDescendantsOf(game, function(descendant: Instance)
		pcall(setGUID, descendant)
	end)
end

return attributeUtil
