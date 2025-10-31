local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VRService = game:GetService("VRService")
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local ClientEvent = require(ReplicatedStorage.Shared.Event.ClientEvent)
local UniqueUtil = require(ReplicatedStorage.Shared.Modules.UniqueUtil)

local DataLogger = {}
DataLogger.__index = DataLogger

type log = {t: number, Head: {number}?, LeftHand: {number}?, RightHand: {number}?, Floor: {number}?}

local function getSnapshot(): log
    local currentTime = DateTime.now().UnixTimestampMillis

    local log = {
        t = currentTime
    }
    for _, userCFrameType in Enum.UserCFrame:GetEnumItems() do
        if not VRService:GetUserCFrameEnabled(userCFrameType) then
            continue
        end
        -- log[userCFrameType.Name] = {CFrame.identity:GetComponents()}
        log[userCFrameType.Name] = {VRService:GetUserCFrame(userCFrameType):GetComponents()}
    end

    return log
end


function DataLogger.new()
    local self = setmetatable({}, DataLogger)
    self.Janitor = Janitor.new()
    self.logs = {}
    self.active = false

    return self
end

function DataLogger:start()
    if self.active then return end
    
    self.active = true
    local janitor: Janitor.Janitor = self.Janitor
    janitor:Add(RunService.RenderStepped:Connect(function(_)
        if not self.active then return end
        local snapshot = getSnapshot()

        if UniqueUtil.Count(snapshot) == 1 then
            return
        end

        table.insert(self.logs, snapshot)        
    end))
end

function DataLogger:stop()
    if not self.active then return end
    self.active = false
    self.Janitor:Destroy()
end

function DataLogger:getLog(): {log}
    return self.logs
end

function DataLogger:sendLog()
    ClientEvent.LogData.Fire(self:getLog())
end

return DataLogger