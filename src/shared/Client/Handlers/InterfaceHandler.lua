local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local BackgroundFrame = require(ReplicatedStorage.Shared.Client.Handlers.Interface.BackgroundFrame)
local Button = require(ReplicatedStorage.Shared.Client.Interface.Components.Default.Button)
local Container = require(ReplicatedStorage.Shared.Client.Interface.Components.Default.Container)
local Interface = {}

local LocalPlayer = Players.LocalPlayer

local scoped = Fusion.scoped
local peek = Fusion.peek
local Children = Fusion.Children
local computed = Fusion.Computed
local OnEvent = Fusion.OnEvent
local Child = Fusion.Child

local Dependency = {
    Background = BackgroundFrame.Create,
}

type scope = Fusion.Scope<typeof(Fusion) & typeof(Dependency)>
type state<T> = Fusion.UsedAs<T>

local scope: any = scoped(Dependency, Fusion)

function Interface.Start()
    local visible = scope:Value("Menu")

    scope:New "ScreenGui" {
        Parent = LocalPlayer.PlayerGui,
        IgnoreGuiInset = true,
        [Children] = {
            scope:Background {},
        }
    }
end

return Interface