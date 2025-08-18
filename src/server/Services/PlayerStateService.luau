--!strict
local AnalyticsService = game:GetService("AnalyticsService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PointService = require(script.Parent.PointService)

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local promptRespawnRemote: RemoteFunction = remotes.PromptRespawn

local PlayerStateService = {
	PromptRespawn = function(player)
		local respawn = promptRespawnRemote:InvokeClient(player)

		if respawn == false then
			player:SetAttribute("State", "Lobby")
			player:LoadCharacter()
		end
	end,
	RespawnPlayer = function(player)
		local currentPoints = PointService:GetPoints(player)
		player:SetAttribute("RevivePoints", currentPoints)
		player:LoadCharacter()
	end,
}

local playerConnections: { [Player]: RBXScriptConnection } = {}

Players.PlayerAdded:Connect(function(player: Player)
	player:SetAttribute("State", "Lobby")
	player:LoadCharacter()
	player:SetAttribute("RevivePoints", 1)

	AnalyticsService:LogOnboardingFunnelStepEvent(player, 1, "Joined Game")

	player.CharacterAdded:Connect(function(character)
		if player:GetAttribute("State") == "Playing" then
			local revivePoints = player:GetAttribute("RevivePoints") :: number
			PointService:SetPoints(player, revivePoints)
			player:SetAttribute("RevivePoints", 1)
			character:PivotTo(
				CFrame.new(
					Vector3.new(
						math.random(-workspace.Baseplate.Size.X / 2, workspace.Baseplate.Size.X / 2),
						4,
						math.random(-workspace.Baseplate.Size.X / 2, workspace.Baseplate.Size.Z / 2)
					)
				)
			)
		else
			local leaderstats = player:FindFirstChild("leaderstats")
			if leaderstats then
				local points = leaderstats:FindFirstChild("Weight") :: IntValue

				if points then
					points.Value = 0
				end
			end
		end

		local humanoid = character:WaitForChild("Humanoid") :: Humanoid
		if playerConnections[player] then
			playerConnections[player]:Disconnect()
		end
		playerConnections[player] = humanoid.Died:Connect(function()
			if player:GetAttribute("State") == "Playing" then
				PlayerStateService.PromptRespawn(player)
			end
		end)
	end)
end)

local touchPartDebounces: { [Player]: boolean } = {}

workspace.Lobby.GamePart.Touched:Connect(function(otherPart: BasePart)
	if Players:GetPlayerFromCharacter(otherPart.Parent) then
		local player = Players:GetPlayerFromCharacter(otherPart.Parent)
		if touchPartDebounces[player] then
			return
		end
		touchPartDebounces[player] = true
		player:SetAttribute("State", "Playing")
		player:LoadCharacter()
		AnalyticsService:LogOnboardingFunnelStepEvent(player, 2, "Started Playing")
		task.delay(2, function()
			touchPartDebounces[player] = false
		end)
	end
end)

return PlayerStateService
