local player = game.Players.LocalPlayer
local camera = game.Workspace.CurrentCamera
local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Drip X"
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 350, 0, 500)
mainFrame.Position = UDim2.new(0, 10, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local shadowFrame = Instance.new("Frame")
shadowFrame.Name = "Shadow"
shadowFrame.Size = UDim2.new(1, 6, 1, 6)
shadowFrame.Position = UDim2.new(0, -3, 0, -3)
shadowFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
shadowFrame.BackgroundTransparency = 0.7
shadowFrame.BorderSizePixel = 0
shadowFrame.ZIndex = 0
shadowFrame.Parent = mainFrame

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 32)
titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 1, 0)
title.Text = "Drip"
title.Font = Enum.Font.GothamSemibold
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 16
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left
title.Position = UDim2.new(0, 10, 0, 0)
title.Parent = titleBar

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 24, 0, 24)
closeButton.Position = UDim2.new(1, -30, 0, 4)
closeButton.Text = "×"
closeButton.Font = Enum.Font.GothamBold
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 20
closeButton.BackgroundTransparency = 1
closeButton.BorderSizePixel = 0
closeButton.Parent = titleBar

closeButton.MouseButton1Click:Connect(function()
    screenGui.Enabled = false
end)

local contentFrame = Instance.new("ScrollingFrame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, 0, 1, -32)
contentFrame.Position = UDim2.new(0, 0, 0, 32)
contentFrame.BackgroundTransparency = 1
contentFrame.ScrollBarThickness = 2
contentFrame.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 70)
contentFrame.CanvasSize = UDim2.new(0, 0, 0, 1000)
contentFrame.Parent = mainFrame

-- Función para crear secciones minimalistas
local function createSection(title, positionY)
    local section = Instance.new("Frame")
    section.Name = title .. "Section"
    section.Size = UDim2.new(0.9, 0, 0, 25)
    section.Position = UDim2.new(0.05, 0, 0, positionY)
    section.BackgroundTransparency = 1
    section.Parent = contentFrame
    
    local sectionTitle = Instance.new("TextLabel")
    sectionTitle.Size = UDim2.new(1, 0, 1, 0)
    sectionTitle.Text = title
    sectionTitle.Font = Enum.Font.GothamSemibold
    sectionTitle.TextColor3 = Color3.fromRGB(180, 180, 180)
    sectionTitle.TextSize = 14
    sectionTitle.BackgroundTransparency = 1
    sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
    sectionTitle.Parent = section
    
    return positionY + 30
end

-- Función para crear botones minimalistas
local function createStyledButton(text, positionY, color, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.9, 0, 0, 36)
    button.Position = UDim2.new(0.05, 0, 0, positionY)
    button.Text = text
    button.Font = Enum.Font.GothamMedium
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14
    button.BackgroundColor3 = color
    button.BorderSizePixel = 0
    button.Parent = contentFrame
    
    -- Agregar esquinas redondeadas sutiles
    local cornerRadius = Instance.new("UICorner")
    cornerRadius.CornerRadius = UDim.new(0, 4)
    cornerRadius.Parent = button
    
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(
            math.min(color.R * 255 + 15, 255)/255,
            math.min(color.G * 255 + 15, 255)/255,
            math.min(color.B * 255 + 15, 255)/255
        )
    end)
    
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = color
    end)
    
    button.MouseButton1Click:Connect(callback)
    
    return positionY + 44
end

-- Función para crear sliders minimalistas
local function createSlider(name, positionY, minValue, maxValue, defaultValue, callback)
    local sliderLabel = Instance.new("TextLabel")
    sliderLabel.Size = UDim2.new(0.9, 0, 0, 20)
    sliderLabel.Position = UDim2.new(0.05, 0, 0, positionY)
    sliderLabel.Text = name .. ": " .. defaultValue
    sliderLabel.Font = Enum.Font.GothamMedium
    sliderLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
    sliderLabel.TextSize = 14
    sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    sliderLabel.BackgroundTransparency = 1
    sliderLabel.Parent = contentFrame
    
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(0.9, 0, 0, 4)
    sliderFrame.Position = UDim2.new(0.05, 0, 0, positionY + 25)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    sliderFrame.BorderSizePixel = 0
    sliderFrame.Parent = contentFrame
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 2)
    sliderCorner.Parent = sliderFrame
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((defaultValue - minValue) / (maxValue - minValue), 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(90, 160, 230)
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderFrame
    
    local sliderFillCorner = Instance.new("UICorner")
    sliderFillCorner.CornerRadius = UDim.new(0, 2)
    sliderFillCorner.Parent = sliderFill
    
    local sliderButton = Instance.new("TextButton")
    sliderButton.Size = UDim2.new(0, 12, 0, 12)
    sliderButton.Position = UDim2.new((defaultValue - minValue) / (maxValue - minValue), -6, 0, -4)
    sliderButton.Text = ""
    sliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderButton.BorderSizePixel = 0
    sliderButton.Parent = sliderFrame
    
    local sliderButtonCorner = Instance.new("UICorner")
    sliderButtonCorner.CornerRadius = UDim.new(1, 0)
    sliderButtonCorner.Parent = sliderButton
    
    local value = defaultValue
    
    local function updateSlider(mouseX)
        local absoluteX = mouseX - sliderFrame.AbsolutePosition.X
        local relativeX = math.clamp(absoluteX / sliderFrame.AbsoluteSize.X, 0, 1)
        value = minValue + (maxValue - minValue) * relativeX
        value = math.floor(value * 10) / 10 
        
        sliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
        sliderButton.Position = UDim2.new(relativeX, -6, 0, -4)
        sliderLabel.Text = name .. ": " .. value
        
        callback(value)
    end
    
    sliderButton.MouseButton1Down:Connect(function()
        local dragging = true
        
        local dragConnection = runService.RenderStepped:Connect(function()
            if dragging then
                updateSlider(userInputService:GetMouseLocation().X)
            end
        end)
        
        userInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
                dragConnection:Disconnect()
            end
        end)
    end)
    
    sliderFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            updateSlider(input.Position.X)
        end
    end)
    
    callback(defaultValue)
    
    return positionY + 40
end

