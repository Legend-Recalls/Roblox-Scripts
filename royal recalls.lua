
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "Royal Recalls", HidePremium = true, SaveConfig = true,IntroEnabled = true, ConfigFolder = "OrionTest"})

local Tab = Window:MakeTab({
    Name = "Gem Farm",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local Section = Tab:AddSection({
    Name = "Tween Settings"
})


-- Define the slider and its callback function
local movementSpeedSlider = Tab:AddSlider({
    Name = "Movement Speed",
    Min = 0,
    Max = 200,
    Default = 15,
    Color = Color3.fromRGB(255,255,255),
    Increment = 1,
    ValueName = "ticks",
    Callback = function(value)
        -- Modify the SPEED_LIMITER variable in the existing script
        SPEED_LIMITER = value
    end
})

Tab:AddButton({
    Name = "Rejoin (use when out of diamonds)",
    Callback = function()
        local module = loadstring(game:HttpGet"https://raw.githubusercontent.com/LeoKholYt/roblox/main/lk_serverhop.lua")()
		module:Teleport(game.PlaceId)
    end
})


-- Set up the Part ESP
local function createPartESP(part)
    local BillboardGui = Instance.new('BillboardGui')
    local TextLabel = Instance.new('TextLabel')
    
    BillboardGui.Parent = part
    BillboardGui.AlwaysOnTop = true
    BillboardGui.Size = UDim2.new(0, 50, 0, 50)
    BillboardGui.StudsOffset = Vector3.new(0,2,0)
    
    TextLabel.Parent = BillboardGui
    TextLabel.BackgroundColor3 = Color3.new(1,1,1)
    TextLabel.BackgroundTransparency = 1
    TextLabel.Size = UDim2.new(1, 0, 1, 0)
    TextLabel.Text = "Distance: "
    TextLabel.TextColor3 = Color3.new(1, 0, 0)
    TextLabel.TextScaled = true
    
    -- Continuously update the distance on the Part ESP
    game:GetService("RunService").Heartbeat:Connect(function()
        local player = game.Players.LocalPlayer
        local distance = math.floor((player.Character.HumanoidRootPart.Position - part.Position).magnitude)
        TextLabel.Text = "Distance: " .. tostring(distance)
    end)
end

-- Create the Part ESP for all parts in CollectibleDiamonds
for _, part in pairs(game.Workspace.CollectibleDiamonds:GetDescendants()) do
    if part:IsA("BasePart") then
        createPartESP(part)
    end
end

-- Continuously create the Part ESP for new parts
game.Workspace.CollectibleDiamonds.DescendantAdded:Connect(function(part)
    if part:IsA("BasePart") and not part:FindFirstChild("BillboardGui") then
        createPartESP(part)
    end
end)

Tab:AddToggle({
	Name = "Tween on nearest diamond",
	Default = true,
	Callback = function(Value)
		-- Modify the shouldTween variable in the existing script
        shouldTween = Value
	end    
})

-- Teleport to nearest diamond on key press
local TELEPORT_HOTKEY = 'f'


local function teleportToNearestDiamond()
    local user = game.Players.LocalPlayer
    local root_part = user.Character:FindFirstChild('HumanoidRootPart') or user.Character:FindFirstChild('Torso')
    root_part.Anchored = true
    
    local nearestPart
    local nearestDist = math.huge
    
    -- Find the nearest diamond
    for _, part in pairs(game.Workspace.CollectibleDiamonds:GetDescendants()) do
        if part:IsA("BasePart") then
            local distance = (part.Position - root_part.Position).magnitude
            if distance < nearestDist then
                nearestDist = distance
                nearestPart = part
            end
        end
    end
    
    -- Move towards the nearest diamond using tween if shouldTween is true
    if nearestPart and shouldTween then
        local target = nearestPart.Position + Vector3.new(0, 4, 0)
        local start = root_part.CFrame
        local distance = (target - start.p).magnitude
        local time = distance / SPEED_LIMITER
        
        game:GetService("TweenService"):Create(root_part, TweenInfo.new(time, Enum.EasingStyle.Linear), {CFrame = CFrame.new(target)}):Play()
		
		--check if sitting
		local player = game:GetService("Players").LocalPlayer
		local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid.Sit then
	
			local Char = game:GetService("Players").LocalPlayer.Character
			local humanoid = Char:FindFirstChild("Humanoid")

			if humanoid then
				humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
				humanoid.StateChanged:Connect(function(oldState, newState)
					-- handle state change here
				end)
			end
		end

    
        root_part.Anchored = false
    end
end

    
    -- Move towards the nearest diamond using tween if shouldTween is true
    if nearestPart and shouldTween then
        local target = nearestPart.Position + Vector3.new(0, 4, 0)
        local start = root_part.CFrame
        local distance = (target - start.p).magnitude
        local time = distance / SPEED_LIMITER
        
        game:GetService("TweenService"):Create(root_part, TweenInfo.new(time, Enum.EasingStyle.Linear), {CFrame = CFrame.new(target)}):Play()
		
		--check if sitting
        local Char = game:GetService("Players").LocalPlayer.Character
        local humanoid = Char:FindFirstChild("Humanoid")
        
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            humanoid.StateChanged:Connect(function(oldState, newState)
                if oldState == Enum.HumanoidStateType.Jumping and 
                   (newState == Enum.HumanoidStateType.Running or 
                    newState == Enum.HumanoidStateType.Walking) then
                    humanoid:ChangeState(newState)
                end
            end)
        end
        


    end
    
    root_part.Anchored = false
end

-- Teleport on key press
game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode[string.upper(TELEPORT_HOTKEY)] then
        teleportToNearestDiamond()
    end
end)

local toggleTween = false -- keep track of whether the toggle is on or off

-- Add the toggle to the "Gem Farm" tab
Tab:AddToggle({
    Name = "Auto Tween",
    Default = false,
    Callback = function(Value)
        toggleTween = Value -- update the toggleTween variable with the current toggle value
        if toggleTween then -- if the toggle is on, continuously tween to the nearest diamond
            while toggleTween do
                teleportToNearestDiamond()
                wait(1) -- wait for 1 second before checking for the nearest diamond again
            end
        end
    end    
})



OrionLib:Init()
