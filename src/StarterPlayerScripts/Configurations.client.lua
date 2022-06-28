local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Bindables = require(ReplicatedStorage.Bindables)
local Reset_Bindable = Bindables.create("Reset_Bindable")

local Configurations = require(ReplicatedStorage.Configurations)
local RoundInProgress = Configurations.COLLECTION_TAGS.RoundInProgress

local Utilities = ReplicatedStorage.Utilities
local playerUtil = require(Utilities.playerUtil)

local function doSetCore() --! Annoying StarterGui
	local StarterGui = game:GetService("StarterGui")

	local function reconfigureResetButton()
		StarterGui:SetCore("ResetButtonCallback", Reset_Bindable.BindableEvent)

		Reset_Bindable.Event:Connect(function()
			if workspace:GetAttribute(RoundInProgress) then
				local playerInfo = playerUtil.getPlayerInfo(localPlayer)
				playerUtil.killHumanoid(playerInfo.Humanoid)
			end
		end)
	end

	while task.wait(1) do
		if xpcall(reconfigureResetButton, reconfigureResetButton) then
			break
		end
	end

	local function setCoreGuiSettings()
		for CoreGuiType, disabled in pairs(Configurations.CORE_GUI_SETTINGS) do
			StarterGui:SetCoreGuiEnabled(CoreGuiType, disabled)
		end
	end
	setCoreGuiSettings()

	StarterGui:SetCore("ChatActive", Configurations.ChatActive)
end
doSetCore()
