local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage:WaitForChild("Assets")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local gamepart = workspace:WaitForChild("Lobby", 3):WaitForChild("GamePart", 3)

local PlayerStateController = {
	CreateBeam = function()
		if player:GetAttribute("State") == "Lobby" then
			local humanoidRootPart = character:WaitForChild("HumanoidRootPart") :: BasePart

			local rootAttachment = Instance.new("Attachment")
			rootAttachment.Parent = humanoidRootPart

			local arrowBeam: Beam = Assets.ArrowBeam:Clone()
			arrowBeam.Parent = character
			arrowBeam.Attachment0 = rootAttachment
			if gamepart then
				arrowBeam.Attachment1 = gamepart:FindFirstChildOfClass("Attachment")
			end
		end
	end,
}
PlayerStateController.CreateBeam()

player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	PlayerStateController.CreateBeam()
end)

return PlayerStateController
