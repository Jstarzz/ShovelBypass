--// Game Place ID Check
if game.PlaceId ~= 126884695634066 then
    return
end

--// Unload existing UI if any (from previous runs of this script)
if getgenv().ui then
    getgenv().ui:Destroy()
    getgenv().ui = nil
end

--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer

--// Runtime Control
local running = true -- Controls the main loops for auto-idle
local uiActive = true -- Controls the UI loops (used for unload)

--// Configuration and Defaults
local config = {
    AutoIdle = false,         -- Single toggle for all auto-idling
    Notifications = true,
}

local configFolder = "grangrant"
local configFile = configFolder .. "/config.json"

--// Save/Load Functions
local function saveConfig()
    if not isfolder(configFolder) then
        makefolder(configFolder)
    end
    writefile(configFile, HttpService:JSONEncode(config))
end

local function loadConfig()
    if isfile(configFile) then
        local ok, data = pcall(function()
            return HttpService:JSONDecode(readfile(configFile))
        end)
        if ok and data then
            for k, v in pairs(data) do
                if config[k] ~= nil then
                    config[k] = v
                end
            end
        end
    end
    for k, v in pairs(config) do
        if rawget(config, k) == nil then
            config[k] = v
        end
    end
end

loadConfig()

--// Notification Function
local function notify(title, text, time)
    if not config.Notifications then return end

    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title or "Farm Helper",
        Text = text or "Done",
        Duration = time or 3
    })
end

