local DefaultSpringSpeed = 12
local DefaultSpringDamp = 0.8

local Storage = {
    Position = {
        Speed = 10,
        Damp = 0.75
    },

    toggleColor = {
        Speed = 5,
        Damp = 0.6
    }
}
local StateData = {}

local function SplitCamelCase(input: string)
    local prefix, suffix = input:match("^(%l+)(%u%w+)$")
    if prefix and suffix then
        return {input, prefix, suffix}
    else
        return {input}
    end
end

local function GetSpringData(Keys: {string}): {Speed: number, Damp: number}?
    for _, Key in Keys do
        if Storage[Key] then
            return Storage[Key]
        end
    end
    return nil
end

function StateData.GetSpring(SpringType: string): number
    local PossibleSpringData = GetSpringData(SplitCamelCase(SpringType))
    if PossibleSpringData then
        return PossibleSpringData.Speed
    end
    return DefaultSpringSpeed
end

function StateData.GetDamp(SpringType: string): number
    local PossibleSpringData = GetSpringData(SplitCamelCase(SpringType))
    if PossibleSpringData then
        return PossibleSpringData.Damp
    end
    return DefaultSpringDamp
end

return StateData