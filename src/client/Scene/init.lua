--[[
    Scene
    HawDevelopment
    01/26/2022
--]]

local Test = require(script:WaitForChild("Test"))
local Sphere = require(script:WaitForChild("Sphere"))
local Plane = require(script:WaitForChild("Plane"))
local Light = require(script:WaitForChild("Light"))
local RenderModifier = require(script:WaitForChild("RenderModifier"))

local RedReflector = RenderModifier({ Color = Color3.new(1, 0, 0), Reflection = 0.5 })

local Red = RenderModifier({ Color = Color3.new(1, 0, 0) })
local Blue = RenderModifier({ Color = Color3.new(0, 0, 1) })
local Grey = RenderModifier({ Color = Color3.new(0.5, 0.5, 0.5) })

return function ()
    return {
        -- RedReflector(Sphere.new(Vector3.new(0, 3, 5), 1)),
        Red(Test.new(Vector3.new(0, 0, 0), 1)),
        
        -- Grey(Plane.new(Vector3.new(0, -6, 0), Vector3.new(0, 1, 0))),
        -- Grey(Plane.new(Vector3.new(0, 6, 0), Vector3.new(0, -1, 0))),
        -- Grey(Plane.new(Vector3.new(0, 0, 12), Vector3.new(0, 0, -1))),
        -- Blue(Plane.new(Vector3.new(-6, 0, 6), Vector3.new(1, 0, 0))),
        -- Red(Plane.new(Vector3.new(6, 0, 6), Vector3.new(-1, 0, 0))),
        
    }, {
        Light.new(Vector3.new(0, 2, -5), 50, 10)
    }
end