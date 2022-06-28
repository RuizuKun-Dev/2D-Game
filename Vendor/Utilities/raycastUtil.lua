local camera = workspace.CurrentCamera

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local mouse

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utilities = ReplicatedStorage.Utilities
local characterUtil = require(Utilities.characterUtil)

local CollectionService = game:GetService("CollectionService")

local RunService = game:GetService("RunService")

local raycastUtil = {}

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
raycastParams.IgnoreWater = true

local DEFAULT_MAX_DISTANCE = 1000

local WorldRootIgnoreLists = {}

local function _getIgnoredPartsForWorldRoot(worldroot: WorldRoot)
	if not WorldRootIgnoreLists[worldroot] then
		local IgnoredParts = {}
		for _, descendant: Instance in ipairs(worldroot:GetDescendants()) do
			if descendant:IsA("BasePart") then
				local BasePart: BasePart = descendant
				if not BasePart.CanCollide or BasePart.Transparency == 1 then
					if not CollectionService:HasTag(BasePart, "RaycastWhitelist") then
						table.insert(IgnoredParts, BasePart)
					end
				end
			end
		end
		WorldRootIgnoreLists[worldroot] = IgnoredParts
	end
	return WorldRootIgnoreLists[worldroot]
end
raycastUtil.getIgnoredPartsForWorldRoot = _getIgnoredPartsForWorldRoot

local function _handleIgnoredPartsForWorldRoot(worldroot: WorldRoot)
	if not WorldRootIgnoreLists[worldroot] then
		local IgnoredParts = {}

		for _, descendant: Instance in ipairs(worldroot:GetDescendants()) do
			if descendant:IsA("BasePart") then
				local BasePart: BasePart = descendant
				if not BasePart.CanCollide or BasePart.Transparency == 1 then
					if not CollectionService:HasTag(BasePart, "RaycastWhitelist") then
						table.insert(IgnoredParts, BasePart)
					end
				end
			end
		end

		worldroot.DescendantAdded:Connect(function(AddedDescendant: Instance)
			if AddedDescendant:IsA("BasePart") then
				local BasePart: BasePart = AddedDescendant
				if not BasePart.CanCollide or BasePart.Transparency == 1 then
					if not CollectionService:HasTag(BasePart, "RaycastWhitelist") then
						table.insert(IgnoredParts, BasePart)
					end
				end
			end
		end)

		worldroot.DescendantRemoving:Connect(function(RemovedDescendant: Instance)
			if RemovedDescendant:IsA("BasePart") then
				local BasePart: BasePart = RemovedDescendant
				table.remove(IgnoredParts, table.find(IgnoredParts, BasePart))
			end
		end)

		WorldRootIgnoreLists[worldroot] = IgnoredParts
	end
end
raycastUtil.handleIgnoredPartsForWorldRoot = _handleIgnoredPartsForWorldRoot

function raycastUtil.RaycastFromMouse(IgnoredParts: table?, maxDistance: number?): RaycastResult?
	local mouseRay: Ray = camera:ScreenPointToRay(mouse.X, mouse.Y)
	raycastParams.FilterDescendantsInstances = IgnoredParts
	return workspace:Raycast(mouseRay.Origin, mouseRay.Direction * (maxDistance or DEFAULT_MAX_DISTANCE), raycastParams)
end

function raycastUtil.Raycast(worldroot: WorldRoot, Origin: Vector3, Direction: Vector3): RaycastResult?
	raycastParams.FilterDescendantsInstances = _getIgnoredPartsForWorldRoot(worldroot)
	return worldroot:Raycast(Origin, Direction, raycastParams)
end

if RunService:IsClient() then
	mouse = localPlayer:GetMouse()

	_handleIgnoredPartsForWorldRoot(workspace)
	local IgnoredParts = _getIgnoredPartsForWorldRoot(workspace)

	characterUtil.handleCharacterDied(localPlayer, function(character: Model)
		task.wait()
		table.insert(IgnoredParts, character)
	end)

	characterUtil.handleCharacterRemoving(localPlayer, function(character: Model)
		task.wait()
		table.remove(IgnoredParts, table.find(IgnoredParts, character))
	end)
end

return raycastUtil
