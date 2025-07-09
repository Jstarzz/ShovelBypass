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
    AutoIdleToggle = false,
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

--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Modules & Remotes
local GetPetCooldown = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("GetPetCooldown")
local IdleHandler = require(ReplicatedStorage.Modules.PetServices.PetActionUserInterfaceService.PetActionsHandlers.Idle)

--// Runtime Variables
getgenv().AutoIdle = false
getgenv().AutoIdleToggle = config.AutoIdleToggle or false

local function createGui()
    local gui = Instance.new("ScreenGui")
    gui.Name = "ModernFarmHelper"
    gui.Parent = player.PlayerGui
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Main container
    local main = Instance.new("Frame")
    main.Name = "MainFrame"
    main.Size = UDim2.new(0, 300, 0, 220)
    main.Position = UDim2.new(0.5, -150, 0.5, -110)
    main.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
    main.BorderSizePixel = 0
    main.Parent = gui

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 16)
    mainCorner.Parent = main

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(22, 22, 26)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 18, 20))
    }
    gradient.Rotation = 45
    gradient.Parent = main

    -- Header
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

    -- Close button
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

    -- Minimize button
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Name = "MinimizeButton"
    minimizeBtn.Size = UDim2.new(0, 32, 0, 32)
    minimizeBtn.Position = UDim2.new(1, -82, 0, 9)
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(255, 193, 7)
    minimizeBtn.BorderSizePixel = 0
    minimizeBtn.Text = "—"
    minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minimizeBtn.TextSize = 18
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.Parent = header

    local minimizeBtnCorner = Instance.new("UICorner")
    minimizeBtnCorner.CornerRadius = UDim.new(0, 8)
    minimizeBtnCorner.Parent = minimizeBtn

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

    -- Toggle function
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
            getgenv().AutoIdleToggle = state
            updateToggle()
            save()
            notify("Settings", text .. " " .. (state and "enabled" or "disabled"))
            if not state then
                getgenv().AutoIdle = false
            end
        end)

        return toggleFrame
    end

    -- Button function
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
    createToggle("AutoIdleToggle", "Auto Idle", 1)
    createToggle("notify", "Notifications", 2)
    createButton("shovel", "Shovel Sprinkler", 3, function()
        local Players = game:GetService("Players")
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local player = Players.LocalPlayer

        local character, backpack = player.Character or player.CharacterAdded:Wait(), player:WaitForChild("Backpack")
        local DeleteObject = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("DeleteObject")

        local function EquipShovel()
            local equippedTool = character:FindFirstChildWhichIsA("Tool")
            if equippedTool and equippedTool.Name == "Shovel [Destroy Plants]" then
                return true
            end
            local shovel = character:FindFirstChild("Shovel [Destroy Plants]") or backpack:FindFirstChild("Shovel [Destroy Plants]")
            if shovel then
                shovel.Parent = character
                player.Character.Humanoid:EquipTool(shovel)
                return true
            end
            return false
        end

        local function UnequipShovel()
            local equippedTool = character:FindFirstChildWhichIsA("Tool")
            if equippedTool and equippedTool.Name == "Shovel [Destroy Plants]" then
                equippedTool.Parent = backpack
            end
        end

        local garden
        for _, plot in pairs(workspace.Farm:GetChildren()) do
            if plot:FindFirstChild("Important")
                and plot.Important:FindFirstChild("Data")
                and plot.Important.Data.Owner.Value == player.Name then
                garden = plot
                break
            end
        end
        if not garden then 
            notify("Error", "Garden not found")
            return 
        end

        if not EquipShovel() then 
            notify("Error", "Shovel not found")
            return 
        end

        local objectsFolder = garden.Important:FindFirstChild("Objects_Physical")
        if not objectsFolder then 
            notify("Error", "No objects found")
            return 
        end

        for _, model in ipairs(objectsFolder:GetChildren()) do
            if model:IsA("Model") and string.find(model.Name, "Sprinkler") then
                DeleteObject:FireServer(model)
                task.wait(0.2)
            end
        end

        UnequipShovel()
        notify("Success", "Sprinklers cleared")
    end)

    -- Floating toggle button (minimized state)
    local floatingBtn = Instance.new("TextButton")
    floatingBtn.Name = "FloatingButton"
    floatingBtn.Size = UDim2.new(0, isMobile and 60 or 50, 0, isMobile and 60 or 50)
    floatingBtn.Position = UDim2.new(0, 20, 0.4, 0) -- Left side, slightly above center
    floatingBtn.BackgroundColor3 = Color3.fromRGB(52, 168, 83)
    floatingBtn.BorderSizePixel = 0
    floatingBtn.Text = isMobile and "🐀" or "🌾"
    floatingBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    floatingBtn.TextSize = isMobile and 30 or 24
    floatingBtn.Font = Enum.Font.GothamBold
    floatingBtn.Parent = gui
    floatingBtn.Visible = false

    local floatingBtnCorner = Instance.new("UICorner")
    floatingBtnCorner.CornerRadius = UDim.new(0.5, 0)
    floatingBtnCorner.Parent = floatingBtn

    -- Shadow effect
    local shadow = Instance.new("Frame")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 6, 1, 6)
    shadow.Position = UDim2.new(0, -3, 0, -3)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.8
    shadow.BorderSizePixel = 0
    shadow.ZIndex = floatingBtn.ZIndex - 1
    shadow.Parent = floatingBtn

    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(0.5, 0)
    shadowCorner.Parent = shadow

    local isMinimized = false

    -- Minimize/Restore functionality
    local function toggleMinimize()
        isMinimized = not isMinimized

        if isMinimized then
            tween:Create(main, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
                Size = UDim2.new(0, 0, 0, 0)
            }):Play()

            task.wait(0.3)
            main.Visible = false
            floatingBtn.Visible = true

            floatingBtn.Size = UDim2.new(0, 0, 0, 0)
            tween:Create(floatingBtn, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
                Size = UDim2.new(0, isMobile and 60 or 50, 0, isMobile and 60 or 50)
            }):Play()
        else
            tween:Create(floatingBtn, TweenInfo.new(0.2), {
                Size = UDim2.new(0, 0, 0, 0)
            }):Play()

            task.wait(0.2)
            floatingBtn.Visible = false
            main.Visible = true

            main.Size = UDim2.new(0, 0, 0, 0)
            tween:Create(main, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
                Size = UDim2.new(0, 300, 0, 220)
            }):Play()
        end
    end

    -- Close button
    closeBtn.MouseButton1Click:Connect(function()
        running = false
        gui:Destroy()
    end)

    -- Minimize button
    minimizeBtn.MouseButton1Click:Connect(toggleMinimize)

    -- Floating button
    floatingBtn.MouseButton1Click:Connect(toggleMinimize)

    -- Button hover effects
    closeBtn.MouseEnter:Connect(function()
        tween:Create(closeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(255, 89, 89)}):Play()
    end)

    closeBtn.MouseLeave:Connect(function()
        tween:Create(closeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(255, 69, 69)}):Play()
    end)

    minimizeBtn.MouseEnter:Connect(function()
        tween:Create(minimizeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(255, 213, 47)}):Play()
    end)

    minimizeBtn.MouseLeave:Connect(function()
        tween:Create(minimizeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(255, 193, 7)}):Play()
    end)

    floatingBtn.MouseEnter:Connect(function()
        tween:Create(floatingBtn, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(62, 185, 96),
            Size = UDim2.new(0, isMobile and 65 or 55, 0, isMobile and 65 or 55)
        }):Play()
    end)

    floatingBtn.MouseLeave:Connect(function()
        tween:Create(floatingBtn, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(52, 168, 83),
            Size = UDim2.new(0, isMobile and 60 or 50, 0, isMobile and 60 or 50)
        }):Play()
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

    -- Toggle visibility with Insert key
    input.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Insert then
            if isMinimized then
                toggleMinimize()
            else
                main.Visible = not main.Visible
            end
        end
    end)

    return gui
