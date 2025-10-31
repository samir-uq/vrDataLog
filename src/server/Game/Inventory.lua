local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Inventory = {}
local ItemList = require(ReplicatedStorage.Shared.Configs.Data.ItemList)
local ItemTypeData = require(ReplicatedStorage.Shared.Configs.ItemTypeData)
local GameTypes = require(ReplicatedStorage.Shared.Configs.GameTypes)
local UniqueUtil = require(ReplicatedStorage.Shared.Modules.UniqueUtil)

function Inventory.GetItemFromName(ItemName: string): GameTypes.Item?
	for _, ItemData in ItemList do
		if ItemData.Name == ItemName then return ItemData end
	end
    return nil
end

function Inventory.AddItem(Entity: GameTypes.Entity, ItemName: string, CustomData: GameTypes.InvItemData?): (boolean, string, number)
	local PredefinedItem = Inventory.GetItemFromName(ItemName)
	if not PredefinedItem then return false, "Unable to locate correct item", 0 end

	local ClonedItem = table.clone(PredefinedItem)
	ClonedItem.Data = CustomData or {}

	local Index = 0

    Entity:UpdateSavedData(function(Data)
        table.insert(Data.Inventory, ClonedItem)
        Data.Inventory = Data.Inventory
        Index = UniqueUtil.Count(Data.Inventory)

        return true
    end)

    Entity:GetEvent("ItemAdded"):Fire(ItemName, Index, CustomData)
	return true, "Added item to inventory", Index
end

function Inventory.RemoveItem(Entity: GameTypes.Entity, Index: number): (boolean, string)
    local Success = true
    local ItemName
    Entity:UpdateSavedData(function(Data)
        local FoundItem = Data.Inventory[Index]
        if not FoundItem then
            Success = false
            return false
        end
        ItemName = FoundItem.Name
        table.remove(Data.Inventory, Index)
        Data.Inventory = Data.Inventory

        return true
    end)

    if Success then
        Entity:GetEvent("ItemRemoved"):Fire(ItemName, Index)
        return true, "Removed item from inventory"
    else
        return false, "Unable to find item in player's inventory"
    end
end

function Inventory.ConfigureItem(Entity: GameTypes.Entity, Index: number, Callback: (({})->{}))
    local Status = 0

    Entity:UpdateSavedData(function(Data)
        local FoundItem = Data.Inventory[Index]
        if not FoundItem then
            Status = 1
            return false
        end

        FoundItem = Callback(FoundItem)
        if not FoundItem or not FoundItem.Name then
            Status = 2
            return false
        end

        Data.Inventory[Index] = FoundItem
        return true
    end)

    if Status == 0 then
        return true, "Configured item"
    elseif Status == 1 then
        return false, "Unable to find item in player's inventory"
    else
        return false, "Failed to configue item"
    end
end

function Inventory.HasItem(Entity: GameTypes.Entity, ItemName: string, Matching: (({})->boolean)?): (boolean, {})
	local PlayerInventory = Entity:GetSavedData().Inventory :: {GameTypes.InventoryItem}
	local Items = {}

	for _, Item: GameTypes.InventoryItem in PlayerInventory do
		if Item.Name ~= ItemName then continue end
		if Matching and not Matching(Item) then continue end
		table.insert(Items, Item)
	end

	return #Items ~= 0, Items
end

function Inventory.UseItem(Entity: GameTypes.Entity, Index: number): (boolean, string)
	local PlayerInventory = Entity:GetSavedData().Inventory

	local FoundItem = PlayerInventory[Index]
	if not FoundItem then return false, "Unable to find item in player's inventory" end

	local PredefinedItem = Inventory.GetItemFromName(FoundItem.Name)
	if not PredefinedItem then return false, "Unable to locate correct item" end

	local FinalMethod = PredefinedItem.Use or ItemTypeData[PredefinedItem.Type].Use
	if not FinalMethod then return false, "Cannot use this item" end

	local Success, Result = FinalMethod.Use(Entity, Index, PlayerInventory)
    Entity:GetEvent("ItemUsed"):Fire(PredefinedItem.Name, Index) -- more logic?
	if Success then return true, "Used item" end

	return false, Result or "Error whilst using item"
end

function Inventory.Start()
end

return Inventory