-- Función para crear un toggle minimalista
local function createToggle(name, positionY, defaultValue, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(0.9, 0, 0, 30)
    toggleFrame.Position = UDim2.new(0.05, 0, 0, positionY)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Parent = contentFrame
    
    local toggleLabel = Instance.new("TextLabel")
    toggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    toggleLabel.Position = UDim2.new(0, 0, 0, 0)
    toggleLabel.Text = name
    toggleLabel.Font = Enum.Font.GothamMedium
    toggleLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
    toggleLabel.TextSize = 14
    toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    toggleLabel.BackgroundTransparency = 1
    toggleLabel.Parent = toggleFrame
    
    local toggleButton = Instance.new("Frame")
    toggleButton.Size = UDim2.new(0, 34, 0, 16)
    toggleButton.Position = UDim2.new(1, -40, 0.5, -8)
    toggleButton.BackgroundColor3 = defaultValue and Color3.fromRGB(90, 160, 230) or Color3.fromRGB(70, 70, 75)
    toggleButton.BorderSizePixel = 0
    toggleButton.Parent = toggleFrame
    
    local toggleButtonCorner = Instance.new("UICorner")
    toggleButtonCorner.CornerRadius = UDim.new(1, 0)
    toggleButtonCorner.Parent = toggleButton
    
    local toggleCircle = Instance.new("Frame")
    toggleCircle.Size = UDim2.new(0, 12, 0, 12)
    toggleCircle.Position = UDim2.new(defaultValue and 0.6 or 0.1, 0, 0.5, -6)
    toggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleCircle.BorderSizePixel = 0
    toggleCircle.Parent = toggleButton
    
    local toggleCircleCorner = Instance.new("UICorner")
    toggleCircleCorner.CornerRadius = UDim.new(1, 0)
    toggleCircleCorner.Parent = toggleCircle
    
    local value = defaultValue
    
    toggleFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            value = not value
            
            toggleButton.BackgroundColor3 = value and Color3.fromRGB(90, 160, 230) or Color3.fromRGB(70, 70, 75)
            toggleCircle:TweenPosition(
                value and UDim2.new(0.6, 0, 0.5, -6) or UDim2.new(0.1, 0, 0.5, -6),
                Enum.EasingDirection.Out,
                Enum.EasingStyle.Quart,
                0.15,
                true
            )
            
            callback(value)
        end
    end)
    
    callback(defaultValue)
    
    return positionY + 38
end

-- Función para crear selector de opciones minimalista
local function createDropdown(name, positionY, options, defaultOption, callback)
    local dropdownLabel = Instance.new("TextLabel")
    dropdownLabel.Size = UDim2.new(0.9, 0, 0, 20)
    dropdownLabel.Position = UDim2.new(0.05, 0, 0, positionY)
    dropdownLabel.Text = name
    dropdownLabel.Font = Enum.Font.GothamMedium
    dropdownLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
    dropdownLabel.TextSize = 14
    dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
    dropdownLabel.BackgroundTransparency = 1
    dropdownLabel.Parent = contentFrame
    
    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Size = UDim2.new(0.9, 0, 0, 30)
    dropdownFrame.Position = UDim2.new(0.05, 0, 0, positionY + 25)
    dropdownFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    dropdownFrame.BorderSizePixel = 0
    dropdownFrame.Parent = contentFrame
    
    local dropdownCorner = Instance.new("UICorner")
    dropdownCorner.CornerRadius = UDim.new(0, 4)
    dropdownCorner.Parent = dropdownFrame
    
    local selectedOption = Instance.new("TextLabel")
    selectedOption.Size = UDim2.new(1, -40, 1, 0)
    selectedOption.Position = UDim2.new(0, 10, 0, 0)
    selectedOption.Text = defaultOption
    selectedOption.Font = Enum.Font.GothamMedium
    selectedOption.TextColor3 = Color3.fromRGB(230, 230, 230)
    selectedOption.TextSize = 14
    selectedOption.TextXAlignment = Enum.TextXAlignment.Left
    selectedOption.BackgroundTransparency = 1
    selectedOption.Parent = dropdownFrame
    
    local dropdownArrow = Instance.new("TextLabel")
    dropdownArrow.Size = UDim2.new(0, 20, 0, 20)
    dropdownArrow.Position = UDim2.new(1, -25, 0.5, -10)
    dropdownArrow.Text = "▾"
    dropdownArrow.Font = Enum.Font.GothamMedium
    dropdownArrow.TextColor3 = Color3.fromRGB(230, 230, 230)
    dropdownArrow.TextSize = 14
    dropdownArrow.BackgroundTransparency = 1
    dropdownArrow.Parent = dropdownFrame
    
    local optionsFrame = Instance.new("Frame")
    optionsFrame.Size = UDim2.new(0.9, 0, 0, #options * 28)
    optionsFrame.Position = UDim2.new(0.05, 0, 0, positionY + 60)
    optionsFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    optionsFrame.BorderSizePixel = 0
    optionsFrame.Visible = false
    optionsFrame.ZIndex = 5
    optionsFrame.Parent = contentFrame
    
    local optionsCorner = Instance.new("UICorner")
    optionsCorner.CornerRadius = UDim.new(0, 4)
    optionsCorner.Parent = optionsFrame
    
    for i, option in ipairs(options) do
        local optionButton = Instance.new("TextButton")
        optionButton.Size = UDim2.new(1, 0, 0, 28)
        optionButton.Position = UDim2.new(0, 0, 0, (i-1) * 28)
        optionButton.Text = option
        optionButton.Font = Enum.Font.GothamMedium
        optionButton.TextColor3 = Color3.fromRGB(230, 230, 230)
        optionButton.TextSize = 14
        optionButton.BackgroundTransparency = 1
        optionButton.ZIndex = 6
        optionButton.Parent = optionsFrame
        
        optionButton.MouseEnter:Connect(function()
            optionButton.BackgroundTransparency = 0.9
        end)
        
        optionButton.MouseLeave:Connect(function()
            optionButton.BackgroundTransparency = 1
        end)
        
        optionButton.MouseButton1Click:Connect(function()
            selectedOption.Text = option
            optionsFrame.Visible = false
            callback(option)
        end)
    end
    
    dropdownFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            optionsFrame.Visible = not optionsFrame.Visible
        end
    end)
    
    callback(defaultOption)
    
    return positionY + 65
end

