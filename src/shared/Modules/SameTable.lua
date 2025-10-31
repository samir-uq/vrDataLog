function KeysMatch(table1, table2, key)
	if table2[key] == nil then
		return
	end

	if typeof(table1[key]) ~= typeof(table2[key]) then
		return
	end

	if typeof(table1[key]) == "table" then
		if not CheckKeys(table1[key], table2[key]) then
			return
		end
	elseif table1[key] ~= table2[key] then
		return
	end

	return true
end

function CheckKeys(table1: {}, table2: {}): any
	if not table1 then
		return
	end

	for key in pairs(table1) do
		if not KeysMatch(table1, table2, key) then
			return
		end
	end

	return true
end

function AreTablesSame(table1, table2)
	if not CheckKeys(table1, table2) then
		return
	end

	if not CheckKeys(table2, table1) then
		return
	end

	return true
end

return AreTablesSame