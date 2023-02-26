local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utilities = ReplicatedStorage.Utilities
local array = require(Utilities.array)

local SoundService = game:GetService("SoundService")

local Sounds = require(SoundService.Sounds)

local ContentProvider = game:GetService("ContentProvider")
local RunService = game:GetService("RunService")

local SoundRegistry = { AllSprites = {}, AllSheets = {}, IS_CYCLICAL = true }
SoundRegistry.__index = SoundRegistry

local SoundGroups = {}
SoundRegistry.SoundGroups = SoundGroups

export type Splice = {
	Start: number,
	End: number,

	Name: string,
	Number: integer,
	Next: Splice,
	Previous: Splice,
	SheetName: string,
	SpriteName: string,
	Duration: number,
	Sound: Sound,
}

local Splices: Splices = {}
SoundRegistry.Splices = Splices

local function createSplice(spliceNumber: integer, splice: Splice, sprite: Sprite)
	splice.Name = sprite.Name
	splice.Number = spliceNumber
	splice.Next = sprite.Splices[spliceNumber + 1]
	splice.Previous = sprite.Splices[spliceNumber - 1]
	splice.SheetName = sprite.SheetName
	splice.SpriteName = sprite.Name
	splice.Sound = sprite.Sound

	table.insert(Splices[sprite.Name], splice)
end

function SoundRegistry.getSplice(spliceName: string): Splice?
	return Splices[spliceName]
end

function SoundRegistry.getRandomSpliceFromSprite(spriteName: string): Splice?
	return array.random(Splices[spriteName])
end

local function registerSplice(sprite: Sprite)
	Splices[sprite.Name] = {}

	for spliceNumber: integer, splice: Splice in ipairs(sprite.Splices) do
		createSplice(spliceNumber, splice, sprite)
	end
end

export type Sprite = {
	Name: string,
	Splices: { Splice },

	Number: integer,
	Next: spriteData,
	Previous: spriteData,
	SheetName: string,
	Sound: Sound,
	SoundGroup: SoundGroup,
}

local Sprites = {}
SoundRegistry.Sprites = Sprites

local function createSprite(spriteNumber: integer, sprite: Sprite, sheet: Sheet)
	sprite.Number = spriteNumber
	sprite.Next = sheet.Sprites[spriteNumber + 1]
	sprite.Previous = sheet.Sprites[spriteNumber - 1]

	sprite.SheetName = sheet.Name
	sprite.Sound = sheet.Sound

	sprite.SoundGroup = sheet.SoundGroup

	Sprites[sprite.Name] = sprite

	registerSplice(sprite)

	table.insert(SoundGroups[sprite.SoundGroup.Name].Sprites, sprite.Name)

	table.insert(SoundRegistry.AllSprites, sprite.Name)
end

function SoundRegistry.getSprite(sheetName: string): Sprite?
	return Sprites[sheetName]
end

local function registerSprites(sheet: Sheet)
	for spriteNumber: integer, sprite: Sprite in ipairs(sheet.Sprites) do
		createSprite(spriteNumber, sprite, sheet)
	end
end

export type Sheet = {
	URL: string,
	Name: string,
	Sprites: { Sprite },
	Properties: { [string]: any? },

	script: ModuleScript,
	Sound: Sound,
	SoundId: string,
	SoundGroup: SoundGroup,
}

export type Sheets = { Sheet }

local Sheets = {}
SoundRegistry.Sheets = Sheets

local function createSheet(moduleScript: ModuleScript, soundgroup: SoundGroup)
	local sheet = require(moduleScript)

	sheet.script = moduleScript
	sheet.Sound = moduleScript.Sound
	sheet.SoundId = moduleScript.Sound.SoundId
	sheet.SoundGroup = soundgroup

	sheet.Sound.SoundGroup = soundgroup

	Sheets[moduleScript.Name] = sheet

	registerSprites(sheet)

	table.insert(SoundGroups[moduleScript.Parent.Name].Sheets, sheet.Name)

	table.insert(SoundRegistry.AllSheets, sheet.Name)
end

function SoundRegistry.getSheet(sheetName: string): Sheet?
	return Sheets[sheetName]
end

local function registerSheets(soundgroup: SoundGroup)
	for _, child: Instance in ipairs(soundgroup:GetChildren()) do
		if child:IsA("ModuleScript") then
			createSheet(child, soundgroup)
		end
	end
end

local function createSoundGroup(soundgroup: SoundGroup)
	SoundGroups[soundgroup.Name] = {
		Sheets = {},
		Sprites = {},
		SoundGroup = soundgroup,
	}

	registerSheets(soundgroup)
end

function SoundRegistry.getSoundGroup(soundgroupName: string): SoundGroup?
	return SoundGroups[soundgroupName]
end

function SoundRegistry.getRandomSheetFromSoundGroup(soundgroupName: string): string
	return array.random(SoundGroups[soundgroupName].Sheets)
end

function SoundRegistry.getRandomSpriteFromSoundGroup(soundgroupName: string): string
	return array.random(SoundGroups[soundgroupName].Sprites)
end

function SoundRegistry.remove(sheet: Sheet)
	for _, sprite in ipairs(sheet.Sprites) do
		Splices[sprite.Name] = nil
		Sprites[sprite.Name] = nil
		array.remove(SoundRegistry.AllSprites, sprite.Name)
		array.remove(SoundGroups[sheet.SoundGroup.Name].Sprites, sprite.Name)
	end

	Sheets[sheet.Name] = nil
	array.remove(SoundRegistry.AllSheets, sheet.Name)
	array.remove(SoundGroups[sheet.SoundGroup.Name].Sheets, sheet.Name)
end

local function registerSoundGroups(source: Instance)
	for _, child: Instance in ipairs(source:GetChildren()) do
		if child:IsA("SoundGroup") then
			createSoundGroup(child)
			registerSoundGroups(child)
		end
	end
end

function SoundRegistry.WaitUntilLoadedSounds()
	if not script:GetAttribute("isLoaded") then
		script:GetAttributeChangedSignal("isLoaded"):Wait()
	end
end

task.spawn(function()
	if RunService:IsServer() then
		Sounds.GenerateSoundsFromURL()
		registerSoundGroups(SoundService.Sounds.Master)
		script:SetAttribute("isLoaded", true)

		local FAILURE = Enum.AssetFetchStatus.Failure
		ContentProvider:PreloadAsync({ SoundService.Sounds }, function(contentId, AssetFetchStatus)
			if AssetFetchStatus == FAILURE then
				Sounds.SoundFailedToLoad:Fire(contentId)
			end
		end)
	elseif RunService:IsClient() then
		function SoundRegistry.WaitUntilRegisteredSounds()
			if not script:GetAttribute("isRegistered") then
				script:GetAttributeChangedSignal("isRegistered"):Wait()
			end
		end

		function SoundRegistry.WaitUntilPreloadedSounds()
			if not script:GetAttribute("isPreloaded") then
				script:GetAttributeChangedSignal("isPreloaded"):Wait()
			end
		end

		SoundRegistry.WaitUntilLoadedSounds()

		registerSoundGroups(SoundService.Sounds.Master)
		script:SetAttribute("isRegistered", true)

		ContentProvider:PreloadAsync({ SoundService.Sounds })
		script:SetAttribute("isPreloaded", true)
	end
end)

return SoundRegistry
