local collisiongroupUtil = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Configurations = require(ReplicatedStorage.Configurations)

local CollectionService = game:GetService("CollectionService")
local PhysicsService = game:GetService("PhysicsService")

local function setupCollisionGroups()
	for collisiongroupName: string, _ in pairs(Configurations.COLLISION_GROUPS) do
		PhysicsService:CreateCollisionGroup(collisiongroupName)
	end

	for collisiongroupName: string, collisiongroupData in pairs(Configurations.COLLISION_GROUPS) do
		for otherCollisiongroup, canCollide in pairs(collisiongroupData) do
			PhysicsService:CollisionGroupSetCollidable(collisiongroupName, otherCollisiongroup, canCollide)
		end
	end
end
setupCollisionGroups()

local function setCollisionGroup(BasePart: BasePart, CollisionGroupName: string)
	if BasePart:IsA("BasePart") then
		local previousCollisionGroup = PhysicsService:GetCollisionGroupName(BasePart.CollisionGroupId)
		CollectionService:RemoveTag(BasePart, previousCollisionGroup)
		PhysicsService:SetPartCollisionGroup(BasePart, CollisionGroupName)
		CollectionService:AddTag(BasePart, CollisionGroupName)
	end
end
collisiongroupUtil.setCollisionGroup = setCollisionGroup

function collisiongroupUtil.setAccessoriesCollisionGroup(humanoid: Humanoid, CollisionGroupName: string)
	for _, accessory: Accessory in ipairs(humanoid:GetAccessories()) do
		setCollisionGroup(accessory.Handle, CollisionGroupName)
	end
end

function collisiongroupUtil.setCharacterCollisionGroup(character: Model, CollisionGroupName: string)
	for _, descendants in ipairs(character:GetDescendants()) do
		setCollisionGroup(descendants, CollisionGroupName)
	end
end

return collisiongroupUtil
