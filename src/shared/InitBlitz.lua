local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local IsServer = RunService:IsServer()

-- local function ProtectedCall(Callback: (any)->any, Iteration: number?, WaitTime: number?)
-- 	Iteration = Iteration or 5
-- 	if not Iteration then return end

-- 	for _ = 1, Iteration do
-- 		local Success, Result = pcall(Callback)
-- 		if Success then
-- 			return Result
-- 		end
-- 		task.wait(WaitTime)
-- 	end
-- end

local function LoadModules(Folders: {Folder})
	for _, Folder in Folders do
		for _, Module: Instance in Folder:GetDescendants() do
			if not Module:IsA("ModuleScript") then continue end

			task.spawn(function()
				local Success, Result = pcall(require, Module)
				if not Success then
					error("Unable to require Module ".. Module.Name)
				end

				if typeof(Result)~="table" then return end
				if not Result.Start then return end

				Success, Result = pcall(Result.Start)
				if not Success then
					error("Unable to start Module ".. Module.Name.. "Reason: "..Result)
				end
			end)
		end
	end
end

local function Initialize()
	local Clock = os.clock()

	local LoadingFolders = table.create(2)

	if IsServer then
		table.insert(LoadingFolders, game.ServerScriptService.Server)
	else
		table.insert(LoadingFolders, ReplicatedStorage.Shared.Client)
	end
	table.insert(LoadingFolders, ReplicatedStorage.Shared.Modules)

	LoadModules(LoadingFolders)
	print("Initialized Game in " .. string.format("%.3" .. "f", (os.clock()-Clock)*10) .. ".")

	if not RunService:IsStudio() then
		print("Framework by uniquedummie")
		-- dont delete this this is my signature onb..
	end
end


return Initialize