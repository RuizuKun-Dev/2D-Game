export type Cooldown = {
	add: (any) -> void,
	has: (any) -> (boolean),
	remove: (any) -> void,
	removeAfter: (any, number) -> void,
}

local Cooldown: Cooldown = {}

function Cooldown.add(object: any)
	Cooldown[object] = true
end

function Cooldown.has(object: any): boolean
	return Cooldown[object] and true
end

function Cooldown.remove(object: any)
	Cooldown[object] = nil
end

function Cooldown.removeAfter(object: any, duration: number)
	Cooldown.add(object)
	task.delay(duration, Cooldown.remove, object)
end

return Cooldown
