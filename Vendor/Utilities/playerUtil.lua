local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utilities = ReplicatedStorage.Utilities
local TypeChecks = require(Utilities.TypeChecks)

local CollectionService = game:GetService("CollectionService")

local playerUtil = { PlayerAdded = {}, PlayerRemoving = {}, TeamChanged = {}, script = script }

function playerUtil.freezeHumanoid(humanoid: Humanoid)
	TypeChecks.Strict.Humanoid(humanoid)

	local walkspeed = humanoid.WalkSpeed
	local jumppower = humanoid.JumpPower
	humanoid.WalkSpeed = 0
	humanoid.JumpPower = 0
	return function()
		humanoid.WalkSpeed = walkspeed
		humanoid.JumpPower = jumppower
	end
end

function playerUtil.getPlayerFromPart(basepart: BasePart): Player?
	TypeChecks.Strict.BasePart(basepart)

	local character: Model = basepart:FindFirstAncestorOfClass("Model")
	local player: Player = character
		and (
			Players:GetPlayerFromCharacter(character)
			or CollectionService:GetTagged(character:GetAttribute("Player") or "")[1]
		)
	return player
end

function playerUtil.getPlayerFromHumanoid(humanoid: Humanoid): Player?
	TypeChecks.Strict.Humanoid(humanoid)
	local player: Player = Players:GetPlayerFromCharacter(humanoid:FindFirstAncestorOfClass("Model"))
	return player
end

local function getCharacterFromPart(basepart: BasePart): Model?
	TypeChecks.Strict.BasePart(basepart)

	local player: Player = playerUtil.getPlayerFromPart(basepart)
	local character: Model = player and player.Character
	return character
end
playerUtil.getCharacterFromPart = getCharacterFromPart

function playerUtil.getHumanoidFromPart(basepart: BasePart): Humanoid?
	TypeChecks.Strict.BasePart(basepart)

	local character: Model = getCharacterFromPart(basepart)
	local humanoid: Humanoid = character and character:FindFirstChildOfClass("Humanoid")
	return humanoid
end

function playerUtil.getPlayerInfoFromPart(basepart: BasePart): PlayerInfo
	TypeChecks.Strict.BasePart(basepart)

	local character: Model = basepart:FindFirstAncestorOfClass("Model")
	local player: Player = character
		and (
			Players:GetPlayerFromCharacter(character)
			or CollectionService:GetTagged(character:GetAttribute("Player") or "")[1]
		)
	local humanoid: Humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local rootpart: BasePart = humanoid and humanoid.RootPart
	return {
		Player = player,
		Character = character,
		Humanoid = humanoid,
		Head = character.Head,
		RootPart = rootpart,
		HumanoidRootPart = rootpart,
	}
end

export type PlayerInfo = {
	Player: Player,
	Character: Model,
	Humanoid: Humanoid,
	Head: BasePart,
	RootPart: BasePart,
	HumanoidRootPart: BasePart,
}

function playerUtil.getPlayerInfo(player: Player): PlayerInfo
	TypeChecks.Strict.Player(player)

	local character: Model = player:IsA("Player") and player.Character
		or CollectionService:GetTagged(player:GetAttribute("Character") or "")[1]
	local humanoid: Humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local rootpart: BasePart = humanoid and humanoid.RootPart
	return {
		Player = player,
		Character = character,
		Humanoid = humanoid,
		Head = character.Head,
		RootPart = rootpart,
		HumanoidRootPart = rootpart,
	}
end

function playerUtil.getHumanoidOfPlayer(player: Player): Humanoid?
	TypeChecks.Strict.Player(player)

	return player.Character and player.Character:FindFirstChildOfClass("Humanoid")
end

function playerUtil.isHumanoidAlive(humanoid: Humanoid): boolean
	TypeChecks.Strict.Humanoid(humanoid)

	return humanoid.Health > 0
end

local DEAD = Enum.HumanoidStateType.Dead

function playerUtil.killHumanoid(humanoid: Humanoid)
	TypeChecks.Strict.Humanoid(humanoid)

	humanoid:SetStateEnabled(DEAD, true)
	humanoid:ChangeState(DEAD)
	humanoid.Health = 0
end

function playerUtil.isValidCharacter(character: Model): boolean
	TypeChecks.Strict.Model(character)

	return character and character:FindFirstChildOfClass("Humanoid") and character.Humanoid.RootPart and true
end

function playerUtil.validateTarget(targetInfo): boolean?
	if targetInfo then
		local player: Player = targetInfo.Player
		local character: Model = targetInfo.Character
		local humanoid: Humanoid = targetInfo.Humanoid

		if player and character and humanoid then
			if player:IsA("Player") and player.Character == character then
				if playerUtil.getHumanoidOfPlayer(player) == humanoid then
					return humanoid.Health > 0
				end
			elseif player:IsA("Configuration") then
				return humanoid.Health > 0
			end
		end
	end
end

function playerUtil.getPlayerFromHumanoid(humanoid: Humanoid): Player
	TypeChecks.Strict.Humanoid(humanoid)
	local character: Model = humanoid:FindFirstAncestorOfClass("Model")
	local player: Player = Players:GetPlayerFromCharacter(character)
	return player
end

function playerUtil.handlePlayerAdded(callback)
	table.insert(playerUtil.PlayerAdded, callback)

	for _, player: Player in ipairs(Players:GetPlayers()) do
		task.spawn(callback, player)
	end
end

Players.PlayerAdded:Connect(function(player: Player)
	for _, callback in ipairs(playerUtil.PlayerAdded) do
		task.spawn(callback, player)
	end
end)

function playerUtil.handlePlayerRemoving(callback)
	table.insert(playerUtil.PlayerRemoving, callback)
end

Players.PlayerRemoving:Connect(function(player: Player)
	for _, callback in ipairs(playerUtil.PlayerRemoving) do
		task.spawn(callback, player)
	end
end)

if localPlayer then
	function playerUtil.isLocalPlayer(player: Player): boolean
		return player == localPlayer
	end

	function playerUtil.handleTeamChanged(callback)
		table.insert(playerUtil.TeamChanged, callback)

		for _, player: Player in ipairs(Players:GetPlayers()) do
			task.spawn(callback, player)
		end
	end

	localPlayer:GetPropertyChangedSignal("Team"):Connect(function()
		for _, callback in ipairs(playerUtil.TeamChanged) do
			task.spawn(callback)
		end
	end)
end

return playerUtil
