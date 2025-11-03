local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Robase = require(script.Parent.Robase)
local LogBase = (Robase :: any):GetRobase("Logs")

local randomModulescript = {}

local parts = {
	Head = Instance.new("Part", workspace),
	LeftHand = Instance.new("Part", workspace),
	RightHand = Instance.new("Part", workspace),
	Floor = Instance.new("Part", workspace)
}

for _, part in pairs(parts) do
	part.Anchored = true
	part.Size = Vector3.new(1,1,1)
end

parts.Head.BrickColor = BrickColor.Black()
parts.Floor.BrickColor = BrickColor.White()
parts.LeftHand.BrickColor = BrickColor.Red()
parts.RightHand.BrickColor = BrickColor.Blue()

local function arrayToCFrame(arr: any)
	return CFrame.new(table.unpack(arr)) * CFrame.new(0, 10, 0)
end

function randomModulescript.showSimulation(id: string, simIndex: number?)
    local _,data = LogBase:GetAsync("Content")
	warn(data)
    local frames = data[id][(simIndex or 0)+1]

	task.spawn(function()
		while true do
			for i, frame in ipairs(frames) do
				for partName, arr in pairs(frame) do
					if parts[partName] then
						parts[partName].CFrame = arrayToCFrame(arr)
					end
				end
				task.wait(0.03)
			end

			task.wait(1)
		end
	end)
end

function randomModulescript.Start()
    task.wait(3)
    randomModulescript.showSimulation(" punch test 11 1 12pm",3)
end

return randomModulescript
