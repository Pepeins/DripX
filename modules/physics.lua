-- Drip X - Physics/Gravity modifier Module

local module = {}
local Config, Services, UI, Player, Workspace

local function updateGravity()
    local targetGravity = Config.gravityEnabled and Config.gravityValue or 196.2 
    if math.abs(Workspace.Gravity - targetGravity) > 0.1 then
        Workspace.Gravity = targetGravity
    end
end

local function teleportToSpawn()
    local character = Player.Character
    if not character or not character.PrimaryPart then
        UI.showNotification("Cannot teleport: Character not found.", 2)
        return
    end

    local spawnPoint = nil
    for _, sp in pairs(Workspace:GetChildren()) do
        if sp:IsA("SpawnLocation") and not sp.Neutral and sp.TeamColor == Player.TeamColor then
            spawnPoint = sp
            break
        elseif sp:IsA("SpawnLocation") and sp.Neutral then
            spawnPoint = sp 
        end
    end

    if not spawnPoint then
         spawnPoint = Workspace:FindFirstChildOfClass("SpawnLocation")
         if not spawnPoint then
             UI.showNotification("Cannot teleport: No spawn location found.", 2)
             return
         end
    end

    local targetCFrame = spawnPoint.CFrame + Vector3.new(0, 3, 0)
    pcall(function() character:SetPrimaryPartCFrame(targetCFrame) end)
    UI.showNotification("Teleported to spawn.", 1.5)
end

function module:init(sharedEnv)
    Config = sharedEnv.Config
    Services = sharedEnv.Services
    UI = sharedEnv.UI
    Player = sharedEnv.Player
    Workspace = Services.Workspace

    Config.originalValues.gravity = Workspace.Gravity

    UI.createSection("Physics")

    UI.createToggle("Custom Gravity", Config.gravityEnabled, function(value)
        Config.gravityEnabled = value
        updateGravity()
    end)

    UI.createSlider("Gravity Value", 0, 196.2 * 2, Config.gravityValue, function(value) 
        Config.gravityValue = value
        if Config.gravityEnabled then updateGravity() end
    end)

    UI.createStyledButton("Teleport to Spawn", Color3.fromRGB(70, 130, 180), function() 
        teleportToSpawn()
    end)

    updateGravity()

    print("Physics Module Initialized")
end


function module:destroy()
    if Config.originalValues.gravity then
        pcall(function() Workspace.Gravity = Config.originalValues.gravity end)
    end
    print("Physics Module Destroyed")
end

return module