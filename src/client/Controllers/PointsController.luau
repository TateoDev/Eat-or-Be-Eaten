local LocalizationService = game:GetService("LocalizationService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Collection.GameConfig)
local Fusion = require(ReplicatedStorage.Shared.fusion.Fusion)
local scoped = Fusion.scoped
local peek = Fusion.peek
local children = Fusion.Children

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local updatePoints: RemoteEvent = remotes.UpdatePoints

local player = Players.LocalPlayer

local pointsScope = scoped(Fusion)
local points = pointsScope:Value(0)

local PointsController = {
	Init = function()
		return pointsScope:New("ScreenGui")({
			Parent = player:FindFirstChildOfClass("PlayerGui"),
			IgnoreGuiInset = true,
			Enabled = false,
			DisplayOrder = 3,
			[children] = {
				pointsScope:New("TextLabel")({
					Text = pointsScope:Computed(function(use, _)
						use(points)
						local p = peek(points)
						-- fun bit of localization
						if LocalizationService:GetCountryRegionForPlayerAsync(player) == "US" then
							return `Weight: {p} LBS`
						else
							return `Weight: {p} KILOS`
						end
					end),
					Font = Enum.Font.BuilderSansBold,
					BackgroundTransparency = 1,
					TextColor3 = GameConfig.Colors.Yellow,
					Size = UDim2.fromScale(0.5, 0.1),
					Position = UDim2.fromScale(0.5, 0.1),
					AnchorPoint = Vector2.new(0.5, 0.5),
					TextScaled = true,
					[children] = {
						pointsScope:New("UIStroke")({
							Thickness = 2,
							Color = Color3.new(0, 0, 0),
						}),
					},
				}),
			},
		})
	end,
	UpdatePoints = function(pointsTotal)
		points:set(pointsTotal)
	end,
}

local UI = PointsController.Init()
updatePoints.OnClientEvent:Connect(PointsController.UpdatePoints)

player.CharacterAdded:Connect(function(_character)
	if player:GetAttribute("State") == "Lobby" then
		UI.Enabled = false
	else
		UI.Enabled = true
	end
end)
return PointsController
