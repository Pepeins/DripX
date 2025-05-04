-- Drip X - Aimbot Module

local module = {}
local Config, Services, UI, Player, Camera, Workspace, RunService, UserInputService

-- // Module Specific State \\ --
local aimPart = nil
local aimbotRenderStepConn = nil
local aimbotToggleKeyConn = nil

-- // Helper Functions \\ --

local function isTargetValid(otherPlayer)
    if not otherPlayer or otherPlayer == Player then return false end
    if not otherPlayer.Character then return false end
    local humanoid = otherPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end
    if Config.aimbotTeamCheck then
        local Teams = game:GetService("Teams")
        if Player.Team and otherPlayer.Team and Player.Team == otherPlayer.Team then
            return false
        end
        if Player.TeamColor and otherPlayer.TeamColor and Player.TeamColor == otherPlayer.TeamColor then
             return false
        end
    end
    return true
end

local function getAimTargetPart(character)
    local targetPartInstance = character:FindFirstChild(Config.aimbotTarget)
    if not targetPartInstance or not targetPartInstance:IsA("BasePart") then
        targetPartInstance = character:FindFirstChild("HumanoidRootPart") 
        if not targetPartInstance or not targetPartInstance:IsA("BasePart") then
             targetPartInstance = character:FindFirstChild("Torso")
             if not targetPartInstance or not targetPartInstance:IsA("BasePart") then
                targetPartInstance = character.PrimaryPart
             end
        end
    end
    return targetPartInstance
end


local function getClosestEnemy()
    local closestEnemy = nil
    local closestPart = nil
    local shortestDistance = Config.aimbotRange

    for _, otherPlayer in ipairs(Services.Players:GetPlayers()) do
        if isTargetValid(otherPlayer) then
            local character = otherPlayer.Character
            local targetPartInstance = getAimTargetPart(character)

            if targetPartInstance then
                local targetPos = targetPartInstance.Position
                local distance = (Camera.CFrame.Position - targetPos).Magnitude

                if distance < shortestDistance and distance <= Config.aimbotRange then
                    local rayOrigin = Camera.CFrame.Position
                    local rayDirection = (targetPos - rayOrigin).Unit * distance
                    local ray = Ray.new(rayOrigin, rayDirection)

                    local ignoreList = {Player.Character, Camera}
                    if aimPart then table.insert(ignoreList, aimPart) end

                    local hit, hitPos = Workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)

                    if not hit or hit:IsDescendantOf(character) then
                        local screenPoint, onScreen = Camera:WorldToViewportPoint(targetPos)
                        local VpSize = Camera.ViewportSize
                        if onScreen or (screenPoint.X > -100 and screenPoint.X < VpSize.X + 100 and screenPoint.Y > -100 and screenPoint.Y < VpSize.Y + 100) then
                             closestEnemy = character
                             closestPart = targetPartInstance
                             shortestDistance = distance
                        end
                    end
                end
            end
        end
    end

    return closestEnemy, closestPart
end

-- movement predict
local function predictMovement(targetPart)
    if not targetPart or not targetPart:IsA("BasePart") then return Vector3.new() end
    local velocity = targetPart.AssemblyLinearVelocity
    local distance = (Camera.CFrame.Position - targetPart.Position).Magnitude
    local predictionTime = distance / 1500 
    predictionTime = math.clamp(predictionTime, 0.05, 0.2) 

    local futurePosition = targetPart.Position + (velocity * predictionTime)
    return futurePosition
end

local function runAimbot()
    if not Config.aimbotEnabled or not Camera then
        if aimPart then aimPart.Transparency = 1 end 
        return
    end

    local enemyChar, targetPart = getClosestEnemy()

    if enemyChar and targetPart then
        local targetPos = targetPart.Position
        
        if targetPart.AssemblyLinearVelocity.Magnitude > 1 then
             targetPos = predictMovement(targetPart)
        end
        
        if aimPart then
             aimPart.Position = targetPos 
             aimPart.Transparency = Config.aimbotVisibility and 0.5 or 1
        end

        
        local newLookVector = (targetPos - Camera.CFrame.Position).Unit
        local newCFrame = CFrame.lookAt(Camera.CFrame.Position, Camera.CFrame.Position + newLookVector)

        
        local effectiveSpeed = Config.aimbotSpeed * (Config.aimbotSensitivity * 1.5)
        effectiveSpeed = math.clamp(effectiveSpeed, 0.01, 1) 

        Camera.CFrame = Camera.CFrame:Lerp(newCFrame, effectiveSpeed)

        -- Auto Shoot (Example posiblmente no ande)
        if Config.aimbotAutoShoot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            local tool = Player.Character and Player.Character:FindFirstChildOfClass("Tool")
            if tool then
                
                local fireEvent = tool:FindFirstChild("Fire") or tool:FindFirstChild("Shoot") or tool:FindFirstChild("RemoteEvent") 
                 if fireEvent and fireEvent:IsA("RemoteEvent") then
                      -- The arguments needed for FireServer vary WILDLY between games.
                      -- Common patterns include: (targetPos), (lookVector), (targetInstance), ()
                      -- This is a guess:
                      pcall(fireEvent.FireServer, fireEvent, targetPos)
                 end
            end
        end
    else
        
        if aimPart then aimPart.Transparency = 1 end
    end
