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

local PlayerBadgeService: PlayerBadgeServiceImpl = {
	AwardPointBadges = function(player, points)
		for pointsValue, badgeID in POINT_BADGES do
			if points >= pointsValue then
				local success, ownsBadge = pcall(function()
					BadgeService:UserHasBadgeAsync(player.UserId, badgeID)
				end)
				if success and not ownsBadge then
					BadgeService:AwardBadge(player.UserId, badgeID)
				end
			end
		end
	end,
}

Players.PlayerAdded:Connect(function(player)
	local success, ownsBadge = pcall(function()
		BadgeService:UserHasBadgeAsync(player.UserId, JOIN_BADGE)
	end)
	if success and not ownsBadge then
		BadgeService:AwardBadge(player.UserId, JOIN_BADGE)
	end
end)

return PlayerBadgeService
