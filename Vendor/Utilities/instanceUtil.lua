type Properties = { [string]: any }

export type InstanceUtil = {
	create: (className: string, properties: Properties, parent: Instance?) -> (Instance),
	setProperties: (instance: Instance, properties: Properties) -> (Instance),
	clearAllDescendantsOfClass: (ancestor: Instance, className: string) -> void,
	clearAllDescendantsOfClasses: (ancestor: Instance, classNames: Array<string>) -> void,
	doForAllDescendantsOf: (ancestor: Instance, callback: (Instance) -> void) -> void,
	forEachDescendantsOfClassDo: (ancestor: Instance, className: string, callback: (Instance) -> void) -> void,
	getAllDescendantsOfClass: (ancestor: Instance, className: string) -> (Array<Instance>),
}

--[[
	@class instanceUtil

	Utility functions for creating and setting properties on instances.
]]
local instanceUtil = {}

--[=[
    Sets the properties of an instance.

    @within instanceUtil
    @param instance Instance -- The instance you wanna set properties on
    @param properties Properties -- The properties you wanna set on the instance
]=]
function instanceUtil.setProperties(instance: Instance, properties: Properties, parent: Instance?)
	for property: string, value: any in pairs(properties) do
		instance[property] = value
	end

	if parent then
		instance.Parent = parent
	end
end

--[=[
    Creates an instance.

    @within instanceUtil
    @param className: string -- The name of the class you wanna create
    @param properties Properties -- The properties you wanna set on the instance
	@param parent Instance? -- The parent of the instance you wanna create
	@param instance Instance -- The instance you wanna create
]=]
function instanceUtil.create(className: string, properties: Properties, parent: Instance?): Instance
	local instance = Instance.new(className)

	instanceUtil.setProperties(instance, properties)

	instance.Parent = parent

	return instance
end

function instanceUtil.clearAllDescendantsOfClass(ancestor: Instance, className: string)
	for _, descendant: Instance in ipairs(ancestor:GetDescendants()) do
		if descendant:IsA(className) then
			descendant:Destroy()
		end
	end
end

function instanceUtil.clearAllDescendantsOfClasses(ancestor: Instance, classNames: Array<string>)
	for _, className: string in ipairs(classNames) do
		instanceUtil.clearAllDescendantsOfClass(ancestor, className)
	end
end

function instanceUtil.doForAllDescendantsOf(ancestor: Instance, callback: (Instance) -> void)
	for _, descendant: Instance in ipairs(ancestor:GetDescendants()) do
		task.spawn(callback, descendant)
	end

	ancestor.DescendantAdded:Connect(function(descendant: Instance)
		callback(descendant)
	end)
end

function instanceUtil.forEachDescendantsOfClassDo(ancestor: Instance, className: string, callback: (Instance) -> void)
	for _, descendant: Instance in ipairs(ancestor:GetDescendants()) do
		if descendant:IsA(className) then
			task.spawn(callback, descendant)
		end
	end
end

function instanceUtil.getAllDescendantsOfClass(ancestor: Instance, className: string): Array<Instance>
	local descendants = {}
	for _, descendant: Instance in ipairs(ancestor:GetDescendants()) do
		if descendant:IsA(className) then
			table.insert(descendants, descendant)
		end
	end
	return descendants
end

return instanceUtil
