
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local UiLabs = require(ReplicatedStorage.Packages.UiLabs)
local Button = require(ReplicatedStorage.Shared.Client.Interface.Components.Default.Button)
local Container = require(ReplicatedStorage.Shared.Client.Interface.Components.Default.Container)
local Text = require(ReplicatedStorage.Shared.Client.Interface.Components.Default.Text)


local Scoped = Fusion.scoped
local peek = Fusion.peek
local Children = Fusion.Children
local Child = Fusion.Child

local Controls = {
    text = "hey gygyy!",
    textColor = Color3.new(),
    textAccentColor = Color3.new(0.090196, 0.27451, 1),
    disableShadow = false,
    disableButton = false,

    roundness = UiLabs.Slider(0, 0, 1),
    buttonColor = Color3.new(),
    visible = true,
}

local Dependency = {
    Container = Container,
    Text = Text,
    Button = Button
}

local Story: UiLabs.FusionStory = {
    fusion = Fusion,
    controls = Controls,
    story = function(props: UiLabs.FusionProps)
        local scope = props.scope:deriveScope(Dependency) :: Fusion.Scope<typeof(Fusion)&typeof(Dependency)>
        local controls = props.controls

        return scope:Hydrate(scope:Container {}) {
            [Children] = Child {
                scope:Hydrate(scope:Button {
                    disabled = controls.disableButton,
                    roundness = controls.roundness,
                    visible = controls.visible,
                    color = controls.buttonColor
                }:FindFirstChildWhichIsA("ImageButton") :: ImageButton) {
                    [Children] = Child {
                        scope:Text {
                            text = controls.text,
                            color = controls.textColor,
                            accentColor = controls.textAccentColor,
                            disableShadow = controls.disableShadow
                        }
                    }
                }
            }
        }
    end
}

return Story