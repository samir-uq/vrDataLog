local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Container = require(ReplicatedStorage.Shared.Client.Interface.Components.Default.Container)
local ColorPallete = require(ReplicatedStorage.Shared.Client.Interface.MetaData.ColorPallete)
local StateData = require(ReplicatedStorage.Shared.Client.Interface.MetaData.StateData)
local UIConfiguration = require(ReplicatedStorage.Shared.Client.Interface.MetaData.UIConfiguration)

local scoped = Fusion.scoped
local peek = Fusion.peek
local Children = Fusion.Children
local Child = Fusion.Child
local Out = Fusion.Out
local OnEvent = Fusion.OnEvent
local Dependency = {
    Container = Container,
}

type scope = Fusion.Scope<typeof(Fusion) & typeof(Dependency)>
type state<T> = Fusion.UsedAs<T>
return function (scope: any, props: {
    text: Fusion.Value<string>,
    size: state<UDim2>?,
    position: state<UDim2>?,
    placeholderText: state<string>?,
    textYAlignment: state<Enum.TextYAlignment>?,
    textScaled: state<boolean>?,
    textSize: state<number>?,
    maxTextSize: state<number>?,
})
    local scope: scope = scope:innerScope(Dependency)
    local scaleSpring = scope:Spring(scope:Value(1), StateData.GetSpring("searchbarSize"), StateData.GetDamp("searchbarSize"))
    

    local textTransparency = scope:Computed(function(use, scope: scope)
        return use(props.text):len() > 0 and 0 or 0.5
    end)
    local textTransparencySpring = scope:Spring(textTransparency, StateData.GetSpring("searchbarTransparency"), StateData.GetDamp("searchbarTransparency"))

    scope:Observer(props.text):onChange(function()
        scaleSpring:addVelocity(0.6)
    end)


    return scope:Hydrate(scope:Container {
        size = props.size or UDim2.fromScale(0.415, 1),
        position = props.position,
        color = ColorPallete.whiteOne,
        transparency = 0,
    }) {
        [Children] = Child {
            scope:New "UICorner" {
                CornerRadius = UDim.new(0, 20),
            },

            scope:New "UIScale" {
                Scale =  scaleSpring
            },


            scope:New "TextBox" {
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromScale(0.95, 0.95),
                PlaceholderColor3 = ColorPallete.greyTwo,
                PlaceholderText = props.placeholderText,
                TextColor3 = Color3.new(0,0,0),
                PlaceholderColor3 = ColorPallete.greyOne,
                TextScaled = if (props.textScaled ~= nil) then props.textScaled else true,
                TextSize = props.textSize or 1,
                TextYAlignment = props.textYAlignment,
                TextXAlignment = Enum.TextXAlignment.Left,
                FontFace = UIConfiguration.default.primaryFont,
                TextTransparency = textTransparencySpring,

                [Out "Text"] = props.text,
                [Children] = Child {
                    scope:Computed(function(use): Instance?
                        local maxSize = use(props.maxTextSize)

                        if not maxSize then return nil end
                        return scope:New "UITextSizeConstraint" {
                            MaxTextSize = maxSize,
                        }
                    end)
                }
            }
        }
    }
end