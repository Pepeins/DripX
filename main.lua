-- Drip X
-- Made by wesk with <3

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local TeleportService = game:GetService("TeleportService") 
local VirtualInputManager 

local successVIM, vim = pcall(game.GetService, game, "VirtualInputManager")
if successVIM then
    VirtualInputManager = vim
    print("Drip X: VirtualInputManager loaded.")
else
    warn("Drip X: VirtualInputManager service not found. Auto Parry key simulation might not work.")
end

-- // Local Player & Camera \\ --
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- // Shared Environment \\ --
local SharedEnvironment = {
    Services = {
        Players = Players,
        Workspace = Workspace,
        UserInputService = UserInputService,
        RunService = RunService,
        Lighting = Lighting,
        TweenService = TweenService,
        Debris = Debris,
        TeleportService = TeleportService,
        VirtualInputManager = VirtualInputManager,       
    },
    Player = LocalPlayer,
    Camera = Camera,
    Config = {}, 
    Modules = {}, 
    UI = nil, 
    External = { 
        Drawing = Drawing, 
        HookFunction = hookfunction, 
        HookMetamethod = hookmetamethod, 
        GetGC = getgc, 
        GetNamecallMethod = getnamecallmethod, 
        SetClipboard = setclipboard, 
        KeyPress = function(keyCode) 
            if VirtualInputManager then
                pcall(function()
                    VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
                    task.wait(0.05)
                    VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
                end)
            else
                warn("Drip X: KeyPress unavailable (VirtualInputManager missing).")
            end
        end
    }
}

-- // Default Configuration \\ --
SharedEnvironment.Config = {
    guiToggleKey = Enum.KeyCode.RightShift,
    toggleGUI = true, 

    teamCheck = false, 

    speedMultiplier = 2,
    sizeMultiplier = 1.5,
    speedEnabled = false,
    sizeEnabled = false,

    gravityEnabled = false,
    gravityValue = 50,
    teleportToSpawnEnabled = false, 

    randomColorEnabled = false, 

    espEnabled = false,
    espShowBoxes = true,
    espShowNames = true,
    espTeamCheck = false,

    aimbotEnabled = false,
    aimbotSpeed = 0.2,
    aimbotTarget = "Head",
    aimbotVisibility = true,
    aimbotRange = 500,
    aimbotToggleKey = Enum.KeyCode.X, 
    aimbotAutoShoot = false,
    aimbotTeamCheck = false,
    aimbotSensitivity = 0.5,

    silentAimEnabled = false,
    silentAimFOV = 100,
    silentAimHitChance = 85,
    silentAimShowFOV = true,
    silentAimTargetPart = "Head",
    silentAimWallCheck = true,

    hitboxExpanderEnabled = false,
    hitboxSize = 2,
    hitboxTransparency = 0.5,
    hitboxPart = "Head",

    autoParryEnabled = false,
    autoParryDistance = 15,
    autoParryReactionTime = 0.15,
    autoParryDetectionRange = 30,

    fullBright = false,
    noFog = false,
    customTime = false,
    timeValue = 12,
    removeVisualObstructions = false,
    -- contrast = false

    antiRecoilEnabled = false,
    recoilReduction = 90,

    -- Runtime state storage
    connections = {},
    originalValues = {}, 
    hookedFunctions = {}, 
    hookedMetamethods = {} 
}

local uiModuleScript = script.Parent:FindFirstChild("ui"):FindFirstChild("gui")
if not uiModuleScript then
    error("Drip X Error: ui/gui.lua not found!")
end

local successUI, uiModule = pcall(require, uiModuleScript)
if not successUI or typeof(uiModule) ~= "table" or not uiModule.init then
    error("Drip X Error: Failed to load or initialize ui/gui.lua - " .. tostring(uiModule))
end

SharedEnvironment.UI = uiModule:init(SharedEnvironment) 
print("Drip X: UI Initialized")

-- // Load Feature Modules \\ --
local modulesFolder = script.Parent:FindFirstChild("modules")
if not modulesFolder then
    error("Drip X Error: modules folder not found!")
end

local moduleOrder = {
    "movement",
    "physics",
    "appearance", 
    "esp",
    "aimbot",
    "silent_aim",
    "hitbox_expander",
    "auto_parry",
    "visual_improvements",
    "anti_recoil"
    --"fly"
    --"disabler"
}