--// UI Creation Function
local function createGui()
    local gui = Instance.new("ScreenGui")
    gui.Name = "ModernFarmHelper"
    gui.Parent = Player.PlayerGui
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Main container with modern styling
    local main = Instance.new("Frame")
    main.Name = "MainFrame"
    main.Size = UDim2.new(0, 300, 0, 220)
    main.Position = UDim2.new(0.5, -150, 0.5, -110)
    main.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
    main.BorderSizePixel = 0
    main.Parent = gui

    -- Soft rounded corners
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 16)
    mainCorner.Parent = main

    -- Subtle gradient
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(22, 22, 26)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 18, 20))
    }
    gradient.Rotation = 45
    gradient.Parent = main

    -- Modern header (draggable area)
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 50)
    header.Position = UDim2.new(0, 0, 0, 0)
    header.BackgroundTransparency = 1
    header.Parent = main

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -80, 1, 0)
    title.Position = UDim2.new(0, 20, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Farm Helper"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Font = Enum.Font.GothamBold
    title.Parent = header

    -- Modern close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseButton"
    closeBtn.Size = UDim2.new(0, 32, 0, 32)
    closeBtn.Position = UDim2.new(1, -45, 0, 9)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 69, 69)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 18
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = header

    local closeBtnCorner = Instance.new("UICorner")
    closeBtnCorner.CornerRadius = UDim.new(0, 8)
    closeBtnCorner.Parent = closeBtn

    -- Minimized button (now main toggle for min/max)
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Name = "MinimizeButton"
    minimizeBtn.Size = UDim2.new(0, UserInputService.TouchEnabled and 60 or 50, 0, UserInputService.TouchEnabled and 60 or 50)
    minimizeBtn.Position = UDim2.new(0.05, -minimizeBtn.Size.X.Offset / 2, 0.4, -minimizeBtn.Size.Y.Offset / 2)
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(52, 168, 83)
    minimizeBtn.BorderSizePixel = 0
    minimizeBtn.Text = UserInputService.TouchEnabled and "🐀" or "🌾"
    minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minimizeBtn.TextSize = UserInputService.TouchEnabled and 30 or 24
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.Parent = gui
    minimizeBtn.Visible = false

    local minimizeBtnCorner = Instance.new("UICorner")
    minimizeBtnCorner.CornerRadius = UDim.new(0.5, 0)
    minimizeBtnCorner.Parent = minimizeBtn

    -- Add shadow effect to floating button
    local shadow = Instance.new("Frame")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 6, 1, 6)
    shadow.Position = UDim2.new(0, -3, 0, -3)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.8
    shadow.BorderSizePixel = 0
    shadow.ZIndex = minimizeBtn.ZIndex - 1
    shadow.Parent = minimizeBtn

    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(0.5, 0)
    shadowCorner.Parent = shadow

    -- Content area for toggles and buttons
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -24, 1, -70)
    content.Position = UDim2.new(0, 12, 0, 58)
    content.BackgroundTransparency = 1
    content.Parent = main

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Padding = UDim.new(0, 12)
    contentLayout.Parent = content

    -- Modern toggle function
    local function createToggle(name, text, order)
        local toggleFrame = Instance.new("Frame")
        toggleFrame.Name = name .. "Toggle"
        toggleFrame.Size = UDim2.new(1, 0, 0, 36)
        toggleFrame.BackgroundColor3 = Color3.fromRGB(26, 26, 30)
        toggleFrame.BorderSizePixel = 0
        toggleFrame.Parent = content
        toggleFrame.LayoutOrder = order

        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(0, 10)
        toggleCorner.Parent = toggleFrame

        local toggleLabel = Instance.new("TextLabel")
        toggleLabel.Size = UDim2.new(1, -60, 1, 0)
        toggleLabel.Position = UDim2.new(0, 16, 0, 0)
        toggleLabel.BackgroundTransparency = 1
        toggleLabel.Text = text
        toggleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
        toggleLabel.TextSize = 14
        toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
        toggleLabel.Font = Enum.Font.Gotham
        toggleLabel.Parent = toggleFrame

        local toggleSwitch = Instance.new("Frame")
        toggleSwitch.Size = UDim2.new(0, 44, 0, 24)
        toggleSwitch.Position = UDim2.new(1, -56, 0.5, -12)
        toggleSwitch.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
        toggleSwitch.BorderSizePixel = 0
        toggleSwitch.Parent = toggleSwitch

        local switchCorner = Instance.new("UICorner")
        switchCorner.CornerRadius = UDim.new(0, 12)
        switchCorner.Parent = toggleSwitch

        local switchKnob = Instance.new("Frame")
        switchKnob.Size = UDim2.new(0, 18, 0, 18)
        switchKnob.Position = UDim2.new(0, 3, 0.5, -9)
        switchKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        switchKnob.BorderSizePixel = 0
        switchKnob.Parent = toggleSwitch

        local knobCorner = Instance.new("UICorner")
        knobCorner.CornerRadius = UDim.new(0, 9)
        knobCorner.Parent = switchKnob

        local switchButton = Instance.new("TextButton")
        switchButton.Size = UDim2.new(1, 0, 1, 0)
        switchButton.Position = UDim2.new(0, 0, 0, 0)
        switchButton.BackgroundTransparency = 1
        switchButton.Text = ""
        switchButton.Parent = toggleSwitch

        local state = config[name] or false

        local function updateToggle()
            local bgColor = state and Color3.fromRGB(52, 168, 83) or Color3.fromRGB(60, 60, 65)
            local knobPos = state and UDim2.new(0, 23, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)

            TweenService:Create(toggleSwitch, TweenInfo.new(0.2), {BackgroundColor3 = bgColor}):Play()
            TweenService:Create(switchKnob, TweenInfo.new(0.2), {Position = knobPos}):Play()
        end

        updateToggle()

        switchButton.MouseButton1Click:Connect(function()
            state = not state
            config[name] = state
            updateToggle()
            saveConfig()
            notify("Settings", text .. " " .. (state and "enabled" or "disabled"))
        end)

        return toggleFrame
    end

    -- Modern button function
    local function createButton(name, text, order, callback)
        local button = Instance.new("TextButton")
        button.Name = name .. "Button"
        button.Size = UDim2.new(1, 0, 0, 36)
        button.BackgroundColor3 = Color3.fromRGB(52, 168, 83)
        button.BorderSizePixel = 0
        button.Text = text
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextSize = 14
        button.Font = Enum.Font.GothamBold
        button.Parent = content
        button.LayoutOrder = order

        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 10)
        buttonCorner.Parent = button

        button.MouseEnter:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(62, 185, 96)}):Play()
        end)

        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(52, 168, 83)}):Play()
        end)

        button.MouseButton1Click:Connect(callback)

        return button
    end

    -- Create UI elements
    createToggle("AutoIdle", "Auto Idle", 1)
    createToggle("Notifications", "Notifications", 2)
    createButton("clear", "Clear Sprinklers", 3, function()
        clearSprinklers()
    end)

    local isMinimized = false

    -- Minimize/Restore functionality
    local function toggleMinimize()
        isMinimized = not isMinimized

        if isMinimized then
            TweenService:Create(main, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
                Size = UDim2.new(0, 0, 0, 0)
            }):Play()

            task.wait(0.3)
            main.Visible = false
            minimizeBtn.Visible = true

            TweenService:Create(minimizeBtn, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
                BackgroundTransparency = 0
            }):Play()
        else
            TweenService:Create(minimizeBtn, TweenInfo.new(0.2), {
                BackgroundTransparency = 1
            }):Play()

            task.wait(0.2)
            minimizeBtn.Visible = false
            main.Visible = true

            main.Size = UDim2.new(0, 0, 0, 0)
            TweenService:Create(main, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
                Size = UDim2.new(0, 300, 0, 220)
            }):Play()
        end
    end

    -- Close button functionality
    closeBtn.MouseButton1Click:Connect(function()
        running = false
        uiActive = false
        gui:Destroy()
    end)

    -- Minimize button on the main UI
    local headerMinimizeBtn = Instance.new("TextButton")
    headerMinimizeBtn.Name = "MinimizeButton"
    headerMinimizeBtn.Size = UDim2.new(0, 32, 0, 32)
    headerMinimizeBtn.Position = UDim2.new(1, -82, 0, 9)
    headerMinimizeBtn.BackgroundColor3 = Color3.fromRGB(255, 193, 7)
    headerMinimizeBtn.BorderSizePixel = 0
    headerMinimizeBtn.Text = "—"
    headerMinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    headerMinimizeBtn.TextSize = 18
    headerMinimizeBtn.Font = Enum.Font.GothamBold
    headerMinimizeBtn.Parent = header
    
    local headerMinimizeBtnCorner = Instance.new("UICorner")
    headerMinimizeBtnCorner.CornerRadius = UDim.new(0, 8)
    headerMinimizeBtnCorner.Parent = headerMinimizeBtn

    headerMinimizeBtn.MouseButton1Click:Connect(toggleMinimize)

    -- Button hover effects for close and minimize on main UI
    closeBtn.MouseEnter:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(255, 89, 89)}):Play()
    end)

    closeBtn.MouseLeave:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(255, 69, 69)}):Play()
    end)

    headerMinimizeBtn.MouseEnter:Connect(function()
        TweenService:Create(headerMinimizeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(255, 213, 47)}):Play()
    end)

    headerMinimizeBtn.MouseLeave:Connect(function()
        TweenService:Create(headerMinimizeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(255, 193, 7)}):Play()
    end)

    -- **REFINED DRAGGING FUNCTIONALITY FOR MAIN FRAME**
    local mainIsDragging = false
    local mainDragStartPos = Vector2.new() -- Stores the initial mouse/touch position
    local mainInitialUIPos = UDim2.new()   -- Stores the UI's position when drag starts

    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            mainIsDragging = true
            mainDragStartPos = input.Position
            mainInitialUIPos = main.Position

            local inputEndedConn = UserInputService.InputEnded:Connect(function(endedInput)
                if endedInput.UserInputType == Enum.UserInputType.MouseButton1 or endedInput.UserInputType == Enum.UserInputType.Touch then
                    mainIsDragging = false
                    inputEndedConn:Disconnect() -- Disconnect this specific connection
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if mainIsDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - mainDragStartPos
            main.Position = UDim2.new(mainInitialUIPos.X.Scale, mainInitialUIPos.X.Offset + delta.X,
                                       mainInitialUIPos.Y.Scale, mainInitialUIPos.Y.Offset + delta.Y)
        end
    end)

    -- **REFINED DRAGGING FUNCTIONALITY FOR MINIMIZED BUTTON**
    local minimizeIsDragging = false
    local minimizeDragStartPos = Vector2.new()
    local minimizeInitialUIPos = UDim2.new()

    minimizeBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            minimizeIsDragging = true
            minimizeDragStartPos = input.Position
            minimizeInitialUIPos = minimizeBtn.Position

            local inputEndedConn = UserInputService.InputEnded:Connect(function(endedInput)
                if endedInput.UserInputType == Enum.UserInputType.MouseButton1 or endedInput.UserInputType == Enum.UserInputType.Touch then
                    minimizeIsDragging = false
                    inputEndedConn:Disconnect()
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if minimizeIsDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - minimizeDragStartPos
            minimizeBtn.Position = UDim2.new(minimizeInitialUIPos.X.Scale, minimizeInitialUIPos.X.Offset + delta.X,
                                              minimizeInitialUIPos.Y.Scale, minimizeInitialUIPos.Y.Offset + delta.Y)
        end
    end)

    -- Toggle visibility with Insert key
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Insert then
            toggleMinimize()
        end
    end)

    return gui
