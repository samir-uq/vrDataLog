local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Signal = require(ReplicatedStorage.Packages.Signal)
local GameTypes = require(ReplicatedStorage.Shared.Configs.GameTypes)
local UniqueUtil = require(ReplicatedStorage.Shared.Modules.UniqueUtil)

local InputHandler = {}

local LockRegistry: {[string]: {Status: Enum.MouseBehavior, Priority: number}} = {}
local BindRegistry: {[string]: GameTypes.BindData} = {}

local scope = Fusion.scoped(Fusion)
local deviceType= scope:Value "Computer"
local controllerType = scope:Value "Xbox"
local mouseLocked = scope:Value (Enum.MouseBehavior.Default)
local mousePosition = scope:Value (Vector2.zero)

local DeviceChanged = Signal.new()
local ControllerChanged = Signal.new()
local MouseLockChanged = Signal.new()

local DeviceTypeCache = Fusion.peek(deviceType)
local ControllerTypeCache = Fusion.peek(controllerType)

local MobileReferences = {"Touch", "Gyro", "Accelerometer"}

local function LockUpdate()
     local HighestPriorityData = {Status = Enum.MouseBehavior.Default, Priority = 0}
    for _, PriorityData in LockRegistry do
        if PriorityData.Priority < HighestPriorityData.Priority then
            continue
        end

        if PriorityData.Priority == HighestPriorityData.Priority then
            if not PriorityData.Status then
                continue
            end
        end

        HighestPriorityData = PriorityData
    end
    mouseLocked:set(HighestPriorityData.Status or Enum.MouseBehavior.Default)
end

local function ProcessInput(InputObject: InputObject)
    local InputType = InputObject.UserInputType
    local Pos = InputObject.Position

    local NewDeviceType: GameTypes.DeviceType = "Computer"
    local NewControllerType: GameTypes.ConsoleType
    if string.find(InputType.Name, "Gamepad") then
        NewDeviceType = "Console"
    elseif table.find(MobileReferences,InputType.Name) then
        NewDeviceType = "Mobile"
    end

    if NewDeviceType ~= DeviceTypeCache then
        deviceType:set(NewDeviceType)
    end

    if NewDeviceType == "Console" then
        NewControllerType = UserInputService:GetImageForKeyCode(Enum.KeyCode.ButtonX)
            :match("Controls/(%w+)Controller")

        if NewControllerType ~= ControllerTypeCache then
            controllerType:set(NewControllerType)
        end
    end

    if InputType == Enum.UserInputType.MouseMovement then
        local MousePos = Vector2.new(Pos.X, Pos.Y) + GuiService:GetGuiInset()
        mousePosition:set(MousePos)
    end

    for _, BindData in BindRegistry do
        if not table.find(BindData.ListeningTo, InputType) and not table.find(BindData.ListeningTo, InputObject.KeyCode) then
            continue
        end

        if not table.find(BindData.State, InputObject.UserInputState) then
            continue
        end

        task.spawn(BindData.Callback, InputObject)
    end
end

function InputHandler.RegisterLockStatus(Id: string, Status: Enum.MouseBehavior, Priority: number?)
    if not Priority then
        if LockRegistry[Id] then
            Priority = LockRegistry[Id].Priority
        else
            Priority = 1
        end
    end
    local Priority: number = Priority :: number -- just typechecking

    LockRegistry[Id] = {Status = Status, Priority = Priority}
    LockUpdate()
end

function InputHandler.DeregisterLockStatus(Id: string)
    LockRegistry[Id] = nil
    LockUpdate()
end

function InputHandler.Bind(Id: string, BindData: GameTypes.BindData)
    BindRegistry[Id] = BindData
end

function InputHandler.Unbind(Id: string)
    BindRegistry[Id] = nil
end

function InputHandler.GetDeviceTypeValue()
    return deviceType
end

function InputHandler.GetControllerTypeValue()
    return controllerType
end

function InputHandler.GetMouseLockedValue()
    return mouseLocked
end

function InputHandler.GetMousePositionValue()
    return mousePosition
end

function InputHandler.GetDeviceChangedSignal()
    return DeviceChanged
end

function InputHandler.GetControllerChangedSignal()
    return ControllerChanged
end

function InputHandler.GetMouseLockChangedSignal()
    return MouseLockChanged
end

function InputHandler.Start()
    scope:Observer(deviceType):onChange(function()
        DeviceChanged:Fire(Fusion.peek(deviceType))
    end)

    scope:Observer(controllerType):onChange(function()
        ControllerChanged:Fire(Fusion.peek(controllerType))
    end)

    scope:Observer(mouseLocked):onChange(function()
        local lockType = Fusion.peek(mouseLocked)

        UserInputService.MouseBehavior = lockType
	    UserInputService.MouseIconEnabled = (lockType == Enum.MouseBehavior.Default)
        MouseLockChanged:Fire(lockType)
    end)

    UserInputService.InputBegan:Connect(ProcessInput)
    UserInputService.InputChanged:Connect(ProcessInput)
    UserInputService.InputEnded:Connect(ProcessInput)
end

return InputHandler