-- Variables de configuración
local config = {
    speedMultiplier = 2,
    sizeMultiplier = 1.5,
    speedEnabled = false,
    sizeEnabled = false,
    gravityEnabled = false,
    gravityValue = 50,
    
    -- Configuración de aimbot
    aimbotEnabled = false,          -- Activar/Desactivar aimbot
    aimbotSpeed = 0.2,              -- Velocidad de apuntado (suavizado)
    aimbotTarget = "Head",          -- Parte del cuerpo objetivo ("Head", "Torso", "HumanoidRootPart", etc.)
    aimbotVisibility = true,        -- Visibilidad del indicador visual del aimbot
    aimbotRange = 500,              -- Rango de detección del aimbot (en studs)
    aimbotToggleKey = Enum.KeyCode.X, -- Tecla para activar/desactivar el aimbot
    aimbotAutoShoot = false,        -- Disparo automático
    aimbotTeamCheck = false,        -- Verificar si el objetivo está en el mismo equipo
    aimbotSensitivity = 0.5,        -- Sensibilidad ajustable del aimbot
}

-- Crear secciones
local posY = 10
posY = createSection("Movimiento", posY)

-- Slider de velocidad
posY = createSlider("Multiplicador de Velocidad", posY, 1, 10, config.speedMultiplier, function(value)
    config.speedMultiplier = value
end)

-- Toggle para activar velocidad
posY = createToggle("Velocidad Aumentada", posY, config.speedEnabled, function(value)
    config.speedEnabled = value
    local character = player.Character
    if character and character:FindFirstChild("Humanoid") then
        local humanoid = character.Humanoid
        humanoid.WalkSpeed = value and (16 * config.speedMultiplier) or 16
    end
end)

posY = createSection("Apariencia", posY)

-- Slider de tamaño
posY = createSlider("Multiplicador de Tamaño", posY, 0.5, 5, config.sizeMultiplier, function(value)
    config.sizeMultiplier = value
end)

-- Toggle para activar tamaño
posY = createToggle("Tamaño Aumentado", posY, config.sizeEnabled, function(value)
    config.sizeEnabled = value
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        if value then
            character:ScaleTo(config.sizeMultiplier)
        else
            character:ScaleTo(1)
        end
    end
end)

-- Botón para cambiar color
posY = createStyledButton("Cambiar Color", posY, Color3.fromRGB(255, 165, 0), function()
    local character = player.Character
    if character then
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                part.BrickColor = BrickColor.Random()
            end
        end
    end
end)

posY = createSection("Física", posY)

-- Slider de gravedad
posY = createSlider("Valor de Gravedad", posY, 0, 196.2, config.gravityValue, function(value)
    config.gravityValue = value
    if config.gravityEnabled then
        workspace.Gravity = value
    end
end)

-- Toggle para activar gravedad
posY = createToggle("Gravedad Personalizada", posY, config.gravityEnabled, function(value)
    config.gravityEnabled = value
    workspace.Gravity = value and config.gravityValue or 196.2
end)

-- Botón de teleport
posY = createStyledButton("Teleportar al Spawn", posY, Color3.fromRGB(255, 0, 0), function()
    local spawnLocation = game.Workspace:FindFirstChild("SpawnLocation")
    local character = player.Character
    if spawnLocation and character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = spawnLocation.CFrame + Vector3.new(0, 5, 0)
    end
end)

posY = createSection("Visuales", posY)

-- toggle para activar ESP
posY = createToggle("Activar ESP", posY, config.espEnabled, function(value)
    config.espEnabled = value
end)

-- toggle para mostrar box
posY = createToggle("Mostrar Cajas", posY, config.espShowBoxes, function(value)
    config.espShowBoxes = value
end)

-- toggle para mostrar nick
posY = createToggle("Mostrar Nombres", posY, config.espShowNames, function(value)
    config.espShowNames = value
end)

-- toggle para verificar equipo
posY = createToggle("Verificar Equipo", posY, config.espTeamCheck, function(value)
    config.espTeamCheck = value
end)

--AIMBOT
posY = createSection("Aimbot Avanzado", posY)

-- Toggle para activar aimbot
posY = createToggle("Activar Aimbot", posY, config.aimbotEnabled, function(value)
    config.aimbotEnabled = value
end)

-- Selector de parte del cuerpo
posY = createDropdown("Objetivo", posY, {"Head", "HumanoidRootPart", "Torso"}, config.aimbotTarget, function(option)
    config.aimbotTarget = option
end)

-- Slider de velocidad de aimbot
posY = createSlider("Velocidad de Aimbot", posY, 0.01, 1, config.aimbotSpeed, function(value)
    config.aimbotSpeed = value
end)

-- Slider de rango del aimbot
posY = createSlider("Rango de Aimbot", posY, 50, 2000, config.aimbotRange, function(value)
    config.aimbotRange = value
end)

-- Toggle para activar disparo automático
posY = createToggle("Disparo Automático", posY, config.aimbotAutoShoot, function(value)
    config.aimbotAutoShoot = value
end)

-- Toggle para verificar equipo
posY = createToggle("Verificar Equipo", posY, config.aimbotTeamCheck, function(value)
    config.aimbotTeamCheck = value
end)

-- Crear indicador visual de aimbot
local aimPart = Instance.new("Part")
aimPart.Size = Vector3.new(0.5, 0.5, 0.5)
aimPart.Anchored = true
aimPart.CanCollide = false
aimPart.Material = Enum.Material.Neon
aimPart.BrickColor = BrickColor.new("Really red")
aimPart.Transparency = 0.5
aimPart.Shape = Enum.PartType.Ball
aimPart.Parent = workspace

-- Función avanzada para encontrar el enemigo más cercano
local function getClosestEnemy()
    local closestEnemy = nil
    local closestPart = nil
    local shortestDistance = config.aimbotRange
    
    for _, otherPlayer in pairs(game.Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character then
            -- Verificar equipo si está activado
            if config.aimbotTeamCheck and otherPlayer.Team == player.Team then
                continue
            end
            
            local targetPart = otherPlayer.Character:FindFirstChild(config.aimbotTarget)
            if not targetPart then
                targetPart = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
            end
            
            if targetPart then
                local targetPos = targetPart.Position
                local distance = (camera.CFrame.Position - targetPos).Magnitude
                
                -- Verificar si está en el rango
                if distance < shortestDistance then
                    -- Verificar línea de visión
                    local ray = Ray.new(camera.CFrame.Position, (targetPos - camera.CFrame.Position).Unit * distance)
                    local hit, hitPos = workspace:FindPartOnRayWithIgnoreList(ray, {player.Character, aimPart})
                    
                    if not hit or hit:IsDescendantOf(otherPlayer.Character) then
                        closestEnemy = otherPlayer.Character
                        closestPart = targetPart
                        shortestDistance = distance
                    end
                end
            end
        end
    end
    
    return closestEnemy, closestPart
end

-- Función para activar/desactivar aimbot con tecla
userInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == config.aimbotToggleKey then
        config.aimbotEnabled = not config.aimbotEnabled
    end
end)

