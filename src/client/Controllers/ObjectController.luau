local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local sine = math.sin --Tiny optimization for when calculating tons of items

local MAX_DISTANCE = 200
local BOBBING_SPEED = 2
local BOBBING_AMPLITUDE = 0.5
local ROTATION_SPEED = 1

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart") :: BasePart

local ObjectController = {
	RotateItems = function(_dt)
		local t = os.clock()
		for _, model: Model in CollectionService:GetTagged("Object") do
			local pivot = model:GetPivot()
			if not pivot or (pivot.Position - humanoidRootPart.Position).Magnitude > MAX_DISTANCE then
				continue
			end
			local startTime = model:GetAttribute("StartTime")
			local originalPosition = model:GetAttribute("Base")

			local newPosition = originalPosition
				+ Vector3.new(0, sine((t + startTime) * BOBBING_SPEED) * BOBBING_AMPLITUDE, 0)
			model:PivotTo(CFrame.new(newPosition) * CFrame.Angles(0, ROTATION_SPEED * t, 0))
		end
	end,
}

RunService.PreSimulation:Connect(ObjectController.RotateItems)

player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	humanoidRootPart = newCharacter:WaitForChild("HumanoidRootPart")
end)

return ObjectController
