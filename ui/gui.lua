-- Drip X - Gui Module

local module = {}
local SharedEnvironment 

-- // UI State \\ --
local screenGui
local mainFrame
local contentFrame
local currentY = 10 
local elementSpacing = 6 
local horizontalPadding = 0.05 
local elementWidth = 1 - (horizontalPadding * 2) 
local uiElements = {} 

-- // Helper: Create Notification \\ --
local function showNotification(text, duration)
    if not screenGui or not screenGui.Parent then return end 

    for _, existingNotif in pairs(screenGui:GetChildren()) do
        if existingNotif.Name == "DripX_Notification" then
            existingNotif:Destroy()
        end
    end

    local notification = Instance.new("TextLabel")
    notification.Name = "DripX_Notification"
    notification.Size = UDim2.new(0, 250, 0, 40)
    notification.Position = UDim2.new(0.5, -125, 0, 20) 
    notification.Text = text
    notification.Font = Enum.Font.GothamSemibold
    notification.TextColor3 = Color3.fromRGB(255, 255, 255)
    notification.TextSize = 14
    notification.TextWrapped = true
    notification.TextYAlignment = Enum.TextYAlignment.Center
    notification.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    notification.BackgroundTransparency = 0.1
    notification.BorderSizePixel = 0
    notification.ZIndex = 100
    notification.Parent = screenGui

    local corner = Instance.new("UICorner", notification)
    corner.CornerRadius = UDim.new(0, 4)

    SharedEnvironment.Services.Debris:AddItem(notification, duration or 3)
end

-- // UI Creation Functions (Manage Y position internally) \\ --

local function createSection(title)
    local section = Instance.new("Frame")
    section.Name = title .. "Section"
    section.Size = UDim2.new(elementWidth, 0, 0, 25)
    section.Position = UDim2.new(horizontalPadding, 0, 0, currentY)
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

    table.insert(uiElements, {type="section", name=title, element=section})
    currentY = currentY + section.Size.Y.Offset + elementSpacing / 2
    return currentY
end

local function createStyledButton(text, color, callback)
    local button = Instance.new("TextButton")
    button.Name = text:gsub("%s+", "") .. "Button"
    button.Size = UDim2.new(elementWidth, 0, 0, 36)
    button.Position = UDim2.new(horizontalPadding, 0, 0, currentY)
    button.Text = text
    button.Font = Enum.Font.GothamMedium
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14
    button.BackgroundColor3 = color
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.Parent = contentFrame

    local cornerRadius = Instance.new("UICorner")
    cornerRadius.CornerRadius = UDim.new(0, 4)
    cornerRadius.Parent = button

    local originalColor = color
    local hoverColor = Color3.fromRGB(
        math.min(originalColor.R * 255 + 20, 255)/255,
        math.min(originalColor.G * 255 + 20, 255)/255,
        math.min(originalColor.B * 255 + 20, 255)/255
    )

    button.MouseEnter:Connect(function()
        SharedEnvironment.Services.TweenService:Create(button, TweenInfo.new(0.1), {BackgroundColor3 = hoverColor}):Play()
    end)

    button.MouseLeave:Connect(function()
         SharedEnvironment.Services.TweenService:Create(button, TweenInfo.new(0.1), {BackgroundColor3 = originalColor}):Play()
    end)

    if callback then
        button.MouseButton1Click:Connect(callback)
    end

    table.insert(uiElements, {type="button", name=text, element=button})
    currentY = currentY + button.Size.Y.Offset + elementSpacing
    return currentY
end

