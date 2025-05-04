-- Drip X - ESP Module
-- NOTE: This really I don't think it's working, but idk

local module = {}
local Config, Services, UI, Player, Camera, RunService

local espObjects = {} 

local function cleanupESP()
    for player, objTable in pairs(espObjects) do
        if objTable and objTable[1] and objTable[1].Parent then
            objTable[1]:Destroy()
        end
    end
    espObjects = {}
end

local function updateESP()
    if not Config.espEnabled then
        if next(espObjects) then cleanupESP() end 
        return
    end

    local localPlayer = Player
    if not localPlayer then return end
    local camera = Camera
    if not camera then return end

    local currentPlayers = {}

    for _, player in ipairs(Services.Players:GetPlayers()) do
        currentPlayers[player] = true 

        if player == localPlayer then continue end
        if Config.espTeamCheck and player.Team == localPlayer.Team then
             if espObjects[player] then
                 if espObjects[player][1] and espObjects[player][1].Parent then espObjects[player][1]:Destroy() end
                 espObjects[player] = nil
             end
             continue
        end

        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local rootPart = humanoid and character:FindFirstChild("HumanoidRootPart")

        if character and humanoid and humanoid.Health > 0 and rootPart then
            local screenPos, onScreen = camera:WorldToViewportPoint(rootPart.Position)

            if onScreen then
                if not espObjects[player] then
                    local billboardGui = Instance.new("BillboardGui")
                    billboardGui.Name = "PlayerESP"
                    billboardGui.Size = UDim2.new(0, 100, 0, 50) 
                    billboardGui.StudsOffsetWorldSpace = Vector3.new(0, 2, 0)
                    billboardGui.AlwaysOnTop = true
                    billboardGui.LightInfluence = 0
                    billboardGui.Adornee = rootPart

                    local box = Instance.new("Frame") 
                    box.Name = "Box"
                    box.Size = UDim2.fromScale(1, 1)
                    box.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                    box.BackgroundTransparency = 0.8
                    box.BorderSizePixel = 1
                    box.BorderColor3 = Color3.fromRGB(255,255,255)
                    box.Visible = Config.espShowBoxes 
                    box.Parent = billboardGui

                     local nameLabel = Instance.new("TextLabel")
                     nameLabel.Name = "NameLabel"
                     nameLabel.Size = UDim2.new(1, 0, 0, 15)
                     nameLabel.Position = UDim2.new(0, 0, 0, -15) 
                     nameLabel.Text = player.Name
                     nameLabel.Font = Enum.Font.SourceSans
                     nameLabel.TextSize = 14
                     nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                     nameLabel.BackgroundTransparency = 1
                     nameLabel.TextStrokeTransparency = 0.5
                     nameLabel.Visible = Config.espShowNames
                     nameLabel.Parent = billboardGui

                    espObjects[player] = {billboardGui, box, nameLabel}
                    billboardGui.Parent = camera 
                end

                local guiElements = espObjects[player]
                if guiElements then
                    local billboard = guiElements[1]
                    local box = guiElements[2]
                    local name = guiElements[3]

                    if billboard and not billboard.Parent then billboard.Parent = camera end
                    if billboard and billboard.Adornee ~= rootPart then billboard.Adornee = rootPart end 

                    if box then box.Visible = Config.espShowBoxes end
                    if name then name.Visible = Config.espShowNames end
                end

            else
                if espObjects[player] then
                    if espObjects[player][1] and espObjects[player][1].Parent then espObjects[player][1].Parent = nil end 
                end
            end
        else

            if espObjects[player] then
                 if espObjects[player][1] and espObjects[player][1].Parent then espObjects[player][1]:Destroy() end
                 espObjects[player] = nil
            end
        end
    end

     for player, objTable in pairs(espObjects) do
         if not currentPlayers[player] then
             if objTable[1] and objTable[1].Parent then objTable[1]:Destroy() end
             espObjects[player] = nil
         end
     end
end


function module:init(sharedEnv)
    Config = sharedEnv.Config
    Services = sharedEnv.Services
    UI = sharedEnv.UI
    Player = sharedEnv.Player
    Camera = sharedEnv.Camera
    RunService = Services.RunService

    UI.createSection("Visuals (ESP)")

    UI.createToggle("Enable ESP", Config.espEnabled, function(value)
        Config.espEnabled = value
        if not value then cleanupESP() end 
    end)

    UI.createToggle("Show Boxes", Config.espShowBoxes, function(value)
        Config.espShowBoxes = value
        -- Update existing visuals if needed (updateESP handles visibility)
    end)

    UI.createToggle("Show Names", Config.espShowNames, function(value)
        Config.espShowNames = value
        -- Update existing visuals if needed (updateESP handles visibility)
    end)

    UI.createToggle("Team Check", Config.espTeamCheck, function(value)
        Config.espTeamCheck = value
        cleanupESP() 
    end)

    Config.connections.espUpdate = RunService.RenderStepped:Connect(updateESP)

    print("ESP Module Initialized (Prob no work)")
end

function module:destroy()
    if Config.connections.espUpdate then Config.connections.espUpdate:Disconnect() end
    cleanupESP()
    print("ESP Module Destroyed")
end

return module