local Utilities = {}

local InsertService = game:GetService("InsertService")

local RunService = game:GetService("RunService")
local isServer = RunService:IsServer()

local ERROR_FORMAT = "Found duplicated %s modules: %q, name must be unique"

local function registerUtilityModules()
	for _, child: Instance in ipairs(script:GetChildren()) do
		if child:IsA("ModuleScript") then
			local moduleScript: ModuleScript = child
			if Utilities[moduleScript.Name] == nil then
				Utilities[moduleScript.Name] = moduleScript
			else
				error(string.format(ERROR_FORMAT, "Utilities", moduleScript.Name))
			end
		end
	end
end

registerUtilityModules()

local function registerThirdPartyModules()
	local THIRDPARTY_MODULE_ASSET_ID = 8255468519
	local Model: Model = InsertService:LoadAsset(THIRDPARTY_MODULE_ASSET_ID)
	local thirdpartyModule: ModuleScript = require(Model.MainModule)
	for _, child: Instance in ipairs(thirdpartyModule:GetChildren()) do
		if child:IsA("ModuleScript") then
			local moduleScript: ModuleScript = child
			moduleScript.Parent = script
			if Utilities[moduleScript.Name] == nil then
				Utilities[moduleScript.Name] = moduleScript
			else
				error(string.format(ERROR_FORMAT, "Third-party", moduleScript.Name))
			end
		end
	end
	thirdpartyModule:Destroy()
end

if isServer then
	registerThirdPartyModules()
end

return Utilities
