local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local TestService = game:GetService("TestService")

local function runScripts(require)
	for _, modulescript: ModuleScript in ipairs(CollectionService:GetTagged("Auto-Run")) do
		task.spawn(require, modulescript)
	end

	CollectionService:GetInstanceAddedSignal("Auto-Run"):Connect(function(modulescript: ModuleScript)
		task.spawn(require, modulescript)
	end)

	for _, modulescript: ModuleScript in ipairs(CollectionService:GetTagged("Auto-Run [Client]")) do
		task.spawn(require, modulescript)
	end

	CollectionService:GetInstanceAddedSignal("Auto-Run [Client]"):Connect(function(modulescript: ModuleScript)
		task.spawn(require, modulescript)
	end)
end

if RunService:IsStudio() and TestService.ENABLE_BENCHMARKER.Value then
	local timeMap = {}
	local timeList = {}
	local totalTime = 0

	runScripts(function(modulescript: ModuleScript)
		local startTime = os.clock()
		require(modulescript)
		local endTime = os.clock()
		local runTime = endTime - startTime
		totalTime += runTime

		timeMap[runTime] = modulescript
		table.insert(timeList, runTime)
	end)

	local function results()
		table.sort(timeList)
		for _, runTime: number in ipairs(timeList) do
			warn(timeMap[runTime], runTime)
		end
		warn("Total Runtime:", totalTime)
	end
	results()
else
	runScripts(require)
end