end

--// Clear Sprinklers Function (Same as before)
local function findGarden()
    local farm = workspace:FindFirstChild("Farm")
    if not farm then return nil end

    for _, plot in pairs(farm:GetChildren()) do
        if plot:FindFirstChild("Important") and
            plot.Important:FindFirstChild("Data") and
            plot.Important.Data:FindFirstChild("Owner") and
            plot.Important.Data.Owner.Value == Player.Name then
            return plot
        end
    end
    return nil
end

function clearSprinklers()
    local char = Player.Character
    if not char then
        notify("Error", "Character not found")
        return
    end

    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        notify("Error", "Humanoid not found")
        return
    end

    local backpack = Player:FindFirstChild("Backpack")
    if not backpack then
        notify("Error", "Backpack not found")
        return
    end

    local shovel = char:FindFirstChild("Shovel [Destroy Plants]") or
                     backpack:FindFirstChild("Shovel [Destroy Plants]")

    if not shovel then
        notify("Error", "Shovel not found")
        return
    end

    local equippedTool = humanoid.EquippedTool
    if equippedTool ~= shovel then
        shovel.Parent = char
        humanoid:EquipTool(shovel)
        task.wait(0.4)
    end

    local garden = findGarden()
    if not garden then
        notify("Error", "Garden not found")
        return
    end

    local objects = garden.Important:FindFirstChild("Objects_Physical")
    if not objects then
        notify("Error", "No objects found in garden")
        return
    end

    local gameEvents = ReplicatedStorage:WaitForChild("GameEvents")
    if not gameEvents then
        notify("Error", "Game events not found")
        return
    end

    local deleteEvent = gameEvents:WaitForChild("DeleteObject")
    if not deleteEvent then
        notify("Error", "Delete event not found")
        return
    end

    local count = 0

    for _, obj in pairs(objects:GetChildren()) do
        if obj:IsA("Model") and obj.Name and string.find(obj.Name, "Sprinkler") then
            local success = pcall(function()
                deleteEvent:FireServer(obj)
            end)
            if success then
                count = count + 1
            end
            task.wait(0.1)
        end
    end

    notify("Success", count .. " sprinklers cleared")

    if equippedTool ~= shovel and char:FindFirstChild("Shovel [Destroy Plants]") then
        char:FindFirstChild("Shovel [Destroy Plants]").Parent = backpack
    end
