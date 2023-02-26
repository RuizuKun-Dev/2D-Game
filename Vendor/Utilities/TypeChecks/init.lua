local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utilities = ReplicatedStorage.Utilities
local t = require(Utilities.t)

local TypeChecks = {
	Optional = {},
	Strict = {},
}

TypeChecks.Strict.String = t.strict(t.string)

TypeChecks.Strict.Number = t.strict(t.number)

--

TypeChecks.Strict.CFrame = t.strict(t.CFrame)

TypeChecks.Strict.Instance = t.strict(t.Instance)

TypeChecks.Strict.Vector3 = t.strict(t.Vector3)

--

TypeChecks.Animator = t.instanceIsA("Animator")
TypeChecks.Strict.Animator = t.strict(t.instanceIsA("Animator"))

TypeChecks.AnimationTrack = t.instanceIsA("AnimationTrack")
TypeChecks.Strict.AnimationTrack = t.strict(t.instanceIsA("AnimationTrack"))

TypeChecks.BasePart = t.instanceIsA("BasePart")
TypeChecks.Strict.BasePart = t.strict(t.instanceIsA("BasePart"))

TypeChecks.Humanoid = t.instanceIsA("Humanoid")
TypeChecks.Strict.Humanoid = t.strict(t.instanceIsA("Humanoid"))

TypeChecks.Player = t.union(t.instanceIsA("Player"), t.instanceIsA("Configuration"))
TypeChecks.Strict.Player = t.strict(t.union(t.instanceIsA("Player"), t.instanceIsA("Configuration")))

TypeChecks.ProximityPrompt = t.instanceIsA("ProximityPrompt")
TypeChecks.Strict.ProximityPrompt = t.strict(t.instanceIsA("ProximityPrompt"))

TypeChecks.Model = t.instanceIsA("Model")
TypeChecks.Strict.Model = t.strict(t.instanceIsA("Model"))

TypeChecks.Motor6D = t.instanceIsA("Motor6D")
TypeChecks.Strict.Motor6D = t.strict(t.instanceIsA("Motor6D"))

TypeChecks.Tool = t.instanceIsA("Tool")
TypeChecks.Strict.Tool = t.strict(t.instanceIsA("Tool"))

TypeChecks.WorldModel = t.instanceIsA("WorldModel")
TypeChecks.Strict.WorldModel = t.strict(t.instanceIsA("WorldModel"))

--

return TypeChecks