end

--// Auto Idle for Moon Cats
task.spawn(function()
    while running do
        if getgenv().AutoIdle then
            for _, v in ipairs(workspace.PetsPhysical:GetChildren()) do
                if v:IsA("BasePart") and v.Name == "PetMover" then
                    local model = v:FindFirstChild(v:GetAttribute("UUID"))
                    if model and model:IsA("Model") and model:GetAttribute("CurrentSkin") == "Moon Cat" then
                        task.spawn(IdleHandler.Activate, v)
                    end
                end
            end
        end
        task.wait()
    end
end)

--// Echo Frog detection
task.spawn(function()
    while running do
        if getgenv().AutoIdleToggle then 
            for _, v in ipairs(workspace.PetsPhysical:GetChildren()) do
                if v:IsA("BasePart") and v.Name == "PetMover" then
                    local uuid = v:GetAttribute("UUID")
                    local model = uuid and v:FindFirstChild(uuid)

                    if model and model:IsA("Model") and model:GetAttribute("CurrentSkin") == nil then
                        local ok, cooldowns = pcall(GetPetCooldown.InvokeServer, GetPetCooldown, uuid)
                        if ok and typeof(cooldowns) == "table" then
                            for _, cd in ipairs(cooldowns) do
                                local time = tonumber(cd.Time)
                                if time and time >= 79 and time <= 81 and not getgenv().AutoIdle then
                                    notify("Auto Idle", "True")
                                    getgenv().AutoIdle = true
                                    task.delay(10, function()
                                        getgenv().AutoIdle = false
                                        notify("Auto Idle", "False")
                                    end)
                                    break
                                end
                            end
                        end
                    end
                end
            end
        else
            getgenv().AutoIdle = false
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