if game.PlaceId ~= 126884695634066 then 
  print("wrong game twin")
  return 
end

if getgenv().help then
  getgenv().help:Destroy()
  getgenv().help = nil
end

local plrs = game:GetService("Players")
local repStorage = game:GetService("ReplicatedStorage")
local uis = game:GetService("UserInputService")
local tweens = game:GetService("TweenService")
local runSvc = game:GetService("RunService")
local http = game:GetService("HttpService")

local me = plrs.LocalPlayer
local clickyThing = me:GetMouse()

local isRunning = true
local stuff = {
  idleMode = false,
  smartStuff = true,
  shovelThing = false,
  popups = true,
  coolTheme = "Dark"
}

local folderName = "MyEpicScript"
local fileName = folderName .. "/epicSettings.json"

local function saveStuff()
  if not isfolder(folderName) then
      makefolder(folderName)
  end
  writefile(fileName, http:JSONEncode(stuff))
end

local function loadStuff()
  if isfile(fileName) then
      local worked, data = pcall(function()
          return http:JSONDecode(readfile(fileName))
      end)
      if worked then
          for k, v in pairs(data) do
              stuff[k] = v
          end
      end
  end
end

loadStuff()

local function popup(title, msg, time)
  if not stuff.popups then return end
  
  game:GetService("StarterGui"):SetCore("SendNotification", {
      Title = title or "rat",
      Text = msg or "something happened idk",
      Duration = time or 3
  })
end

