local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientEvent = require(ReplicatedStorage.Shared.Event.ClientEvent)
local Signal = require(ReplicatedStorage.Packages.Signal)
local UniqueUtil = require(ReplicatedStorage.Shared.Modules.UniqueUtil)
local GameTypes = require(ReplicatedStorage.Shared.Configs.GameTypes)

local EntityContainer = {}

local Storage = {}
local Signals = {}

function EntityContainer.GetTempData(Key: string?, EntityId: number)
	Storage[EntityId] = Storage[EntityId] or {}
	Signals[EntityId] = Signals[EntityId] or Signal.new()

	if Key then
		return Storage[EntityId][Key]
	end

	return Storage[EntityId]
end

function EntityContainer.GetInstance(EntityId: number): GameTypes.R6 | Player
    local Tagged = CollectionService:GetTagged(`Entity_{EntityId}`)
    return Tagged[1]
end

function EntityContainer.GetId(EntityInstance: GameTypes.R6 | Player): number?
    local Tags = EntityInstance:GetTags()
    for _, Tag in Tags do
        if not string.match(Tag, "Entity") then
            continue
        end

        local Seperation = string.split(Tag, "_")
        return tonumber(Seperation[2])
    end

    return nil
end

function EntityContainer.GetSignal(EntityId: number): Signal.Signal<string, any>
    return Signals[EntityId]
end

function EntityContainer.Start()
    ClientEvent.EntityAction.On(function(Value)
        local EntityId = Value.EntityId
        if Value.Action == "Create" then
            Storage[EntityId] = Storage[EntityId] or {}
	        Signals[EntityId] = Signals[EntityId] or Signal.new()

            -- Signals[EntityId]:Connect(function(...)
            --     warn(EntityId, ...)
            -- end)
        end

        if Value.Action == "Destroy" then
            Storage[EntityId] = nil
            Signals[EntityId] = nil
        end

        if Value.EntityData then
            local Difference = UniqueUtil.ChangesFromTable(Value.EntityData, Storage[EntityId])

            Signals[EntityId] = Signals[EntityId] or Signal.new()
            for Key, Value in Difference do
                local KeyString = Key :: string
                Storage[EntityId][KeyString] = Value
                Signals[EntityId]:Fire(KeyString, Value)
            end
        end
    end)

    Storage = ClientEvent.FetchEntities.Invoke()
end

return EntityContainer