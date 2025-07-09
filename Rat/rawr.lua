if game.PlaceId ~= 126884695634066 then 
    return 
end

if getgenv().ui then
    getgenv().ui:Destroy()
    getgenv().ui = nil
end

local players = game:GetService("Players")
local storage = game:GetService("ReplicatedStorage")
local input = game:GetService("UserInputService")
local tween = game:GetService("TweenService")
local run = game:GetService("RunService")
local http = game:GetService("HttpService")

local player = players.LocalPlayer
local mouse = player:GetMouse()

local running = true
local config = {
    idle = false,
    smart = true,
    notify = true,
}

local folder = "farmtool"
local file = folder .. "/config.json"
local isMobile = input.TouchEnabled and not input.KeyboardEnabled

local function save()
    if not isfolder(folder) then
        makefolder(folder)
    end
    writefile(file, http:JSONEncode(config))
end

local function load()
    if isfile(file) then
        local ok, data = pcall(function()
            return http:JSONDecode(readfile(file))
        end)
        if ok and data then
            for k, v in pairs(data) do
                config[k] = v
            end
        end
    end
end

load()

local function notify(title, text, time)
    if not config.notify then return end
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title or "Farm Helper",
        Text = text or "Done",
        Duration = time or 3
    })
end

local function createGui()
    local gui = Instance.new("ScreenGui")
    gui.Name = "ModernFarmHelper"
    gui.Parent = player.PlayerGui
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Main container with modern styling
    local main = Instance.new("Frame")
    main.Name = "MainFrame"
    main.Size = UDim2.new(0, 300, 0, 200)
    main.Position = UDim2.new(0.5, -150, 0.5, -100)
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
    
    -- Modern header
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
    
    -- Content area
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
        toggleSwitch.Parent = toggleFrame
        
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
            
            tween:Create(toggleSwitch, TweenInfo.new(0.2), {BackgroundColor3 = bgColor}):Play()
            tween:Create(switchKnob, TweenInfo.new(0.2), {Position = knobPos}):Play()
        end
        
        updateToggle()
        
        switchButton.MouseButton1Click:Connect(function()
            state = not state
            config[name] = state
            updateToggle()
            save()
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
            tween:Create(button, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(62, 185, 96)}):Play()
        end)
        
        button.MouseLeave:Connect(function()
            tween:Create(button, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(52, 168, 83)}):Play()
        end)
        
        button.MouseButton1Click:Connect(callback)
        
        return button
    end
    
    -- Create UI elements
    createToggle("idle", "Auto Idle", 1)
    createToggle("smart", "Smart Mode", 2)
    createButton("clear", "Clear Sprinklers", 3, function()
        clearSprinklers()
    end)
    createToggle("notify", "Notifications", 4)
    
    -- Close button functionality
    closeBtn.MouseButton1Click:Connect(function()
        running = false
        gui:Destroy()
    end)
    
    -- Close button hover effect
    closeBtn.MouseEnter:Connect(function()
        tween:Create(closeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(255, 89, 89)}):Play()
    end)
    
    closeBtn.MouseLeave:Connect(function()
        tween:Create(closeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(255, 69, 69)}):Play()
    end)
    
    -- Dragging functionality
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
        end
    end)
    
    input.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    input.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    -- Toggle visibility
    input.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Insert then
            main.Visible = not main.Visible
        end
    end)
    
    return gui
end

local function findGarden()
    local farm = workspace:FindFirstChild("Farm")
    if not farm then return nil end
    
    for _, plot in pairs(farm:GetChildren()) do
        if plot:FindFirstChild("Important") and 
           plot.Important:FindFirstChild("Data") and 
           plot.Important.Data:FindFirstChild("Owner") and
           plot.Important.Data.Owner.Value == player.Name then
            return plot
        end
    end
    return nil
end

function clearSprinklers()
    local char = player.Character
    if not char then
        notify("Error", "Character not found")
        return
    end
    
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then
        notify("Error", "Humanoid not found")
        return
    end
    
    local backpack = player:FindFirstChild("Backpack")
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
    
    if shovel.Parent == backpack then
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
        notify("Error", "No objects found")
        return 
    end
    
    local gameEvents = storage:FindFirstChild("GameEvents")
    if not gameEvents then
        notify("Error", "Game events not found")
        return
    end
    
    local deleteEvent = gameEvents:FindFirstChild("DeleteObject")
    if not deleteEvent then
        notify("Error", "Delete event not found")
        return
    end
    
    local count = 0
    
    for _, obj in pairs(objects:GetChildren()) do
        if obj:IsA("Model") and obj.Name and obj.Name:find("Sprinkler") then
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
    
    -- Put shovel back
    if char:FindFirstChild("Shovel [Destroy Plants]") then
        char:FindFirstChild("Shovel [Destroy Plants]").Parent = backpack
    end
end

local function handleIdle()
    if not config.idle then return end
    
    local gameEvents = storage:FindFirstChild("GameEvents")
    if not gameEvents then return end
    
    local getCooldown = gameEvents:FindFirstChild("GetPetCooldown")
    if not getCooldown then return end
    
    local modules = storage:FindFirstChild("Modules")
    if not modules then return end
    
    local petServices = modules:FindFirstChild("PetServices")
    if not petServices then return end
    
    local petActionUI = petServices:FindFirstChild("PetActionUserInterfaceService")
    if not petActionUI then return end
    
    local petHandlers = petActionUI:FindFirstChild("PetActionsHandlers")
    if not petHandlers then return end
    
    local idleHandler = petHandlers:FindFirstChild("Idle")
    if not idleHandler then return end
    
    local success, handler = pcall(require, idleHandler)
    if not success or not handler then return end
    
    local petsPhysical = workspace:FindFirstChild("PetsPhysical")
    if not petsPhysical then return end
    
    for _, pet in pairs(petsPhysical:GetChildren()) do
        if pet.Name == "PetMover" and pet:IsA("BasePart") then
            local uuid = pet:GetAttribute("UUID")
            if uuid then
                local model = pet:FindFirstChild(uuid)
                if model and model:IsA("Model") then
                    local skin = model:GetAttribute("CurrentSkin")
                    
                    -- Always idle Moon Cat
                    if skin == "Moon Cat" then
                        pcall(function()
                            task.spawn(handler.Activate, pet)
                        end)
                    end
                    
                    -- Smart mode for other pets
                    if config.smart and not skin then
                        local ok, cooldowns = pcall(getCooldown.InvokeServer, getCooldown, uuid)
                        if ok and type(cooldowns) == "table" then
                            for _, cd in pairs(cooldowns) do
                                if cd and cd.Time then
                                    local time = tonumber(cd.Time)
                                    if time and time >= 78 and time <= 82 then
                                        pcall(function()
                                            task.spawn(handler.Activate, pet)
                                        end)
                                        notify("Auto Idle", "Activated - " .. math.floor(time) .. "s")
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
end

-- Main loop
task.spawn(function()
    while running do
        if config.idle then
            pcall(handleIdle)
        end
        task.wait(1)
    end
end)

local gui = createGui()
getgenv().ui = gui

notify("Farm Helper", isMobile and "Touch to interact" or "Press Insert to toggle")

getgenv().ui = {
    gui = gui,
    Destroy = function()
        running = false
        if gui then gui:Destroy() end
    end
}