--[[
    Config.
    HawDevelopment
    01/26/2022
--]]

local Config = {}
Config.PixelSize = 10

Config.FOV = 70

Config.FrameTime = 1 / 60
workspace:SetAttribute("FrameTime", Config.FrameTime)

Config.RUNNERS = { Image = 0, RealTime = 1, Parallel = 2 }

Config.Runner = Config.RUNNERS.Image

if Config.Runner == Config.RUNNERS.Image then
    Config.ScreenSize = Vector2.new(math.ceil(1920), math.ceil(1080))
else
    local screenSize = workspace.CurrentCamera.ViewportSize / Config.PixelSize
    Config.ScreenSize = Vector2.new(math.ceil(screenSize.X), math.ceil(screenSize.Y))
end

print(Config.ScreenSize)

return Config