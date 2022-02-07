--[[
    Render Modifier
    HawDevelopment
    01/29/2022
--]]

return function (modifiers)
    return function (shape)
        for index, value in pairs(modifiers) do
            shape[index] = value
        end
        return shape
    end
end