local function makeTheUI()
  local gui = Instance.new("ScreenGui")
  gui.Name = "EpicGUI"
  gui.Parent = me.PlayerGui
  gui.ResetOnSpawn = false
  
  local bigBox = Instance.new("Frame")
  bigBox.Name = "BigBox"
  bigBox.Size = UDim2.new(0, 420, 0, 280)
  bigBox.Position = UDim2.new(0.5, -210, 0.5, -140)
  bigBox.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
  bigBox.BorderSizePixel = 0
  bigBox.Parent = gui
  
  local roundyThing = Instance.new("UICorner")
  roundyThing.CornerRadius = UDim.new(0, 15)
  roundyThing.Parent = bigBox
  
  local prettyColors = Instance.new("UIGradient")
  prettyColors.Color = ColorSequence.new{
      ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 40)),
      ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 30))
  }
  prettyColors.Rotation = 69
  prettyColors.Parent = bigBox
  
  local topBar = Instance.new("Frame")
  topBar.Name = "TopBar"
  topBar.Size = UDim2.new(1, 0, 0, 40)
  topBar.Position = UDim2.new(0, 0, 0, 0)
  topBar.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
  topBar.BorderSizePixel = 0
  topBar.Parent = bigBox
  
  local topRoundy = Instance.new("UICorner")
  topRoundy.CornerRadius = UDim.new(0, 15)
  topRoundy.Parent = topBar
  
  local titleThing = Instance.new("TextLabel")
  titleThing.Name = "TitleThing"
  titleThing.Size = UDim2.new(1, -80, 1, 0)
  titleThing.Position = UDim2.new(0, 15, 0, 0)
  titleThing.BackgroundTransparency = 1
  titleThing.Text = "super cool farm thing"
  titleThing.TextColor3 = Color3.fromRGB(255, 255, 255)
  titleThing.TextScaled = true
  titleThing.TextXAlignment = Enum.TextXAlignment.Left
  titleThing.Font = Enum.Font.GothamBold
  titleThing.Parent = topBar
  
  local xButton = Instance.new("TextButton")
  xButton.Name = "XButton"
  xButton.Size = UDim2.new(0, 30, 0, 30)
  xButton.Position = UDim2.new(1, -40, 0, 5)
  xButton.BackgroundColor3 = Color3.fromRGB(255, 69, 69)
  xButton.BorderSizePixel = 0
  xButton.Text = "X"
  xButton.TextColor3 = Color3.fromRGB(255, 255, 255)
  xButton.TextScaled = true
  xButton.Font = Enum.Font.GothamBold
  xButton.Parent = topBar
  
  local xRoundy = Instance.new("UICorner")
  xRoundy.CornerRadius = UDim.new(0, 8)
  xRoundy.Parent = xButton
  
  local innerStuff = Instance.new("Frame")
  innerStuff.Name = "InnerStuff"
  innerStuff.Size = UDim2.new(1, -20, 1, -60)
  innerStuff.Position = UDim2.new(0, 10, 0, 50)
  innerStuff.BackgroundTransparency = 1
  innerStuff.Parent = bigBox
  
  local function makeToggle(name, txt, pos, callback)
      local toggleBox = Instance.new("Frame")
      toggleBox.Name = name
      toggleBox.Size = UDim2.new(1, 0, 0, 45)
      toggleBox.Position = pos
      toggleBox.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
      toggleBox.BorderSizePixel = 0
      toggleBox.Parent = innerStuff
      
      local boxRoundy = Instance.new("UICorner")
      boxRoundy.CornerRadius = UDim.new(0, 10)
      boxRoundy.Parent = toggleBox
      
      local words = Instance.new("TextLabel")
      words.Size = UDim2.new(1, -60, 1, 0)
      words.Position = UDim2.new(0, 15, 0, 0)
      words.BackgroundTransparency = 1
      words.Text = txt
      words.TextColor3 = Color3.fromRGB(200, 200, 200)
      words.TextScaled = true
      words.TextXAlignment = Enum.TextXAlignment.Left
      words.Font = Enum.Font.Gotham
      words.Parent = toggleBox
      
      local clickyBtn = Instance.new("TextButton")
      clickyBtn.Size = UDim2.new(0, 50, 0, 25)
      clickyBtn.Position = UDim2.new(1, -60, 0.5, -12.5)
      clickyBtn.BackgroundColor3 = Color3.fromRGB(255, 69, 69)
      clickyBtn.BorderSizePixel = 0
      clickyBtn.Text = "nah"
      clickyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
      clickyBtn.TextScaled = true
      clickyBtn.Font = Enum.Font.GothamBold
      clickyBtn.Parent = toggleBox
      
      local btnRoundy = Instance.new("UICorner")
      btnRoundy.CornerRadius = UDim.new(0, 15)
      btnRoundy.Parent = clickyBtn
      
      local isOn = false
      
      clickyBtn.MouseButton1Click:Connect(function()
          isOn = not isOn
          local newColor = isOn and Color3.fromRGB(69, 255, 69) or Color3.fromRGB(255, 69, 69)
          local newTxt = isOn and "yep" or "nah"
          
          local tween = tweens:Create(clickyBtn, TweenInfo.new(0.2), {
              BackgroundColor3 = newColor
          })
          tween:Play()
          
          clickyBtn.Text = newTxt
          callback(isOn)
      end)
      
      return toggleBox
  end
  
  local function makeBtn(name, txt, pos, callback)
      local btn = Instance.new("TextButton")
      btn.Name = name
      btn.Size = UDim2.new(1, 0, 0, 40)
      btn.Position = pos
      btn.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
      btn.BorderSizePixel = 0
      btn.Text = txt
      btn.TextColor3 = Color3.fromRGB(255, 255, 255)
      btn.TextScaled = true
      btn.Font = Enum.Font.GothamBold
      btn.Parent = innerStuff
      
      local btnRoundy = Instance.new("UICorner")
      btnRoundy.CornerRadius = UDim.new(0, 10)
      btnRoundy.Parent = btn
      
      btn.MouseEnter:Connect(function()
          local tween = tweens:Create(btn, TweenInfo.new(0.1), {
              BackgroundColor3 = Color3.fromRGB(70, 120, 220)
          })
          tween:Play()
      end)
      
      btn.MouseLeave:Connect(function()
          local tween = tweens:Create(btn, TweenInfo.new(0.1), {
              BackgroundColor3 = Color3.fromRGB(50, 100, 200)
          })
          tween:Play()
      end)
      
      btn.MouseButton1Click:Connect(callback)
      
      return btn
  end
  
  makeToggle("IdleToggle", "🎯 auto idle (not cool)", UDim2.new(0, 0, 0, 0), function(state)
      stuff.idleMode = state
      saveStuff()
      popup("idle mode", state and "on lol" or "off :(")
  end)
  
  makeToggle("SmartToggle", "🧠 smart mode (200 iq)", UDim2.new(0, 0, 0, 55), function(state)
      stuff.smartStuff = state
      saveStuff()
      popup("big brain mode", state and "activated" or "deactivated")
  end)
  
  makeBtn("ShovelBtn", "🔥 fuck sprinklers", UDim2.new(0, 0, 0, 115), function()
      destroyThoseSprinklers()
  end)
  
  makeToggle("PopupToggle", "🔔 annoying popups", UDim2.new(0, 0, 0, 165), function(state)
      stuff.popups = state
      saveStuff()
  end)
  
  local isDragging = false
  local dragStart = nil
  local startPos = nil
  
  topBar.InputBegan:Connect(function(input)
      if input.UserInputType == Enum.UserInputType.MouseButton1 then
          isDragging = true
          dragStart = input.Position
          startPos = bigBox.Position
      end
  end)
  
  uis.InputChanged:Connect(function(input)
      if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
          local delta = input.Position - dragStart
          bigBox.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
      end
  end)
  
  uis.InputEnded:Connect(function(input)
      if input.UserInputType == Enum.UserInputType.MouseButton1 then
          isDragging = false
      end
  end)
  
  xButton.MouseButton1Click:Connect(function()
      isRunning = false
      gui:Destroy()
  end)
  
  bigBox.InputBegan:Connect(function(input)
      if input.UserInputType == Enum.UserInputType.MouseButton2 then
          bigBox.Visible = false
      end
  end)
  
  uis.InputBegan:Connect(function(input)
      if input.KeyCode == Enum.KeyCode.Insert then
          bigBox.Visible = not bigBox.Visible
      end
  end)
  
  return gui
