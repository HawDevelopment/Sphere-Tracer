--[[
    Buffer
    HawDevelopment
    01/28/2022
--]]

local Buffer = {}
Buffer.__index = Buffer

function Buffer.new(sizex, sizey, default)
    local self = setmetatable({}, Buffer)
    
    self.Size = Vector2.new(sizex, sizey)
    self.Buffer = table.create(sizex * sizey, default)
    
    return self
end

function Buffer:set(x, y, value)
    self.Buffer[(y - 1) * self.Size.x + x] = value
end

function Buffer:get(x, y)
    return self.Buffer[(y - 1) * self.Size.x + x]
end

function Buffer:Destroy()
    table.clear(self.Buffer)
end

return Buffer
