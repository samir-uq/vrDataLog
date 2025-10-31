local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UiLabs = require(ReplicatedStorage.Packages.UiLabs)


local Storybook: UiLabs.Storybook = {
    name = "Stories",
    storyRoots = script.Parent:GetChildren(),
    groupRoots = true,
}
return Storybook