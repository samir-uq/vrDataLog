return {
    
    default = {
        primaryFont = Font.fromName("Montserrat", Enum.FontWeight.SemiBold),

        anchorPoint = Vector2.new(0.5, 0.5),
        size = UDim2.fromScale(0.5, 0.5),
        position = UDim2.fromScale(0.5, 0.5),
        backgroundColor3 = Color3.fromRGB(255,255,255),
    },

    button = {
        animationPos = {
            bottom = {
                idleAnchorPoint = Vector2.new(0.5, 1),
                activePosition = UDim2.fromScale(0.5, 0.55),
                inactivePosition = UDim2.fromScale(0.5, 1.5)
            },

            top = {
                idleAnchorPoint = Vector2.new(0.5, 0),
                activePosition = UDim2.fromScale(0.5, 0.45),
                inactivePosition = UDim2.fromScale(0.5, -1.5)
            },

            left = {
                idleAnchorPoint = Vector2.new(0, 0.5),
                activePosition = UDim2.fromScale(0.55, 0.5),
                inactivePosition = UDim2.fromScale(-1.5, 0.5)
            },

            right = {
                idleAnchorPoint = Vector2.new(1, 0.5),
                activePosition = UDim2.fromScale(0.45, 0.5),
                inactivePosition = UDim2.fromScale(1.5, 0.5)
            }
        }
    },

    canvas = {
        animationPos = {
            bottom = {
                idleAnchorPoint = Vector2.new(0.5, 1),
                activePosition = UDim2.fromScale(0.5, 0.55),
                inactivePosition = UDim2.fromScale(0.5, 1)
            },

            top = {
                idleAnchorPoint = Vector2.new(0.5, 0),
                activePosition = UDim2.fromScale(0.5, 0.45),
                inactivePosition = UDim2.fromScale(0.5, 0)
            },

            left = {
                idleAnchorPoint = Vector2.new(0, 0.5),
                activePosition = UDim2.fromScale(0.55, 0.5),
                inactivePosition = UDim2.fromScale(0, 0.5)
            },

            right = {
                idleAnchorPoint = Vector2.new(1, 0.5),
                activePosition = UDim2.fromScale(0.45, 0.5),
                inactivePosition = UDim2.fromScale(1, 0.5)
            }
        },

        position = UDim2.fromScale(0.5, 1),
        anchorPoint = Vector2.new(0.5, 1),
        titleSize = 0.125 --sacle,
    },

    text = {
        shadowOffset = UDim2.fromOffset(5, 0)
    },

    garden = {
        buttonCornerRadius = 0.25,
        buttonBackgroundDarkness = 0.65,
    }
}