--!strict
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Collection.GameConfig)

local Fusion = require(ReplicatedStorage.Shared.fusion.Fusion)
local scoped = Fusion.scoped
local peek = Fusion.peek
local OverheadTag = require(ReplicatedStorage.Shared.UIComponents.OverheadTag)

type PointsServiceImpl = {
	GetPoints: (self: PointsServiceImpl, player: Player) -> number,
	SetPoints: (self: PointsServiceImpl, player: Player, pointsToSet: number) -> (),
	IncrementPoints: (self: PointsServiceImpl, player: Player, pointsToIncrement: number) -> (),
}

local POINTS_NAME = "Weight"

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local updatePoints: RemoteEvent = remotes.UpdatePoints
local pointsEvent: BindableEvent = remotes.PointsEvent

local PointsService: PointsServiceImpl = {
	GetPoints = function(_self, player)
		local leaderstats = player:WaitForChild("leaderstats") :: Folder
		local points = leaderstats:WaitForChild(POINTS_NAME) :: IntValue

		return points.Value
	end,
	SetPoints = function(_self, player, pointsToSet)
		local leaderstats = player:WaitForChild("leaderstats") :: Folder
		local points = leaderstats:WaitForChild(POINTS_NAME) :: IntValue

		points.Value = pointsToSet
		local character = player.Character or player.CharacterAdded:Wait()
		local humanoid = character:WaitForChild("Humanoid") :: Humanoid

		local desc = humanoid:GetAppliedDescription()
		desc.WidthScale = math.clamp(math.log(points.Value) / 2, 0.3, math.huge)
		desc.DepthScale = math.clamp(math.log(points.Value) / 2, 0.3, math.huge)
		desc.HeightScale = math.clamp(math.log(points.Value) / 4, 1, math.huge)

		humanoid:ApplyDescription(desc)
		updatePoints:FireClient(player, pointsToSet)
		pointsEvent:Fire(player, pointsToSet)
	end,
	IncrementPoints = function(self, player, pointsToSet)
		if MarketplaceService:UserOwnsGamePassAsync(player.UserId, 1406193916) then
			self:SetPoints(player, math.ceil(self:GetPoints(player) + (pointsToSet * 1.5)))
		else
			self:SetPoints(player, self:GetPoints(player) + pointsToSet)
		end
	end,
}

Players.PlayerAdded:Connect(function(player: Player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local points = Instance.new("IntValue")
	points.Name = POINTS_NAME
	points.Value = 0
	points.Parent = leaderstats

	local diedConnection: RBXScriptConnection? = nil
	local pointsConnection: RBXScriptConnection? = nil

	player.CharacterAdded:Connect(function(newCharacter)
		if player:GetAttribute("State") ~= "Playing" then
			return
		end
		local humanoid = newCharacter:WaitForChild("Humanoid") :: Humanoid
		local head = newCharacter:WaitForChild("Head") :: MeshPart

		local tagScope = scoped(Fusion, {
			Tag = OverheadTag,
		})
		local pointsValue = tagScope:Value(1)
		local isVip = tagScope:Value(MarketplaceService:UserOwnsGamePassAsync(player.UserId, 1406193916))

		local _tag = tagScope:Tag({
			Text = tagScope:Computed(function(use, _)
				use(pointsValue)
				return `{peek(pointsValue)}`
			end),
			Parent = head,
			Color = tagScope:Computed(function(use, _)
				use(isVip)
				if isVip then
					return GameConfig.Colors.Magenta
				else
					return GameConfig.Colors.Yellow
				end
			end),
			Height = 3,
		})

		if diedConnection then
			diedConnection:Disconnect()
		end
		diedConnection = humanoid.Died:Connect(function()
			tagScope:doCleanup()
		end)

		if pointsConnection then
			pointsConnection:Disconnect()
		end
		pointsConnection = pointsEvent.Event:Connect(function(pPlayer, pPoints)
			if pPlayer == player then
				pointsValue:set(pPoints)
			end
		end)
	end)
end)

return PointsService
