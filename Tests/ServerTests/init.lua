local RunService = game:GetService("RunService")

if RunService:IsStudio() then
	local TestService = game:GetService("TestService")
	if TestService.ENABLE_TESTS.Value then
		local TestEZ = require(TestService.testez)
		if RunService:IsServer() then
			local results = TestEZ.TestBootstrap:run({ script })
			if results.failureCount == 0 then
				print(script, "✅")
			else
				print(script, "❌")
				error("Tests failed")
			end
		end
	end
end

return {}
