local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SocialService = game:GetService("SocialService")

local Fusion = require(ReplicatedStorage.Shared.fusion.Fusion)
local Button = require(ReplicatedStorage.Shared.UIComponents.Button)
local scoped = Fusion.scoped
local children = Fusion.Children

local player = Players.LocalPlayer

local socialScope = scoped(Fusion, {
	Button = Button,
})

local SocialController = {
	Init = function()
		return socialScope:New("ScreenGui")({
			Parent = player:FindFirstChildOfClass("PlayerGui"),
			Name = "Social",
			IgnoreGuiInset = true,
			Enabled = true,

			[children] = {
				socialScope:Button({
					Text = "Invite Friends",
					Color = Color3.new(0.760784, 0.815686, 0.894118),
					TextStrokeColor = Color3.new(1, 1, 1),

					Position = UDim2.fromScale(0.95, 0.6),
					Size = UDim2.fromScale(0.15, 0.15),

					OnClick = function()
						local success, canSend = pcall(function()
							return SocialService:CanSendCallInviteAsync(player)
						end)
						if success and canSend then
							SocialService:PromptGameInvite(player)
						end
					end,
				}),
			},
		})
	end,
}

local _socialUi = SocialController.Init()

return SocialController
