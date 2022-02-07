--[[
    Render.
    HawDevelopment
    01/26/2022
--]]

local Buffer = require(script.Parent:WaitForChild("Buffer"))

local Render = {}
Render.__index = Render

function Render.new(config, scene, dirs, lights)
    local self = setmetatable({}, Render)
    
    self.Scene = scene
    self.Lights = lights
    self.Buffer = Buffer.new(config.ScreenSize.X, config.ScreenSize.Y, Color3.new(0, 0, 0))
    self.Dirs = dirs
    self.Size = config.ScreenSize
    self.CFrame = CFrame.new(0, 2, -5)
    
    return self
end

local MAX_DIST = 300
local MAX_STEPS = 50
local EPSILON = 0.001
local REFLECTION_AMOUNT = 1

function Render:_sceneSDF(pos)
    local minDist = math.huge
    local hit
    for i = 1, #self.Scene do
        local shape = self.Scene[i]
        
        local dist
        if shape.ClassName == "Sphere" then dist = (shape.Position - pos).Magnitude - shape.Radius
        elseif shape.ClassName == "Plane" then dist = shape.Normal:Dot(pos - shape.Position)
        elseif shape.ClassName == "Test" then
            local modulo = Vector3.new((pos.X + 2) % 4 - 2, (pos.Y + 2) % 4 - 2, (pos.Z + 2) % 4 - 2)
            dist = (modulo).Magnitude - shape.Radius
        end
        
        if dist < minDist then
            minDist = dist
            hit = shape
        end
    end
    return minDist, hit
end

function Render:_sphereTrace(origin, dir)
    local t = 0
    local steps = 0
    local hit
    
    local minDist = math.huge
    local pos = origin + dir * t
    
    while t < MAX_DIST and steps < MAX_STEPS do
        minDist, hit = self:_sceneSDF(pos)
        
        if minDist < EPSILON * t then
            return steps, t, hit
        end
        
        t += minDist
        steps += 1
        minDist = math.huge
        pos = origin + dir * t
    end
    
    
    return 0, t, nil
end

function Render:_shadowTrace(origin, dir, maxDist)
    local t = 0
    
    local minDist = math.huge
    local hit
    local pos = origin + dir * t
    local steps = 0
    
    while t < maxDist and steps < MAX_STEPS do
        minDist, hit = self:_sceneSDF(pos)
        
        if minDist < EPSILON * t then
            return true
        end
        
        t += minDist
        steps += 1
        minDist = math.huge
        pos = origin + dir * t
    end
    
    return false
end

local function GetNormal(shape, pos)
    local normal
    if shape.ClassName == "Sphere" then normal = (pos - shape.Position).Unit
    elseif shape.ClassName == "Plane" then normal = shape.Normal.Unit
    elseif shape.ClassName == "Test" then
        local modulo = Vector3.new((pos.X + 2) % 4 - 2, (pos.Y + 2) % 4 - 2, (pos.Z + 2) % 4 - 2)
        normal = (modulo).Unit
    end
    return normal
end

local function Reflect(dir, normal)
    return dir - normal * 2 * normal:Dot(dir)
end

local black = Color3.new()

function Render:_shade(pos, shapeColor, normal)
    local color = 0
    for i = 1, #self.Lights do
        local light = self.Lights[i]
        local lightDir = (light.Position - pos)
        local dist = lightDir.Magnitude
        lightDir = lightDir.Unit
        local shadow = self:_shadowTrace(pos, lightDir, dist) and 0.1 or 1
        color += shadow * lightDir:Dot(normal) * light.Color * (light.Intensity / (dist * dist))
    end
    return black:Lerp(shapeColor, math.clamp(color, 0, 1))
end

function Render:_renderColor(origin, dir)
    local _, t, hit = self:_sphereTrace(origin, dir)
    if not hit then
        return black
    end
    
    local pos = origin + dir * t
    local normal = GetNormal(hit, pos)
    
    local shaded = self:_shade(pos, hit.Color, normal)
    
    if hit.Reflection then
        
        local reflected
        for _ = 1, REFLECTION_AMOUNT do
            dir = Reflect(dir, normal)
            local _, reflectT, reflectHit = self:_sphereTrace(pos + normal, dir)
            
            local reflectedShaded
            if not reflectHit then
                reflectedShaded = black
            else
                pos = pos + dir * reflectT
                normal = GetNormal(reflectHit, pos)
                reflectedShaded = self:_shade(pos, reflectHit.Color, normal)
            end
            
            reflected = (reflected or shaded):Lerp(reflectedShaded, hit.Reflection)
            
            if reflectHit and not reflectHit.Reflection then
                break
            end
        end
        
        return reflected or shaded
    end
    
    return shaded
end

function Render:RenderToBuffer()
    for i = 1, self.Size.X * self.Size.Y do
        self.Buffer.Buffer[i] = self:_renderColor(self.CFrame.p, self.CFrame:VectorToWorldSpace(self.Dirs.Buffer[i]))
    end
end

function Render:FlushToScreen(screen)
    for i = 1, self.Size.X * self.Size.Y do
        screen.Buffer[i].BackgroundColor3 = self.Buffer.Buffer[i]
    end
end

function Render:RenderToScreen(screen)
    local buffer = screen.Buffer
    for i = 1, self.Size.X * self.Size.Y do
        buffer[i].BackgroundColor3 = self:_renderColor(self.CFrame.p, self.CFrame:VectorToWorldSpace(self.Dirs.Buffer[i]))
    end
end

return Render

