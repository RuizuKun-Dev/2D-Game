export type Splice = {
	Start: number,
	End: number,
}

export type Sprite = {
	Name: string,
	Splices: { Splice },
}

export type Sheet = {
	URL: string,
	Name: string,
	Sprites: { Sprite },
	Properties: { [string]: any? },
}

return {

	URL = "https://www.roblox.com/library/6766230018/Silence",
	Name = "Silence",

	Sprites = {
		{
			Name = "Silence",
			Splices = {
				{ Start = 0, End = 0.01 },
			},
		},
	},

	Properties = {
		Volume = 1,
	},
}
