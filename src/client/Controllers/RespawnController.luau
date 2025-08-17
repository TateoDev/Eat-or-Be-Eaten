local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local GameConfig = require(ReplicatedStorage.Collection.GameConfig)

local Fusion = require(ReplicatedStorage.Shared.fusion.Fusion)
local scoped = Fusion.scoped
local RespawnUI = require(ReplicatedStorage.Shared.UIComponents.RespawnUI)

type RespawnControllerImpl = {
	OnRespawnPrompted: () -> boolean,
}

local RESPAWN_PRODUCT_ID = GameConfig.DevProducts.Respawn

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local promptRespawn: RemoteFunction = remotes.PromptRespawn

local player = Players.LocalPlayer

local RespawnController: RespawnControllerImpl = {
	OnRespawnPrompted = function()
		local resultEvent = Instance.new("BindableEvent")

		local respawnScope = scoped(Fusion, {
			UI = RespawnUI,
		})

		local _UI = respawnScope:UI({
			LobbyCallback = function()
				resultEvent:Fire(false)
			end,

			RespawnCallback = function()
				MarketplaceService:PromptProductPurchase(player, RESPAWN_PRODUCT_ID)
				MarketplaceService.PromptProductPurchaseFinished:Connect(function(pPlayer, pId, success)
					if pPlayer == player and pId == RESPAWN_PRODUCT_ID then
						if success then
							resultEvent:Fire(true)
						end
					end
				end)
			end,
		})
		local result = resultEvent.Event:Wait()
		return result
	end,
}

promptRespawn.OnClientInvoke = function()
	return RespawnController.OnRespawnPrompted()
end

return RespawnController
