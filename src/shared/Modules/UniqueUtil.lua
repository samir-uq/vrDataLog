local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SameTable = require(ReplicatedStorage.Shared.Modules.SameTable)
local MainUtil = {}

type ProbabilityTableType = {
	{
		Weight: number,
		any: any,
	}
}

function MainUtil.GetRandom(ProbabilityTable: ProbabilityTableType)
	local OriginalCopy = ProbabilityTable
	local DeepCopy = {}

	for _, x in ProbabilityTable do
		table.insert(DeepCopy,table.clone(x))
	end

	local CurrentWeight = 0
	for _, Data in DeepCopy do
		Data.Weight = Data.Weight + CurrentWeight
		CurrentWeight = Data.Weight
	end

	local Chosen = math.random()*CurrentWeight

	for Index, Data in DeepCopy do
		if Chosen < Data.Weight then
			return Index
		end
	end

	task.wait()
	return MainUtil.GetRandom(OriginalCopy)
end

function MainUtil.FindFromKey(Table: {[any]: any}, Key: string, MatchingValue: any): number?
	for Index, Data in Table do
		if Data[Key] == MatchingValue then
			return Index
		end
	end
	return nil
end

function MainUtil.Count(Table: {[any]: any}): number
	local C = 0
	for _, _ in Table do C+=1 end
	return C
end

function MainUtil.ChangesFromTable(NewData: {}, OldData: {}): {}
	NewData = NewData or {}
	OldData = OldData or {}
	
	local Changed = {}
    for Key, Value in NewData do
        local OldType = typeof(OldData[Key])
        local NewType = typeof(NewData[Key])

        if OldType == NewType then
            if OldType == "table" then
             if not SameTable(OldData[Key], NewData[Key]) then
                 Changed[Key] = Value
             end
            elseif OldData[Key] ~= NewData[Key] then
                Changed[Key] = Value
            end
         else
             Changed[Key] = Value
         end
    end

	for Key, Value in OldData do
		if not NewData[Key] then
			-- warn(" DO NOT EVER NIL A KEY ")
		end
	end
	return Changed
end

function MainUtil.GetRequiredXP(Level: number)
	local BaseXP = 100
	local XPMultiplier = 1.5
	local XPRequired = BaseXP * math.pow(XPMultiplier, Level - 1)

	return math.ceil(XPRequired)
end

function MainUtil.Lerp(A: number, B: number, T: number): number
	return A * (1 - T) + B * T
end

function MainUtil.Wrap(num: number, min: number, max: number): number
    return min + (num - min) % (max - min)
end

function MainUtil.LerpAngle2(a1: number, a2: number, percent: number): number
    a1 += 180
    a2 += 180
    local difference = math.abs(a2 - a1)
    if difference > 180 then
        if a2 > a1 then
            a2 -= 360
        else
            a1 -= 360
        end
    end
    a1 = (a1 - 180)
    a2 = (a2 - 180)
    return MainUtil.Wrap(MainUtil.Lerp(a1, a2, percent), -180, 180)
end


return MainUtil