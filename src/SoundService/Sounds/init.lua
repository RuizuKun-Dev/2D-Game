--# selene: allow(shadowing)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utilities = ReplicatedStorage.Utilities
local instanceUtil = require(Utilities.instanceUtil)
local marketplaceUtil = require(Utilities.marketplaceUtil)
local Signals = require(Utilities.Signals)

local Sounds = {
	SoundSheets = {},
	SoundFailedToLoad = Signals.create(),
}

local function getSoundIdFromURL(URL): string
	return "rbxassetid://" .. string.match(URL, "%d+")
end

local Asset = Enum.InfoType.Asset

local function createSound(moduleScript: ModuleScript, soundGroup: SoundGroup)
	local soundSheet = require(moduleScript)

	soundSheet.Properties.SoundId = getSoundIdFromURL(soundSheet.URL)
	soundSheet.Properties.SoundGroup = soundGroup

	local sound: Sound = instanceUtil.create("Sound", soundSheet.Properties, moduleScript)

	marketplaceUtil.getProductInfo(string.match(soundSheet.URL, "%d+"), Asset)
		:andThen(function(ProductInfo)
			soundSheet.ProductInfo = ProductInfo
		end)
		:catch(function(message)
			warn(message)
		end)

	soundSheet.Sound = sound

	Sounds.SoundSheets[sound.SoundId] = soundSheet
end

local function createSoundGroup(folder: Folder): SoundGroup
	local SoundGroup: SoundGroup = Instance.new("SoundGroup")
	SoundGroup.Name = folder.Name
	SoundGroup.Volume = 1

	for _, child: Instance in ipairs(folder:GetChildren()) do
		if child:IsA("ModuleScript") then
			local ModuleScript: ModuleScript = child
			createSound(ModuleScript, SoundGroup)
			ModuleScript.Parent = SoundGroup
		elseif child:IsA("Folder") then
			local folder: Folder = child
			createSoundGroup(folder).Parent = SoundGroup
		end
	end

	folder:Destroy()

	return SoundGroup
end

function Sounds.GetSoundSheetFromSoundId(soundId: string)
	return Sounds.SoundSheets[soundId]
end

function Sounds.GenerateSoundsFromURL()
	for _, child: Instance in ipairs(script.Master:GetChildren()) do
		if child:IsA("Folder") then
			local folder: Folder = child
			local soundGroup = createSoundGroup(folder)
			soundGroup.Parent = script.Master
		end
	end
end

Sounds.SoundFailedToLoad:Connect(function(soundId: string)
	local soundSheet = Sounds.GetSoundSheetFromSoundId(soundId)
	soundSheet.Sound:SetAttribute("FailedToLoad", true)
	soundSheet.FailedToLoad = true
end)

return Sounds
