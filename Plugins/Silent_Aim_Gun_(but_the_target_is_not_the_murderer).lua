local shared = odh_shared_plugins

local Players = game:GetService("Players")
local client = Players.LocalPlayer

if not shared or shared.executor == "Unknown" then return end

local notify = shared.Notify
local hook = hookfunction or hookfunc

if not hook then
    error("Silent Aim Gun couldn't be loaded.")
    return
end

local sct = shared.AddSection("Silent Aim Gun (but the target is not the murderer)")

local silent_aim_target_enabled = false
local silent_aim_nearest_enabled = false
local selected_target = nil

local function getPlayerList()
    local playerList = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= client and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            table.insert(playerList, player.Name)
        end
    end
    return playerList
end

local function getNearestPlayer()
    local nearestPlayer = nil
    local nearestDistance = math.huge
    local clientPos = client.Character and client.Character:FindFirstChild("HumanoidRootPart") and client.Character.HumanoidRootPart.Position
    if not clientPos then return nil end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= client and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local distance = (clientPos - player.Character.HumanoidRootPart.Position).Magnitude
            if distance < nearestDistance then
                nearestDistance = distance
                nearestPlayer = player
            end
        end
    end
    return nearestPlayer
end

local function getTargetRoot()
    if silent_aim_target_enabled and selected_target then
        local targetPlayer = Players:FindFirstChild(selected_target)
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") and targetPlayer.Character:FindFirstChild("Humanoid") and targetPlayer.Character.Humanoid.Health > 0 then
            return targetPlayer.Character.HumanoidRootPart
        end
    elseif silent_aim_nearest_enabled then
        return getNearestPlayer() and getNearestPlayer().Character and getNearestPlayer().Character:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

local old
local hook_func = function(slf, ...)
    if slf.Name ~= "RemoteFunction" or slf.Parent.Name ~= "CreateBeam" then
        return old(slf, ...)
    end
    local args = { ... }
    local arg1 = args[1]
    local arg2 = args[2]
    local arg3 = args[3]
    args = nil
    if not tonumber(arg1) or arg3 ~= "AH2" then
        return old(slf, ...)
    end
    local root = getTargetRoot()
    if not root then
        return old(slf, arg1, arg2, arg3)
    end
    return old(slf, arg1, root.Position + (root.AssemblyLinearVelocity.Unit * (-1.53882292591036378 + math.pi)), arg3)
end

local remotefunction = Instance.new("RemoteFunction")
local invoke_server = remotefunction.InvokeServer
remotefunction:Destroy()
old = hook(invoke_server, hook_func)

sct:AddDropdown("Select Target", getPlayerList(), function(selected)
    selected_target = selected
    notify("Target set to " .. selected, 1)
end)

sct:AddButton("Reset", function()
    selected_target = nil
    sct:UpdateDropdown("Select Target", getPlayerList())
    notify("Target list reset!", 4)
end)

sct:AddToggle("Silent Aim Selected Target", function(state)
    silent_aim_target_enabled = state
    if state and silent_aim_nearest_enabled then
        silent_aim_nearest_enabled = false
        sct:UpdateToggle("Silent Aim Nearest Player", false)
    end
    if state and not selected_target then
        silent_aim_target_enabled = false
        sct:UpdateToggle("Silent Aim Selected Target", false)
        notify("No target selected!", 2)
    end
end)

sct:AddToggle("Silent Aim Nearest Player", function(state)
    silent_aim_nearest_enabled = state
    if state and silent_aim_target_enabled then
        silent_aim_target_enabled = false
        sct:UpdateToggle("Silent Aim Selected Target", false)
    end
end)

notify("Silent Aim Gun loaded.", 1)
