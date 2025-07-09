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
        if ok then
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
    
    local main = Instance.new("Frame")
    main.Name = "main"
    main.Size = UDim2.new(0, 380, 0, 260)
    main.Position = UDim2.new(0.5, -190, 0.5, -130)
    main.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    main.BorderSizePixel = 0
    main.Parent = gui
    
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
    top.Size = UDim2.new(1, 0, 0, 35)
    top.Position = UDim2.new(0, 0, 0, 0)
    top.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    top.BorderSizePixel = 0
    top.Parent = main
    
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
    
    local close = Instance.new("TextButton")
    close.Name = "close"
    close.Size = UDim2.new(0, 25, 0, 25)
    close.Position = UDim2.new(1, -32, 0, 5)
    close.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
    close.BorderSizePixel = 0
    close.Text = "×"
    close.TextColor3 = Color3.fromRGB(255, 255, 255)
    close.TextScaled = true
    close.Font = Enum.Font.Gotham
    close.Parent = top
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 4)
    closeCorner.Parent = close
    
    local content = Instance.new("Frame")
    content.Name = "content"
    content.Size = UDim2.new(1, -16, 1, -45)
    content.Position = UDim2.new(0, 8, 0, 40)
    content.BackgroundTransparency = 1
    content.Parent = main
    
    local function makeToggle(name, text, pos, callback)
        local toggle = Instance.new("Frame")
        toggle.Name = name
        toggle.Size = UDim2.new(1, 0, 0, 38)
        toggle.Position = pos
        toggle.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        toggle.BorderSizePixel = 0
        toggle.Parent = content
        
        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(0, 6)
        toggleCorner.Parent = toggle
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -50, 1, 0)
        label.Position = UDim2.new(0, 12, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(180, 180, 180)
        label.TextScaled = true
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Gotham
        label.Parent = toggle
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 35, 0, 20)
        btn.Position = UDim2.new(1, -42, 0.5, -10)
        btn.BackgroundColor3 = Color3.fromRGB(180, 80, 80)
        btn.BorderSizePixel = 0
        btn.Text = "off"
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextScaled = true
        btn.Font = Enum.Font.Gotham
        btn.Parent = toggle
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 10)
        btnCorner.Parent = btn
        
        local state = false
        
        btn.MouseButton1Click:Connect(function()
            state = not state
            local color = state and Color3.fromRGB(80, 180, 80) or Color3.fromRGB(180, 80, 80)
            local text = state and "on" or "off"
            
            local tw = tween:Create(btn, TweenInfo.new(0.2), {
                BackgroundColor3 = color
            })
            tw:Play()
            
            btn.Text = text
            callback(state)
        end)
        
        return toggle
    end
    
    local function makeButton(name, text, pos, callback)
        local btn = Instance.new("TextButton")
        btn.Name = name
        btn.Size = UDim2.new(1, 0, 0, 32)
        btn.Position = pos
        btn.BackgroundColor3 = Color3.fromRGB(60, 90, 180)
        btn.BorderSizePixel = 0
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextScaled = true
        btn.Font = Enum.Font.Gotham
        btn.Parent = content
        
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
    
    makeToggle("idle", "auto idle", UDim2.new(0, 0, 0, 0), function(state)
        config.idle = state
        save()
        notify("idle", state and "enabled" or "disabled")
    end)
    
    makeToggle("smart", "smart mode", UDim2.new(0, 0, 0, 45), function(state)
        config.smart = state
        save()
        notify("smart", state and "enabled" or "disabled")
    end)
    
    makeButton("shovel", "clear sprinklers", UDim2.new(0, 0, 0, 95), function()
        clearSprinklers()
    end)
    
    makeToggle("notify", "notifications", UDim2.new(0, 0, 0, 135), function(state)
        config.notify = state
        save()
    end)
    
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    top.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = inp.Position
            startPos = main.Position
        end
    end)
    
    input.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = inp.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    input.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    close.MouseButton1Click:Connect(function()
        running = false
        gui:Destroy()
    end)
    
    main.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton2 then
            main.Visible = false
        end
    end)
    
    input.InputBegan:Connect(function(inp)
        if inp.KeyCode == Enum.KeyCode.Insert then
            main.Visible = not main.Visible
        end
    end)
    
    return gui
end

local function findGarden()
    for _, plot in pairs(workspace.Farm:GetChildren()) do
        if plot:FindFirstChild("Important") and 
           plot.Important:FindFirstChild("Data") and 
           plot.Important.Data.Owner.Value == player.Name then
            return plot
        end
    end
    return nil
end

function clearSprinklers()
    local char = player.Character or player.CharacterAdded:Wait()
    local backpack = player:WaitForChild("Backpack")
    
    local shovel = char:FindFirstChild("Shovel [Destroy Plants]") or 
                   backpack:FindFirstChild("Shovel [Destroy Plants]")
    
    if not shovel then
        notify("error", "no shovel")
        return
    end
    
    if shovel.Parent == backpack then
        shovel.Parent = char
        char.Humanoid:EquipTool(shovel)
        wait(0.4)
    end
    
    local garden = findGarden()
    if not garden then
        notify("error", "no garden")
        return
    end
    
    local objects = garden.Important:FindFirstChild("Objects_Physical")
    if not objects then return end
    
    local deleteEvent = storage:WaitForChild("GameEvents"):WaitForChild("DeleteObject")
    local count = 0
    
    for _, obj in pairs(objects:GetChildren()) do
        if obj:IsA("Model") and obj.Name:find("Sprinkler") then
            deleteEvent:FireServer(obj)
            count = count + 1
            task.wait(0.1)
        end
    end
    
    notify("cleared", count .. " sprinklers")
    
    if char:FindFirstChild("Shovel [Destroy Plants]") then
        char:FindFirstChild("Shovel [Destroy Plants]").Parent = backpack
    end
end

local function handleIdle()
    if not config.idle then return end
    
    local getCooldown = storage:WaitForChild("GameEvents"):WaitForChild("GetPetCooldown")
    local idleHandler = require(storage.Modules.PetServices.PetActionUserInterfaceService.PetActionsHandlers.Idle)
    
    for _, pet in pairs(workspace.PetsPhysical:GetChildren()) do
        if pet.Name == "PetMover" and pet:IsA("BasePart") then
            local uuid = pet:GetAttribute("UUID")
            if uuid then
                local model = pet:FindFirstChild(uuid)
                if model and model:IsA("Model") then
                    local skin = model:GetAttribute("CurrentSkin")
                    
                    if skin == "Moon Cat" then
                        task.spawn(idleHandler.Activate, pet)
                    end
                    
                    if config.smart and not skin then
                        local ok, cooldowns = pcall(getCooldown.InvokeServer, getCooldown, uuid)
                        if ok and type(cooldowns) == "table" then
                            for _, cd in pairs(cooldowns) do
                                local time = tonumber(cd.Time)
                                if time and time >= 78 and time <= 82 then
                                    task.spawn(idleHandler.Activate, pet)
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

task.spawn(function()
    while running do
        if config.idle then
            handleIdle()
        end
        task.wait(1)
    end
end)

local gui = createGui()
getgenv().ui = gui

notify("loaded", "press insert to toggle")

getgenv().ui = {
    gui = gui,
    Destroy = function()
        running = false
        if gui then gui:Destroy() end
    end
}