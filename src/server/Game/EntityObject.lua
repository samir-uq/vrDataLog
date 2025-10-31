local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameTypes = require(ReplicatedStorage.Shared.Configs.GameTypes)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Signal = require(ReplicatedStorage.Packages.Signal)
local DataLoader = require(script.Parent.DataLoader)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
local UniqueUtil = require(ReplicatedStorage.Shared.Modules.UniqueUtil)
local ServerEvent = require(ReplicatedStorage.Shared.Event.ServerEvent)
local TemplateData = require(ReplicatedStorage.Shared.Configs.TemplateData)

local Entity = {}
local Storage = {}
Entity.__index = Entity


local AddedSignal: Signal.Signal<GameTypes.Entity> = Signal.new()
local RemovedSignal: Signal.Signal<GameTypes.Entity> = Signal.new()


Entity.EntityAdded = AddedSignal
Entity.EntityRemoved = RemovedSignal
local function GenerateEntityId(): number
    for X = 0, 255 do
        if not Storage[X] then
            return X
        end
    end
    error("Entity Overflow")
end

function Entity.New(EntityInstance: GameTypes.R6|Player): GameTypes.Entity
    if Entity.FromInstance(EntityInstance) then
        return Entity.FromInstance(EntityInstance)
    end

    local self = setmetatable({}:: any, Entity) :: GameTypes.Entity

    self.IsAPlayer = EntityInstance:IsA("Player")
    self.Instance = EntityInstance
    self.Janitor = Janitor.new()

    self.EntityDataChanged = Signal.new()
    self.SavedDataChanged = Signal.new()

    if not self.IsAPlayer then
        self.MockData = TableUtil.Copy(TemplateData.template, true)
    else
        self.Janitor:Add(DataLoader.Changed:Connect(function(UserId: number, Changed: {[string]: any})
            if not self.Instance:IsA("Player") then return end
            local PlayerInstance: Player = self.Instance
            if UserId ~= PlayerInstance.UserId then return end

            for Key, Value in Changed do
                self.SavedDataChanged:Fire(Key, Value)
            end
        end))
    end

    self.JoinTime = os.time()
    self.EntityData = {}
    self.EventContainer = {}
    self.Events = setmetatable({}, {
        __index = function(RawTable: {}, Key: string)
            if not self.EventContainer[Key] then
                local NewSignal = Signal.new()
                self.Janitor:Add(NewSignal)
                self.EventContainer[Key] = NewSignal
            end
            return self.EventContainer[Key]
        end
    })

    self.Id = GenerateEntityId()
    self.Instance:AddTag(`Entity_{self.Id}`)
    Storage[self.Id] = self

    Entity.EntityAdded:Fire(self)
    ServerEvent.EntityAction.FireAll({
        EntityId =  self.Id,
        Action =  "Create"
    })
    return self
end

function Entity.FromId(Id: number): GameTypes.Entity
    return Storage[Id]
end

function Entity.FromInstance(EntityInstance: GameTypes.R6|Player): GameTypes.Entity
    return Storage[UniqueUtil.FindFromKey(Storage, "Instance", EntityInstance)]
end

function Entity:Destroy()
    if not self.Id then return end
    Entity.EntityRemoved:Fire(self)
    -- Figure out another way to do this
    self:GetEvent("PlayTime"):Fire(os.time()-self.JoinTime)
    self.Janitor:Destroy()

    ServerEvent.EntityAction.FireAll({
        EntityId =  self.Id,
        Action =  "Destroy"
    })
    for Key, _ in self do
        self[Key] = nil
    end
end

function Entity:GetSavedData()
    if not self.Id then return end

    local Fetched
    if self.IsAPlayer then
        Fetched = DataLoader.Store:getAsync(self.Instance)
    else
        Fetched = self.MockData
    end

    return Fetched
end

function Entity:UpdateSavedData(Callback: ({})->boolean)
    if not self.Id then return end

    if self.IsAPlayer then
        return DataLoader.Store:updateAsync(self.Instance, Callback)
    end

    local CloneSave = TableUtil.Copy(self.MockData, true)
    Callback(self.MockData)

    local Changes = UniqueUtil.ChangesFromTable(self.MockData, CloneSave)
    for Key, Value in Changes do
        self.SavedDataChanged:Fire(Key, Value)
    end
end

function Entity:GetTempData()
    if not self.Id then return  end
    return self.EntityData
end

function Entity:UpdateTempData(Callback: ({})->boolean)
    local CloneSave = TableUtil.Copy(self.EntityData or {}, true)
    Callback(self.EntityData or {})

    local Changes: {[string]: any} = UniqueUtil.ChangesFromTable(self.EntityData, CloneSave)
    for Key, Value in Changes do
        self.EntityDataChanged:Fire(Key, Value)
    end

    ServerEvent.EntityAction.FireAll({
        Action =  "Update",
        EntityId = self.Id,
        EntityData = Changes
    })
end

function Entity:GetPlayerStore()
    return self.Store
end

function Entity:GetEvent(EventName: string): Signal.Signal<any>
    return self.Events[EventName]
end

function Entity.Start()
    Players.PlayerAdded:Connect(function(Player)
        while not Player:HasTag("DataLoaded") do
            if not Player or not Player.Parent then break end
            task.wait()
        end

        if not Player or not Player.Parent then return end
        Entity.New(Player)
    end)
    Players.PlayerRemoving:Connect(function(Player)
        if Entity.FromInstance(Player) then
            Entity.FromInstance(Player):Destroy()
        end
    end)

    ServerEvent.FetchEntities.On(function()
        local Container: {[number]: ServerEvent.EntityData} = {}

        for _, EntityObject in Storage do
            local Data = EntityObject.EntityData :: ServerEvent.EntityData
            Container[EntityObject.Id] = Data
        end

        return Container
    end)
end

return Entity