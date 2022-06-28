local CollectionService = game:GetService("CollectionService")

local tagUtil = {}

function tagUtil.AddTag(instance: Instance, tag: string)
	CollectionService:AddTag(instance, tag)
end

function tagUtil.ClearAllTags(instance: Instance)
	for _, tag: string in ipairs(CollectionService:GetTags(instance)) do
		tagUtil.Remove(instance, tag)
	end
end

function tagUtil.HasTag(instance: Instance, tag: string): boolean
	return CollectionService:HasTag(instance, tag)
end

function tagUtil.RemoveTag(instance: Instance, tag: string)
	CollectionService:RemoveTag(instance, tag)
end

function tagUtil.doForTagged(tag: (string), callback: (Instance) -> void): RBXScriptConnection
	for _, instance: Instance in ipairs(CollectionService:GetTagged(tag)) do
		task.spawn(callback, instance)
	end

	return CollectionService:GetInstanceAddedSignal(tag):Connect(callback)
end

do
	local function setClassName(instance: Instance)
		if not game:FindService(instance.ClassName) then
			CollectionService:AddTag(instance, instance.ClassName)
		end
	end

	for _, descendant: Instance in ipairs(game:GetDescendants()) do
		task.spawn(pcall, setClassName, descendant)
	end

	game.DescendantAdded:Connect(function(descendant: Instance)
		task.defer(pcall, setClassName, descendant)
	end)
end

return tagUtil
