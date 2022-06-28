local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BackUp = require(ReplicatedStorage.Backup)

local Utilities = ReplicatedStorage.Utilities
local Promise = require(Utilities.Promise)

local MarketplaceService = game:GetService("MarketplaceService")

local marketplaceUtil = {}

marketplaceUtil.getProductInfo = Promise.promisify(function(assetId: number, infoType: EnumItem)
	local productInfo = BackUp.getProductInfo(assetId, infoType)
	if not productInfo then
		return MarketplaceService:GetProductInfo(assetId, infoType)
	end
	return productInfo
end)

return marketplaceUtil
