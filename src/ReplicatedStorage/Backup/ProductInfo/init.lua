local Asset = Enum.InfoType.Asset
local GamePass = Enum.InfoType.GamePass
local Product = Enum.InfoType.Product

local ProductInfo = {
	[Asset] = require(script.Asset),
	[GamePass] = require(script.GamePass),
	[Product] = require(script.Product),
}

return ProductInfo
