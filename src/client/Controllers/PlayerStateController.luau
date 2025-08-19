local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage:WaitForChild("Assets")

local player = Players.LocalPlayer

local PlayerStateController = {}

player.CharacterAdded:Connect(function(character)
	if player:GetAttribute("State") == "Lobby" then
		local humanoidRootPart = character:WaitForChild("HumanoidRootPart") :: BasePart

		local rootAttachment = Instance.new("Attachment")
		rootAttachment.Parent = humanoidRootPart

		local arrowBeam: Beam = Assets.ArrowBeam:Clone()
		arrowBeam.Parent = character
		arrowBeam.Attachment0 = rootAttachment
		arrowBeam.Attachment1 = workspace.Lobby.GamePart.Attachment
	end
end)

return PlayerStateController
