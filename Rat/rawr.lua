--[[
    Author: Mimi
    Date: 10/05/2025
    Last Update: 10/07/2025
    DD/MM/YYYY
]]--

if game.PlaceId ~= 126884695634066 then return end

local players = game:GetService("Players")
local storage = game:GetService("ReplicatedStorage")
local input = game:GetService("UserInputService")
local tween = game:GetService("TweenService")
local run = game:GetService("RunService")
local http = game:GetService("HttpService")
local player = players.LocalPlayer
local mouse = player:GetMouse()

if getgenv().FarmHelper then
    getgenv().FarmHelper:Destroy()
end

local running = true
local config = {
    AutoIdleToggle = false,
    notify = true,
    AutoBuySeeds = false,
    AutoBuyGear = false,
    AutoBuyEggs = false,
    AutoShovelFruitsToggle = false,
    WeightThreshold = 5,
    ThresholdType = "Above",
    SelectedPlants = {},
    FruitHoverDisplay = true,
}

local folder = "farmtool"
local file = folder .. "/config.json"
local isMobile = input.TouchEnabled and not input.KeyboardEnabled

local function saveConfig()
    if not isfolder(folder) then makefolder(folder) end
    writefile(file, http:JSONEncode(config))
end

local function loadConfig()
    if isfile(file) then
        local ok, data = pcall(function()
            return http:JSONDecode(readfile(file))
        end)
        if ok and data then
            for k, v in pairs(data) do
                if config[k] ~= nil then
                    config[k] = v
                end
            end
        end
    end
end

loadConfig()

local function showNotification(title, text)
    if not config.notify then return end
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = 2
    })
end

local BuySeedStockRemote = storage.GameEvents.BuySeedStock
local BuyGearStockRemote = storage.GameEvents.BuyGearStock
local BuyPetEggRemote = storage.GameEvents.BuyPetEgg
local GetPetCooldown = storage.GameEvents.GetPetCooldown
local Remove_Item = storage.GameEvents.Remove_Item
local DeleteObject = storage.GameEvents.DeleteObject
local IdleHandler = require(storage.Modules.PetServices.PetActionUserInterfaceService.PetActionsHandlers.Idle)

local seedTypes = {
    "Apple", "Avocado", "Bamboo", "Banana", "Beanstalk", "Bell Pepper", "Blueberry", "Burning Bud",
    "Cacao", "Cactus", "Carrot", "Cauliflower", "Chocolate Carrot", "Coconut", "Corn", "Cranberry",
    "Daffodil", "Dragon Fruit", "Ember Lily", "Feijoa", "Grape", "Green Apple", "Kiwi", "Loquat",
    "Mango", "Mushroom", "Orange Tulip", "Pepper", "Pineapple", "Pitcher Plant", "Prickly Pear",
    "Pumpkin", "Rafflesia", "Strawberry", "Sugar Apple", "Tomato", "Watermelon"
}

local eggTypes = {
    "Bee Egg", "Bug Egg", "Common Egg", "Common Summer Egg", "Legendary Egg",
    "Mythical Egg", "Paradise Egg", "Rare Egg", "Rare Summer Egg", "Uncommon Egg"
}

local gearTypes = {
    "Advanced Sprinkler", "Basic Sprinkler", "Cleaning Spray", "Favorite Tool",
    "Friendship Pot", "Godly Sprinkler", "Harvest Tool", "Magnifying Glass",
    "Master Sprinkler", "Recall Wrench", "Tanning Mirror", "Trowel", "Watering Can"
}

local plantTypes = {
    "Apple", "Avocado", "Bamboo", "Banana", "Beanstalk", "Bell Pepper", "Blueberry", 
    "Burning Bud", "Cacao", "Cactus", "Carrot", "Cauliflower", "Chocolate Carrot", 
    "Coconut", "Corn", "Cranberry", "Daffodil", "Dragon Fruit", "Ember Lily", "Feijoa", 
    "Grape", "Green Apple", "Kiwi", "Loquat", "Mango", "Mushroom", "Orange Tulip", 
    "Pepper", "Pineapple", "Pitcher Plant", "Prickly Pear", "Pumpkin", "Rafflesia", 
    "Strawberry", "Sugar Apple", "Tomato", "Watermelon"
}

