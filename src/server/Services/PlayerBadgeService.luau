local BadgeService = game:GetService("BadgeService")
local Players = game:GetService("Players")

type PlayerBadgeServiceImpl = {
	AwardPointBadges: (player: Player, points: number) -> (),
}

local POINT_BADGES = {
	[100] = 3177261438529814,
	[1000] = 1427405704007801,
	[10_000] = 4485609247508280,
	[100_000] = 374883704126420,
}

local JOIN_BADGE = 2887094190919384

-- I could set this up when the player joins, but even just doing this while save several async calls
local playerBadges: { [Player]: { [number]: boolean } } = {}

local PlayerBadgeService: PlayerBadgeServiceImpl = {
	AwardPointBadges = function(player, points)
		for pointsValue, badgeID in POINT_BADGES do
			if playerBadges[player][badgeID] == true then
				continue
			end

			if points >= pointsValue then
				local success, ownsBadge = pcall(function()
					return BadgeService:UserHasBadgeAsync(player.UserId, badgeID)
				end)
				if success and not ownsBadge then
					BadgeService:AwardBadge(player.UserId, badgeID)
					playerBadges[player][badgeID] = true
				end
			end
		end
	end,
}

Players.PlayerAdded:Connect(function(player)
	local success, ownsBadge = pcall(function()
		return BadgeService:UserHasBadgeAsync(player.UserId, JOIN_BADGE)
	end)
	if success and not ownsBadge then
		BadgeService:AwardBadge(player.UserId, JOIN_BADGE)
	end
	playerBadges[player] = {}
end)

Players.PlayerRemoving:Connect(function(player)
	playerBadges[player] = nil
end)

return PlayerBadgeService