local function createSlider(name, minValue, maxValue, defaultValue, callback)
    local sliderFrameContainer = Instance.new("Frame")
    sliderFrameContainer.Name = name:gsub("%s+", "") .. "SliderContainer"
    sliderFrameContainer.Size = UDim2.new(elementWidth, 0, 0, 40)
    sliderFrameContainer.Position = UDim2.new(horizontalPadding, 0, 0, currentY)
    sliderFrameContainer.BackgroundTransparency = 1
    sliderFrameContainer.Parent = contentFrame

    local sliderLabel = Instance.new("TextLabel")
    sliderLabel.Name = "Label"
    sliderLabel.Size = UDim2.new(1, 0, 0, 20)
    sliderLabel.Position = UDim2.new(0, 0, 0, 0)
    sliderLabel.Text = name .. ": " .. string.format("%.1f", defaultValue) 
    sliderLabel.Font = Enum.Font.GothamMedium
    sliderLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
    sliderLabel.TextSize = 14
    sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    sliderLabel.BackgroundTransparency = 1
    sliderLabel.Parent = sliderFrameContainer

    local sliderFrame = Instance.new("Frame")
    sliderFrame.Name = "SliderBar"
    sliderFrame.Size = UDim2.new(1, 0, 0, 4)
    sliderFrame.Position = UDim2.new(0, 0, 0, 25)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    sliderFrame.BorderSizePixel = 0
    sliderFrame.Active = true 
    sliderFrame.Parent = sliderFrameContainer

    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 2)
    sliderCorner.Parent = sliderFrame

    local sliderFill = Instance.new("Frame")
    sliderFill.Name = "Fill"
    local initialFill = math.clamp((defaultValue - minValue) / (maxValue - minValue), 0, 1)
    sliderFill.Size = UDim2.new(initialFill, 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(90, 160, 230)
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderFrame

    local sliderFillCorner = Instance.new("UICorner")
    sliderFillCorner.CornerRadius = UDim.new(0, 2)
    sliderFillCorner.Parent = sliderFill

    local sliderButton = Instance.new("TextButton") 
    sliderButton.Name = "Handle"
    sliderButton.Size = UDim2.new(0, 12, 0, 12)
    sliderButton.Position = UDim2.new(initialFill, -6, 0.5, -6) 
    sliderButton.Text = ""
    sliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderButton.BorderSizePixel = 0
    sliderButton.ZIndex = 3
    sliderButton.AutoButtonColor = false
    sliderButton.Parent = sliderFrame

    local sliderButtonCorner = Instance.new("UICorner")
    sliderButtonCorner.CornerRadius = UDim.new(1, 0) 
    sliderButtonCorner.Parent = sliderButton

    local value = defaultValue

    local function updateSlider(mouseX)
        local frameAbsPos = sliderFrame.AbsolutePosition.X
        local frameAbsSize = sliderFrame.AbsoluteSize.X
        if frameAbsSize <= 0 then return end 

        local relativeX = math.clamp((mouseX - frameAbsPos) / frameAbsSize, 0, 1)
        local newValue = minValue + (maxValue - minValue) * relativeX
        newValue = math.floor(newValue * 10 + 0.5) / 10 

        if math.abs(newValue - value) < 0.01 and sliderFill.Size.X.Scale == relativeX then return end 
        value = newValue

        sliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
        sliderButton.Position = UDim2.new(relativeX, -6, 0.5, -6) 
        sliderLabel.Text = name .. ": " .. string.format("%.1f", value)

        if callback then
            pcall(callback, value) 
        end
    end

    local dragConnection = nil
    local inputEndedConn = nil

    sliderButton.MouseButton1Down:Connect(function()
        if dragConnection then dragConnection:Disconnect() end 
        if inputEndedConn then inputEndedConn:Disconnect() end

        local mouse = SharedEnvironment.Services.UserInputService:GetMouseLocation()
        updateSlider(mouse.X) 

        dragConnection = SharedEnvironment.Services.RunService.RenderStepped:Connect(function()
             if not SharedEnvironment.Services.UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                 if dragConnection then dragConnection:Disconnect(); dragConnection = nil end 
                 return
             end
             local currentMouse = SharedEnvironment.Services.UserInputService:GetMouseLocation()
             updateSlider(currentMouse.X)
        end)

        inputEndedConn = SharedEnvironment.Services.UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                if dragConnection then dragConnection:Disconnect(); dragConnection = nil end
                if inputEndedConn then inputEndedConn:Disconnect(); inputEndedConn = nil end
            end
        end)
    end)

    sliderFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            updateSlider(input.Position.X)
        end
    end)

    if callback then pcall(callback, defaultValue) end

    table.insert(uiElements, {type="slider", name=name, element=sliderFrameContainer, label=sliderLabel, handle=sliderButton, fill=sliderFill})
    currentY = currentY + sliderFrameContainer.Size.Y.Offset + elementSpacing
    return currentY
