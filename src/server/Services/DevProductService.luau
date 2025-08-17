-- Most of this is lifted from Roblox's documentation
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Collection.GameConfig)
local PlayerStateService = require(script.Parent.PlayerStateService)
local PointService = require(script.Parent.PointService)

local productFunctions = {}

productFunctions[GameConfig.DevProducts.Respawn] = function(_receipt, player)
	PlayerStateService.RespawnPlayer(player)
end

productFunctions[GameConfig.DevProducts.TenK] = function(_reciept, player)
	PointService:IncrementPoints(player, 10_000)
end

productFunctions[GameConfig.DevProducts.FiftyK] = function(_reciept, player)
	PointService:IncrementPoints(player, 50_000)
end

productFunctions[GameConfig.DevProducts.HundredK] = function(_reciept, player)
	PointService:IncrementPoints(player, 100_000)
end

local function processReceipt(receiptInfo)
	local userId = receiptInfo.PlayerId
	local productId = receiptInfo.ProductId

	local player = Players:GetPlayerByUserId(userId)
	if player then
		-- Gets the handler function associated with the developer product ID and attempts to run it
		local handler = productFunctions[productId]
		local success, result = pcall(handler, receiptInfo, player)
		if success then
			-- The user has received their items
			-- Returns "PurchaseGranted" to confirm the transaction
			return Enum.ProductPurchaseDecision.PurchaseGranted
		else
			warn("Failed to process receipt:", receiptInfo, result)
		end
	end

	-- The user's items couldn't be awarded
	-- Returns "NotProcessedYet" and tries again next time the user joins the experience
	return Enum.ProductPurchaseDecision.NotProcessedYet
end

-- Sets the callback
-- This can only be done once by one server-side script
MarketplaceService.ProcessReceipt = processReceipt

return nil
