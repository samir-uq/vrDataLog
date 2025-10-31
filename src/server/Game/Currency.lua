local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameTypes = require(ReplicatedStorage.Shared.Configs.GameTypes)

local CurrencyHandler = {}
function CurrencyHandler.GetBoost(Entity: GameTypes.Entity, CurrencyName: string)
	return 1
end

return CurrencyHandler