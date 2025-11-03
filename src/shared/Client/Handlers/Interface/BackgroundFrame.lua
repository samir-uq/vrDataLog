local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local InputHandler = require(ReplicatedStorage.Shared.Client.Handlers.InputHandler)
local VRDataLog = require(ReplicatedStorage.Shared.Client.Handlers.VRDataLog)
local Background = require(ReplicatedStorage.Shared.Client.Interface.Components.Background)
local Button = require(ReplicatedStorage.Shared.Client.Interface.Components.Default.Button)
local Container = require(ReplicatedStorage.Shared.Client.Interface.Components.Default.Container)
local Searchbar = require(ReplicatedStorage.Shared.Client.Interface.Components.Default.Searchbar)
local Text = require(ReplicatedStorage.Shared.Client.Interface.Components.Default.Text)
local Interface = {}

local LocalPlayer = Players.LocalPlayer

local scoped = Fusion.scoped
local peek = Fusion.peek
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local Child = Fusion.Child

local Dependency = {
    BackgroundComponent = Background,
    Container = Container,
    Text = Text,
    SearchBar = Searchbar
}

type scope = Fusion.Scope<typeof(Fusion) & typeof(Dependency)>
type state<T> = Fusion.UsedAs<T>

function Interface.Create(scope: scope, props: {

})
    scope = scope:innerScope(Dependency)

    local status = scope:Value(0)
    local textSizeScale = scope:Spring(scope:Value(1), 12, 1)

    local id = scope:Value("unidentified action")

    local textSize = scope:Computed(function(use)
        local size = use(textSizeScale)
        return UDim2.fromScale(0.5*size, 0.1*size)
    end)

    local current

    InputHandler.Bind("VRButtonA", {
        ListeningTo = {Enum.KeyCode.ButtonA},
        State = {Enum.UserInputState.Begin, Enum.UserInputState.End},
        Callback = function(InputObject: InputObject)
            if InputObject.UserInputState == Enum.UserInputState.Begin then
                if current then
                    current:stop()
                end
                current = VRDataLog.new()
                current:start()
                status:set(1)
            else
                if not current then return end
                current:stop()
                current:sendLog(peek(id))
                status:set(0)

                StarterGui:SetCore("SendNotification", {
                    Title = "Data Logging",
                    Text = "Data has been sent to the cloud to be logged",
                    Duration = 5,
                })
            end
        end
    })

    task.spawn(function()
        while task.wait(1) do
            textSizeScale:addVelocity(2.5)
        end
    end)

    return scope:Hydrate(scope:Container {
        size = UDim2.fromScale(1,1)
    }) {
        [Children] = Child {
            scope:BackgroundComponent {},

            scope:Text {
                disableShadow = true,
                size = textSize,
                position = UDim2.fromScale(0.5, 0.8),
                color = Color3.new(1,1,1),
                text = scope:Computed(function(use)
                    if use(status) == 0 then
                        return "Hold A to record data.."
                    end

                    return "Recording..."
                end)
            },

            scope:SearchBar {
                text = id,
                size = UDim2.fromScale(0.5, 0.1),
                placeholderText = "add id",
            }
        }
    }
end

function Interface.Start()

end

return Interface