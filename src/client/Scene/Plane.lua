--[[
    Plane
    HawDevelopment
    01/27/2022
--]]


local Plane = {}
Plane.__index = Plane

Plane.ClassName = "Plane"

function Plane.new(position, normal)
    local self = setmetatable({}, Plane)
    
    self.Position = position
    self.Normal = normal
    
    return self
end

return Plane
