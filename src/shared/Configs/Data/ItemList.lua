local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameTypes = require(ReplicatedStorage.Shared.Configs.GameTypes)


return {
	{
		Name = "Wooden Rod",
		Type = "Fishing Rod",
		Price = 100,
		PriceType = "Coins",

		CanSpin = false,
		--Chance = 0.1,

		--ShotClock = 5,
		ShotClock = function(Entity: GameTypes.Entity, HoldDuration: number)
			return 5
		end,

		CastDistance = {
			Min = Vector2.new(2,2),
			Max = Vector2.new(10,10)
		},

		--CastDistance = function(Entity: GameTypes.Entity, PowerPercentage: number, HoldDuration: number)
		--	return Vector2.new(5,5)
		--end,

		Power = 5, --> display, could be a function
		Luck = 1, --> display, could be a function

		LureCycles = {
			Min = 5,
			Max = 6,
		},

		--LureCycles = function(Entity: GameTypes.Entity, PowerPercentage: number, HoldDuration: number, WaitDuration: number)
		--	return 3
		--end,

		WaitDuration = {
			Min = 3,
			Max = 5
		},

		--WaitDuration = function(Entity: GameTypes.Entity, PowerPercentage: number, HoldDuration: number)
		--	return 4
		--end,

		Data = {
			Level = 1, --> Higher the level, more luck / power and everything.
			XP = 0,
		},

		Use = nil,
	},

	{
		Name = "Plastic Rod",
		Type = "Fishing Rod",
		Price = 500,
		PriceType = "Coins",

		CanSpin = false,

		ShotClock = 5,
		CastDistance = {
			Min = Vector2.new(2,2),
			Max = Vector2.new(10,10)
		},

		Power = 5,
		Luck = 2,

		LureCycles = {
			Min = 4,
			Max = 5
		},

		WaitDuration = {
			Min = 3,
			Max = 5
		},

		Data = {
			Level = 1,
			XP = 0
		}
	},

	{
		Name = "Wild Oak Rod",
		Type = "Fishing Rod",
		Price = 1500,
		PriceType = "Coins",

		CanSpin = false,

		ShotClock = 5,
		CastDistance = {
			Min = Vector2.new(2,2),
			Max = Vector2.new(10,10)
		},

		Power = 5,
		Luck = 2,

		LureCycles = {
			Min = 4,
			Max = 5
		},

		WaitDuration = {
			Min = 3,
			Max = 5
		},

		Data = {
			Level = 1,
			XP = 0
		}
	},


	{
		Name = "Fish Test One",
		Type = "Fish"
	},

	{
		Name = "Fish Test Two",
		Type = "Fish",
	}
} :: {GameTypes.Item}