local function findShovel()
    local character = player.Character or player.CharacterAdded:Wait()
    local backpack = player.Backpack
    local equipped = character:FindFirstChildWhichIsA("Tool")
    
    if equipped and equipped.Name == "Shovel [Destroy Plants]" then
        return true
    end
    
    local shovel = character:FindFirstChild("Shovel [Destroy Plants]") or backpack:FindFirstChild("Shovel [Destroy Plants]")
    if shovel then
        shovel.Parent = character
        character.Humanoid:EquipTool(shovel)
        return true
    end
    
    return false
end

local function putAwayShovel()
    local character = player.Character
    if not character then return end
    local equipped = character:FindFirstChildWhichIsA("Tool")
    if equipped and equipped.Name == "Shovel [Destroy Plants]" then
        equipped.Parent = player.Backpack
    end
end

local function findMyGarden()
    for _, plot in pairs(workspace.Farm:GetChildren()) do
        if plot.Important and plot.Important.Data and plot.Important.Data.Owner.Value == player.Name then
            return plot
        end
    end
    return nil
end

local function createMainUI()
    local screenUI = Instance.new("ScreenGui")
    screenUI.Name = "FarmHelperUI"
    screenUI.Parent = player.PlayerGui
    screenUI.ResetOnSpawn = false
    screenUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 320, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -160, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenUI

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 12)
    mainCorner.Parent = mainFrame

    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 50)
    header.BackgroundTransparency = 1
    header.Parent = mainFrame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -100, 1, 0)
    title.Position = UDim2.new(0, 20, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Farm Assistant"
    title.TextColor3 = Color3.fromRGB(240, 240, 240)
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Font = Enum.Font.GothamBold
    title.Parent = header

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 32, 0, 32)
    closeBtn.Position = UDim2.new(1, -45, 0, 9)
    closeBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 18
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = header

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeBtn

    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Size = UDim2.new(0, 32, 0, 32)
    minimizeBtn.Position = UDim2.new(1, -82, 0, 9)
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(240, 180, 50)
    minimizeBtn.BorderSizePixel = 0
    minimizeBtn.Text = "—"
    minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minimizeBtn.TextSize = 18
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.Parent = header

    local minimizeCorner = Instance.new("UICorner")
    minimizeCorner.CornerRadius = UDim.new(0, 8)
    minimizeCorner.Parent = minimizeBtn

    local tabs = {"Farm", "Shop", "Shovel", "Settings"}
    local tabButtons = {}
    local tabFrames = {}

    local tabContainer = Instance.new("Frame")
    tabContainer.Size = UDim2.new(1, -24, 0, 36)
    tabContainer.Position = UDim2.new(0, 12, 0, 58)
    tabContainer.BackgroundTransparency = 1
    tabContainer.Parent = mainFrame

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.Padding = UDim.new(0, 6)
    tabLayout.Parent = tabContainer

    for i, tabName in ipairs(tabs) do
        local tabBtn = Instance.new("TextButton")
        tabBtn.Size = UDim2.new(0.25, -6, 1, 0)
        tabBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
        tabBtn.BorderSizePixel = 0
        tabBtn.Text = tabName
        tabBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
        tabBtn.TextSize = 14
        tabBtn.Font = Enum.Font.Gotham
        tabBtn.Parent = tabContainer
        
        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 8)
        tabCorner.Parent = tabBtn
        
        tabBtn.MouseButton1Click:Connect(function()
            for _, frame in pairs(tabFrames) do
                frame.Visible = false
            end
            tabFrames[tabName].Visible = true
            for _, btn in pairs(tabButtons) do
                btn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
            end
            tabBtn.BackgroundColor3 = Color3.fromRGB(70, 180, 90)
        end)
        
        tabButtons[tabName] = tabBtn
        
        local tabFrame = Instance.new("ScrollingFrame")
        tabFrame.Size = UDim2.new(1, -24, 1, -100)
        tabFrame.Position = UDim2.new(0, 12, 0, 100)
        tabFrame.BackgroundTransparency = 1
        tabFrame.Visible = i == 1
        tabFrame.ScrollBarThickness = 4
        tabFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        tabFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
        tabFrame.Parent = mainFrame
        
        local tabList = Instance.new("UIListLayout")
        tabList.SortOrder = Enum.SortOrder.LayoutOrder
        tabList.Padding = UDim.new(0, 10)
        tabList.Parent = tabFrame
        
        tabFrames[tabName] = tabFrame
    end

    local function makeToggle(name, text, order, parent)
        local toggleFrame = Instance.new("Frame")
        toggleFrame.Size = UDim2.new(1, 0, 0, 36)
        toggleFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        toggleFrame.BorderSizePixel = 0
        toggleFrame.LayoutOrder = order
        toggleFrame.Parent = parent

        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(0, 8)
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
        toggleSwitch.BackgroundColor3 = Color3.fromRGB(70, 70, 75)
        toggleSwitch.BorderSizePixel = 0
        toggleSwitch.Parent = toggleFrame

        local switchCorner = Instance.new("UICorner")
        switchCorner.CornerRadius = UDim.new(0, 12)
        switchCorner.Parent = toggleSwitch

        local switchKnob = Instance.new("Frame")
        switchKnob.Size = UDim2.new(0, 18, 0, 18)
        switchKnob.Position = UDim2.new(0, 3, 0.5, -9)
        switchKnob.BackgroundColor3 = Color3.fromRGB(250, 250, 250)
        switchKnob.BorderSizePixel = 0
        switchKnob.Parent = toggleSwitch

        local knobCorner = Instance.new("UICorner")
        knobCorner.CornerRadius = UDim.new(0, 9)
        knobCorner.Parent = switchKnob

        local switchButton = Instance.new("TextButton")
        switchButton.Size = UDim2.new(1, 0, 1, 0)
        switchButton.BackgroundTransparency = 1
        switchButton.Text = ""
        switchButton.Parent = toggleSwitch

        local state = config[name] or false

        local function updateToggle()
            local bgColor = state and Color3.fromRGB(70, 180, 90) or Color3.fromRGB(70, 70, 75)
            local knobPos = state and UDim2.new(0, 23, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)

            tween:Create(toggleSwitch, TweenInfo.new(0.15), {BackgroundColor3 = bgColor}):Play()
            tween:Create(switchKnob, TweenInfo.new(0.15), {Position = knobPos}):Play()
        end

        updateToggle()

        switchButton.MouseButton1Click:Connect(function()
            state = not state
            config[name] = state
            updateToggle()
            saveConfig()
            showNotification("Settings", text .. " " .. (state and "enabled" or "disabled"))
        end)

        return toggleFrame
    end

    local function makeButton(name, text, order, callback, parent)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, 0, 0, 36)
        button.BackgroundColor3 = Color3.fromRGB(70, 180, 90)
        button.BorderSizePixel = 0
        button.Text = text
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextSize = 14
        button.Font = Enum.Font.GothamBold
        button.LayoutOrder = order
        button.Parent = parent

        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 8)
        buttonCorner.Parent = button

        button.MouseButton1Click:Connect(callback)

        return button
    end

    local farmTab = tabFrames["Farm"]
    makeToggle("AutoIdleToggle", "Auto Idle Pets", 1, farmTab)
    makeToggle("notify", "Show Notifications", 2, farmTab)
    makeToggle("FruitHoverDisplay", "Show Fruit Weight", 3, farmTab)
    
    makeButton("shovel", "Remove Sprinklers", 4, function()
        local garden = findMyGarden()
        if not garden then 
            showNotification("Error", "Couldn't find your garden")
            return 
        end
        
        if not findShovel() then 
            showNotification("Error", "Couldn't find shovel")
            return 
        end
        
        local objects = garden.Important.Objects_Physical
        if not objects then 
            showNotification("Error", "No objects found")
            return 
        end
        
        for _, item in ipairs(objects:GetChildren()) do
            if item:IsA("Model") and string.find(item.Name, "Sprinkler") then
                DeleteObject:FireServer(item)
                task.wait(0.15)
            end
        end
        
        putAwayShovel()
        showNotification("Done", "Sprinklers removed")
    end, farmTab)

    local shopTab = tabFrames["Shop"]
    makeToggle("AutoBuySeeds", "Auto Buy Seeds", 1, shopTab)
    makeToggle("AutoBuyGear", "Auto Buy Gear", 2, shopTab)
    makeToggle("AutoBuyEggs", "Auto Buy Eggs", 3, shopTab)

    local shovelTab = tabFrames["Shovel"]
    makeToggle("AutoShovelFruitsToggle", "Auto Shovel Fruits", 1, shovelTab)
    
    local thresholdFrame = Instance.new("Frame")
    thresholdFrame.Size = UDim2.new(1, 0, 0, 36)
    thresholdFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    thresholdFrame.LayoutOrder = 2
    thresholdFrame.Parent = shovelTab
    
    local thresholdCorner = Instance.new("UICorner")
    thresholdCorner.CornerRadius = UDim.new(0, 8)
    thresholdCorner.Parent = thresholdFrame
    
    local thresholdLabel = Instance.new("TextLabel")
    thresholdLabel.Size = UDim2.new(0.4, 0, 1, 0)
    thresholdLabel.Position = UDim2.new(0, 16, 0, 0)
    thresholdLabel.BackgroundTransparency = 1
    thresholdLabel.Text = "Weight Threshold:"
    thresholdLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    thresholdLabel.TextSize = 14
    thresholdLabel.TextXAlignment = Enum.TextXAlignment.Left
    thresholdLabel.Font = Enum.Font.Gotham
    thresholdLabel.Parent = thresholdFrame
    
    local thresholdBox = Instance.new("TextBox")
    thresholdBox.Size = UDim2.new(0.3, -8, 0.7, 0)
    thresholdBox.Position = UDim2.new(0.4, 8, 0.15, 0)
    thresholdBox.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    thresholdBox.BorderSizePixel = 0
    thresholdBox.Text = tostring(config.WeightThreshold)
    thresholdBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    thresholdBox.TextSize = 14
    thresholdBox.Font = Enum.Font.Gotham
    thresholdBox.Parent = thresholdFrame
    
    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 6)
    boxCorner.Parent = thresholdBox
    
    local typeButton = Instance.new("TextButton")
    typeButton.Size = UDim2.new(0.25, -8, 0.7, 0)
    typeButton.Position = UDim2.new(0.75, 8, 0.15, 0)
    typeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    typeButton.BorderSizePixel = 0
    typeButton.Text = config.ThresholdType
    typeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    typeButton.TextSize = 14
    typeButton.Font = Enum.Font.Gotham
    typeButton.Parent = thresholdFrame
    
    local typeCorner = Instance.new("UICorner")
    typeCorner.CornerRadius = UDim.new(0, 6)
    typeCorner.Parent = typeButton
    
    typeButton.MouseButton1Click:Connect(function()
        config.ThresholdType = config.ThresholdType == "Above" and "Below" or "Above"
        typeButton.Text = config.ThresholdType
        saveConfig()
    end)
    
    thresholdBox.FocusLost:Connect(function()
        local num = tonumber(thresholdBox.Text)
        if num then
            config.WeightThreshold = num
            saveConfig()
        else
            thresholdBox.Text = tostring(config.WeightThreshold)
        end
    end)
    
    local selectedLabel = Instance.new("TextLabel")
    selectedLabel.Size = UDim2.new(1, 0, 0, 20)
    selectedLabel.BackgroundTransparency = 1
    selectedLabel.Text = "Selected: " .. (#config.SelectedPlants > 0 and table.concat(config.SelectedPlants, ", ") or "None")
    selectedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    selectedLabel.TextSize = 12
    selectedLabel.TextXAlignment = Enum.TextXAlignment.Left
    selectedLabel.LayoutOrder = 3
    selectedLabel.Parent = shovelTab
    
    local function updateSelectedText()
        selectedLabel.Text = "Selected: " .. (#config.SelectedPlants > 0 and table.concat(config.SelectedPlants, ", ") or "None")
    end
    
    local plantContainer = Instance.new("Frame")
    plantContainer.Size = UDim2.new(1, 0, 0, 200)
    plantContainer.BackgroundTransparency = 1
    plantContainer.LayoutOrder = 4
    plantContainer.Parent = shovelTab
    
    local searchBox = Instance.new("TextBox")
    searchBox.Size = UDim2.new(1, 0, 0, 30)
    searchBox.PlaceholderText = "Search plants..."
    searchBox.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    searchBox.TextSize = 14
    searchBox.Font = Enum.Font.Gotham
    searchBox.Parent = plantContainer
    
    local searchCorner = Instance.new("UICorner")
    searchCorner.CornerRadius = UDim.new(0, 6)
    searchCorner.Parent = searchBox
    
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, 0, 1, -40)
    scrollFrame.Position = UDim2.new(0, 0, 0, 35)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 4
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scrollFrame.Parent = plantContainer
    
    local plantGrid = Instance.new("UIGridLayout")
    plantGrid.CellSize = UDim2.new(0.5, -4, 0, 30)
    plantGrid.CellPadding = UDim2.new(0, 0, 0, 4)
    plantGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center
    plantGrid.Parent = scrollFrame
    
    local plantButtons = {}
    
    local function refreshPlantList(search)
        for _, btn in ipairs(plantButtons) do
            btn:Destroy()
        end
        plantButtons = {}
        
        for _, plant in ipairs(plantTypes) do
            if search == "" or string.find(string.lower(plant), string.lower(search)) then
                local plantBtn = Instance.new("TextButton")
                plantBtn.Size = UDim2.new(1, 0, 0, 30)
                plantBtn.BackgroundColor3 = table.find(config.SelectedPlants, plant) 
                    and Color3.fromRGB(70, 180, 90) 
                    or Color3.fromRGB(50, 50, 55)
                plantBtn.BorderSizePixel = 0
                plantBtn.Text = plant
                plantBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                plantBtn.TextSize = 12
                plantBtn.Font = Enum.Font.Gotham
                plantBtn.Parent = scrollFrame
                
                local plantCorner = Instance.new("UICorner")
                plantCorner.CornerRadius = UDim.new(0, 6)
                plantCorner.Parent = plantBtn
                
                plantBtn.MouseButton1Click:Connect(function()
                    if table.find(config.SelectedPlants, plant) then
                        table.remove(config.SelectedPlants, table.find(config.SelectedPlants, plant))
                        plantBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
                    else
                        table.insert(config.SelectedPlants, plant)
                        plantBtn.BackgroundColor3 = Color3.fromRGB(70, 180, 90)
                    end
                    saveConfig()
                    updateSelectedText()
                end)
                
                table.insert(plantButtons, plantBtn)
            end
        end
    end
    
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        refreshPlantList(searchBox.Text)
    end)
    
    refreshPlantList("")
    
    local settingsTab = tabFrames["Settings"]
    makeButton("reset", "Reset All Settings", 1, function()
        config = {
            AutoIdleToggle = false,
            notify = true,
            AutoBuySeeds = false,
            AutoBuyGear = false,
            AutoBuyEggs = false,
            AutoShovelFruitsToggle = false,
            WeightThreshold = 5,
            ThresholdType = "Above",
            SelectedPlants = {},
            FruitHoverDisplay = true,
        }
        saveConfig()
        showNotification("Settings", "All settings reset")
        task.wait(0.5)
        if screenUI then screenUI:Destroy() end
        loadfile("FarmHelper.lua")()
    end, settingsTab)
    
    makeButton("reload", "Reload UI", 2, function()
        running = false
        if screenUI then screenUI:Destroy() end
        task.wait(0.5)
        loadfile("FarmHelper.lua")()
    end, settingsTab)

    closeBtn.MouseButton1Click:Connect(function()
        running = false
        screenUI:Destroy()
    end)

    minimizeBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = not mainFrame.Visible
    end)

    local dragging = false
    local dragStart = nil
    local startPos = nil

    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)

    input.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    input.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    input.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Insert then
            mainFrame.Visible = not mainFrame.Visible
        end
    end)

    return screenUI
