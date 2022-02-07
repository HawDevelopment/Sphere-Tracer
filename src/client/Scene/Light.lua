--[[
    Light.
    HawDevelopment
    01/28/2022
--]]

local Light = {}
Light.__index = Light

function Light.new(pos, color, intensity)
    local self = setmetatable({}, Light)
    
    self.Position = pos
    self.Color = color
    self.Intensity = intensity
    
    return self
end

return Light