-- Función mejorada de aimbot
local function runAimbot()
    if config.aimbotEnabled then
        local enemy, targetPart = getClosestEnemy()
        
        if enemy and targetPart then
            -- Actualizar posición del indicador visual
            if config.aimbotVisibility then
                aimPart.Position = targetPart.Position
                aimPart.Transparency = 0.5
            else
                aimPart.Transparency = 1
            end
            
            local targetPos = targetPart.Position
            
            -- Predecir movimiento si el objetivo tiene velocidad
            if targetPart.Velocity.Magnitude > 0.1 then
                -- Añadir predicción simple de movimiento
                targetPos = targetPos + (targetPart.Velocity * 0.1)
            end
            
            -- Calcular nueva orientación de cámara
            local direction = (targetPos - camera.CFrame.Position).Unit
            local newCFrame = CFrame.new(camera.CFrame.Position, targetPos)
            
            -- Aplicar suavizado según la configuración
            camera.CFrame = camera.CFrame:Lerp(newCFrame, config.aimbotSpeed)
            
            -- Simular disparo automático si está activado
            if config.aimbotAutoShoot and userInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
                if tool and tool:FindFirstChild("Fire") and tool:FindFirstChild("Fire"):IsA("RemoteEvent") then
                    tool.Fire:FireServer(targetPos)
                end
            end
        else
            -- Ocultar indicador si no hay objetivo
            aimPart.Transparency = 1
        end
    else
        -- Ocultar indicador cuando aimbot está desactivado
        aimPart.Transparency = 1
    end
end

-- Conectar el aimbot al bucle del juego
runService.RenderStepped:Connect(runAimbot)

-- Mostrar tecla de aimbot
local keyHint = Instance.new("TextLabel")
keyHint.Size = UDim2.new(0, 200, 0, 30)
keyHint.Position = UDim2.new(0, 10, 0, -40)
keyHint.AnchorPoint = Vector2.new(0, 1)
keyHint.Text = "bind of the aimbot: X"
keyHint.Font = Enum.Font.GothamBold
keyHint.TextColor3 = Color3.fromRGB(255, 255, 255)
keyHint.TextSize = 14
keyHint.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
keyHint.BackgroundTransparency = 0.5
keyHint.BorderSizePixel = 0
-- Completar la visualización de la tecla de activación del aimbot
keyHint.Parent = player.PlayerGui

-- Completar las variables de configuración para el aimbot
config.aimbotToggleKey = Enum.KeyCode.X
config.aimbotVisibility = true  -- Para activar/desactivar la visibilidad del indicador

-- Mejorar la predicción del movimiento con una fórmula más avanzada
local function predictMovement(targetPart, time)
    -- Aplicar un cálculo simple de predicción basándose en la velocidad y dirección
    local velocity = targetPart.Velocity
    local futurePosition = targetPart.Position + (velocity * time)
    return futurePosition
end

