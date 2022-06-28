local AnalyticsService = game:GetService("AnalyticsService")

-- local RunService = game:GetService("RunService")
local DISABLE_ANALYTICS = true
local IsStudio = DISABLE_ANALYTICS --RunService:IsStudio()

local playfabUtil = {}

export type ProgressionInfo = {
	Player: Player,
	Category: string,
	ProgressionStatus: EnumItem,
	Location: Dictionary,
	Statistics: Dictionary?,
	CustomData: (number | string | table)?,
}

-- playfabUtil.ProgressionInfo = {}

function playfabUtil.Progression(progressionInfo)
	if not IsStudio then
		AnalyticsService:FirePlayerProgressionEvent(
			progressionInfo.Player,
			progressionInfo.Category,
			progressionInfo.ProgressionStatus,
			progressionInfo.Location,
			progressionInfo.Statistics,
			progressionInfo.CustomData
		)
	end
end

export type EconomyInfo = {
	Player: Player,
	ItemName: string,
	EconomyAction: EnumItem,
	ItemCategory: string,
	Amount: integer,
	Currency: string,
	Location: Dictionary,
	CustomData: (number | string | table)?,
}

-- playfabUtil.EconomyInfo = {}

function playfabUtil.Economy(economyInfo)
	if not IsStudio then
		AnalyticsService:FireInGameEconomyEvent(
			economyInfo.Player,
			economyInfo.ItemName,
			economyInfo.EconomyAction,
			economyInfo.ItemCategory,
			economyInfo.Amount,
			economyInfo.Currency,
			economyInfo.Location,
			economyInfo.CustomData
		)
	end
end

export type LogInfo = {
	Player: Player?,
	LogLevel: EnumItem,
	Message: string,
	DebugInfo: {
		errorCode: string,
		stackTrace: string,
	}?,
	CustomData: (number | string | table)?,
}

-- playfabUtil.LogInfo = {}

function playfabUtil.Log(logInfo)
	if not IsStudio then
		AnalyticsService:FireLogEvent(
			logInfo.Player,
			logInfo.LogLevel,
			logInfo.Message,
			logInfo.DebugInfo,
			logInfo.CustomData
		)
	end
end

export type CustomInfo = {
	Player: Player?,
	EventCategory: string,
	CustomData: (number | string | table)?,
}

-- playfabUtil.CustomInfo = {}

function playfabUtil.Custom(customInfo)
	if not IsStudio then
		AnalyticsService:FireCustomEvent(customInfo.Player, customInfo.EventCategory, customInfo.CustomData)
	end
end

return playfabUtil
