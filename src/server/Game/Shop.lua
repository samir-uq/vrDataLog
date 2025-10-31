local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")


local Shop = {}

local Inventory = require(ServerScriptService.Server.Game.Inventory)
local ItemList = require(ReplicatedStorage.Shared.Configs.Data.ItemList)
local Robase = require(ServerScriptService.Server.Utilities.Robase) :: any
local GameTypes = require(ReplicatedStorage.Shared.Configs.GameTypes)
--TODO fix robase issue
local ItemCache = {}

local ExternalInformation = Robase:GetRobase("Info")
local ExternalShop = Robase:GetRobase("Shop")
local ExternalItems = Robase:GetRobase("Items")

function Shop.FetchItems()
	for _, Item in ItemList do
		if not Item.Limited then continue end
		if Item.LimitedSpan and not Item.LimitedSpan() then continue end

		ItemCache[Item.Name] = ExternalShop:GetAsync(Item.Name)
	end
end

function Shop.UpdateItem(Key: string, Value: any)
	ItemCache[Key] = Value
end

function Shop.GetCache()
    return ItemCache
end

function Shop.GenerateUniqueId(ItemName: string, OwnerId: number?): number
	local GeneratedNumber = nil

	local Index = 0

	for I, ItemData in ItemList do
		if ItemData.Name == ItemName then Index = I end
	end

	ExternalInformation:UpdateAsync("IdInfo", function(Data: {Count: number?})
		Data = Data or {}
		local CurrentId = Data.Count or -1

		ExternalItems:SetAsync(tostring(CurrentId + 1), {
			Owner = OwnerId,
			Item = Index
		})

		GeneratedNumber = CurrentId + 1
		return {Count = GeneratedNumber}
	end)

	if not GeneratedNumber then
		task.wait()
		return Shop.GenerateUniqueId(ItemName, OwnerId)
	end

	return GeneratedNumber
end

function Shop.AttemptUniqueItemFetch(Entity: GameTypes.Entity, ItemName: string): (boolean, string)
	local PredefinedItem = Inventory.GetItemFromName(ItemName)
	if not PredefinedItem then return false, "Unable to locate correct item" end

	local SuccessfullyBought = false
	local Reason = "There was an unexpected error whilst registering your purchase, you have been refunded!"
	ExternalShop:UpdateAsync(ItemName, function(PreviousData)
		PreviousData = PreviousData or {}
		PreviousData.Copies = PreviousData.Copies or PredefinedItem.LimitedAmount or 100
		PreviousData.Ids = PreviousData.Ids or {}

		local Tokenized = #PreviousData.Ids

		if PreviousData.Copies > Tokenized then

			local UniqueId = Shop.GenerateUniqueId(ItemName, Entity.Id)
			Inventory.AddItem(Entity, ItemName, {UniqueId = UniqueId})

			table.insert(PreviousData.Ids, UniqueId)
			SuccessfullyBought = true
			Reason = "Purchased item successfully!"
		else
			Reason = "All the copies of this item has ran out, you have been refunded!"
		end

		Shop.UpdateItem(ItemName, PreviousData)
		return PreviousData
	end)

	return SuccessfullyBought, Reason
end

function Shop.Purchase(Entity: GameTypes.Entity, ItemName: string): (boolean, string)
	local PredefinedItem = Inventory.GetItemFromName(ItemName)
	if not PredefinedItem then return false, "Unable to locate correct item" end

	if PredefinedItem.NotForSale then
		if typeof(PredefinedItem.NotForSale) == "function" then
			local IsForSale = PredefinedItem.NotForSale(Entity)
			if not IsForSale then return false, "Item is not for sale" end
		else return false, "Item is not for sale" end
	end

	local Cost = PredefinedItem.Price or 0
	local CostCurrency = PredefinedItem.PriceType or "Coins"

	if Cost > Entity:GetSavedData()[CostCurrency] then return false, "Not enough "..CostCurrency.." to purchase the item" end
	if PredefinedItem.CanPurchase and not PredefinedItem.CanPurchase(Entity) then return false, "You are unable to purchase this" end

	if PredefinedItem.MaxPerPlayer then
		local _, ContainedItems = Inventory.HasItem(Entity, ItemName)
		if #ContainedItems >= PredefinedItem.MaxPerPlayer then return false, "You exceed the max amount of copies you can own of this item" end
	end

    Entity:UpdateSavedData(function(Data)
        Data[CostCurrency] -= Cost
        return true
    end)

	if PredefinedItem.Limited and (if PredefinedItem.LimitedSpan then PredefinedItem.LimitedSpan() else true) then
		local Success, Reason = Shop.AttemptUniqueItemFetch(Entity, ItemName)
		if not Success then
            -- this is just refund
            Entity:UpdateSavedData(function(Data)
                Data[CostCurrency] += Cost
                return true
            end)
		else
			Entity:GetEvent("ItemPurchased"):Fire(ItemName)
		end
		return Success, Reason
	else
		local Success, Reason, _ = Inventory.AddItem(Entity, ItemName)
		if not Success then return false, Reason end

		Entity:GetEvent("ItemPurchased"):Fire(ItemName)
		return true, "Purchased item successfully!"
	end
end

function Shop.Start()
	task.spawn(function()
		while true do
			Shop.FetchItems()
			task.wait(60)
		end
	end)
end

return Shop