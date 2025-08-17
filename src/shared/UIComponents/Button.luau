local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local AudioController = require(StarterPlayer.StarterPlayerScripts.Client.Controllers.AudioController)
local Fusion = require(ReplicatedStorage.Shared.fusion.Fusion)
local children = Fusion.Children
local event = Fusion.OnEvent

type UsedAs<t> = Fusion.UsedAs<t>

local function Button(
	scope: Fusion.Scope,
	props: {
		Position: UsedAs<UDim2>?,
		Size: UsedAs<UDim2>?,
		Text: UsedAs<string>?,
		TextColor: UsedAs<Color3>?,
		TextStrokeColor: UsedAs<Color3>?,
		Color: UsedAs<Color3>?,
		Name: UsedAs<string>?,
		LayoutOrder: UsedAs<number>?,
		OnClick: (() -> ())?,
	}
)
	local goal = scope:Value(1)
	local sizeSpring = scope:Spring(goal, 25, 0.5)

	return scope:New("TextButton")({
		--styling
		Position = props.Position,
		Name = props.Name or "Button",
		Text = props.Text,
		TextColor3 = props.TextColor or Color3.new(0, 0, 0),
		TextStrokeColor3 = props.TextStrokeColor or Color3.new(0, 0, 0),
		TextStrokeTransparency = if props.TextStrokeColor ~= nil then 0 else 1,
		TextScaled = true,
		Font = Enum.Font.BuilderSans,

		LayoutOrder = props.LayoutOrder or 1,

		BackgroundTransparency = 0,
		BackgroundColor3 = props.Color,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = props.Size or UDim2.fromScale(0.1, 0.1),

		[event("MouseEnter")] = function()
			goal:set(1.2)
			AudioController.playLocalSound("Hover", 1)
		end,

		[event("MouseLeave")] = function()
			goal:set(1)
		end,

		[children] = {
			scope:New("UIAspectRatioConstraint")({
				AspectRatio = 1,
			}),
			scope:New("UICorner")({
				CornerRadius = UDim.new(0.3, 0),
			}),
			scope:New("UIScale")({
				Scale = sizeSpring,
			}),
		},

		--functionality
		[event("Activated")] = function()
			AudioController.playLocalSound("Select", 1)
			sizeSpring:addVelocity(-10)
			if props.OnClick ~= nil then
				props.OnClick()
			end
		end,
	})
end
return Button