end


-- // Initialization \\ --
function module:init(sharedEnv)
    Config = sharedEnv.Config
    Services = sharedEnv.Services
    UI = sharedEnv.UI
    Player = sharedEnv.Player
    Camera = sharedEnv.Camera
    Workspace = Services.Workspace
    RunService = Services.RunService
    UserInputService = Services.UserInputService

    print("Initializing Aimbot Module...")

    aimPart = Workspace.CurrentCamera:FindFirstChild("DripX_AimbotTargetVisual")
    if not aimPart then
        aimPart = Instance.new("Part")
        aimPart.Name = "DripX_AimbotTargetVisual"
        aimPart.Size = Vector3.new(0.6, 0.6, 0.6)
        aimPart.Anchored = true
        aimPart.CanCollide = false
        aimPart.Material = Enum.Material.Neon
        aimPart.Color = Color3.fromRGB(255, 0, 0)
        aimPart.Transparency = 1 
        aimPart.Shape = Enum.PartType.Ball
        
        aimPart.Parent = Workspace.CurrentCamera
    end


    UI.createSection("Aimbot")

    UI.createToggle("Enable Aimbot", Config.aimbotEnabled, function(value)
        Config.aimbotEnabled = value
        if not value and aimPart then aimPart.Transparency = 1 end 
    end)

    UI.createToggle("Team Check", Config.aimbotTeamCheck, function(value)
        Config.aimbotTeamCheck = value
    end)

    UI.createToggle("Auto Shoot", Config.aimbotAutoShoot, function(value)
        Config.aimbotAutoShoot = value
    end)

    UI.createToggle("Show Target Visual", Config.aimbotVisibility, function(value)
        Config.aimbotVisibility = value
        if aimPart and not Config.aimbotEnabled then aimPart.Transparency = 1 end 
    end)

    UI.createDropdown("Target Part", {"Head", "HumanoidRootPart", "Torso"}, Config.aimbotTarget, function(option)
        Config.aimbotTarget = option
    end)

    UI.createSlider("Aim Smoothness", 0.01, 1, Config.aimbotSpeed, function(value)
        Config.aimbotSpeed = value 
    end)

    UI.createSlider("Aim Sensitivity", 0.1, 2, Config.aimbotSensitivity, function(value)
        Config.aimbotSensitivity = value
    end)

     UI.createSlider("Range (Studs)", 50, 2000, Config.aimbotRange, function(value)
        Config.aimbotRange = value
    end)

    aimbotRenderStepConn = RunService.RenderStepped:Connect(runAimbot)
    Config.connections.aimbotRenderStep = aimbotRenderStepConn -- Store connection

    aimbotToggleKeyConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Config.aimbotToggleKey then
             Config.aimbotEnabled = not Config.aimbotEnabled
             UI.showNotification("Aimbot: " .. (Config.aimbotEnabled and "Enabled" or "Disabled"), 1.5)
             if not Config.aimbotEnabled and aimPart then aimPart.Transparency = 1 end 
        end
    end)
    Config.connections.aimbotToggleKey = aimbotToggleKeyConn 
end

-- // Cleanup Function \\ --
function module:destroy()
    if Config.connections.aimbotRenderStep then
        Config.connections.aimbotRenderStep:Disconnect()
        Config.connections.aimbotRenderStep = nil
    end
     if Config.connections.aimbotToggleKey then
        Config.connections.aimbotToggleKey:Disconnect()
        Config.connections.aimbotToggleKey = nil
    end
    if aimPart then
        aimPart:Destroy()
        aimPart = nil
    end
    print("Aimbot Module Destroyed")
end


return module