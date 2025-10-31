local ReplicatedStorage = game:GetService("ReplicatedStorage")
local t = require(ReplicatedStorage.Packages.t)
local UniqueUtil = require(ReplicatedStorage.Shared.Modules.UniqueUtil)

local u8, u16, u32 = 2^8-1, 2^16-1, 2^32-1

local GamepassList = require(ReplicatedStorage.Shared.Configs.Data.GamepassList)
local ItemList = require(ReplicatedStorage.Shared.Configs.Data.ItemList)
return {
    name = "PlayerData-Test",
    template = {
        RobuxSpent = 0,
        Gamepasses = {},
        Inventory = {},
    },

    schema = t.strictInterface {
        RobuxSpent = t.numberConstrained(0, u32),
        Gamepasses = t.array(function(Val: number)
            return table.find(GamepassList, Val) ~= nil
        end),

        Inventory = t.map(t.number, t.strictInterface({
            Name = t.strict(function(Val: string)
                return UniqueUtil.FindFromKey(ItemList, "Name", Val) ~= nil
            end),
            Count = t.numberConstrained(0, u32),
            Data = t.strictInterface {
                Level = t.optional(t.numberConstrained(1, u16)),
                XP = t.optional(t.numberConstrained(0, u32)),
                UniqueId = t.numberConstrained(0, u32),
            }
        })),
    },

    changedCallbacks =  {}
}