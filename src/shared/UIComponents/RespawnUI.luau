local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Collection.GameConfig)
local Fusion = require(ReplicatedStorage.Shared.fusion.Fusion)
local children = Fusion.Children
local Button = require(script.Parent.Button)

type UsedAs<t> = Fusion.UsedAs<t>

local player = Players.LocalPlayer

local function RespawnUI(
	scope: Fusion.Scope,
	props: {
		RespawnCallback: UsedAs<() -> ()>,
		LobbyCallback: UsedAs<() -> ()>,
	}
)
	local inScope = scope:innerScope({
		Button = Button,
	})

	return scope:New("ScreenGui")({
		Name = "RespawnUI",
		IgnoreGuiInset = true,
		ResetOnSpawn = true,
		Parent = player:FindFirstChildWhichIsA("PlayerGui"),
		[children] = {
			scope:New("Frame")({
				Size = UDim2.fromScale(1, 1),
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),

				BackgroundColor3 = Color3.new(0, 0, 0),
				BackgroundTransparency = 0.3,

				[children] = {
					scope:New("TextLabel")({
						Text = "YOU DIED",
						Font = Enum.Font.BuilderSansExtraBold,
						TextScaled = true,
						TextXAlignment = Enum.TextXAlignment.Center,
						TextColor3 = GameConfig.Colors.Red,

						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.25),
						Size = UDim2.fromScale(0.33, 0.2),

						BackgroundTransparency = 1,
						[children] = {
							scope:New("UIStroke")({
								Thickness = 1,
								Color = Color3.new(0, 0, 0),
							}),
						},
					}),
					inScope:Button({
						Text = "Respawn: 25 ROBUX",
						Size = UDim2.fromScale(0.3, 0.3),
						Position = UDim2.fromScale(0.3, 0.6),
						Color = GameConfig.Colors.Red,
						TextStrokeColor = Color3.new(1, 1, 1),
						OnClick = props.RespawnCallback,
					}),
					inScope:Button({
						Text = "Return to Lobby",
						Size = UDim2.fromScale(0.3, 0.3),
						Position = UDim2.fromScale(0.7, 0.6),
						TextStrokeColor = Color3.new(1, 1, 1),
						Color = GameConfig.Colors.Blue,
						OnClick = props.LobbyCallback,
					}),
				},
			}),
		},
	})
end

return RespawnUI
