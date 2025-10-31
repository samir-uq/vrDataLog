
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Container = require(ReplicatedStorage.Shared.Client.Interface.Components.Default.Container)
local ColorPallete = require(ReplicatedStorage.Shared.Client.Interface.MetaData.ColorPallete)

local scoped = Fusion.scoped
local peek = Fusion.peek
local Children = Fusion.Children
local Child = Fusion.Child

local Dependency = {
    Container = Container
}

type scope = Fusion.Scope<typeof(Fusion) & typeof(Dependency)>
type state<T> = Fusion.UsedAs<T>
return function (scope: scope, props: {})
    local scope = scope:innerScope(Dependency)

    local mainColor = scope:Value(Color3.fromRGB(215, 96, 255))
    local mainColorSpring = scope:Spring(mainColor, 6, 0.6)

    local LastChanged = 0
    local Length = 3

    local starSize = workspace.CurrentCamera.ViewportSize.X > 500 and 100 or 40
    local starPadding = workspace.CurrentCamera.ViewportSize.X > 500 and 40 or 20

    local starSpeed, starDamp = 12, 0.3

    local globalStarScale = scope:Value(1)
    local globalStarSpring = scope:Spring(globalStarScale, starSpeed, starDamp)

    local globalRotationScale = scope:Value(0)
    local globalRotationSpring = scope:Spring(globalRotationScale, starSpeed/2, starDamp)


    task.spawn(function()
        while task.wait() do
            if os.time() - LastChanged <= Length then
                continue
            end
            
            local newColor
            repeat
                newColor = ColorPallete.colorRotation[math.random(1, #ColorPallete.colorRotation)]
            until newColor ~= peek(mainColor)
            
            mainColor:set(newColor)
            globalStarSpring:addVelocity(workspace.CurrentCamera.ViewportSize.X//850)
            globalRotationSpring:addVelocity(360)
            LastChanged = os.time()
        end
    end)

    return scope:Hydrate(scope:Container {
        size = UDim2.fromScale(1,1),
        transparency = 0,
    }) {
        [Children] = Child {
            scope:Hydrate(scope:Container { -- pattern container
                size = UDim2.fromScale(1,1),
            }) {

            },

            scope:New "UIGradient" {
                Color = scope:Computed(function(use, scope: scope)
                    local currentColor: Color3 = use(mainColorSpring) :: any

                    local secondaryColor = Color3.new(
                        math.clamp(currentColor.R*0.7, 0, 1),
                        math.clamp(currentColor.G*0.7, 0, 1),
                        math.clamp(currentColor.B*0.7, 0, 1)
                    )
                    
                    return ColorSequence.new({
                        ColorSequenceKeypoint.new(0, currentColor),
                        ColorSequenceKeypoint.new(1, secondaryColor)
                    })
                end),
                Rotation = 45,
            }
        }
    }
end