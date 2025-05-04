-- Drip X - Auto Parry Module

local module = {}
local Config, Services, UI, Player, Workspace, RunService, KeyPress

local attackAnimations = {"punch", "swing", "slash", "attack", "hit", "lunge", "strike"} 
local activeParryDebounce = {} 

local function getDistanceFromCharacter(otherCharacter)
    if not Player.Character or not Player.Character.PrimaryPart or not otherCharacter or not otherCharacter.PrimaryPart then
        return math.huge
    end
    return (Player.Character.PrimaryPart.Position - otherCharacter.PrimaryPart.Position).Magnitude
end

local function isAttackAnimation(animationTrack)
    if not animationTrack or not animationTrack.Animation then return false end
    local animName = animationTrack.Animation.Name:lower()
    local animId = tostring(animationTrack.Animation.AnimationId):lower()

    for _, keyword in ipairs(attackAnimations) do
        if animName:find(keyword, 1, true) or animId:find(keyword, 1, true) then
            return true
        end
    end
    return false
end

local function attemptParry(sourcePlayer)
    if not Config.autoParryEnabled then return end

    local now = tick()
    if activeParryDebounce[sourcePlayer] and (now - activeParryDebounce[sourcePlayer]) < 0.5 then 
        return
    end
    activeParryDebounce[sourcePlayer] = now

    task.delay(Config.autoParryReactionTime, function()
        if not Config.autoParryEnabled then return end 
        local character = Player.Character
        if not character then return end

        local distance = getDistanceFromCharacter(sourcePlayer.Character)
        if distance > Config.autoParryDistance then 
             -- print("AutoParry: Target too far after delay.") -- Debug
             return
        end

        -- print("AutoParry: Attempting parry against", sourcePlayer.Name) -- Debug

        -- Method 1: Fire RemoteEvent (Game Specific)
        local tool = character:FindFirstChildOfClass("Tool")
        local parryEventFired = false
        if tool then
            for _, obj in pairs(tool:GetDescendants()) do
                if obj:IsA("RemoteEvent") and (obj.Name:lower():match("parry") or obj.Name:lower():match("block")) then
                    pcall(obj.FireServer, obj)
                    parryEventFired = true
                    -- print("AutoParry: Fired RemoteEvent", obj.Name) -- Debug
                    break 
                end
            end
        end

        -- Method 2: Simulate Key Press (Commonly F or Right Mouse)
        if not parryEventFired then 
            if KeyPress then
                 --print("AutoParry: Simulating Key Press F") -- Debug
                KeyPress(Enum.KeyCode.F) 
                -- KeyPress(Enum.UserInputType.MouseButton2) -- Try Right Mouse Button (might interfere with aiming)
            else
                 warn("AutoParry: KeyPress function not available.")
            end
        end
    end)
end


local function checkAnimations()
    if not Config.autoParryEnabled or not Player.Character then return end

    for _, otherPlayer in ipairs(Services.Players:GetPlayers()) do
        if otherPlayer ~= Player and otherPlayer.Character then
            local distance = getDistanceFromCharacter(otherPlayer.Character)

            if distance <= Config.autoParryDetectionRange then
                local humanoid = otherPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                        if isAttackAnimation(track) then
                           
                           if track.TimePosition < 0.3 then 
                               attemptParry(otherPlayer)
                               
                           end
                        end
                    end
                end
            end
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
    KeyPress = sharedEnv.External.KeyPress 

    UI.createSection("Auto Parry")

    UI.createToggle("Enable Auto Parry", Config.autoParryEnabled, function(value)
        Config.autoParryEnabled = value
        if not value then activeParryDebounce = {} end 
    end)

    UI.createSlider("Detection Range", 5, 50, Config.autoParryDetectionRange, function(value)
        Config.autoParryDetectionRange = value
    end)

    UI.createSlider("Parry Distance", 3, 30, Config.autoParryDistance, function(value)
        Config.autoParryDistance = value
    end)

    UI.createSlider("Reaction Time (s)", 0, 0.5, Config.autoParryReactionTime, function(value)
        Config.autoParryReactionTime = value
    end)

    Config.connections.autoParryUpdate = RunService.Heartbeat:Connect(checkAnimations) 

    print("Auto Parry Module Initialized")
end

function module:destroy()
    if Config.connections.autoParryUpdate then Config.connections.autoParryUpdate:Disconnect() end
    activeParryDebounce = {}
    print("Auto Parry Module Destroyed")
end

return module