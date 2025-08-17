local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Collection.GameConfig)
local Button = require(ReplicatedStorage.Shared.UIComponents.Button)

local Fusion = require(ReplicatedStorage.Shared.fusion.Fusion)
local scoped = Fusion.scoped
local children = Fusion.Children

local VALUES = {
	[1] = { id = GameConfig.DevProducts.TenK, value = 10_000 },
	[2] = { id = GameConfig.DevProducts.FiftyK, value = 50_000 },
	[3] = { id = GameConfig.DevProducts.HundredK, value = 100_000 },
}

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid") :: Humanoid

local diedConnection: RBXScriptConnection = nil

local productScope = scoped(Fusion, { Button = Button })

local DevProductController = {
	Init = function()
		return productScope:New("ScreenGui")({
			Parent = player:FindFirstChildOfClass("PlayerGui"),
			Name = "DevProducts",
			IgnoreGuiInset = true,
			Enabled = false,
			DisplayOrder = 2,

			[children] = {
				productScope:New("Frame")({
					AnchorPoint = Vector2.new(0.5, 0.5),
					Size = UDim2.fromScale(0.5, 0.2),
					Position = UDim2.fromScale(0.5, 0.9),
					BackgroundColor3 = Color3.new(0, 1, 0),
					BackgroundTransparency = 1,

					[children] = {
						productScope:New("UIListLayout")({
							FillDirection = Enum.FillDirection.Horizontal,
							Padding = UDim.new(0.01, 0),
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
							VerticalAlignment = Enum.VerticalAlignment.Center,
							SortOrder = Enum.SortOrder.LayoutOrder,
						}),

						productScope:ForValues(VALUES, function(_use, _scope, value)
							return productScope:Button({
								Text = `+{value.value} weight`,
								Size = UDim2.fromScale(0.8, 0.8),
								Name = `{value.value}`,
								Color = GameConfig.Colors.Blue,
								TextColor = Color3.new(1, 1, 1),
								TextStrokeColor = Color3.new(0, 0, 0),
								LayoutOrder = value.value,
								OnClick = function()
									MarketplaceService:PromptProductPurchase(player, value.id)
								end,
							})
						end),
					},
				}),
			},
		})
	end,
}

local UI = DevProductController.Init()

player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	humanoid = newCharacter:WaitForChild("Humanoid")

	if diedConnection then
		diedConnection:Disconnect()
	end
	diedConnection = humanoid.Died:Connect(function()
		UI.Enabled = false
	end)

	if player:GetAttribute("State") == "Lobby" then
		UI.Enabled = false
	else
		UI.Enabled = true
	end
end)

return DevProductController
