--[[
    Sphere.
    HawDevelopment
    01/26/2022
--]]

local Sphere = {}
Sphere.__index = Sphere

Sphere.ClassName = "Sphere"

function Sphere.new(position, radius)
    local self = setmetatable({}, Sphere)
    
    self.Position = position
    self.Radius = radius
    
    return self
end

return Sphere