end

local mainUI = createMainUI()
getgenv().FarmHelper = mainUI
showNotification("Farm Assistant", "Press Insert to toggle UI")

getgenv().AutoIdle = false
getgenv().AutoIdleToggle = config.AutoIdleToggle

task.spawn(function()
    while running do
        if getgenv().AutoIdle then
            for _, pet in ipairs(workspace.PetsPhysical:GetChildren()) do
                if pet:IsA("BasePart") and pet.Name == "PetMover" then
                    local model = pet:FindFirstChild(pet:GetAttribute("UUID"))
                    if model and model:GetAttribute("CurrentSkin") == "Moon Cat" then
                        task.spawn(IdleHandler.Activate, pet)
                    end
                end
            end
        end
        task.wait()
    end
end)

task.spawn(function()
    while running do
        if getgenv().AutoIdleToggle then 
            for _, pet in ipairs(workspace.PetsPhysical:GetChildren()) do
                if pet:IsA("BasePart") and pet.Name == "PetMover" then
                    local uuid = pet:GetAttribute("UUID")
                    local model = uuid and pet:FindFirstChild(uuid)

                    if model and model:GetAttribute("CurrentSkin") == nil then
                        local success, cooldowns = pcall(GetPetCooldown.InvokeServer, GetPetCooldown, uuid)
                        if success and type(cooldowns) == "table" then
                            for _, cd in ipairs(cooldowns) do
                                local time = tonumber(cd.Time)
                                if time and time >= 79 and time <= 81 and not getgenv().AutoIdle then
                                    showNotification("Auto Idle", "Activated")
                                    getgenv().AutoIdle = true
                                    task.delay(10, function()
                                        getgenv().AutoIdle = false
                                        showNotification("Auto Idle", "Deactivated")
                                    end)
                                    break
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

task.spawn(function()
    while running do
        if config.AutoBuySeeds then
            for _, seed in ipairs(seedTypes) do
                pcall(BuySeedStockRemote.FireServer, BuySeedStockRemote, seed)
                task.wait(0.05)
                if not config.AutoBuySeeds then break end
            end
        else
            task.wait(0.5)
        end
    end
end)

task.spawn(function()
    while running do
        if config.AutoBuyGear then
            for _, gear in ipairs(gearTypes) do
                pcall(BuyGearStockRemote.FireServer, BuyGearStockRemote, gear)
                task.wait(0.05)
                if not config.AutoBuyGear then break end
            end
        else
            task.wait(0.5)
        end
    end
end)

task.spawn(function()
    while running do
        if config.AutoBuyEggs then
            for idx, _ in ipairs(eggTypes) do
                pcall(BuyPetEggRemote.FireServer, BuyPetEggRemote, idx)
                task.wait(0.05)
                if not config.AutoBuyEggs then break end
            end
        else
            task.wait(0.5)
        end
    end
end)

task.spawn(function()
    while running do
        if config.AutoShovelFruitsToggle and #config.SelectedPlants > 0 then
            local garden = findMyGarden()
            if garden then
                local plants = garden.Important.Plants_Physical
                if plants then
                    local shovelReady = findShovel()
                    
                    for _, plant in ipairs(plants:GetChildren()) do
                        if table.find(config.SelectedPlants, plant.Name) then
                            local fruits = plant:FindFirstChild("Fruits")
                            if fruits then
                                for _, fruit in ipairs(fruits:GetChildren()) do
                                    local weight = fruit:FindFirstChild("Weight")
                                    if weight and weight:IsA("NumberValue") then
                                        local shouldRemove = false
                                        if config.ThresholdType == "Above" then
                                            shouldRemove = weight.Value > config.WeightThreshold
                                        else
                                            shouldRemove = weight.Value < config.WeightThreshold
                                        end
                                        
                                        if shouldRemove then
                                            local part = fruit.PrimaryPart or fruit:FindFirstChildWhichIsA("BasePart")
                                            if part then
                                                Remove_Item:FireServer(part)
                                                task.wait(0.1)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                    
                    if shovelReady then
                        putAwayShovel()
                    end
                end
            end
        end
        task.wait(5)
    end
end)

task.spawn(function()
    local weightDisplay = Instance.new("ScreenGui")
    weightDisplay.Name = "FruitWeightDisplay"
    weightDisplay.Parent = player.PlayerGui
    
    local displayFrame = Instance.new("Frame")
    displayFrame.Size = UDim2.new(0, 140, 0, 36)
    displayFrame.BackgroundTransparency = 1
    displayFrame.Visible = config.FruitHoverDisplay
    displayFrame.Parent = weightDisplay
    
    local weightText = Instance.new("TextLabel")
    weightText.Size = UDim2.new(1, 0, 1, 0)
    weightText.Text = ""
    weightText.TextColor3 = Color3.fromRGB(255, 255, 255)
    weightText.BackgroundTransparency = 1
    weightText.Font = Enum.Font.GothamBold
    weightText.TextSize = 18
    weightText.TextStrokeTransparency = 0.5
    weightText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    weightText.Parent = displayFrame
    
    run.RenderStepped:Connect(function()
        displayFrame.Visible = config.FruitHoverDisplay
        if not config.FruitHoverDisplay then return end
        
        local target = mouse.Target
        local fruitModel = nil
        
        if target then
            local parent = target.Parent
            while parent do
                if parent.Name == "Fruits" and parent:IsA("Folder") then
                    fruitModel = target:FindFirstAncestorWhichIsA("Model")
                    break
                end
                parent = parent.Parent
            end
        end
        
        if fruitModel then
            local weight = fruitModel:FindFirstChild("Weight")
            if weight and weight:IsA("NumberValue") then
                weightText.Text = string.format("%.2f kg", weight.Value)
                displayFrame.Position = UDim2.new(0, mouse.X - 150, 0, mouse.Y - 20)
                displayFrame.Visible = true
            else
                displayFrame.Visible = false
            end
        else
            displayFrame.Visible = false
        end
    end)
end)