local ReplicatedStorage = game:GetService("ReplicatedStorage")

export type GrowthObject = {
	Model: Model,
	Points: number,
	Weight: number,
}

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Models = Assets.Models

local ObjectTypes: { [string]: GrowthObject } = {
	["Apple"] = {
		Model = Models.Apple,
		Points = 1,
		Weight = 100,
	},
	["Banana"] = {
		Model = Models.Banana,
		Points = 4,
		Weight = 100,
	},
	["Burger"] = {
		Model = Models.Burger,
		Points = 32,
		Weight = 75,
	},
	["Pizza"] = {
		Model = Models.Pizza,
		Points = 128,
		Weight = 100,
	},
}

return ObjectTypes
