--# selene: allow(shadowing)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utilities = ReplicatedStorage.Utilities
local attributeUtil = require(Utilities.attributeUtil)
local instanceUtil = require(Utilities.instanceUtil)
local JSON = require(Utilities.JSON)
local t = require(Utilities.t)
local TypeChecks = require(Utilities.TypeChecks)
local tagUtil = require(Utilities.tagUtil)

local SoundRegistry = require(script.SoundRegistry)

local SoundSystem = setmetatable({
	USING_METATABLE = true,
	-- Metatable = SoundRegistry,
}, SoundRegistry)

TypeChecks.Strict.SFXCheck = t.strict(t.tuple(t.string, t.Instance))

local function shouldPlaySFX(parent: Instance, spriteName: string): boolean
	-- return true if parent does not have spriteTag
	return (not tagUtil.HasTag(parent, spriteName))
end

local function PlaySound(sound: Sound)
	if not sound:GetAttribute("FailedToLoad") and not sound.IsLoaded then
		sound.Loaded:Wait()
	end

	sound:Play()
end

local function createSoundAttributes(splice)
	local duration = (splice.End - splice.Start) / splice.Sound.PlaybackSpeed

	return {
		CreationTime = workspace:GetServerTimeNow(),

		Start = splice.Start,
		End = splice.End,

		Duration = duration,

		Hash = JSON.GenerateGUID(false),
	}
end

function SoundSystem.PlaySFX(spriteName: string, parent: Instance): Sound?
	TypeChecks.Strict.SFXCheck(spriteName, parent)

	if shouldPlaySFX(parent, spriteName) then
		tagUtil.AddTag(parent, spriteName)
		local splice: Splice = SoundRegistry.getRandomSpliceFromSprite(spriteName)
		if splice then
			local sound: Sound = splice.Sound:Clone()
			sound.Archivable = false

			local soundAttributes = createSoundAttributes(splice)
			soundAttributes.Play = true

			attributeUtil.SetAttributes(sound, soundAttributes)

			instanceUtil.setProperties(
				sound,
				{ Name = spriteName, TimePosition = splice.Start, Playing = true },
				parent
			)

			PlaySound(sound)

			return sound
		else
			warn(spriteName .. " is NOT a valid member of Sounds")
		end
	end
end

function SoundSystem.LoopSFX(spriteName: string, parent: Instance, loops: integer): Sound?
	TypeChecks.Strict.SFXCheck(spriteName, parent)

	if shouldPlaySFX(parent, spriteName) then
		tagUtil.AddTag(parent, spriteName)
		local splice: Splice = SoundRegistry.getRandomSpliceFromSprite(spriteName)
		if splice then
			local sound: Sound = splice.Sound:Clone()
			sound.Archivable = false

			local soundAttributes = createSoundAttributes(splice)
			soundAttributes.Loop = true
			soundAttributes.Intervals = loops

			attributeUtil.SetAttributes(sound, soundAttributes)

			instanceUtil.setProperties(
				sound,
				{ Name = spriteName, TimePosition = splice.Start, Playing = true, Looped = true },
				parent
			)

			PlaySound(sound)

			return sound
		else
			warn(spriteName .. " is NOT a valid member of Sounds")
		end
	end
end

local function StopSound(sound: Sound)
	sound:Stop()
	sound:Destroy()
end

function SoundSystem.StopSFX(spriteName: string, parent: Instance, sound: Sound?)
	if parent then
		TypeChecks.Strict.SFXCheck(spriteName, parent)

		local sound = sound or parent:FindFirstChild(spriteName)
		if sound then
			StopSound(sound)
			tagUtil.RemoveTag(parent, spriteName)
		end
	end
end

tagUtil.doForTagged(
	"Sound",
	t.wrap(function(sound: Sound)
		local currentTime = workspace:GetServerTimeNow()

		local soundAttributes = attributeUtil.GetAttributes(sound)

		if soundAttributes.Hash then
			local replicationTime = currentTime - soundAttributes.CreationTime
			if soundAttributes.Play then
				local totalPlayTime = soundAttributes.Duration - replicationTime
				task.delay(totalPlayTime, SoundSystem.StopSFX, sound.Name, sound.Parent, sound)
			elseif soundAttributes.Loop then
				while sound.IsPlaying do
					if soundAttributes.Intervals ~= 0 then
						sound.TimePosition = soundAttributes.Start
						task.wait(soundAttributes.Duration)
						soundAttributes.Intervals -= 1
					else
						break
					end
				end
				SoundSystem.StopSFX(sound.Name, sound.Parent, sound)
			end
		end
	end, t.instanceIsA("Sound"))
)

return SoundSystem
