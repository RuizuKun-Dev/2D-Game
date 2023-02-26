local Backup = {}

local ProductInfo = require(script.ProductInfo)

function Backup.getProductInfo(assetId: number, infoType: EnumItem)
	return ProductInfo[infoType][tostring(assetId)]
end

return Backup
