local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Lyra = require(ReplicatedStorage.Packages.Lyra)
local ServerEvent = require(ReplicatedStorage.Shared.Event.ServerEvent)
local Signal = require(ReplicatedStorage.Packages.Signal)
local UniqueUtil = require(ReplicatedStorage.Shared.Modules.UniqueUtil)
local TemplateData = require(ReplicatedStorage.Shared.Configs.TemplateData)

local ChangedSignal: Signal.Signal<number, ServerEvent.PlayerData> = Signal.new()
local DataService = {
    Changed = ChangedSignal
}

---@diagnostic disable-next-line: unused-function
local function _Changed(StoreId: string, NewData, OldData)
    local Player = Players:GetPlayerByUserId(tonumber(StoreId))
    if not Player then return end
    if not OldData then return end

    local ChangesFromTable = UniqueUtil.ChangesFromTable(NewData, OldData) :: ServerEvent.PlayerData
    ServerEvent.PlayerDataReplication.Fire(Player, ChangesFromTable)
    ChangedSignal:Fire(Player.UserId, ChangesFromTable)
end

do
    table.insert(TemplateData.changedCallbacks, _Changed)
    DataService.Store = Lyra.createPlayerStore(TemplateData :: any)
end

local function PlayerAdded(Player: Player)
    DataService.Store:loadAsync(Player)
    Player:AddTag("DataLoaded")
end

local function PlayerRemoving(Player: Player)
    DataService.Store:unloadAsync(Player)
end

function DataService.Start()
    for _, CurrentPlayer: Player in Players:GetPlayers() do
        PlayerAdded(CurrentPlayer)
    end
    game.Players.PlayerAdded:Connect(PlayerAdded)
    game.Players.PlayerRemoving:Connect(PlayerRemoving)

    game:BindToClose(function()
        DataService.Store:closeAsync()
    end)

    ServerEvent.FetchPlayerData.On(function(Player: Player)
        return DataService.Store:get(Player):expect()
    end)
end

return DataService