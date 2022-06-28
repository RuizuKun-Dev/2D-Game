local characterUtil = { script = script }

local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Network = require(ReplicatedStorage.Network)

local Configurations = require(ReplicatedStorage.Configurations)

local Utilities = ReplicatedStorage.Utilities
local Janitor = require(Utilities.Janitor)
local instanceUtil = require(Utilities.instanceUtil)
local playerUtil = require(Utilities.playerUtil)
local t = require(Utilities.t)
local TypeChecks = require(Utilities.TypeChecks)
local waitUntil = require(Utilities.waitUntil)

local connections = Janitor.new()

local RunService = game:GetService("RunService")

local QUICK_CHARACTER_LOADING = false

local function getHumanoidDescriptionFromUserId(player: Player): HumanoidDescription | boolean
	TypeChecks.Strict.Player(player)
	local success: boolean, result = pcall(Players.GetHumanoidDescriptionFromUserId, Players, player.UserId)
	if success then
		return result
	end
	return false
end

local function loadCharacterWithHumanoidDescription(player: Player): boolean
	TypeChecks.Strict.Player(player)
	local humanoidDescription = getHumanoidDescriptionFromUserId(player)
	if humanoidDescription then
		local sucess: boolean = pcall(player.LoadCharacterWithHumanoidDescription, player, humanoidDescription)
		return sucess
	end
	return false
end

local cache = {}
local function getCharacterAppearance(player: Player): Model | boolean
	TypeChecks.Strict.Player(player)
	if cache[player] then
		return cache[player]
	else
		local success, result = pcall(Players.GetCharacterAppearanceAsync, Players, player.UserId)
		if success then
			cache[player] = result
			return result
		end
		return false
	end
end

local function setCharacterAppearance(player: Player, characterAppearance: Model)
	local character: Model = player.Character
	local head: BasePart = character:WaitForChild("Head")
	local humanoid: Humanoid = character:WaitForChild("Humanoid")

	for _, v: Instance in ipairs(characterAppearance:GetChildren()) do
		if v.Name == "R15ArtistIntent" or v.Name == "R15" or v.Name == "R15Fixed" then
			local bodyparts = v
			for _, child: Instance in ipairs(bodyparts:GetChildren()) do
				local bodyPart: BasePart = character:FindFirstChild(child.Name)
				if bodyPart then
					humanoid:ReplaceBodyPartR15(humanoid:GetBodyPartR15(bodyPart), child)
				end
			end
		elseif v.Name == "R15Anim" then
			local animations = v
			for _, child: Instance in ipairs(animations:GetChildren()) do
				local animation: Animation = character.Animate:FindFirstChild(child.Name)
				if animation then
					animation:Destroy()
					child.Parent = character.Animate
				end
			end
		elseif v:IsA("Accessory") then
			humanoid:AddAccessory(v)
		elseif v:IsA("Decal") then
			local face: Decal = head:FindFirstChildOfClass("Decal")
			if face then
				face.Texture = v.Texture
			else
				v.Parent = head
			end
		elseif v:IsA("SpecialMesh") then
			v.Parent = head
		elseif v:IsA("CharacterAppearance") then
			v.Parent = character
		end
	end

	humanoid:BuildRigFromAttachments()
	characterAppearance:Destroy()
end

local function loadCharacterWithAppearance(player: Player)
	TypeChecks.Strict.Player(player)
	local characterAppearance = getCharacterAppearance(player)
	if characterAppearance then
		setCharacterAppearance(player, characterAppearance:Clone())
	end
end

function characterUtil.loadCharacter(player: Player): Model
	TypeChecks.Strict.Player(player)
	if QUICK_CHARACTER_LOADING and RunService:IsStudio() then
		pcall(player.LoadCharacter, player)
		warn("QUICK_CHARACTER_LOADING")
		return player.Character
	end

	if player:IsDescendantOf(Players) then
		if loadCharacterWithHumanoidDescription(player) then
			return player.Character
		elseif pcall(player.LoadCharacter, player) then
			loadCharacterWithAppearance(player)
		end
	end
	return player.Character
end

local MaterialWhitelist = {
	[Enum.Material.Neon] = true,
	[Enum.Material.ForceField] = true,
	[Enum.Material.Glass] = true,
}

local function isWhitelistMaterial(material: EnumItem): boolean
	return MaterialWhitelist[material]
end

local function setMaterial(basepart: BasePart, material: EnumItem)
	if not isWhitelistMaterial(basepart.Material) then
		basepart.Material = material
	end
end

function characterUtil.setCharacterMaterial(character: Model, material: EnumItem)
	for _, descendant: Instance in ipairs(character:GetDescendants()) do
		if descendant:IsA("BasePart") then
			local basePart: BasePart = descendant
			setMaterial(basePart, material)
		end
	end
end

function characterUtil.disableHumanoidStates(humanoid: Humanoid, states: EnumItem)
	if humanoid and humanoid:IsA("Humanoid") then
		for state: EnumItem, enable: boolean in pairs(states or Configurations.HUMANOID_STATES) do
			humanoid:SetStateEnabled(state, enable)
		end
	end
end

function characterUtil.setCharacterMassless(character: Model, bool: boolean)
	for _: ingeter, descendant: Instance in ipairs(character:GetDescendants()) do
		if descendant:IsA("BasePart") then
			local basePart: BasePart = descendant
			basePart.Massless = bool
		end
	end
