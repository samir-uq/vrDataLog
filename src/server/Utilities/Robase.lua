local RobaseService = require(script.Parent.RobaseService.Service)

local BaseURL = "https://uniquedummy-roblox-default-rtdb.firebaseio.com/"
local Token = "sQWFThFl3ocAgt6FDBc309tIqYmtYDP6YBH3EEhA"

return RobaseService.new(BaseURL, Token)