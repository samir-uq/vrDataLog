local RobaseService = require(script.Parent.RobaseService.Service)

local BaseURL = "https://shonen-bg-default-rtdb.firebaseio.com/"
local Token = "MZzrEYtAl6L3MdAoYA0PLht9e24ZEh6GA4wpOHnp"

return RobaseService.new(BaseURL, Token)