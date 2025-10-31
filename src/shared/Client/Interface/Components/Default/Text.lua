--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Container = require(script.Parent.Container)
local UIConfiguration = require(ReplicatedStorage.Shared.Client.Interface.MetaData.UIConfiguration)

local scoped = Fusion.scoped
local peek = Fusion.peek
local Children = Fusion.Children
local Child = Fusion.Child

type scope = Fusion.Scope<typeof(Fusion)>
type state<T> = Fusion.UsedAs<T>

return function (scope: scope, props: {
    size: state<UDim2>?,
    position: state<UDim2>?,
    anchorPoint: state<Vector2>?,
    text: state<string>?,
    textSize: state<number>?,
    color: state<Color3>?,
    accentColor: state<Color3>?,
    disableShadow: state<boolean>?,
    shadowOffset: state<UDim2>?,
    automaticSize: state<Enum.AutomaticSize>?,
})
    local scope = scope:innerScope()

    return scope:Hydrate(Container(scope, props :: any)) {
        [Children] = Child {
            scope:Computed(function(use): Instance?
                local shadowEnabled: boolean =  not use(props.disableShadow or false)
                
                if shadowEnabled then
                    return scope:New "TextLabel" {
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = props.shadowOffset or UDim2.new(0.5,UIConfiguration.text.shadowOffset.X.Offset, 0.5, UIConfiguration.text.shadowOffset.Y.Offset),
                        Size = UDim2.fromScale(1, 1),
                        ZIndex = 1,
                        BackgroundTransparency = 1,
                        FontFace = UIConfiguration.default.primaryFont,
                        RichText = true,
            
            
                        TextScaled = (props.textSize == nil and true or false),
                        TextSize = props.textSize,
                        Text = props.text,
                        TextColor3 = props.accentColor,
                    }
                   end
               return nil
            end),

            scope:New "TextLabel" {
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromScale(1, 1),
                ZIndex = 2,
                BackgroundTransparency = 1,
                FontFace = UIConfiguration.default.primaryFont,
                RichText = true,


                TextScaled = (props.textSize == nil and true or false),
                TextSize = props.textSize,
                Text = props.text,
                TextColor3 = props.color,
            },
        }
    }
end