--[[
    Builder.
    HawDevelopment
    29/01/2022
    
    This is actually old code from my past roblox engine project.
--]]

local HttpService = game:GetService("HttpService")

local Builder = {}
Builder.__index = Builder

local function ConvertData(data)
	local newData = {}
	for i = 1, #data do
		newData[i] = {}

		for j = 1, #data[i] do
			local color = data[i][j]
			newData[i][j] = {
				math.clamp(math.floor(color.R * 255), 0, 255),
				math.clamp(math.floor(color.G * 255), 0, 255),
				math.clamp(math.floor(color.B * 255), 0, 255),
			}
		end
	end

	return newData
end

function Builder.new(data)
	-- Convert Color3 to new Color3
	local hexdata = ConvertData(data)

	HttpService:RequestAsync({
		Url = "http://localhost:3000/Image",
		Method = "POST",
		Body = HttpService:JSONEncode(hexdata),
		Headers = {
			["Content-Type"] = "application/json",
		},
	})
    
    return true
end

return Builder