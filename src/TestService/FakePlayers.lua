local Players = game:GetService("Players")

local FakePlayers = {
	Array = {},
	Dictionary = {},
}

function FakePlayers.create(name: string): Configuration
	local fakeplayer = Instance.new("Configuration")
	fakeplayer.Name = name
	FakePlayers.Dictionary[name] = fakeplayer
	table.insert(FakePlayers.Array, fakeplayer)
	fakeplayer.Parent = Players
	return fakeplayer
end

function FakePlayers.get(name: string): Configuration
	return FakePlayers.Dictionary[name]
end

function FakePlayers.getPlayers()
	return FakePlayers.Array
end

function FakePlayers.remove(name: string)
	local fakeplayer = FakePlayers.get(name)
	FakePlayers.Dictionary[name] = nil
	local index = table.find(FakePlayers.Array, name)
	table.remove(FakePlayers.Array, index)
	fakeplayer:Destroy()
end

FakePlayers.create("mesa4070")

return FakePlayers
