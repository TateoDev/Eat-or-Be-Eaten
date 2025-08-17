local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Shared.fusion.Fusion)

local children = Fusion.Children

type UsedAs<t> = Fusion.UsedAs<t>

local DEFAULT_SIZE = UDim2.fromScale(6, 2)

local function OverHeadTag(
	scope: Fusion.Scope,
	props: {
		Text: UsedAs<string>,
		Parent: UsedAs<Instance>,
		Color: UsedAs<Color3>?,
		Size: UsedAs<UDim2>?,
		Height: UsedAs<number>?,
	}
)
	return scope:New("BillboardGui")({
		Parent = props.Parent,
		Name = "OverheadLabel",
		Adornee = props.Parent,
		AlwaysOnTop = true,
		Size = props.Size or DEFAULT_SIZE,
		MaxDistance = 30,

		StudsOffsetWorldSpace = if typeof(props.Height) == "number"
			then Vector3.new(0, props.Height, 0)
			else Vector3.zero,

		[children] = {
			scope:New("TextLabel")({
				Text = props.Text,
				TextColor3 = props.Color,
				Font = Enum.Font.BuilderSans,
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				Position = UDim2.new(0, 0, 0, 0),
				TextScaled = true,
				[children] = {
					scope:New("UIStroke")({
						Color = Color3.new(0, 0, 0),
						Thickness = 1,
					}),
				},
			}),
		},
	})
end

return OverHeadTag