end

local function findMyGarden()
  for _, plot in pairs(workspace.Farm:GetChildren()) do
      if plot:FindFirstChild("Important") and 
         plot.Important:FindFirstChild("Data") and 
         plot.Important.Data.Owner.Value == me.Name then
          return plot
      end
  end
  return nil
end

function destroyThoseSprinklers()
  local char = me.Character or me.CharacterAdded:Wait()
  local bag = me:WaitForChild("Backpack")
  
  local shovel = char:FindFirstChild("Shovel [Destroy Plants]") or 
                 bag:FindFirstChild("Shovel [Destroy Plants]")
  
  if not shovel then
      popup("rat", "no shovel found smh")
      return
  end
  
  if shovel.Parent == bag then
      shovel.Parent = char
      char.Humanoid:EquipTool(shovel)
      wait(0.5)
  end
  
  local myGarden = findMyGarden()
  if not myGarden then
      popup("oof", "cant find ur garden lol")
      return
  end
  
  local objectThingy = myGarden.Important:FindFirstChild("Objects_Physical")
  if not objectThingy then return end
  
  local deleteRemote = repStorage:WaitForChild("GameEvents"):WaitForChild("DeleteObject")
  local destroyed = 0
  
  for _, model in pairs(objectThingy:GetChildren()) do
      if model:IsA("Model") and model.Name:find("Sprinkler") then
          deleteRemote:FireServer(model)
          destroyed = destroyed + 1
          task.wait(0.1)
      end
  end
  
  popup("destruction", "absolutely fucking destroyed" .. destroyed .. " sprinklers")
  
  if char:FindFirstChild("Shovel [Destroy Plants]") then
      char:FindFirstChild("Shovel [Destroy Plants]").Parent = bag
  end
end

local function doTheIdleThing()
  if not stuff.idleMode then return end
  
  local cooldownThing = repStorage:WaitForChild("GameEvents"):WaitForChild("GetPetCooldown")
  local idleStuff = require(repStorage.Modules.PetServices.PetActionUserInterfaceService.PetActionsHandlers.Idle)
  
  for _, petThing in pairs(workspace.PetsPhysical:GetChildren()) do
      if petThing.Name == "PetMover" and petThing:IsA("BasePart") then
          local uuid = petThing:GetAttribute("UUID")
          if uuid then
              local pet = petThing:FindFirstChild(uuid)
              if pet and pet:IsA("Model") then
                  local skin = pet:GetAttribute("CurrentSkin")
                  
                  if skin == "Moon Cat" then
                      task.spawn(idleStuff.Activate, petThing)
                  end
                  
                  if stuff.smartStuff and not skin then
                      local worked, cooldowns = pcall(cooldownThing.InvokeServer, cooldownThing, uuid)
                      if worked and type(cooldowns) == "table" then
                          for _, cd in pairs(cooldowns) do
                              local timeLeft = tonumber(cd.Time)
                              if timeLeft and timeLeft >= 78 and timeLeft <= 82 then
                                  task.spawn(idleStuff.Activate, petThing)
                                  popup("holyy", "auto idle pet (" .. math.floor(timeLeft) .. "s left)")
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
  while isRunning do
      if stuff.idleMode then
          doTheIdleThing()
      end
      task.wait(1)
  end
end)

local theUI = makeTheUI()
getgenv().help = theUI

popup("wow so epic", "superrr. press insert to toggle")

getgenv().help = {
  UI = theUI,
  Destroy = function()
      isRunning = false
      if theUI then theUI:Destroy() end
  end
}