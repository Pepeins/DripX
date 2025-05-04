-- Drip X - Movement/Speed Module

local module = {}
local Config, Services, UI, Player

local function updateSpeed()
    if not Player or not Player.Character then return end
    local humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    local targetSpeed = Config.speedEnabled and (humanoid.WalkSpeed * Config.speedMultiplier) or 16 
    if humanoid.WalkSpeed ~= targetSpeed then
        pcall(function() humanoid.WalkSpeed = targetSpeed end)
    end
end

local function updateSize()
    if not Player or not Player.Character then return end
 
    pcall(function()
        local currentScale = Player.Character:GetScale()
        local targetScale = Config.sizeEnabled and Config.sizeMultiplier or 1
        if math.abs(currentScale - targetScale) > 0.01 then 
            Player.Character:ScaleTo(targetScale)
        end
    end)
end

function module:init(sharedEnv)
    Config = sharedEnv.Config
    Services = sharedEnv.Services
    UI = sharedEnv.UI
    Player = sharedEnv.Player

    UI.createSection("Movement")

    UI.createToggle("Enable Speed", Config.speedEnabled, function(value)
        Config.speedEnabled = value
        updateSpeed() 
    end)

    UI.createSlider("Speed Multiplier", 1.1, 10, Config.speedMultiplier, function(value)
        Config.speedMultiplier = value
        if Config.speedEnabled then updateSpeed() end
    end)

    UI.createToggle("Enable Size", Config.sizeEnabled, function(value)
        Config.sizeEnabled = value
        updateSize() 
    end)

    UI.createSlider("Size Multiplier", 0.2, 5, Config.sizeMultiplier, function(value)
        Config.sizeMultiplier = value
        if Config.sizeEnabled then updateSize() end
    end)

    local charAddedConn = nil
    local steppedConn = nil

     local function setupCharacterConnections()
         if not Player.Character then return end
         updateSpeed() 
         updateSize()
         if steppedConn then steppedConn:Disconnect() end 

         steppedConn = Services.RunService.RenderStepped:Connect(function()
             if Config.speedEnabled then updateSpeed() end
             -- if Config.sizeEnabled then updateSize() end
         end)
     end


    charAddedConn = Player.CharacterAdded:Connect(function(character)
        task.wait(0.5)
        setupCharacterConnections()
    end)

    if Player.Character then
        setupCharacterConnections()
    end

    Config.connections.movementCharAdded = charAddedConn

    print("Movement Module Initialized")
end

function module:destroy()
    if Player and Player.Character then
        local humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then pcall(function() humanoid.WalkSpeed = 16 end) end
        pcall(function() Player.Character:ScaleTo(1) end)
    end
    if Config.connections.movementCharAdded then Config.connections.movementCharAdded:Disconnect() end

    print("Movement Module Destroyed")
end


return module