end

--// Pet Idle Handler (Same as before)
local GetPetCooldown
local IdleHandler

task.spawn(function()
    GetPetCooldown = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("GetPetCooldown")
    IdleHandler = require(ReplicatedStorage.Modules.PetServices.PetActionUserInterfaceService.PetActionsHandlers.Idle)

    while running do
        if not uiActive then task.wait(1) continue end

        if config.AutoIdle then
            local petsPhysical = workspace:FindFirstChild("PetsPhysical")
            if petsPhysical then
                for _, petMover in ipairs(petsPhysical:GetChildren()) do
                    if petMover:IsA("BasePart") and petMover.Name == "PetMover" then
                        local uuid = petMover:GetAttribute("UUID")
                        local petModel = uuid and petMover:FindFirstChild(uuid)

                        if petModel and petModel:IsA("Model") then
                            local currentSkin = petModel:GetAttribute("CurrentSkin")

                            if currentSkin == "Moon Cat" or currentSkin == "Triceratops" then
                                task.spawn(IdleHandler.Activate, petMover)
                            elseif not currentSkin then
                                local ok, cooldowns = pcall(GetPetCooldown.InvokeServer, GetPetCooldown, uuid)
                                if ok and typeof(cooldowns) == "table" then
                                    for _, cd in ipairs(cooldowns) do
                                        local time = tonumber(cd.Time)
                                        if time and time >= 79 and time <= 81 then
                                            notify({
                                                Title = "Auto Idle",
                                                Description = "True",
                                                Time = 3,
                                            })
                                            task.spawn(IdleHandler.Activate, petMover)
                                            break
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        task.wait(1)
    end
end)

--// Initialize UI and expose to global
local gui = createGui()
getgenv().ui = gui

getgenv().ui = {
    gui = gui,
    Destroy = function()
        running = false
        uiActive = false
        if gui then gui:Destroy() end
    end
}

notify("Farm Helper", UserInputService.TouchEnabled and "Touch to interact" or "Press Insert to toggle")