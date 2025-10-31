local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientEvent = require(ReplicatedStorage.Shared.Event.ClientEvent)
local Signal = require(ReplicatedStorage.Packages.Signal)

local DataHandler = {}
local FetchedData: ClientEvent.PlayerData = nil

DataHandler.Changed = Signal.new()

function DataHandler.Get(Key: string?)
    while not FetchedData do
        task.wait()
    end

    if not Key then return FetchedData end
    return FetchedData[Key]
end

function DataHandler.Start()
    ClientEvent.PlayerDataReplication.On(function(Data: ClientEvent.PlayerData)
        if not FetchedData then FetchedData = {} end

        for Key, Value in Data do
            if not Key then continue end
            local KeyString = Key :: string
            local ValueAny = Value :: any
            FetchedData[KeyString] = ValueAny
            DataHandler.Changed:Fire(KeyString, ValueAny)
        end
    end)

    FetchedData = ClientEvent.FetchPlayerData.Invoke()
    for Key, Value in FetchedData do
        local KeyString = Key :: string
        DataHandler.Changed:Fire(KeyString, Value)
    end
end

return DataHandler