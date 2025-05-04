-- Drip X - SilentAim Module

local module = {}
local Config, Services, UI, Player, Camera, UserInputService, Workspace, RunService, Drawing

local silentAimCircle = nil

local function isPlayerEnemy(otherPlayer)
    if not otherPlayer or otherPlayer == Player then return false end
    if Config.teamCheck and otherPlayer.Team and Player.Team and otherPlayer.Team == Player.Team then
        return false -
    end
    return true
end

-- Helper: Update FOV Circle
local function updateSilentAimFOV()
    if not Drawing or not silentAimCircle then return end

    silentAimCircle.Visible = Config.silentAimEnabled and Config.silentAimShowFOV
    if silentAimCircle.Visible then
        silentAimCircle.Radius = Config.silentAimFOV

        local viewportSize = Camera.ViewportSize
        silentAimCircle.Position = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
    end
end

-- Helper: Get target for silent aim
local function getSilentAimTarget()
    if not Config.silentAimEnabled then return nil end

    if math.random(1, 100) > Config.silentAimHitChance then return nil end

    local mousePos = UserInputService:GetMouseLocation()
    local closestTargetPart = nil
    local smallestDistToMouse = Config.silentAimFOV

    for _, otherPlayer in ipairs(Services.Players:GetPlayers()) do
        if isPlayerEnemy(otherPlayer) and otherPlayer.Character then
            local character = otherPlayer.Character
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid or humanoid.Health <= 0 then continue end

            local targetPartName = Config.silentAimTargetPart
            if targetPartName == "Random" then
                local parts = {"Head", "HumanoidRootPart", "Torso"}
                targetPartName = parts[math.random(1, #parts)]
            end
            local targetPart = character:FindFirstChild(targetPartName)
            if not targetPart or not targetPart:IsA("BasePart") then
                 targetPart = character:FindFirstChild("HumanoidRootPart")
                 if not targetPart or not targetPart:IsA("BasePart") then continue end
            end

            local targetPos = targetPart.Position
            local screenPos, onScreen = Camera:WorldToViewportPoint(targetPos)

            if onScreen then
                local distToMouse = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude

                if distToMouse <= Config.silentAimFOV and distToMouse < smallestDistToMouse then
                    if Config.silentAimWallCheck then
                        local ray = Ray.new(Camera.CFrame.Position, (targetPos - Camera.CFrame.Position).Unit * 1000)
                        local ignoreList = {Player.Character}
                        local hit, _ = Workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)
                        if hit and not hit:IsDescendantOf(character) then
                            continue 
                        end
                    end

                    smallestDistToMouse = distToMouse
                    closestTargetPart = targetPart
                end
            end
        end
    end
    return closestTargetPart
end


local originalNamecall = nil
local function hookNamecall()
    if not SharedEnvironment.External.HookMetamethod or not SharedEnvironment.External.GetNamecallMethod then
        warn("Silent Aim: Cannot hook __namecall (hookmetamethod or getnamecallmethod missing).")
        return
    end
    if originalNamecall then return end 

     originalNamecall = SharedEnvironment.External.HookMetamethod(game, "__namecall", function(self, ...)
         local method = SharedEnvironment.External.GetNamecallMethod()
         local args = {...}

         local silentTarget = getSilentAimTarget() 

         if Config.silentAimEnabled and silentTarget and typeof(self) == "Instance" and self:IsA("RemoteEvent") then
             -- Identify the FireServer call for shooting (heuristic)
             -- This is VERY game-specific and likely needs adjustment
             if method == "FireServer" and (self.Name:lower():match("shoot") or self.Name:lower():match("fire") or self.Name:lower():match("remote")) then
                 -- Try to find a Vector3 argument and replace it with target position
                 local replaced = false
                 for i, arg in ipairs(args) do
                     if typeof(arg) == "Vector3" then
                         args[i] = silentTarget.Position 
                         replaced = true
                         -- print("Silent Aim: Redirecting shot to", silentTarget.Parent.Name) 
                         break 
                     end
                 end
                 -- If no Vector3 found, maybe append or prepend based on game? Risky.
                 -- if not replaced then table.insert(args, 1, silentTarget.Position) end
             end
         end

         return originalNamecall(self, unpack(args))
     end)
     Config.hookedMetamethods.silentAimNamecall = originalNamecall 
     print("Silent Aim: __namecall hook applied.")
end

local function unhookNamecall()
    if not originalNamecall or not Config.hookedMetamethods.silentAimNamecall then return end
    if SharedEnvironment.External.HookMetamethod then 
        SharedEnvironment.External.HookMetamethod(game, "__namecall", Config.hookedMetamethods.silentAimNamecall) -- Restore original
        originalNamecall = nil
        Config.hookedMetamethods.silentAimNamecall = nil
        print("Silent Aim: __namecall hook removed.")
    end
end


function module:init(sharedEnv)
    Config = sharedEnv.Config
    Services = sharedEnv.Services
    UI = sharedEnv.UI
    Player = sharedEnv.Player
    Camera = sharedEnv.Camera
    UserInputService = Services.UserInputService
    Workspace = Services.Workspace
    RunService = Services.RunService
    Drawing = sharedEnv.External.Drawing 

    if not Drawing then
        warn("Silent Aim: Drawing library not available, FOV circle disabled.")
    else
        silentAimCircle = Drawing.new("Circle")
        silentAimCircle.Visible = false
        silentAimCircle.Radius = Config.silentAimFOV
        silentAimCircle.Color = Color3.fromRGB(255, 255, 255)
        silentAimCircle.Thickness = 1
        silentAimCircle.Transparency = 0.7
        silentAimCircle.NumSides = 64
        silentAimCircle.Filled = false
    end

    UI.createSection("Silent Aim")

    UI.createToggle("Enable Silent Aim", Config.silentAimEnabled, function(value)
        Config.silentAimEnabled = value
        if value then hookNamecall() else unhookNamecall() end
        updateSilentAimFOV()
    end)

    UI.createSlider("FOV Radius", 30, 500, Config.silentAimFOV, function(value)
        Config.silentAimFOV = value
        updateSilentAimFOV()
    end)

    UI.createSlider("Hit Chance (%)", 30, 100, Config.silentAimHitChance, function(value)
        Config.silentAimHitChance = value
    end)

    UI.createToggle("Show FOV Circle", Config.silentAimShowFOV, function(value)
        Config.silentAimShowFOV = value
        updateSilentAimFOV()
    end)

    UI.createDropdown("Target Part", {"Head", "HumanoidRootPart", "Torso", "Random"}, Config.silentAimTargetPart, function(option)
        Config.silentAimTargetPart = option
    end)

    UI.createToggle("Wall Check", Config.silentAimWallCheck, function(value)
        Config.silentAimWallCheck = value
    end)

    Config.connections.silentAimFovUpdate = RunService.RenderStepped:Connect(updateSilentAimFOV)

    updateSilentAimFOV()
    if Config.silentAimEnabled then hookNamecall() end

    print("Silent Aim Module Initialized")
end

function module:destroy()
    if Config.connections.silentAimFovUpdate then Config.connections.silentAimFovUpdate:Disconnect() end
    if silentAimCircle then silentAimCircle:Remove() end
    unhookNamecall()
    print("Silent Aim Module Destroyed")
end

return module