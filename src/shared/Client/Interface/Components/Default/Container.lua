local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local UIConfiguration = require(ReplicatedStorage.Shared.Client.Interface.MetaData.UIConfiguration)

local scoped = Fusion.scoped
local peek = Fusion.peek


type scope = Fusion.Scope<typeof(Fusion)>
type state<T> = Fusion.UsedAs<T>
return function (scope: scope, props: {
    size: state<UDim2>?,
    position: state<UDim2>?,
    anchorPoint: state<Vector2>?,
    
    transparency: state<number>?,
    color: state<Color3>?,
    automaticSize: state<Enum.AutomaticSize>?,
})
    local scope = scope:innerScope()
    local text = scope:Value("Text")

    return scope:New "Frame" {
        AnchorPoint = props.anchorPoint or UIConfiguration.default.anchorPoint,
        Size = props.size or UIConfiguration.default.size,
        Position = props.position or UIConfiguration.default.position,
        BackgroundTransparency = props.transparency or 1,
        BackgroundColor3 = props.color,
        AutomaticSize = scope:Computed(function(use)
            local current = use(props.automaticSize)
            return current or Enum.AutomaticSize.None
        end),
    }
end