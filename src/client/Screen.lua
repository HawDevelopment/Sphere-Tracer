--[[
    Screen.
    HawDevelopment
    01/26/2022
--]]

local Players = game:GetService("Players")
local Buffer = require(script.Parent.Buffer)

local Screen = {}
Screen.__index = Screen

local Frame
do
    Frame = Instance.new("Frame")
    Frame.Position = UDim2.new(0, 0, 0, 0)
    Frame.Size = UDim2.new(1, 0, 1, 0)
    Frame.BorderSizePixel = 0
    Frame.BackgroundColor3 = Color3.new(0, 0, 0)
    Frame.AutoLocalize = false
end

function Screen.new(config)
    local self = setmetatable({}, Screen)
    
    self.ScreenSize = config.ScreenSize
    self.PixelSize = config.PixelSize
    
    self.Pixels = Buffer.new(self.ScreenSize.X, self.ScreenSize.Y)
    
    local screen = Frame:Clone()
    screen.Size = UDim2.new(0, self.ScreenSize.X * self.PixelSize, 0, self.ScreenSize.Y * self.PixelSize)
    screen.BackgroundTransparency = 1
    screen.Parent = nil :: Instance
    self.Screen = screen
    
    return self
end

function Screen:CreateScreen()
    self.Screen.Parent = nil
    local size = UDim2.new(0, self.PixelSize, 0, self.PixelSize)
    
    for x = 1, self.ScreenSize.X do
        for y = 1, self.ScreenSize.Y do
            local clone = Frame:Clone()
            clone.Position = UDim2.new(0, (x - 1) * self.PixelSize, 0, (y - 1) * self.PixelSize)
            clone.Size = size
            clone.Parent = self.Screen
            
            self.Pixels:set(x, y, clone)
        end
        
        if x % 10 == 0 then
            task.wait()
        end
    end
    
    local screen = Instance.new("ScreenGui")
    screen.IgnoreGuiInset = true
    screen.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    self.Screen.Parent = screen
end

function Screen:Destroy()
    table.clear(self.Pixels)
    self.Screen:Destroy()
end

function Screen.createPixelDirs(config)
    local result = Buffer.new(config.ScreenSize.X, config.ScreenSize.Y)
    
    local aspectRatio = config.ScreenSize.X / config.ScreenSize.Y
    local fov = math.tan(math.rad(config.FOV / 2))
    
    for x = 1, config.ScreenSize.X do
        for y = 1, config.ScreenSize.Y do
            local xPos = (2 * ((x + 0.5) / config.ScreenSize.X) - 1) * fov * aspectRatio
            local yPos = (1 - 2 * ((y + 0.5) / config.ScreenSize.Y)) * fov
            
            result:set(x, y, Vector3.new(xPos, yPos, 1).Unit)
        end
    end
    
    return result
end

return Screen
