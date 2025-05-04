-- Drip X - Anti-Recoil Module
-- NOTE: ts uses getgc and hookfunction which are common in exploits but
-- specific implementations can vary or be detected

local module = {}
local Config, Services, UI, Player, GetGC, HookFunction

local hookedScripts = {} 
local activeHooks = {} 

local function isHooked(script)
    return hookedScripts[script] or (activeHooks[script] and #activeHooks[script] > 0)
end

-- helper
local function applyRecoilHook(script, envTable, key, originalValue)
    if not HookFunction then return nil end

    local reductionFactor = (1 - Config.recoilReduction / 100)
    local hookRef = nil

    local success, result = pcall(function()
        hookRef = HookFunction(rawget, function(t, k)
            if t == envTable and k == key and Config.antiRecoilEnabled then 
                -- print("AntiRecoil: Modifying", key, "Original:", originalValue, "New:", originalValue * reductionFactor) -- Debug
                return originalValue * reductionFactor
            end
            return hookRef(t, k) 
        end)
    end)

    if success and hookRef then
        if not activeHooks[script] then activeHooks[script] = {} end
        table.insert(activeHooks[script], hookRef)
        return hookRef
    else
        warn("AntiRecoil: Failed to hook rawget for", key, "-", result)
        return nil
    end
end

-- helper
local function unhookScript(script)
    if activeHooks[script] then
        for _, hookRef in ipairs(activeHooks[script]) do
            pcall(unhookfunction, hookRef) 
        end
        activeHooks[script] = nil 
    end
    hookedScripts[script] = nil 
end

local function processGun(tool)
    if not tool or not tool:IsA("Tool") then return end
    if not Config.antiRecoilEnabled then return end

    for _, obj in ipairs(tool:GetDescendants()) do
        if obj:IsA("LocalScript") and not isHooked(obj) then
            print("AntiRecoil: Processing script", obj:GetFullName()) 
            hookedScripts[obj] = true 

            local success, err = pcall(function()

                if not GetGC then warn("AntiRecoil: getgc is not available."); return end

                local gc = GetGC(true)
                local recoilKeywords = {"recoil", "spread", "kick", "shake", "bloom", "accuracy"}

                for _, item in ipairs(gc) do
                     -- try to find tables likely related to the scripts environment
                     -- this is highly speculative and depends on exploit implementation
                     if type(item) == "table" then -- and maybe check if script is in items ancestry?
                         for keyword in pairs(recoilKeywords) do
                             local value = rawget(item, keyword)
                             if type(value) == "number" and value > 0 then 
                                 print("AntiRecoil: Found potential value", keyword, "=", value, "in table associated with", obj.Name) -- Debug
                                 applyRecoilHook(obj, item, keyword, value)
                                 -- maybe break after finding one set per script?
                             end
                         end
                     end
                end
            end)
            if not success then warn("AntiRecoil: Error processing script", obj:GetFullName(), "-", err) end
        end
    end
end

local function processAllGuns()
    if not Config.antiRecoilEnabled then return end

    
    for _, tool in ipairs(Player.Backpack:GetChildren()) do processGun(tool) end
    
    if Player.Character then
        for _, tool in ipairs(Player.Character:GetChildren()) do processGun(tool) end
    end
end

local function stopAntiRecoil()
     local scriptsToUnhook = {}
     for script, _ in pairs(hookedScripts) do table.insert(scriptsToUnhook, script) end
     for script, _ in pairs(activeHooks) do table.insert(scriptsToUnhook, script) end 

     for _, script in ipairs(scriptsToUnhook) do
          if script and typeof(script) == "Instance" then 
             unhookScript(script)
          else
            
              hookedScripts[script] = nil
              activeHooks[script] = nil
          end
     end
     print("AntiRecoil: All hooks removed.")
end

function module:init(sharedEnv)
    Config = sharedEnv.Config
    Services = sharedEnv.Services
    UI = sharedEnv.UI
    Player = sharedEnv.Player
    GetGC = sharedEnv.External.GetGC
    HookFunction = sharedEnv.External.HookFunction

    if not GetGC or not HookFunction then
        warn("Anti-Recoil module disabled: getgc or hookfunction not available in environment.")
    end

    UI.createSection("Anti-Recoil")

    UI.createToggle("Enable Anti-Recoil", Config.antiRecoilEnabled, function(value)
        Config.antiRecoilEnabled = value
        if value then
            processAllGuns()
        else
            stopAntiRecoil()
        end
    end)

    UI.createSlider("Recoil Reduction (%)", 0, 100, Config.recoilReduction, function(value)
        Config.recoilReduction = value
    end)

    Config.connections.antiRecoilBackpackAdded = Player.Backpack.ChildAdded:Connect(function(child)
        if Config.antiRecoilEnabled then processGun(child) end
    end)
    Config.connections.antiRecoilCharAdded = Player.CharacterAdded:Connect(function(character)
        if not Config.antiRecoilEnabled then return end
        task.wait(1)
        if character == Player.Character then
             for _, tool in ipairs(character:GetChildren()) do processGun(tool) end
             Config.connections.antiRecoilCharChildAdded = character.ChildAdded:Connect(function(child)
                 if Config.antiRecoilEnabled then processGun(child) end
             end)
        end
    end)
    if Player.Character then
         Config.connections.antiRecoilCharChildAdded = Player.Character.ChildAdded:Connect(function(child)
             if Config.antiRecoilEnabled then processGun(child) end
         end)
    end


    if Config.antiRecoilEnabled then processAllGuns() end

    print("Anti-Recoil Module Initialized")
end

function module:destroy()
    if Config.connections.antiRecoilBackpackAdded then Config.connections.antiRecoilBackpackAdded:Disconnect() end
    if Config.connections.antiRecoilCharAdded then Config.connections.antiRecoilCharAdded:Disconnect() end
    if Config.connections.antiRecoilCharChildAdded then Config.connections.antiRecoilCharChildAdded:Disconnect() end
    stopAntiRecoil()
    print("Anti-Recoil Module Destroyed")
end

return module