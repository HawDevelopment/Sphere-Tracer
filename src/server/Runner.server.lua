--[[
    Runner.
    HawDevelopment
    01/29/2022
    
    This is actually old code from my past roblox engine project.
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local express = require(ReplicatedStorage.express)
local Builder = require(script.Parent.Builder)

local app = express.App()

app:post("/PostImage", function(req, res)
	local result = Builder.new(req.Body)

	if not result then
		return res:send("Internal server error, failed to send"):status(500)
	end

	res:send(result):status(200)
end)

app:Listen("App")