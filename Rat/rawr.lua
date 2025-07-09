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
    shovel = false,
    notify = true,
    theme = "dark"
}

local folder = "farmtool"
local file = folder .. "/config.json"

-- Mobile detection
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
        Title = title or "farm",
        Text = text or "done",
        Duration = time or 2
    })
end

local function createGui()
    local gui = Instance.new("ScreenGui")
    gui.Name = "farm"
    gui.Parent = player.PlayerGui
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Mobile-responsive sizing
    local screenSize = workspace.CurrentCamera.ViewportSize
    local isSmallScreen = screenSize.X < 800 or screenSize.Y < 600
    
    local mainWidth = isMobile and (isSmallScreen and 320 or 360) or 380
    local mainHeight = isMobile and (isSmallScreen and 240 or 280) or 300
    
    local main = Instance.new("Frame")
    main.Name = "main"
    main.Size = UDim2.new(0, mainWidth, 0, mainHeight)
    main.Position = UDim2.new(0.5, -mainWidth/2, 0.5, -mainHeight/2)
    main.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    main.BorderSizePixel = 0
    main.Parent = gui
    main.ZIndex = 10
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = main
    
    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 35)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 30))
    }
    grad.Rotation = 90
    grad.Parent = main
    
    local top = Instance.new("Frame")
    top.Name = "top"
    top.Size = UDim2.new(1, 0, 0, isMobile and 40 or 35)
    top.Position = UDim2.new(0, 0, 0, 0)
    top.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    top.BorderSizePixel = 0
    top.Parent = main
    top.ZIndex = 11
    
    local topCorner = Instance.new("UICorner")
    topCorner.CornerRadius = UDim.new(0, 8)
    topCorner.Parent = top
    
    local title = Instance.new("TextLabel")
    title.Name = "title"
    title.Size = UDim2.new(1, -70, 1, 0)
    title.Position = UDim2.new(0, 12, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "farm helper"
    title.TextColor3 = Color3.fromRGB(200, 200, 200)
    title.TextScaled = true
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Font = Enum.Font.Gotham
    title.Parent = top
    title.ZIndex = 12
    
    local minimize = Instance.new("TextButton")
    minimize.Name = "minimize"
    minimize.Size = UDim2.new(0, isMobile and 30 or 25, 0, isMobile and 30 or 25)
    minimize.Position = UDim2.new(1, isMobile and -67 or -62, 0, isMobile and 5 or 5)
    minimize.BackgroundColor3 = Color3.fromRGB(80, 120, 180)
    minimize.BorderSizePixel = 0
    minimize.Text = "-"
    minimize.TextColor3 = Color3.fromRGB(255, 255, 255)
    minimize.TextScaled = true
    minimize.Font = Enum.Font.Gotham
    minimize.Parent = top
    minimize.ZIndex = 12
    
    local minimizeCorner = Instance.new("UICorner")
    minimizeCorner.CornerRadius = UDim.new(0, 4)
    minimizeCorner.Parent = minimize
    
    local close = Instance.new("TextButton")
    close.Name = "close"
    close.Size = UDim2.new(0, isMobile and 30 or 25, 0, isMobile and 30 or 25)
    close.Position = UDim2.new(1, isMobile and -32 or -32, 0, isMobile and 5 or 5)
    close.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
    close.BorderSizePixel = 0
    close.Text = "×"
    close.TextColor3 = Color3.fromRGB(255, 255, 255)
    close.TextScaled = true
    close.Font = Enum.Font.Gotham
    close.Parent = top
    close.ZIndex = 12
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 4)
    closeCorner.Parent = close
    
    local content = Instance.new("Frame")
    content.Name = "content"
    content.Size = UDim2.new(1, -16, 1, -(isMobile and 50 or 45))
    content.Position = UDim2.new(0, 8, 0, isMobile and 45 or 40)
    content.BackgroundTransparency = 1
    content.Parent = main
    content.ZIndex = 11
    
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollFrame.Position = UDim2.new(0, 0, 0, 0)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = isMobile and 8 or 6
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    scrollFrame.Parent = content
    scrollFrame.ZIndex = 11
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)
    layout.Parent = scrollFrame
    
    local function updateScrollFrameSize()
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
    end
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateScrollFrameSize)
    
    local function makeToggle(name, text, layoutOrder, callback)
        local toggle = Instance.new("Frame")
        toggle.Name = name
        toggle.Size = UDim2.new(1, -10, 0, isMobile and 45 or 38)
        toggle.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        toggle.BorderSizePixel = 0
        toggle.Parent = scrollFrame
        toggle.LayoutOrder = layoutOrder
        toggle.ZIndex = 12
        
        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(0, 6)
        toggleCorner.Parent = toggle
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -60, 1, 0)
        label.Position = UDim2.new(0, 12, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(180, 180, 180)
        label.TextScaled = true
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Gotham
        label.Parent = toggle
        label.ZIndex = 13
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, isMobile and 45 or 35, 0, isMobile and 25 or 20)
        btn.Position = UDim2.new(1, isMobile and -52 or -42, 0.5, isMobile and -12.5 or -10)
        btn.BackgroundColor3 = Color3.fromRGB(180, 80, 80)
        btn.BorderSizePixel = 0
        btn.Text = "off"
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextScaled = true
        btn.Font = Enum.Font.Gotham
        btn.Parent = toggle
        btn.ZIndex = 13
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 10)
        btnCorner.Parent = btn
        
        local state = config[name] or false
        
        local function updateToggle()
            local color = state and Color3.fromRGB(80, 180, 80) or Color3.fromRGB(180, 80, 80)
            local text = state and "on" or "off"
            
            local tw = tween:Create(btn, TweenInfo.new(0.2), {
                BackgroundColor3 = color
            })
            tw:Play()
            
            btn.Text = text
        end
        
        updateToggle()
        
        btn.MouseButton1Click:Connect(function()
            state = not state
            updateToggle()
            callback(state)
        end)
        
        return toggle
    end
    
    local function makeButton(name, text, layoutOrder, callback)
        local btn = Instance.new("TextButton")
        btn.Name = name
        btn.Size = UDim2.new(1, -10, 0, isMobile and 40 or 32)
        btn.BackgroundColor3 = Color3.fromRGB(60, 90, 180)
        btn.BorderSizePixel = 0
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextScaled = true
        btn.Font = Enum.Font.Gotham
        btn.Parent = scrollFrame
        btn.LayoutOrder = layoutOrder
        btn.ZIndex = 12
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = btn
        
        btn.MouseEnter:Connect(function()
            local tw = tween:Create(btn, TweenInfo.new(0.15), {
                BackgroundColor3 = Color3.fromRGB(80, 110, 200)
            })
            tw:Play()
        end)
        
        btn.MouseLeave:Connect(function()
            local tw = tween:Create(btn, TweenInfo.new(0.15), {
                BackgroundColor3 = Color3.fromRGB(60, 90, 180)
            })
            tw:Play()
        end)
        
        btn.MouseButton1Click:Connect(callback)
        
        return btn
    end
    
    -- Create UI elements
    makeToggle("idle", "auto idle", 1, function(state)
        config.idle = state
        save()
        notify("idle", state and "enabled" or "disabled")
    end)
    
    makeToggle("smart", "smart mode", 2, function(state)
        config.smart = state
        save()
        notify("smart", state and "enabled" or "disabled")
    end)
    
    makeButton("shovel", "clear sprinklers", 3, function()
        clearSprinklers()
    end)
    
    makeToggle("notify", "notifications", 4, function(state)
        config.notify = state
        save()
    end)
    
    updateScrollFrameSize()
    
    -- Dragging functionality
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    local function startDrag(inputPos)
        dragging = true
        dragStart = inputPos
        startPos = main.Position
    end
    
    local function updateDrag(inputPos)
        if dragging then
            local delta = inputPos - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end
    
    local function endDrag()
        dragging = false
    end
    
    -- Desktop dragging
    top.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            startDrag(inp.Position)
        end
    end)
    
    input.InputChanged:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseMovement then
            updateDrag(inp.Position)
        end
    end)
    
    input.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            endDrag()
        end
    end)
    
    -- Mobile dragging
    if isMobile then
        top.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.Touch then
                startDrag(inp.Position)
            end
        end)
        
        input.InputChanged:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.Touch then
                updateDrag(inp.Position)
            end
        end)
        
        input.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.Touch then
                endDrag()
            end
        end)
    end
    
    -- Minimize functionality
    local isMinimized = false
    minimize.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        
        local targetHeight = isMinimized and (isMobile and 40 or 35) or mainHeight
        minimize.Text = isMinimized and "+" or "-"
        content.Visible = not isMinimized
        
        local tw = tween:Create(main, TweenInfo.new(0.3), {
            Size = UDim2.new(0, mainWidth, 0, targetHeight)
        })
        tw:Play()
    end)
    
    close.MouseButton1Click:Connect(function()
        running = false
        gui:Destroy()
    end)
    
    -- Toggle visibility
    local toggleVisibility = function()
        main.Visible = not main.Visible
    end
    
    -- Desktop toggle
    input.InputBegan:Connect(function(inp)
        if inp.KeyCode == Enum.KeyCode.Insert then
            toggleVisibility()
        end
    end)
    
    -- Mobile toggle (double-tap in corner)
    if isMobile then
        local tapCount = 0
        local lastTapTime = 0
        
        gui.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.Touch then
                local currentTime = tick()
                local pos = inp.Position
                local screenCorner = Vector2.new(0, 0)
                
                if (pos - screenCorner).Magnitude < 100 then
                    if currentTime - lastTapTime < 0.5 then
                        tapCount = tapCount + 1
                        if tapCount >= 2 then
                            toggleVisibility()
                            tapCount = 0
                        end
                    else
                        tapCount = 1
                    end
                    lastTapTime = currentTime
                end
            end
        end)
    end
    
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
        notify("error", "no character")
        return
    end
    
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then
        notify("error", "no humanoid")
        return
    end
    
    local backpack = player:FindFirstChild("Backpack")
    if not backpack then
        notify("error", "no backpack")
        return
    end
    
    local shovel = char:FindFirstChild("Shovel [Destroy Plants]") or 
                   backpack:FindFirstChild("Shovel [Destroy Plants]")
    
    if not shovel then
        notify("error", "no shovel found")
        return
    end
    
    if shovel.Parent == backpack then
        shovel.Parent = char
        humanoid:EquipTool(shovel)
        task.wait(0.4)
    end
    
    local garden = findGarden()
    if not garden then
        notify("error", "no garden found")
        return
    end
    
    local objects = garden.Important:FindFirstChild("Objects_Physical")
    if not objects then 
        notify("error", "no objects found")
        return 
    end
    
    local gameEvents = storage:FindFirstChild("GameEvents")
    if not gameEvents then
        notify("error", "no game events")
        return
    end
    
    local deleteEvent = gameEvents:FindFirstChild("DeleteObject")
    if not deleteEvent then
        notify("error", "no delete event")
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
    
    notify("cleared", count .. " sprinklers")
    
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
                                        notify("auto idle", math.floor(time) .. "s")
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

notify("loaded", isMobile and "double-tap corner to toggle" or "press insert to toggle")

getgenv().ui = {
    gui = gui,
    Destroy = function()
        running = false
        if gui then gui:Destroy() end
    end
}