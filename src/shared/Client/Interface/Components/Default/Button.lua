local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Container = require(script.Parent.Container)
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local StateData = require(ReplicatedStorage.Shared.Client.Interface.MetaData.StateData)
local UIConfiguration = require(ReplicatedStorage.Shared.Client.Interface.MetaData.UIConfiguration)

local scoped = Fusion.scoped
local peek = Fusion.peek
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local Child = Fusion.Child

type scope = Fusion.Scope<typeof(Fusion)>
type state<T> = Fusion.UsedAs<T>
return function (scope: scope, props: {
    size: state<UDim2>?,
    position: state<UDim2>?,
    anchorPoint: state<Vector2>?,
    automaticSize: state<Enum.AutomaticSize>?,
    disabled: state<boolean>?,

    image: state<string>?,
    color: state<Color3>,
    transparency: state<number>?,
    visible: state<boolean>,
    roundness: state<number>?,

    hovering: state<boolean>?,
    hoverScale: state<number>?,
    clickingScale: state<number>?,
    animationSide: state<"left"|"right"|"top"|"bottom">?,
    ratio: state<number>?,
    
    onClick: (()->())?,
})
    local scope = scope:innerScope()

    local hovering = scope:Value(false)
    local clicking = scope:Value(false)

    local scale = scope:Computed(function(use)
        if not use(props.disabled or false) then
            if use(clicking) then
                return use(props.clickingScale or 0.9)
            end

            if use(hovering) then
                return use(props.hoverScale or 1.1)
            end
        end
        if use(props.visible or true) then
            return 1
        end
        return 0
    end)
    local scaleSpring = scope:Spring(scale, StateData.GetSpring("buttonScale"), StateData.GetDamp("buttonDamp"))

    local anchor = scope:Computed(function(use)
        local configData = use(props.animationSide or "bottom")
        local animationData = UIConfiguration.button.animationPos[configData]

        if use(props.visible) then
            return UIConfiguration.default.anchorPoint
        end
        return animationData.idleAnchorPoint
    end)
    local anchorSpring = scope:Spring(anchor, StateData.GetSpring("buttonAnchor"), StateData.GetDamp("buttonAnchor"))

    local pos = scope:Computed(function(use)
        local configData = use(props.animationSide or "bottom")
        local animationData = UIConfiguration.button.animationPos[configData]

        if use(hovering) or use(clicking) then
            return animationData.activePosition
        end
        if use(props.visible) then
            return UIConfiguration.default.position
        end
        return animationData.inactivePosition
    end)
    local posSpring = scope:Spring(pos, StateData.GetSpring("buttonPosition"), StateData.GetDamp("buttonPosition"))
    local colorSpring = scope:Spring(props.color, StateData.GetSpring("buttonColor"), StateData.GetDamp("buttonColor"))

    return scope:Hydrate(Container(scope, props)) {
        [Children] = {
            scope:New "ImageButton" {
                AnchorPoint = anchorSpring,
                Size = UDim2.fromScale(1, 1),
                Position = posSpring,
                Image = props.image,
                BackgroundColor3 = colorSpring,
                ImageColor3 = colorSpring,
                BackgroundTransparency = scope:Computed(function(use)
                    local imageString = use(props.image or "")
                    local newTransparency = use(props.transparency or 0)

                    if imageString:len() == 0 then
                        return newTransparency
                    end
                    return 1
                end),
                ImageTransparency = scope:Computed(function(use)
                    local imageString = use(props.image or "")
                    local newTransparency = use(props.transparency or 0)
                    if imageString:len() == 0 then
                        return 1
                    end
                    return newTransparency
                end),

                [OnEvent "MouseEnter"] = function()
                    hovering:set(true)
                end,
                [OnEvent "MouseLeave"] = function()
                    hovering:set(false)
                    clicking:set(false)
                end,

                [OnEvent "MouseButton1Down"] = function()
                    clicking:set(true)
                end,
                [OnEvent "MouseButton1Up"] = function()
                    clicking:set(false)
                end,

                [OnEvent "Activated"] = props.onClick,

                [Children] = Child {
                    scope:New "UIScale" {
                        Scale = scaleSpring
                    },

                    scope:New "UICorner" {
                        CornerRadius = scope:Computed(function(use, _)
                            local finalRoundness = use(props.roundness or 0)
                            return UDim.new(
                                if finalRoundness > 1 then 0 else finalRoundness,
                                if finalRoundness > 1 then finalRoundness else 0
                            )
                        end)
                    },

                    scope:Computed(function(use): Instance?
                        local hasRatio: number = use(props.ratio)
                        if type(hasRatio) ~= "number" then
                            return nil
                        end

                        return scope:New "UIAspectRatioConstraint" {
                            AspectRatio = hasRatio,
                        }
                    end)
                }
            }
        }
    }
end