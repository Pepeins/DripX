-- Drip X - Hitbox Expander Module

local module = {}
local Config, Services, UI, Player, Workspace, RunService

local originalHitboxData = {} 

local function isPlayerEnemy(otherPlayer) 
    if not otherPlayer or otherPlayer == Player then return false end
    if Config.teamCheck and otherPlayer.Team and Player.Team and otherPlayer.Team == Player.Team then return false end
    return true
end

local function restoreHitbox(player, partName)
    if originalHitboxData[player] and originalHitboxData[player][partName] then
        local data = originalHitboxData[player][partName]
        local character = player.Character
        if character then
            local part = character:FindFirstChild(partName)
            if part and part:IsA("BasePart") then
                pcall(function()
                    part.Size = data.size
                    part.Transparency = data.transparency
                    part.CanCollide = data.cancollide
                end)
            end
        end
        originalHitboxData[player][partName] = nil 
        if not next(originalHitboxData[player]) then
            originalHitboxData[player] = nil 
        end
    end
end

local function restoreAllHitboxes()
    local playersToRestore = {}
    for player, _ in pairs(originalHitboxData) do table.insert(playersToRestore, player) end

    for _, player in ipairs(playersToRestore) do
        local partsToRestore = {}
        if originalHitboxData[player] then
            for partName, _ in pairs(originalHitboxData[player]) do table.insert(partsToRestore, partName) end
            for _, partName in ipairs(partsToRestore) do
                 restoreHitbox(player, partName)
            end
        end
    end
    originalHitboxData = {} 
end

local function expandHitbox(player)
    if not player or not player.Character or not isPlayerEnemy(player) then return end

    local character = player.Character
    local partName = Config.hitboxPart
    local part = character:FindFirstChild(partName)

    if part and part:IsA("BasePart") then
        if not originalHitboxData[player] then originalHitboxData[player] = {} end
        if not originalHitboxData[player][partName] then
            originalHitboxData[player][partName] = {
                size = part.Size,
                transparency = part.Transparency,
                cancollide = part.CanCollide
            }
        end

        local targetSize = Vector3.new(Config.hitboxSize, Config.hitboxSize, Config.hitboxSize)
        if part.Size ~= targetSize then part.Size = targetSize end
        if part.Transparency ~= Config.hitboxTransparency then part.Transparency = Config.hitboxTransparency end
        if part.CanCollide ~= false then part.CanCollide = false end 
    end
end

local function updateAllHitboxes()
    if not Config.hitboxExpanderEnabled then
        restoreAllHitboxes()
        return
    end

    local currentPlayers = {}
    for _, player in ipairs(Services.Players:GetPlayers()) do
        if player ~= Player then
            currentPlayers[player] = true
            expandHitbox(player)
        end
    end

    local playersToCleanup = {}
    for player, partData in pairs(originalHitboxData) do
        if not currentPlayers[player] or not isPlayerEnemy(player) then
            table.insert(playersToCleanup, player)
        end
    end
    for _, player in ipairs(playersToCleanup) do
        local partsToRestore = {}
        if originalHitboxData[player] then
             for partName, _ in pairs(originalHitboxData[player]) do table.insert(partsToRestore, partName) end
             for _, partName in ipairs(partsToRestore) do restoreHitbox(player, partName) end
        end
    end
end

function module:init(sharedEnv)
    Config = sharedEnv.Config
    Services = sharedEnv.Services
    UI = sharedEnv.UI
    Player = sharedEnv.Player
    Workspace = Services.Workspace
    RunService = Services.RunService

    UI.createSection("Hitbox Expander")

    UI.createToggle("Enable Expansion", Config.hitboxExpanderEnabled, function(value)
        Config.hitboxExpanderEnabled = value
        if not value then restoreAllHitboxes() end 
    end)

    UI.createSlider("Hitbox Size", 1, 10, Config.hitboxSize, function(value)
        Config.hitboxSize = value
        
    end)

    UI.createSlider("Hitbox Transparency", 0, 1, Config.hitboxTransparency, function(value)
        Config.hitboxTransparency = value
        
    end)

    UI.createDropdown("Expand Part", {"Head", "HumanoidRootPart", "Torso"}, Config.hitboxPart, function(option)
        restoreAllHitboxes() 
        Config.hitboxPart = option
        
    end)

    Config.connections.hitboxUpdate = RunService.Heartbeat:Connect(updateAllHitboxes) 

    Config.connections.hitboxPlayerAdded = Services.Players.PlayerAdded:Connect(function(player)
        task.wait(1) 
        if Config.hitboxExpanderEnabled then expandHitbox(player) end
    end)

    Config.connections.hitboxPlayerRemoving = Services.Players.PlayerRemoving:Connect(function(player)
        restoreHitbox(player, Config.hitboxPart)
    end)

    if Config.hitboxExpanderEnabled then
        task.wait(1) 
        updateAllHitboxes()
    end

    print("Hitbox Expander Module Initialized")
end

function module:destroy()
    if Config.connections.hitboxUpdate then Config.connections.hitboxUpdate:Disconnect() end
    if Config.connections.hitboxPlayerAdded then Config.connections.hitboxPlayerAdded:Disconnect() end
    if Config.connections.hitboxPlayerRemoving then Config.connections.hitboxPlayerRemoving:Disconnect() end
    restoreAllHitboxes() 
    print("Hitbox Expander Module Destroyed")
end

return module