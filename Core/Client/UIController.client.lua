local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local PlayerGui = localPlayer.PlayerGui
local PlayerScripts = localPlayer.PlayerScripts

local ContentProvider = game:GetService("ContentProvider")

for _, child: Instance in ipairs(PlayerScripts:WaitForChild("UI"):GetChildren()) do
	if child:IsA("ModuleScript") then
		local moduleScript: ModuleScript = child
		task.spawn(function()
			local UI = require(moduleScript)
			moduleScript.Parent = UI
			UI.Parent = PlayerGui
			script:SetAttribute(moduleScript.Name, true)
		end)
	end
end

ContentProvider:PreloadAsync({ PlayerGui })
