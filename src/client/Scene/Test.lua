--[[
    Test.
    HawDevelopment
    01/26/2022
--]]

local Test = {}
Test.__index = Test

Test.ClassName = "Test"

function Test.new(position, radius)
    local self = setmetatable({}, Test)
    
    self.Position = position
    self.Radius = radius
    
    return self
end

return Test