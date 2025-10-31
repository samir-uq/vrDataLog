
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Packages.Fusion)

local scoped = Fusion.scoped
local peek = Fusion.peek
local Children = Fusion.Children
local Child = Fusion.Child

local Dependency = {

}

type scope = Fusion.Scope<typeof(Fusion) & typeof(Dependency)>
type state<T> = Fusion.UsedAs<T>
return function (props: {
    scope: scope,
})
    local scope = props.scope:innerScope()
end