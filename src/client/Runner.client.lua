--[[
    Runner.
    HawDevelopment
    26/01/2022
--]]

--[[
    Heres an outline of steps:
    1. Create a screen of pixels.

    2. Find ray intersections.
    3. Apply lighting and color.
    4. Output to screen.
    5. Repeat.
--]]

local Config = require(script.Parent:WaitForChild("Config"))
if Config.Runner == Config.RUNNERS.Parallel then
    return
end

local UserInputService = game:GetService("UserInputService")
local express = require(game:GetService("ReplicatedStorage"):WaitForChild("express"))
local Render = require(script.Parent:WaitForChild("Render"))
local Screen = require(script.Parent:WaitForChild("Screen"))
local Scene = require(script.Parent:WaitForChild("Scene"))

task.wait(3)

local shapes, lights = Scene()
local pixelToDir = Screen.createPixelDirs(Config)
local renderer = Render.new(Config, shapes, pixelToDir, lights)
print("Renderer created")

task.wait(1)

if Config.Runner == Config.RUNNERS.RealTime then
    local screen = Screen.new(Config)
    screen:CreateScreen()
    
    local MOVEMENT_SPEED = 0.5
    local function Input()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            renderer.CFrame += renderer.CFrame.LookVector * -MOVEMENT_SPEED
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            renderer.CFrame += renderer.CFrame.LookVector * MOVEMENT_SPEED
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            renderer.CFrame += renderer.CFrame.RightVector * -MOVEMENT_SPEED
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            renderer.CFrame += renderer.CFrame.RightVector * MOVEMENT_SPEED
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Q) then
            renderer.CFrame += renderer.CFrame.UpVector * MOVEMENT_SPEED
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.E) then
            renderer.CFrame += renderer.CFrame.UpVector * -MOVEMENT_SPEED
        end
    end
    local function MouseInput()
        local rotationAngle = 0
		local delta = UserInputService:GetMouseDelta()

		if math.abs(delta.X) > 0 then
			rotationAngle = delta.X / 20
            renderer.CFrame *= CFrame.Angles(0, rotationAngle, 0)
		end
		if math.abs(delta.Y) > 0 then
			rotationAngle = delta.Y / 20
            renderer.CFrame *= CFrame.Angles(rotationAngle, 0, 0)
		end
    end
    
    local frame = 0
    while true do
        -- Input
        Input()
        MouseInput()
        
        -- Update Lighting
        renderer.Lights[1].Position = renderer.CFrame.Position
        
        -- Update Geometry
        frame += 1
        
        -- Render
        -- local stop = TakeTime(renderer.RenderToScreen, renderer, screen.Pixels)
        local start = os.clock()
        debug.profilebegin("Render")
        renderer:RenderToScreen(screen.Pixels)
        debug.profileend()
        local stop = os.clock() - start
        
        -- Breath time
        task.wait(math.max((workspace:GetAttribute("FrameTime") or Config.FrameTime) - stop, 0))
    end
else
    local buffer = table.create(Config.ScreenSize.X)
    for x = 1, Config.ScreenSize.X do
        buffer[x] = table.create(Config.ScreenSize.Y)
        for y = 1, Config.ScreenSize.Y do
            buffer[x][y] = renderer:_renderColor(renderer.CFrame.p, renderer.CFrame:VectorToWorldSpace(renderer.Dirs:get(x, y)))
        end
        
        if x % 25 == 0 then
            task.wait()
            print("Rendered " .. x .. " of " .. Config.ScreenSize.X)
        end
    end

    express.Request("App://PostImage", "POST", buffer)
end