end

function characterUtil.setCharacterShadow(character: Model, bool: boolean)
	for _, descendant: Instance in ipairs(character:GetDescendants()) do
		if descendant:IsA("BasePart") then
			local basePart: BasePart = descendant
			basePart.CastShadow = bool
		end
	end
end

function characterUtil.setCharacterTransparency(character: Model, transparency: number)
	for _, descendant: Instance in ipairs(character:GetDescendants()) do
		if descendant:IsA("BasePart") then
			local basePart: BasePart = descendant
			basePart.Transparency = transparency
		end
	end
end

function characterUtil.setAccessoryCollisionPhysics(humanoid: Humanoid, bool: boolean)
	for _, accessory: Accessory in ipairs(humanoid:GetAccessories()) do
		accessory.Handle.CanCollide = bool
		accessory.Handle.CanTouch = bool
		accessory.Handle.CanQuery = bool
	end
end

characterUtil.Default_ClassBlacklist = {
	"Beam",
	"Fire",
	"Light",
	"Model",
	"ParticleEmitter",
	"PointLight",
	"Smoke",
	"Sound",
	"Sparkles",
	"SpotLight",
	"Tool",
	"Trail",
}

function characterUtil.cloneCharacterWithFilter(character: Model, classBlacklist: Array<string>?): Model
	local clone: Model = character:Clone()
	instanceUtil.clearAllDescendantsOfClasses(clone, classBlacklist or characterUtil.Default_ClassBlacklist)

	instanceUtil.forEachDescendantsOfClassDo(clone, "BasePart", function(bodypart: BasePart)
		instanceUtil.setProperties(bodypart, {
			--📝 When an Instance is cloned all properties are copied including Velocity, so we must clear it
			Velocity = Vector3.new(0, 0, 0),
			Transparency = 0,
		})
		if bodypart.Name == "HumanoidRootPart" then
			bodypart.Transparency = 1
		end
	end)

	return clone
end

if RunService:IsClient() then
	local characterUtil_Remote = Network.get("characterUtil_Remote")

	function characterUtil.teleportCharacter(character: Model, cframe: CFrame)
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			character:SetAttribute("LastTeleportLocation", cframe.Position)
			character:SetPrimaryPartCFrame(cframe + Vector3.new(0, humanoid.hipHeight, 0))
			character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
		end
	end

	Network.handleClientEvents(characterUtil_Remote, {
		teleportCharacter = t.wrap(characterUtil.teleportCharacter, TypeChecks.Model, t.CFrame),
	})
elseif RunService:IsServer() then
	local characterUtil_Remote = Network.create("characterUtil_Remote")
	function characterUtil.teleportCharacter(character: Model, cframe: CFrame)
		local player = Players:GetPlayerFromCharacter(character)
		if player then
			characterUtil_Remote.FireClient(player, "teleportCharacter", character, cframe)
		end
	end
end

function characterUtil.isPlayerCharacter(player: Player, model: Model): boolean
	return model.Name == player.Name
end

local Characters = {}

local DEAD = Enum.HumanoidStateType.Dead

function characterUtil.handleCharacterAdded(player: Player, callback)
	table.insert(Characters[player].CharacterAdded, callback)

	if player.Character then
		if characterUtil.isPlayerCharacter(player, player.Character) then
			waitUntil(workspace).IsAncestorOf(player.Character)
			player.Character:WaitForChild("Humanoid")
			callback(player.Character)
		end
	end
end

function characterUtil.handleCharacterRemoving(player: Player, callback)
	table.insert(Characters[player].CharacterRemoving, callback)
end

function characterUtil.handleCharacterDied(player: Player, callback)
	table.insert(Characters[player].Died, callback)
end

playerUtil.handlePlayerAdded(function(player: Player)
	Characters[player] = {
		CharacterAdded = {},
		CharacterRemoving = {},
		Died = {},
	}

	local humanoid: Humanoid

	local function characterAdded(character: Model)
		if Characters[player] then
			if characterUtil.isPlayerCharacter(player, character) then
				waitUntil(workspace).IsAncestorOf(character)

				humanoid = character:WaitForChild("Humanoid")

				for _, callback in ipairs(Characters[player].CharacterAdded) do
					task.spawn(callback, character)
				end

				local function died()
					connections:Remove(humanoid)

					if Characters[player] then
						for _, callback in ipairs(Characters[player].Died) do
							task.spawn(callback, humanoid)
						end
					end
				end

				connections:Add(humanoid.Died:Connect(died), "Disconnect", humanoid)
			end
		end
	end

	task.spawn(characterAdded, player.Character or player.CharacterAdded:Wait())

	player.CharacterAdded:Connect(characterAdded)

	local function characterRemoving(character: Model)
		humanoid:SetStateEnabled(DEAD, true)
		humanoid:ChangeState(DEAD)

		if Characters[player] then
			for _, callback in ipairs(Characters[player].CharacterRemoving) do
				task.spawn(callback, character)
			end
		end
	end

	player.CharacterRemoving:Connect(characterRemoving)
end)

playerUtil.handlePlayerRemoving(t.wrap(function(player: Player)
	Characters[player] = nil
end, TypeChecks.Player))

return characterUtil