end

local function createToggle(name, defaultValue, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Name = name:gsub("%s+", "") .. "Toggle"
    toggleFrame.Size = UDim2.new(elementWidth, 0, 0, 30)
    toggleFrame.Position = UDim2.new(horizontalPadding, 0, 0, currentY)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Parent = contentFrame

    local toggleLabel = Instance.new("TextLabel")
    toggleLabel.Name = "Label"
    toggleLabel.Size = UDim2.new(1, -45, 1, 0) 
    toggleLabel.Position = UDim2.new(0, 0, 0, 0)
    toggleLabel.Text = name
    toggleLabel.Font = Enum.Font.GothamMedium
    toggleLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
    toggleLabel.TextSize = 14
    toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    toggleLabel.BackgroundTransparency = 1
    toggleLabel.Parent = toggleFrame

    local toggleButtonFrame = Instance.new("TextButton")
    toggleButtonFrame.Name = "SwitchFrame"
    toggleButtonFrame.Size = UDim2.new(0, 34, 0, 16)
    toggleButtonFrame.Position = UDim2.new(1, -40, 0.5, -8) 
    toggleButtonFrame.BackgroundColor3 = defaultValue and Color3.fromRGB(90, 160, 230) or Color3.fromRGB(70, 70, 75)
    toggleButtonFrame.BorderSizePixel = 0
    toggleButtonFrame.Text = ""
    toggleButtonFrame.AutoButtonColor = false
    toggleButtonFrame.Parent = toggleFrame

    local toggleButtonCorner = Instance.new("UICorner")
    toggleButtonCorner.CornerRadius = UDim.new(1, 0)
    toggleButtonCorner.Parent = toggleButtonFrame

    local toggleCircle = Instance.new("Frame")
    toggleCircle.Name = "SwitchCircle"
    toggleCircle.Size = UDim2.new(0, 12, 0, 12)
    local circleOnPos = UDim2.new(1, -14, 0.5, -6) 
    local circleOffPos = UDim2.new(0, 2, 0.5, -6)  
    toggleCircle.Position = defaultValue and circleOnPos or circleOffPos
    toggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleCircle.BorderSizePixel = 0
    toggleCircle.ZIndex = toggleButtonFrame.ZIndex + 1
    toggleCircle.Parent = toggleButtonFrame

    local toggleCircleCorner = Instance.new("UICorner")
    toggleCircleCorner.CornerRadius = UDim.new(1, 0) 
    toggleCircleCorner.Parent = toggleCircle

    local value = defaultValue

    toggleButtonFrame.MouseButton1Click:Connect(function()
        value = not value

        local targetColor = value and Color3.fromRGB(90, 160, 230) or Color3.fromRGB(70, 70, 75)
        local targetPos = value and circleOnPos or circleOffPos
        local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

        SharedEnvironment.Services.TweenService:Create(toggleButtonFrame, tweenInfo, {BackgroundColor3 = targetColor}):Play()
        SharedEnvironment.Services.TweenService:Create(toggleCircle, tweenInfo, {Position = targetPos}):Play()

        if callback then
            pcall(callback, value) 
        end
    end)

    if callback then pcall(callback, defaultValue) end

    table.insert(uiElements, {type="toggle", name=name, element=toggleFrame, switch=toggleButtonFrame, circle=toggleCircle, label=toggleLabel})
    currentY = currentY + toggleFrame.Size.Y.Offset + elementSpacing
    return currentY
end

local function createDropdown(name, options, defaultOption, callback)
    local dropdownContainer = Instance.new("Frame")
    dropdownContainer.Name = name:gsub("%s+", "") .. "DropdownContainer"
    dropdownContainer.Size = UDim2.new(elementWidth, 0, 0, 55) 
    dropdownContainer.Position = UDim2.new(horizontalPadding, 0, 0, currentY)
    dropdownContainer.BackgroundTransparency = 1
    dropdownContainer.ClipsDescendants = false 
    dropdownContainer.Parent = contentFrame
    dropdownContainer.ZIndex = 2 

    local dropdownLabel = Instance.new("TextLabel")
    dropdownLabel.Name = "Label"
    dropdownLabel.Size = UDim2.new(1, 0, 0, 20)
    dropdownLabel.Position = UDim2.new(0, 0, 0, 0)
    dropdownLabel.Text = name
    dropdownLabel.Font = Enum.Font.GothamMedium
    dropdownLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
    dropdownLabel.TextSize = 14
    dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
    dropdownLabel.BackgroundTransparency = 1
    dropdownLabel.Parent = dropdownContainer

    local dropdownFrame = Instance.new("TextButton")
    dropdownFrame.Name = "DropdownButton"
    dropdownFrame.Size = UDim2.new(1, 0, 0, 30)
    dropdownFrame.Position = UDim2.new(0, 0, 0, 25) 
    dropdownFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    dropdownFrame.BorderSizePixel = 0
    dropdownFrame.Text = ""
    dropdownFrame.AutoButtonColor = false
    dropdownFrame.Parent = dropdownContainer
    dropdownFrame.ZIndex = 3

    local dropdownCorner = Instance.new("UICorner")
    dropdownCorner.CornerRadius = UDim.new(0, 4)
    dropdownCorner.Parent = dropdownFrame

    local selectedOptionLabel = Instance.new("TextLabel")
    selectedOptionLabel.Name = "SelectedOption"
    selectedOptionLabel.Size = UDim2.new(1, -30, 1, 0) 
    selectedOptionLabel.Position = UDim2.new(0, 10, 0, 0) 
    selectedOptionLabel.Text = defaultOption or options[1] or "Select..." 
    selectedOptionLabel.Font = Enum.Font.GothamMedium
    selectedOptionLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
    selectedOptionLabel.TextSize = 14
    selectedOptionLabel.TextXAlignment = Enum.TextXAlignment.Left
    selectedOptionLabel.BackgroundTransparency = 1
    selectedOptionLabel.ZIndex = 4
    selectedOptionLabel.Parent = dropdownFrame

    local dropdownArrow = Instance.new("TextLabel")
    dropdownArrow.Name = "Arrow"
    dropdownArrow.Size = UDim2.new(0, 20, 1, 0)
    dropdownArrow.Position = UDim2.new(1, -25, 0, 0)
    dropdownArrow.Text = "▾"
    dropdownArrow.Font = Enum.Font.GothamMedium
    dropdownArrow.TextColor3 = Color3.fromRGB(230, 230, 230)
    dropdownArrow.TextSize = 16
    dropdownArrow.TextYAlignment = Enum.TextYAlignment.Center
    dropdownArrow.BackgroundTransparency = 1
    dropdownArrow.ZIndex = 4
    dropdownArrow.Parent = dropdownFrame

    local optionHeight = 28
    local maxVisibleOptions = 5
    local optionsFrameHeight = math.min(#options * optionHeight, maxVisibleOptions * optionHeight)
    local optionsFrameCanvasHeight = #options * optionHeight

    local optionsFrame = Instance.new("ScrollingFrame")
    optionsFrame.Name = "OptionsFrame"
    optionsFrame.Size = UDim2.new(1, 0, 0, 0) 
    optionsFrame.Position = UDim2.new(0, 0, 1, 3) 
    optionsFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    optionsFrame.BorderSizePixel = 1
    optionsFrame.BorderColor3 = Color3.fromRGB(60, 60, 65)
    optionsFrame.Visible = false
    optionsFrame.ZIndex = 10 
    optionsFrame.ClipsDescendants = true
    optionsFrame.CanvasSize = UDim2.new(0, 0, 0, optionsFrameCanvasHeight)
    optionsFrame.ScrollBarThickness = 4
    optionsFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 85)
    optionsFrame.Parent = dropdownContainer 

    local optionsCorner = Instance.new("UICorner")
    optionsCorner.CornerRadius = UDim.new(0, 4)
    optionsCorner.Parent = optionsFrame

    local optionButtons = {}
    local currentOption = defaultOption or options[1]

    for i, optionText in ipairs(options) do
        local optionButton = Instance.new("TextButton")
        optionButton.Name = optionText:gsub("%s+", "") .. "Option"
        optionButton.Size = UDim2.new(1, 0, 0, optionHeight)
        optionButton.Position = UDim2.new(0, 0, 0, (i-1) * optionHeight)
        optionButton.Text = "  " .. optionText -- Indent
        optionButton.Font = Enum.Font.GothamMedium
        optionButton.TextColor3 = Color3.fromRGB(230, 230, 230)
        optionButton.TextSize = 14
        optionButton.TextXAlignment = Enum.TextXAlignment.Left
        optionButton.BackgroundTransparency = 1
        optionButton.AutoButtonColor = false
        optionButton.ZIndex = 11
        optionButton.Parent = optionsFrame

        local hoverColor = Color3.fromRGB(60, 60, 65)
        optionButton.MouseEnter:Connect(function()
            optionButton.BackgroundColor3 = hoverColor
            optionButton.BackgroundTransparency = 0
        end)
        optionButton.MouseLeave:Connect(function()
            optionButton.BackgroundTransparency = 1
        end)

        optionButton.MouseButton1Click:Connect(function()
            if currentOption ~= optionText then
                currentOption = optionText
                selectedOptionLabel.Text = optionText
                if callback then
                    pcall(callback, optionText) 
                end
            end
            dropdownFrame:SendPropertyChangedSignal("MouseButton1Click") 
        end)
        optionButtons[optionText] = optionButton
    end

    local isOpen = false
    local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local closeConnection = nil

    local function closeDropdown()
        if not isOpen then return end
        isOpen = false
        dropdownArrow.Text = "▾"
        game:GetService("TweenService"):Create(optionsFrame, tweenInfo, {Size = UDim2.new(1, 0, 0, 0)}):Play()
        task.delay(tweenInfo.Time, function()
            if not isOpen then optionsFrame.Visible = false end 
        end)
        if closeConnection then
            closeConnection:Disconnect()
            closeConnection = nil
        end
    end

    local function openDropdown()
        if isOpen then return end
        isOpen = true
        optionsFrame.Visible = true 
        dropdownArrow.Text = "▴"
        game:GetService("TweenService"):Create(optionsFrame, tweenInfo, {Size = UDim2.new(1, 0, 0, optionsFrameHeight)}):Play()

        task.wait() 
        if closeConnection then closeConnection:Disconnect() end
        closeConnection = SharedEnvironment.Services.UserInputService.InputBegan:Connect(function(input)
             local clickPos = input.Position
             local buttonPos = dropdownFrame.AbsolutePosition
             local buttonSize = dropdownFrame.AbsoluteSize
             local optionsPos = optionsFrame.AbsolutePosition
             local optionsSize = optionsFrame.AbsoluteSize

             local clickedInButton = (clickPos.X >= buttonPos.X and clickPos.X <= buttonPos.X + buttonSize.X and
                                      clickPos.Y >= buttonPos.Y and clickPos.Y <= buttonPos.Y + buttonSize.Y)
             local clickedInOptions = (clickPos.X >= optionsPos.X and clickPos.X <= optionsPos.X + optionsSize.X and
                                       clickPos.Y >= optionsPos.Y and clickPos.Y <= optionsPos.Y + optionsSize.Y)

             if not clickedInButton and not clickedInOptions then
                 closeDropdown()
             end
        end)
    end

    dropdownFrame.MouseButton1Click:Connect(function()
        if isOpen then closeDropdown() else openDropdown() end
    end)

    if callback then pcall(callback, currentOption) end

    table.insert(uiElements, {type="dropdown", name=name, element=dropdownContainer, optionsFrame=optionsFrame, selectedLabel=selectedOptionLabel})
    currentY = currentY + dropdownContainer.Size.Y.Offset + elementSpacing
    return currentY
end

-- // Initialization Function \\ --
function module:init(env)
    SharedEnvironment = env

    local playerGui = SharedEnvironment.Player:WaitForChild("PlayerGui")
    local existingGui = playerGui:FindFirstChild("Drip X")
    if existingGui then
        warn("Drip X: Destroying existing GUI.")
        existingGui:Destroy()
    end

    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "Drip X"
    screenGui.Parent = playerGui
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling 

    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 350, 0, 500) 
    mainFrame.Position = UDim2.new(0, 20, 0, 20) 
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
    shadowFrame.BackgroundTransparency = 0.75
    shadowFrame.BorderSizePixel = 0
    shadowFrame.ZIndex = mainFrame.ZIndex - 1 
    shadowFrame.Parent = mainFrame

    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 32)
    titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame

    local title = Instance.new("TextLabel")
    title.Name = "TitleLabel"
    title.Size = UDim2.new(1, -40, 1, 0) 
    title.Text = " Drip X" 
    title.Font = Enum.Font.GothamSemibold
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 16
    title.BackgroundTransparency = 1
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Position = UDim2.new(0, 10, 0, 0)
    title.Parent = titleBar

    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 32, 1, 0) 
    closeButton.Position = UDim2.new(1, -32, 0, 0)
    closeButton.Text = "×"
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    closeButton.TextSize = 22
    closeButton.BackgroundTransparency = 1
    closeButton.BorderSizePixel = 0
    closeButton.AutoButtonColor = false
    closeButton.Parent = titleBar

    closeButton.MouseEnter:Connect(function() closeButton.TextColor3 = Color3.fromRGB(255, 80, 80); closeButton.BackgroundTransparency = 0.9 end)
    closeButton.MouseLeave:Connect(function() closeButton.TextColor3 = Color3.fromRGB(200, 200, 200); closeButton.BackgroundTransparency = 1 end)
    closeButton.MouseButton1Click:Connect(function()
        screenGui.Enabled = false
    end)

    contentFrame = Instance.new("ScrollingFrame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, 0, 1, -32)
    contentFrame.Position = UDim2.new(0, 0, 0, 32)
    contentFrame.BackgroundTransparency = 1
    contentFrame.ScrollBarThickness = 6
    contentFrame.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 70)
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, 1000) 
    contentFrame.BorderSizePixel = 0
    contentFrame.ScrollingDirection = Enum.ScrollingDirection.Y
    contentFrame.Parent = mainFrame

    local watermark = Instance.new("TextLabel")
    watermark.Name = "Watermark"
    watermark.Size = UDim2.new(0, 100, 0, 20)
    watermark.Position = UDim2.new(1, -105, 1, -25)
    watermark.Text = "Drip X"
    watermark.Font = Enum.Font.Gotham
    watermark.TextColor3 = Color3.fromRGB(150, 150, 150)
    watermark.TextSize = 12
    watermark.BackgroundTransparency = 1
    watermark.TextXAlignment = Enum.TextXAlignment.Right
    watermark.ZIndex = 5
    watermark.Parent = mainFrame

    return {
        createSection = createSection,
        createStyledButton = createStyledButton,
        createSlider = createSlider,
        createToggle = createToggle,
        createDropdown = createDropdown,
        getCurrentY = function() return currentY end,
        updateCanvasSize = function(newY)
             contentFrame.CanvasSize = UDim2.new(0, 0, 0, newY + 15)
             -- local targetHeight = math.max(300, math.min(600, newY + 32 + 15)) -- Min/Max height
             -- mainFrame.Size = UDim2.new(mainFrame.Size.X.Scale, mainFrame.Size.X.Offset, 0, targetHeight)
        end,
        showNotification = showNotification,
        getScreenGui = function() return screenGui end, 
        getElement = function(name) 
            for _, data in ipairs(uiElements) do
                if data.name == name then return data.element end
            end
            return nil
        end
    }
end

return module