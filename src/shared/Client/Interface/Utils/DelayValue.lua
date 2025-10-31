local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Packages.Fusion)

local scoped = Fusion.scoped
local peek = Fusion.peek
local Children = Fusion.Children

type scope = Fusion.Scope<typeof(Fusion)>
type state<T> = Fusion.UsedAs<T>

local function delayValue<T>(input: state<T>, scope: scope, delayTime: number): state<T>
    local delayed = scope:Value(peek(input))
    local setValue: thread? = nil
  
    scope:Observer(input):onChange(function()
      if setValue then
        task.cancel(setValue)
      end
      
      setValue = task.delay(delayTime, function()
        delayed:set(peek(input))
        setValue = nil
      end)
    end)
  
    return delayed
end

return delayValue
  