for _, moduleName in ipairs(moduleOrder) do
    local moduleScript = modulesFolder:FindFirstChild(moduleName .. ".lua")
    if moduleScript then
        local successLoad, featureModule = pcall(require, moduleScript)
        if successLoad and typeof(featureModule) == "table" and featureModule.init then
            local initSuccess, err = pcall(function()
                featureModule:init(SharedEnvironment) 
                SharedEnvironment.Modules[moduleName] = featureModule 
                print("Drip X: Loaded Module -", moduleName)
            end)
            if not initSuccess then
                 warn("Drip X Error: Failed to initialize module", moduleName, "-", err)
            end
        else
            warn("Drip X Error: Failed to load or require module", moduleName, "-", tostring(featureModule))
        end
    else
        warn("Drip X Warning: Module script not found -", moduleName .. ".lua")
    end
end


-- // Finalize UI Setup (Settings Section) \\ --
local currentY = SharedEnvironment.UI.getCurrentY() 
SharedEnvironment.UI.createSection("Settings") 

currentY = SharedEnvironment.UI.createStyledButton("Reset Config", Color3.fromRGB(200, 50, 50), function()
    SharedEnvironment.UI.showNotification("Config Reset Requested (Manual UI update needed)", 3)
    warn("Drip X: Config reset needs full implementation to visually update UI elements.")
end)

-- Button to Save Config (Copy to Clipboard)
currentY = SharedEnvironment.UI.createStyledButton("Copy Config", Color3.fromRGB(0, 170, 255), function()
    if not SharedEnvironment.External.SetClipboard then
         SharedEnvironment.UI.showNotification("Error: SetClipboard not available.", 3)
         return
    end

    local configString = "-- Drip X Config Snapshot --\nlocal cfg = {\n"
    for key, value in pairs(SharedEnvironment.Config) do
        local vType = typeof(value)
        if key ~= "connections" and key ~= "originalValues" and key ~= "hookedFunctions" and key ~= "hookedMetamethods" and
           vType ~= "function" and vType ~= "table" and vType ~= "userdata" and vType ~= "thread" then

            if vType == "string" then
                configString = configString .. string.format("    %s = %q;\n", key, value)
            elseif vType == "EnumItem" then
                 configString = configString .. string.format("    %s = Enum.%s.%s;\n", key, value.EnumType.Name, value.Name)
            elseif vType == "boolean" or vType == "number" then
                configString = configString .. string.format("    %s = %s;\n", key, tostring(value))
            end
        end
    end
    configString = configString .. "}\n-- Apply this config in main.lua or via a 'Load Config' feature"

    local successCopy, errCopy = pcall(SharedEnvironment.External.SetClipboard, configString)
    if successCopy then
        SharedEnvironment.UI.showNotification("Config Copied to Clipboard!", 2)
    else
        warn("Drip X: Failed to copy config -", errCopy)
        SharedEnvironment.UI.showNotification("Error copying config.", 2)
    end
end)


SharedEnvironment.UI.updateCanvasSize(currentY + 20) 

-- // Global Keybinds \\ --
local function toggleGUI(input, gameProcessed)
    if gameProcessed or not SharedEnvironment.Config.toggleGUI then return end
    if input.KeyCode == SharedEnvironment.Config.guiToggleKey then
        local gui = SharedEnvironment.UI.getScreenGui() 
        if gui then
             gui.Enabled = not gui.Enabled
        end
    end
end

SharedEnvironment.Config.connections.guiToggle = UserInputService.InputBegan:Connect(toggleGUI)

print("--- Drip X Initialized ---")

function SharedEnvironment:Destroy()
    print("--- Drip X Shutting Down ---")
    if SharedEnvironment.Config.connections.guiToggle then
        SharedEnvironment.Config.connections.guiToggle:Disconnect()
    end

    for name, module in pairs(SharedEnvironment.Modules) do
        if module.destroy then
            pcall(module.destroy, module)
            print("Destroyed module:", name)
        end
    end

    local gui = SharedEnvironment.UI.getScreenGui()
    if gui then
        gui:Destroy()
    end
   
    print("--- Drip X Cleanup Complete ---")
end

