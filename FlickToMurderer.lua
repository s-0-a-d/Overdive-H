local shared = odh_shared_plugins

local flick_section = shared.AddSection("Flick to Murderer V3")

flick_section:AddLabel("Credits: @thanhtv68_ (Mồn Lèo)")

local flickEnabled = false
local flickDuration = 0.3
local autoShotEnabled = false
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local murdererButton

local function findMurderer()
    if game.PlaceId == 142823291 then
        local success, roleData = pcall(function()
            local remote = ReplicatedStorage:FindFirstChild("GetPlayerData", true)
            if remote and remote:IsA("RemoteFunction") then
                return remote:InvokeServer()
            end
        end)
        if success and roleData then
            for playerName, data in pairs(roleData) do
                if data.Role == "Murderer" and not data.Killed and not data.Dead then
                    local p = Players:FindFirstChild(playerName)
                    if p then
                        return p
                    end
                end
            end
        end
        return nil
    else
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                local backpack = player:FindFirstChildOfClass("Backpack")
                if backpack and backpack:FindFirstChild("Knife") then
                    return player
                end
                for _, item in ipairs(player.Character:GetChildren()) do
                    if item:IsA("Tool") and item.Name == "Knife" then
                        return player
                    end
                end
            end
        end
        return nil
    end
end

local function shootGun()
    local char = LocalPlayer.Character
    if not char then return end
    local gun = char:FindFirstChild("Gun") or LocalPlayer.Backpack:FindFirstChild("Gun")
    if not gun then return end
    if gun.Parent == LocalPlayer.Backpack then
        LocalPlayer.Character.Humanoid:EquipTool(gun)
        task.wait(0.1)
    end
    local args = {0, Vector3.new(), "AH2"}
    local rf = gun:WaitForChild("KnifeLocal"):WaitForChild("CreateBeam"):WaitForChild("RemoteFunction")
    rf:InvokeServer(unpack(args))
end

local function flickToMurderer()
    if not flickEnabled then return end
    local murderer = findMurderer()
    if not murderer or not murderer.Character or not murderer.Character:FindFirstChild("HumanoidRootPart") then
        shared.Notify("⚠ Murderer not found!", 3)
        return
    end
    local cam = workspace.CurrentCamera
    local oldCFrame = cam.CFrame
    cam.CFrame = CFrame.lookAt(cam.CFrame.Position, murderer.Character.HumanoidRootPart.Position)
    task.delay(flickDuration, function()
        cam.CFrame = oldCFrame
    end)
    if autoShotEnabled then
        shootGun()
    end
end

flick_section:AddToggle("Enable Flick", function(state)
    flickEnabled = state
end)

flick_section:AddTextBox("Set Flick Duration (s) [ default 0.3]", function(text)
    local num = tonumber(text)
    if num and num > 0 then
        flickDuration = num
    else
        shared.Notify("Invalid value!", 3)
    end
end)

flick_section:AddKeybind("Flick Key", "F", function()
    flickToMurderer()
end)

flick_section:AddToggle("Auto Shot After Flick", function(state)
    autoShotEnabled = state
    if murdererButton then
        murdererButton.Text = autoShotEnabled and "FLICK + SHOT" or "FLICK"
    end
end)

flick_section:AddToggle("Show Mobile Flick Button", function(state)
    if state then
        if murdererButton then murdererButton:Destroy() end
        local gui = Instance.new("ScreenGui")
        gui.Name = "FlickMobileGui"
        gui.ResetOnSpawn = false
        gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
        local button = Instance.new("TextButton")
        button.Text = autoShotEnabled and "FLICK + SHOT" or "FLICK"
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
        button.Size = UDim2.new(0, 120, 0, 40)
        button.Position = UDim2.new(0.75, 0, 0.2, 0)
        button.Active = true
        button.Parent = gui
        murdererButton = button

        local dragging, dragInput, dragStart, startPos

        button.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = Vector2.new(button.Position.X.Offset, button.Position.Y.Offset)
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)

        button.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)

        UIS.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                local delta = input.Position - dragStart
                local screenSize = workspace.CurrentCamera.ViewportSize
                button.Position = UDim2.new(
                    0, math.clamp(startPos.X + delta.X, 0, screenSize.X - button.AbsoluteSize.X),
                    0, math.clamp(startPos.Y + delta.Y, 0, screenSize.Y - button.AbsoluteSize.Y)
                )
            end
        end)

        button.MouseButton1Click:Connect(function()
            flickToMurderer()
        end)
    else
        if murdererButton then
            murdererButton:Destroy()
            murdererButton = nil
        end
    end
end)
