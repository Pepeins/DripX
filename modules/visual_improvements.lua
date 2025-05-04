-- Drip X - Visual Improvements Module

local module = {}
local Config, Services, UI, Lighting, Workspace, RunService


local function storeOriginalValue(key, value)
    if Config.originalValues[key] == nil then 
        Config.originalValues[key] = value
    end
end

local function updateFullBright()
    storeOriginalValue("brightness", Lighting.Brightness)
    storeOriginalValue("ambient", Lighting.Ambient)
    storeOriginalValue("outdoorAmbient", Lighting.OutdoorAmbient)

    if Config.fullBright then
        Lighting.Brightness = 2
        Lighting.Ambient = Color3.fromRGB(180, 180, 180) 
        Lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 180)
    else
        Lighting.Brightness = Config.originalValues.brightness or 1 
        Lighting.Ambient = Config.originalValues.ambient or Color3.fromRGB(128, 128, 128)
        Lighting.OutdoorAmbient = Config.originalValues.outdoorAmbient or Color3.fromRGB(128, 128, 128)
    end
end

local function updateFog()
    storeOriginalValue("fogStart", Lighting.FogStart)
    storeOriginalValue("fogEnd", Lighting.FogEnd)
    storeOriginalValue("fogColor", Lighting.FogColor)

    if Config.noFog then
        Lighting.FogStart = 1000000
        Lighting.FogEnd = 1000000
    else
        Lighting.FogStart = Config.originalValues.fogStart or 0
        Lighting.FogEnd = Config.originalValues.fogEnd or 100000
        
    end
end

local function updateTime()
    storeOriginalValue("clockTime", Lighting.ClockTime)
    storeOriginalValue("timeOfDay", Lighting.TimeOfDay) 

    if Config.customTime then
        local timeString = string.format("%02d:00:00", math.floor(Config.timeValue))
        if Lighting.TimeOfDay ~= timeString then
             -- Setting ClockTime is often more reliable than TimeOfDay string
             Lighting.ClockTime = Config.timeValue
             -- Lighting.TimeOfDay = timeString
        end
    else
        if Config.originalValues.clockTime then
             Lighting.ClockTime = Config.originalValues.clockTime
             -- Lighting.TimeOfDay = Config.originalValues.timeOfDay
        end
    end
end

local function handleVisualPart(part, enable)
     if part:IsA("ParticleEmitter") or part:IsA("Smoke") or part:IsA("Fire") or
        part:IsA("Explosion") or part:IsA("Sparkles") or part:IsA("Beam") then
        pcall(function() part.Enabled = enable end)
     end
     -- Could also make certain decals/textures transparent
     -- if part:IsA("Decal") and part.Name:lower():match("blood") then part.Transparency = enable and 1 or 0 end
end

local function updateVisualObstructions()
    local enableState = not Config.removeVisualObstructions 

    for _, obj in ipairs(Workspace:GetDescendants()) do
        handleVisualPart(obj, enableState)
    end

    if Config.removeVisualObstructions then
        if not Config.connections.visualObstructionAdded then
            Config.connections.visualObstructionAdded = Workspace.DescendantAdded:Connect(function(desc)
                handleVisualPart(desc, false) -- Disable immediately if added while active
            end)
        end
    else
        if Config.connections.visualObstructionAdded then
            Config.connections.visualObstructionAdded:Disconnect()
            Config.connections.visualObstructionAdded = nil
            -- Re-enable particles that might have been disabled previously? Complex
            -- Easiest is just to let newly added ones be enabled by default
        end
    end
end


function module:init(sharedEnv)
    Config = sharedEnv.Config
    Services = sharedEnv.Services
    UI = sharedEnv.UI
    Lighting = Services.Lighting
    Workspace = Services.Workspace
    RunService = Services.RunService

    UI.createSection("Visual Improvements")

    UI.createToggle("Full Bright", Config.fullBright, function(value)
        Config.fullBright = value
        updateFullBright()
    end)

    UI.createToggle("No Fog", Config.noFog, function(value)
        Config.noFog = value
        updateFog()
    end)

    UI.createToggle("Custom Time", Config.customTime, function(value)
        Config.customTime = value
        updateTime()
    end)

    UI.createSlider("Time (0-24)", 0, 24, Config.timeValue, function(value)
        Config.timeValue = value
        if Config.customTime then updateTime() end
    end)

    UI.createToggle("Remove Effects/Particles", Config.removeVisualObstructions, function(value)
        Config.removeVisualObstructions = value
        updateVisualObstructions()
    end)

    updateFullBright()
    updateFog()
    updateTime()
    updateVisualObstructions()

    print("Visual Improvements Module Initialized")
end

function module:destroy()
    if Config.originalValues.brightness then Lighting.Brightness = Config.originalValues.brightness end
    if Config.originalValues.ambient then Lighting.Ambient = Config.originalValues.ambient end
    if Config.originalValues.outdoorAmbient then Lighting.OutdoorAmbient = Config.originalValues.outdoorAmbient end
    if Config.originalValues.fogStart then Lighting.FogStart = Config.originalValues.fogStart end
    if Config.originalValues.fogEnd then Lighting.FogEnd = Config.originalValues.fogEnd end
    if Config.originalValues.clockTime then Lighting.ClockTime = Config.originalValues.clockTime end
    if Config.connections.visualObstructionAdded then Config.connections.visualObstructionAdded:Disconnect(); Config.connections.visualObstructionAdded = nil end
    for _, obj in ipairs(Workspace:GetDescendants()) do handleVisualPart(obj, true) end

    print("Visual Improvements Module Destroyed")
end

return module