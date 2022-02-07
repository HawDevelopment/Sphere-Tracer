--[[
    Parallel.
    HawDevelopment
    01/29/2022
--]]

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local PixelSize = 7
local __screenSize = workspace.CurrentCamera.ViewportSize / PixelSize
local ScreenSize = Vector2.new(math.ceil(__screenSize.X), math.ceil(__screenSize.Y))
local aspectRatio = ScreenSize.X / ScreenSize.Y
local fov = math.tan(math.rad(70 / 2))

task.wait(3)

local function NewSphere(pos, radius, color)
    return { ClassName = "Sphere", Position = pos, Radius = radius, Color = color }
end
local function NewPlane(pos, normal, color)
    return { ClassName = "Plane", Position = pos, Normal = normal, Color = color }
end
local function NewTest(pos, radius, color)
    return { ClassName = "Test", Position = pos, Radius = radius, Color = color }
end
local function NewLight(pos, color, intensity)
    return { ClassName = "Light", Position = pos, Color = color, Intensity = intensity }
end

local Scene = {
    NewTest(Vector3.new(0, 0, 0), 1, Color3.new(1, 0, 0)),
    
    -- NewSphere(Vector3.new(0, 0, 5), 1, Color3.new(1, 0, 0)),
    
    -- NewPlane(Vector3.new(0, -6, 0), Vector3.new(0, 1, 0)),
    -- NewPlane(Vector3.new(0, 6, 0), Vector3.new(0, -1, 0)),
    -- NewPlane(Vector3.new(0, 0, 12), Vector3.new(0, 0, -1)),
    
    -- NewPlane(Vector3.new(-6, 0, 6), Vector3.new(1, 0, 0), Color3.new(0, 0, 1)),
    -- NewPlane(Vector3.new(6, 0, 6), Vector3.new(-1, 0, 0), Color3.new(1, 0, 0)),
}

local Lights = {
    NewLight(Vector3.new(0, 5, 0), 50, 10)
}

local MAX_DIST = 300
local MAX_STEPS = 50
local EPSILON = 0.001
local REFLECTION_AMOUNT = 1

local Render
do
    Render = {}
    Render.__index = Render
    
    function Render.new(scene, lights)
        local self = setmetatable({}, Render)
        
        self.Scene = scene
        self.Lights = lights
        self.CFrame = CFrame.new(0, 2, -5)
        
        return self
    end
    
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
            if lightDir:Dot(normal) < 0 then
                continue
            end
            
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
end

if script:GetAttribute("IsTracer") then
    -- Create frames and render them
    local collum = script:GetAttribute("Collum")
    local screen = game.Players.LocalPlayer.PlayerGui:WaitForChild("ScreenGui")
    local parent = Instance.new("Folder")
    
    -- Create frames
    local frames = {}
    for y = 0, ScreenSize.Y do
        local frame = Instance.new("Frame")
        frame.Size = UDim2.fromOffset(PixelSize, PixelSize)
        frame.Position = UDim2.fromOffset(collum * PixelSize, y * PixelSize)
        frame.BorderSizePixel = 0
        frame.BackgroundColor3 = Color3.new(0, 0, 0)
        frame.Parent = parent
        
        frames[y] = frame
    end
    parent.Parent = screen
    
    -- Create pixel direction buffer
    local dirs = table.create(ScreenSize.Y)
    for y = 0, ScreenSize.Y do
        local xPos = (2 * ((collum + 0.5) / ScreenSize.X) - 1) * fov * aspectRatio
        local yPos = (1 - 2 * ((y + 0.5) / ScreenSize.Y)) * fov
        
        dirs[y] = Vector3.new(xPos, yPos, 1).Unit
    end
    
    local buffer = table.create(ScreenSize.Y)
    local renderer = Render.new(Scene, Lights)
    
    
    
    RunService.Heartbeat:ConnectParallel(function()
        for y = 0, ScreenSize.Y do
            buffer[y] = renderer:_renderColor(renderer.CFrame.p, renderer.CFrame:VectorToWorldSpace(dirs[y]))
        end
        task.synchronize()
        for y = 0, ScreenSize.Y do
            frames[y].BackgroundColor3 = buffer[y]
        end
        
        renderer.CFrame = (workspace.Position :: CFrameValue).Value
        renderer.Lights[1].Position = renderer.CFrame.Position
    end)
else
    local Config = require(script.Parent:WaitForChild("Config"))
    
    if Config.Runner ~= Config.RUNNERS.Parallel then
        return
    end
    
    -- Create all actors and renders
    local screen = Instance.new("ScreenGui")
    screen.IgnoreGuiInset = true
    screen.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    
    local parent = Instance.new("Folder")
    parent.Name = "Tracer"
    parent.Parent = script.Parent
    
    local cframe = CFrame.new(0, 2, -5)
    local value = Instance.new("CFrameValue")
    value.Name = "Position"
    value.Value = CFrame.new()
    value.Parent = workspace
    
    for i = 0, ScreenSize.X do
        local actor = Instance.new("Actor")
        actor.Parent = parent
        
        local render = script:Clone()
        render.Name = "Render"
        render:SetAttribute("IsTracer", true)
        render:SetAttribute("Collum", i)
        render.Parent = actor
        
        render.Disabled = false
    end
    
    do
        local MOVEMENT_SPEED = 0.5
        
        local function Input()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                cframe += cframe.LookVector * -MOVEMENT_SPEED
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                cframe += cframe.LookVector * MOVEMENT_SPEED
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                cframe += cframe.RightVector * -MOVEMENT_SPEED
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                cframe += cframe.RightVector * MOVEMENT_SPEED
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Q) then
                cframe += cframe.UpVector * MOVEMENT_SPEED
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.E) then
                cframe += cframe.UpVector * -MOVEMENT_SPEED
            end
        end
        local function MouseInput()
            local rotationAngle = 0
            local delta = UserInputService:GetMouseDelta()

            if math.abs(delta.X) > 0 then
                rotationAngle = delta.X / 20
                cframe *= CFrame.Angles(0, rotationAngle, 0)
            end
            if math.abs(delta.Y) > 0 then
                rotationAngle = delta.Y / 20
                cframe *= CFrame.Angles(rotationAngle, 0, 0)
            end
        end
        
        
        RunService.RenderStepped:Connect(function()
            Input()
            MouseInput()
            value.Value = cframe
        end)
    end
end