-- Función avanzada para encontrar el enemigo más cercano
local function getClosestEnemy()
    local closestEnemy = nil
    local closestPart = nil
    local shortestDistance = config.aimbotRange
    
    for _, otherPlayer in pairs(game.Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character then
            -- Verificar equipo si está activado
            if config.aimbotTeamCheck and otherPlayer.Team == player.Team then
                continue
            end
            
            local targetPart = otherPlayer.Character:FindFirstChild(config.aimbotTarget)
            if not targetPart then
                targetPart = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
            end
            
            if targetPart then
                local targetPos = targetPart.Position
                local distance = (camera.CFrame.Position - targetPos).Magnitude
                
                -- Verificar si está en el rango
                if distance < shortestDistance then
                    -- Verificar línea de visión
                    local ray = Ray.new(camera.CFrame.Position, (targetPos - camera.CFrame.Position).Unit * distance)
                    local hit, hitPos = workspace:FindPartOnRayWithIgnoreList(ray, {player.Character, aimPart})
                    
                    if not hit or hit:IsDescendantOf(otherPlayer.Character) then
                        closestEnemy = otherPlayer.Character
                        closestPart = targetPart
                        shortestDistance = distance
                    end
                end
            end
        end
    end
    
    return closestEnemy, closestPart
end

-- Función mejorada de aimbot
local function runAimbot()
    if config.aimbotEnabled then
        local enemy, targetPart = getClosestEnemy()
        
        if enemy and targetPart then
            -- Actualizar posición del indicador visual
            if config.aimbotVisibility then
                aimPart.Position = targetPart.Position
                aimPart.Transparency = 0.5
            else
                aimPart.Transparency = 1
            end
            
            local targetPos = targetPart.Position
            
            -- Predecir movimiento del objetivo con una fórmula de predicción avanzada
            if targetPart.Velocity.Magnitude > 0.1 then
                local futurePos = predictMovement(targetPart, 0.1)  -- Predecir 0.1 segundos hacia el futuro
                targetPos = futurePos
            end
            
            -- Calcular nueva orientación de cámara
            local direction = (targetPos - camera.CFrame.Position).Unit
            local newCFrame = CFrame.new(camera.CFrame.Position, targetPos)
            
            -- Aplicar suavizado según la configuración
            camera.CFrame = camera.CFrame:Lerp(newCFrame, config.aimbotSpeed)
            
            -- Simular disparo automático si está activado
            if config.aimbotAutoShoot and userInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
                if tool and tool:FindFirstChild("Fire") and tool:FindFirstChild("Fire"):IsA("RemoteEvent") then
                    tool.Fire:FireServer(targetPos)
                end
            end
        else
            -- Ocultar indicador si no hay objetivo
            aimPart.Transparency = 1
        end
    else
        -- Ocultar indicador cuando aimbot está desactivado
        aimPart.Transparency = 1
    end
end

-- Conectar el aimbot al bucle del juego
runService.RenderStepped:Connect(runAimbot)

-- Función para desactivar aimbot automáticamente después de un tiempo
local function deactivateAimbotAfterTime(time)
    wait(time)
    config.aimbotEnabled = false
end

-- Ajustar la lógica de disparo para hacerla más precisa
local function shootAtTarget(targetPos)
    local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
    if tool then
        -- Asegurarse de que el disparo se haga en la dirección correcta
        local shootDirection = (targetPos - camera.CFrame.Position).Unit
        local fireEvent = tool:FindFirstChild("Fire")
        if fireEvent then
            fireEvent:FireServer(shootDirection)
        end
    end
end

-- Implementación de un sistema de sensibilidad ajustable
config.aimbotSensitivity = 0.5  -- Sensibilidad base

-- Función para ajustar la velocidad de apuntado según la sensibilidad
local function adjustAimbotSensitivity(targetPos)
    local currentPos = camera.CFrame.Position
    local direction = (targetPos - currentPos).Unit
    local adjustedSpeed = config.aimbotSpeed * config.aimbotSensitivity
    local newCFrame = CFrame.new(currentPos, targetPos)
    camera.CFrame = camera.CFrame:Lerp(newCFrame, adjustedSpeed)
end
-- Slider de rango del aimbot (esto ya lo tienes, solo aseguramos que se use correctamente)
posY = createSlider("Rango de Detección del Aimbot", posY, 50, 2000, config.aimbotRange, function(value)
    config.aimbotRange = value
end)

-- Función avanzada para encontrar el enemigo más cercano con rango de detección configurable
local function getClosestEnemy()
    local closestEnemy = nil
    local closestPart = nil
    local shortestDistance = config.aimbotRange  -- Usamos el rango configurable aquí
  --local maxDistance = config.aimbotRange bv

    for _, otherPlayer in pairs(game.Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character then
            -- Verificar equipo si está activado
            if config.aimbotTeamCheck and otherPlayer.Team == player.Team then
                continue
            end
            
            local targetPart = otherPlayer.Character:FindFirstChild(config.aimbotTarget)
            if not targetPart then
                targetPart = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
            end
            
            if targetPart then
                local targetPos = targetPart.Position
                local distance = (camera.CFrame.Position - targetPos).Magnitude
                
                -- Verificar si está dentro del rango de detección
                if distance <= config.aimbotRange then
                    -- Verificar línea de visión
                    local ray = Ray.new(camera.CFrame.Position, (targetPos - camera.CFrame.Position).Unit * distance)
                    local hit, hitPos = workspace:FindPartOnRayWithIgnoreList(ray, {player.Character, aimPart})
                    
                    if not hit or hit:IsDescendantOf(otherPlayer.Character) then
                        closestEnemy = otherPlayer.Character
                        closestPart = targetPart
                        shortestDistance = distance
                    end
                end
            end
        end
    end
    
    return closestEnemy, closestPart
end

-- Función mejorada de aimbot con rango de detección
local function runAimbot()
    if config.aimbotEnabled then
        local enemy, targetPart = getClosestEnemy()
        
        if enemy and targetPart then
            -- Actualizar posición del indicador visual
            if config.aimbotVisibility then
                aimPart.Position = targetPart.Position
                aimPart.Transparency = 0.5
            else
                aimPart.Transparency = 1
            end
            
            local targetPos = targetPart.Position
            
            -- Predecir movimiento del objetivo con una fórmula de predicción avanzada
            if targetPart.Velocity.Magnitude > 0.1 then
                local futurePos = predictMovement(targetPart, 0.1)  -- Predecir 0.1 segundos hacia el futuro
                targetPos = futurePos
            end
            
            -- Calcular nueva orientación de cámara
            local direction = (targetPos - camera.CFrame.Position).Unit
            local newCFrame = CFrame.new(camera.CFrame.Position, targetPos)
            
            -- Aplicar suavizado según la configuración
            camera.CFrame = camera.CFrame:Lerp(newCFrame, config.aimbotSpeed)
            
            -- Simular disparo automático si está activado
            if config.aimbotAutoShoot and userInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
                if tool and tool:FindFirstChild("Fire") and tool:FindFirstChild("Fire"):IsA("RemoteEvent") then
                    tool.Fire:FireServer(targetPos)
                end
            end
        else
            -- Ocultar indicador si no hay objetivo
            aimPart.Transparency = 1
        end
    else
        -- Ocultar indicador cuando aimbot está desactivado
        aimPart.Transparency = 1
    end
end

--ESP MODULE (NO SKID) (TEST)
local function updateESP()
    if not config.espEnabled then
        -- Si el ESP está desactivado, eliminar todas las GUI
        for _, espData in pairs(espObjects) do
            espData[1]:Destroy()
        end
        espObjects = {}
        return
    end

    for _, player in pairs(players:GetPlayers()) do
        if player == localPlayer then continue end
        if config.espTeamCheck and player.Team == localPlayer.Team then continue end

        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local rootPart = character:FindFirstChild("HumanoidRootPart")

            -- Convertir coordenadas 3D a 2D
            local screenPos, onScreen = camera:WorldToViewportPoint(rootPart.Position)

            if onScreen then
                -- Si no tiene ESP, lo creamos
                if not espObjects[player] then
                    espObjects[player] = { createESP(player) }
                end

                local espGui, espFrame, espText = unpack(espObjects[player])

                -- Vincular ESP al personaje
                espGui.Adornee = rootPart

                -- Mostrar elementos según la configuración
                espFrame.Visible = config.espShowBoxes
                espText.Visible = config.espShowNames
            else
                -- Si el jugador no está en pantalla, ocultamos el ESP
                if espObjects[player] then
                    local espGui = espObjects[player][1]
                    espGui.Adornee = nil
                end
            end
        else
            -- Si el personaje ya no existe elimina el ESP
            if espObjects[player] then
                espObjects[player][1]:Destroy() 
                espObjects[player] = nil
            end
        end
    end
end

-- Continuar con el script existente
-- Añadir nuevas secciones después de la sección de Aimbot

-- Funciones de utilidad para los nuevos módulos
local function isPlayerEnemy(otherPlayer)
    if config.teamCheck and otherPlayer.Team == player.Team then
        return false
    end
    return true
end

local function getDistanceFromCharacter(otherCharacter)
    local character = player.Character
    if character and otherCharacter then
        local hrp1 = character:FindFirstChild("HumanoidRootPart")
        local hrp2 = otherCharacter:FindFirstChild("HumanoidRootPart")
        if hrp1 and hrp2 then
            return (hrp1.Position - hrp2.Position).Magnitude
        end
    end
    return math.huge
end

---- SILENT AIM MODULE ----
posY = createSection("Silent Aim", posY)

-- Configuración de Silent Aim
config.silentAimEnabled = false
config.silentAimFOV = 100
config.silentAimHitChance = 85
config.silentAimShowFOV = true
config.silentAimTargetPart = "Head"
config.silentAimWallCheck = true

-- Toggle para activar Silent Aim
posY = createToggle("Activar Silent Aim", posY, config.silentAimEnabled, function(value)
    config.silentAimEnabled = value
end)

-- Slider para el FOV del Silent Aim
posY = createSlider("FOV de Silent Aim", posY, 30, 500, config.silentAimFOV, function(value)
    config.silentAimFOV = value
    if silentAimCircle then
        silentAimCircle.Radius = value
    end
end)

-- Slider para probabilidad de acierto
posY = createSlider("Probabilidad de Acierto (%)", posY, 30, 100, config.silentAimHitChance, function(value)
    config.silentAimHitChance = value
end)

-- Toggle para mostrar el FOV del Silent Aim
posY = createToggle("Mostrar Círculo FOV", posY, config.silentAimShowFOV, function(value)
    config.silentAimShowFOV = value
    if silentAimCircle then
        silentAimCircle.Visible = value
    end
end)

-- Partes del cuerpo para apuntar
posY = createDropdown("Parte Objetivo", posY, {"Head", "HumanoidRootPart", "Torso", "Random"}, config.silentAimTargetPart, function(option)
    config.silentAimTargetPart = option
end)

-- Toggle para verificación de pared
posY = createToggle("Verificar Paredes", posY, config.silentAimWallCheck, function(value)
    config.silentAimWallCheck = value
end)

-- Crear círculo FOV para Silent Aim
local silentAimCircle = Drawing.new("Circle")
silentAimCircle.Visible = config.silentAimShowFOV
silentAimCircle.Radius = config.silentAimFOV
silentAimCircle.Color = Color3.fromRGB(255, 255, 255)
silentAimCircle.Thickness = 1
silentAimCircle.Transparency = 0.7
silentAimCircle.NumSides = 64
silentAimCircle.Filled = false

-- Función para actualizar la posición del círculo FOV
local function updateSilentAimFOV()
    if silentAimCircle then
        silentAimCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
        silentAimCircle.Visible = config.silentAimEnabled and config.silentAimShowFOV
    end
end

-- Función para obtener el objetivo válido para Silent Aim
local function getSilentAimTarget()
    if not config.silentAimEnabled then return nil end
    
    -- Verificar probabilidad de acierto
    if math.random(1, 100) > config.silentAimHitChance then return nil end
    
    local closestPlayer = nil
    local shortestDistance = config.silentAimFOV
    local mousePos = userInputService:GetMouseLocation()
    
    for _, otherPlayer in pairs(game.Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character then
            -- Verificar equipo
            if not isPlayerEnemy(otherPlayer) then continue end
            
            -- Determinar la parte objetivo
            local targetPart
            if config.silentAimTargetPart == "Random" then
                local parts = {"Head", "HumanoidRootPart"}
                targetPart = otherPlayer.Character:FindFirstChild(parts[math.random(1, #parts)])
            else
                targetPart = otherPlayer.Character:FindFirstChild(config.silentAimTargetPart)
            end
            
            if not targetPart then continue end
            
            -- Verificar si está en pantalla
            local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
            if not onScreen then continue end
            
            -- Verificar si está dentro del FOV
            local screenDistance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
            if screenDistance > config.silentAimFOV then continue end
            
            -- Verificar línea de visión si está habilitado
            if config.silentAimWallCheck then
                local ray = Ray.new(camera.CFrame.Position, (targetPart.Position - camera.CFrame.Position).Unit * 1000)
                local hit, _ = workspace:FindPartOnRayWithIgnoreList(ray, {player.Character})
                if not hit or not hit:IsDescendantOf(otherPlayer.Character) then continue end
            end
            
            -- Verificar si es el más cercano al cursor
            if screenDistance < shortestDistance then
                closestPlayer = targetPart
                shortestDistance = screenDistance
            end
        end
    end
    
    return closestPlayer
end

---- HITBOX EXPANDER MODULE ----
posY = createSection("Expansor de Hitbox", posY)

-- Configuración del Expansor de Hitbox
config.hitboxExpanderEnabled = false
config.hitboxSize = 2
config.hitboxTransparency = 0.5
config.hitboxPart = "Head"

-- Toggle para activar el Expansor de Hitbox
posY = createToggle("Expandir Hitboxes", posY, config.hitboxExpanderEnabled, function(value)
    config.hitboxExpanderEnabled = value
    
    -- Restaurar hitboxes al desactivar
    if not value then
        for _, otherPlayer in pairs(game.Players:GetPlayers()) do
            if otherPlayer ~= player and otherPlayer.Character then
                local part = otherPlayer.Character:FindFirstChild(config.hitboxPart)
                if part and part:IsA("BasePart") then
                    part.Size = part.Name == "Head" and Vector3.new(1.2, 1.2, 1.2) or 
                                part.Name == "HumanoidRootPart" and Vector3.new(2, 2, 1) or 
                                part.Size
                    part.Transparency = part.Name == "HumanoidRootPart" and 1 or 0
                end
            end
        end
    end
end)

-- Slider para el tamaño del hitbox
posY = createSlider("Tamaño de Hitbox", posY, 1, 10, config.hitboxSize, function(value)
    config.hitboxSize = value
end)

-- Slider para la transparencia del hitbox
posY = createSlider("Transparencia", posY, 0, 1, config.hitboxTransparency, function(value)
    config.hitboxTransparency = value
end)

-- Selección de parte a expandir
posY = createDropdown("Parte a Expandir", posY, {"Head", "HumanoidRootPart", "Torso"}, config.hitboxPart, function(option)
    config.hitboxPart = option
end)

-- Función para actualizar hitboxes
local function updateHitboxes()
    if not config.hitboxExpanderEnabled then return end
    
    for _, otherPlayer in pairs(game.Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character and isPlayerEnemy(otherPlayer) then
            local part = otherPlayer.Character:FindFirstChild(config.hitboxPart)
            if part and part:IsA("BasePart") then
                part.Size = Vector3.new(config.hitboxSize, config.hitboxSize, config.hitboxSize)
                part.Transparency = config.hitboxTransparency
                part.CanCollide = false
            end
        end
    end
end

---- AUTO PARRY MODULE ----
posY = createSection("Auto Parry", posY)

-- Configuración de Auto Parry
config.autoParryEnabled = false
config.autoParryDistance = 15
config.autoParryReactionTime = 0.15
config.autoParryDetectionRange = 30

-- Toggle para activar Auto Parry
posY = createToggle("Activar Auto Parry", posY, config.autoParryEnabled, function(value)
    config.autoParryEnabled = value
end)

-- Slider para la distancia de detección
posY = createSlider("Distancia de Detección", posY, 5, 50, config.autoParryDetectionRange, function(value)
    config.autoParryDetectionRange = value
end)

-- Slider para el tiempo de reacción
posY = createSlider("Tiempo de Reacción (s)", posY, 0, 0.5, config.autoParryReactionTime, function(value)
    config.autoParryReactionTime = value
end)

-- Función para detectar animaciones de ataque
local animationDetected = false
local attackAnimations = {"punch", "swing", "slash", "attack", "hit"}

local function isAttackAnimation(animationTrack)
    local animName = string.lower(animationTrack.Name)
    for _, attackAnim in ipairs(attackAnimations) do
        if string.find(animName, attackAnim) then
            return true
        end
    end
    return false
end

-- Función principal de Auto Parry
local function runAutoParry()
    if not config.autoParryEnabled then return end
    
    local character = player.Character
    if not character then return end
    
    for _, otherPlayer in pairs(game.Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character then
            local distance = getDistanceFromCharacter(otherPlayer.Character)
            
            if distance <= config.autoParryDetectionRange then
                local humanoid = otherPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                        if isAttackAnimation(track) and not animationDetected then
                            animationDetected = true
                            
                            -- Hacer parry con retraso para que parezca más natural
                            delay(config.autoParryReactionTime, function()
                                if distance <= config.autoParryDistance then
                                    -- Buscar remoteEvent de parry en el juego
                                    local tool = character:FindFirstChildOfClass("Tool")
                                    if tool then
                                        for _, obj in pairs(tool:GetDescendants()) do
                                            if obj:IsA("RemoteEvent") and (string.find(string.lower(obj.Name), "parry") or 
                                                                         string.find(string.lower(obj.Name), "block")) then
                                                obj:FireServer()
                                            end
                                        end
                                    end
                                    
                                    -- Intentar también por keybind común de parry (como F)
                                    keyPress(Enum.KeyCode.F)
                                end
                                
                                animationDetected = false
                            end)
                        end
                    end
                end
            end
        end
    end
end

-- Simular pulsación de tecla para Auto Parry
local virtualInputManager = game:GetService("VirtualInputManager")
local function keyPress(keyCode)
    virtualInputManager:SendKeyEvent(true, keyCode, false, game)
    wait(0.05)
    virtualInputManager:SendKeyEvent(false, keyCode, false, game)
end

---- VISUAL MODULE ----
posY = createSection("Mejoras Visuales", posY)

-- Configuración de mejoras visuales
config.fullBright = false
config.noFog = false
config.customTime = false
config.timeValue = 12
config.removeVisualObstructions = false
config.enhanceContrast = false

-- Toggle para activar iluminación máxima (FullBright)
posY = createToggle("Iluminación Máxima", posY, config.fullBright, function(value)
    config.fullBright = value
    
    if value then
        -- Guardar configuración original
        config.originalBrightness = game.Lighting.Brightness
        config.originalAmbient = game.Lighting.Ambient
        
        -- Aplicar fullbright
        game.Lighting.Brightness = 2
        game.Lighting.Ambient = Color3.fromRGB(255, 255, 255)
    else
        -- Restaurar configuración original
        if config.originalBrightness then
            game.Lighting.Brightness = config.originalBrightness
        end
        if config.originalAmbient then
            game.Lighting.Ambient = config.originalAmbient
        end
    end
end)

-- Toggle para eliminar niebla
posY = createToggle("Eliminar Niebla", posY, config.noFog, function(value)
    config.noFog = value
    
    if value then
        -- Guardar configuración original
        config.originalFogStart = game.Lighting.FogStart
        config.originalFogEnd = game.Lighting.FogEnd
        
        -- Eliminar niebla
        game.Lighting.FogStart = 100000
        game.Lighting.FogEnd = 100000
    else
        -- Restaurar configuración original
        if config.originalFogStart then
            game.Lighting.FogStart = config.originalFogStart
        end
        if config.originalFogEnd then
            game.Lighting.FogEnd = config.originalFogEnd
        end
    end
end)

-- Toggle para hora personalizada
posY = createToggle("Hora Personalizada", posY, config.customTime, function(value)
    config.customTime = value
    
    if value then
        -- Guardar configuración original
        config.originalClockTime = game.Lighting.ClockTime
        
        -- Aplicar hora personalizada
        game.Lighting.ClockTime = config.timeValue
    else
        -- Restaurar configuración original
        if config.originalClockTime then
            game.Lighting.ClockTime = config.originalClockTime
        end
    end
end)

-- Slider para seleccionar la hora
posY = createSlider("Hora (0-24)", posY, 0, 24, config.timeValue, function(value)
    config.timeValue = value
    if config.customTime then
        game.Lighting.ClockTime = value
    end
end)

-- Toggle para eliminar obstrucciones visuales
posY = createToggle("Eliminar Obstrucciones", posY, config.removeVisualObstructions, function(value)
    config.removeVisualObstructions = value
    
    local function handlePart(part)
        if part:IsA("ParticleEmitter") or part:IsA("Smoke") or part:IsA("Fire") or
           part:IsA("Explosion") or part:IsA("Sparkles") then
            part.Enabled = not value
        end
    end
    
    -- Recorrer el workspace para ocultar partículas
    for _, obj in pairs(workspace:GetDescendants()) do
        handlePart(obj)
    end
    
    -- Conectar evento para manejar nuevos objetos
    if value and not config.obstructionsConnection then
        config.obstructionsConnection = workspace.DescendantAdded:Connect(function(part)
            handlePart(part)
        end)
    elseif not value and config.obstructionsConnection then
        config.obstructionsConnection:Disconnect()
        config.obstructionsConnection = nil
    end
end)

---- ANTI-RECOIL MODULE ----
posY = createSection("Anti-Retroceso", posY)

-- Configuración de Anti-Recoil
config.antiRecoilEnabled = false
config.recoilReduction = 90

-- Toggle para activar Anti-Recoil
posY = createToggle("Reducir Retroceso", posY, config.antiRecoilEnabled, function(value)
    config.antiRecoilEnabled = value
end)

-- Slider para el porcentaje de reducción
posY = createSlider("Reducción de Retroceso (%)", posY, 0, 100, config.recoilReduction, function(value)
    config.recoilReduction = value
end)

-- Función para detectar y modificar los scripts de retroceso
local function hookRecoilFunction()
    if not config.antiRecoilEnabled then return end
    
    -- Buscar y modificar funciones de retroceso en armas
    local function processGun(tool)
        if not tool:IsA("Tool") then return end
        
        for _, obj in pairs(tool:GetDescendants()) do
            if obj:IsA("LocalScript") then
                -- Intentar modificar valores comunes de retroceso
                local success, _ = pcall(function()
                    -- Evitar doble hook
                    if obj:GetAttribute("AntiRecoilHooked") then return end
                    
                    -- Marcar como hookeado
                    obj:SetAttribute("AntiRecoilHooked", true)
                    
                    local constants = {"Recoil", "RecoilMax", "Spread", "Kick", "CameraShake"}
                    for _, name in pairs(constants) do
                        -- Verificar si hay un valor en el script con ese nombre
                        for _, v in pairs(getgc(true)) do
                            if type(v) == "table" and rawget(v, name) and type(rawget(v, name)) == "number" then
                                -- Reducir valor según el porcentaje
                                local originalValue = rawget(v, name)
                                local hookFn 
                                
                                hookFn = hookfunction(rawget, function(t, k)
                                    if t == v and k == name then
                                        return originalValue * (1 - config.recoilReduction/100)
                                    end
                                    return hookFn(t, k)
                                end)
                            end
                        end
                    end
                end)
            end
        end
    end
    
    -- Procesar armas existentes
    for _, tool in pairs(player.Backpack:GetChildren()) do
        processGun(tool)
    end
    if player.Character then
        for _, tool in pairs(player.Character:GetChildren()) do
            processGun(tool)
        end
    end
    
    -- Conectar evento para procesar nuevas armas
    if not config.antiRecoilConnection then
        config.antiRecoilConnection = player.Backpack.ChildAdded:Connect(processGun)
        if player.Character then
            config.antiRecoilAddedConnection = player.Character.ChildAdded:Connect(processGun)
        end
    end
end

-- Bucle principal para actualizar todas las características
runService.RenderStepped:Connect(function()
    updateSilentAimFOV()
    updateHitboxes()
    runAutoParry()
    
    -- Si estamos usando Silent Aim, modificar el sistema de disparo
    if config.silentAimEnabled then
        local target = getSilentAimTarget()
        if target then
            -- Hook del sistema de disparo (esto varía según el juego)
            local namecall
            namecall = hookmetamethod(game, "__namecall", function(self, ...)
                local args = {...}
                local method = getnamecallmethod()
                
                if method == "FireServer" and self.Name == "Fire" and target then
                    -- Modificar los argumentos de disparo para que apunten al objetivo
                    args[1] = target.Position
                    return namecall(self, unpack(args))
                end
                
                return namecall(self, ...)
            end)
        end
    end
    
    -- Actualizar Anti-Recoil
    if config.antiRecoilEnabled then
        hookRecoilFunction()
    end
end)

-- Añadir listeners para cuando entren/salgan jugadores
game.Players.PlayerAdded:Connect(function(plr)
    wait(1) -- Esperar a que cargue el personaje
    updateHitboxes()
end)

posY = createSection("Ajustes de Drip X", posY)

-- Botón para reiniciar configuración
posY = createStyledButton("Reiniciar Configuración", posY, Color3.fromRGB(255, 0, 0), function()
    -- Restaurar valores predeterminados
    for key, value in pairs(config) do
        if type(value) == "boolean" then
            config[key] = false
        elseif type(value) == "number" then
            config[key] = 1
        end
    end
    
    -- Avisar al usuario
    local notification = Instance.new("TextLabel")
    notification.Size = UDim2.new(0, 200, 0, 50)
    notification.Position = UDim2.new(0.5, -100, 0, 100)
    notification.Text = "Configuración reiniciada"
    notification.Font = Enum.Font.GothamBold
    notification.TextColor3 = Color3.fromRGB(255, 255, 255)
    notification.TextSize = 16
    notification.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    notification.BackgroundTransparency = 0.5
    notification.BorderSizePixel = 0
    notification.Parent = screenGui
    
    wait(2)
    notification:Destroy()
end)

-- Botón para guardar configuración
posY = createStyledButton("Guardar Configuración", posY, Color3.fromRGB(0, 170, 255), function()
    -- Crear un string de configuración
    local configString = ""
    for key, value in pairs(config) do
        if type(value) ~= "function" and type(value) ~= "table" then
            configString = configString .. key .. "=" .. tostring(value) .. ";"
        end
    end
    
    if setclipboard then
        setclipboard(configString)
        
        local notification = Instance.new("TextLabel")
        notification.Size = UDim2.new(0, 200, 0, 50)
        notification.Position = UDim2.new(0.5, -100, 0, 100)
        notification.Text = "Configuracion copiada"
        notification.Font = Enum.Font.GothamBold
        notification.TextColor3 = Color3.fromRGB(255, 255, 255)
        notification.TextSize = 16
        notification.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        notification.BackgroundTransparency = 0.5
        notification.BorderSizePixel = 0
        notification.Parent = screenGui
        
        wait(2)
        notification:Destroy()
    end
end)

-- Añadir marca de agua discreta
local watermark = Instance.new("TextLabel")
watermark.Size = UDim2.new(0, 100, 0, 20)
watermark.Position = UDim2.new(1, -110, 1, -30)
watermark.Text = "Drip X"
watermark.Font = Enum.Font.GothamBold
watermark.TextColor3 = Color3.fromRGB(255, 255, 255)
watermark.TextSize = 14
watermark.BackgroundTransparency = 1
watermark.TextXAlignment = Enum.TextXAlignment.Right
watermark.Parent = screenGui
--CLICK GUI BIND--
-- Actualizar tamaño del scroll frame
contentFrame.CanvasSize = UDim2.new(0, 0, 0, posY + 50)

config.guiToggleKey = Enum.KeyCode.P  -- Valor por defecto

local function toggleGUI(input, gameProcessed)
    if gameProcessed or not config.toggleGUI then return end
    if input.KeyCode == config.guiToggleKey then
        screenGui.Enabled = not screenGui.Enabled
    end
end

-- Conectar la función al evento de teclado
userInputService.InputBegan:Connect(toggleGUI)