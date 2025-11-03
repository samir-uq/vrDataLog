local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Robase = require(ServerScriptService.Server.Utilities.Robase)
local ServerEvent = require(ReplicatedStorage.Shared.Event.ServerEvent)
local LogVRData = {}

local LogBase = (Robase :: any):GetRobase("Logs")


function LogVRData.Start()
    ServerEvent.LogData.On(function(Player, Value)
        LogBase:UpdateAsync("Content", function(Current: any)
            if not Current then Current = {} end
            if not Current[Value.id] then Current[Value.id] = {} end
            
            table.insert(Current[Value.id], Value.data)
            return Current
        end)
    end)
end

return LogVRData