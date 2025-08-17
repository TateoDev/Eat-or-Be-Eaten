--!strict
--LOADED SERVICES--
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--DEPENDENCIES--
local AudioService = require(script.Parent.AudioService)
local GameConfig = require(ReplicatedStorage.Collection.GameConfig)
local PointService = require(script.Parent.PointService)

local collection = ReplicatedStorage:WaitForChild("Collection")
local objectTypes = require(collection.ObjectTypes)

--Fusion nonsense
local Fusion = require(ReplicatedStorage.Shared.fusion.Fusion)
local scoped = Fusion.scoped
local Tag = require(ReplicatedStorage.Shared.UIComponents.OverheadTag)

--TYPES--
type ObjectServiceImpl = {
	GetRandomObject: () -> string,
	SpawnObject: (self: ObjectServiceImpl, object: string, position: Vector2) -> (),
	PlayerTouch: (player: Player, hitPart: BasePart) -> (),
}

--IMPLEMENTATION--
local SPAWN_TIME = 1
local OBJECT_LIFETIME = SPAWN_TIME * 20

local playerConnections: { [Player]: RBXScriptConnection } = {}

local params = RaycastParams.new()
params.FilterType = Enum.RaycastFilterType.Include
params.FilterDescendantsInstances = { workspace.Grass, workspace.Baseplate, workspace.BonusArea }

local ObjectService: ObjectServiceImpl = {
	GetRandomObject = function()
		local totalWeight = 0
		local weights: { { key: string, weight: number } } = {}
		for key, object in objectTypes do
			totalWeight += object.Weight
			table.insert(weights, { key = key, weight = object.Weight })
		end

		local r = math.random() * totalWeight
		local cumulative = 0

		for _key, v in weights do
			cumulative += v.weight
			if r < cumulative then
				return v.key
			end
		end

		return "Apple"
	end,
	SpawnObject = function(_self, object, position)
		local objectInfo = objectTypes[object]
		local objectToSpawn = objectInfo
		local model = objectToSpawn.Model
		model = objectInfo.Model:Clone() :: Model

		model.Parent = workspace
		model.Name = object
		model:AddTag("Object")
		Debris:AddItem(model, OBJECT_LIFETIME)
		model:SetAttribute("StartTime", os.clock())

		if not model.PrimaryPart then
			error(`Primary part not found for object: {object}`)
		end

		local hitbox = Instance.new("Part")
		hitbox.Anchored = true
		hitbox.CanCollide = false
		hitbox.CastShadow = false
		hitbox.Transparency = 1
		hitbox.Size = model.PrimaryPart.Size + Vector3.new(0, 100, 0)
		hitbox.Position = model.PrimaryPart.Position + Vector3.new(0, hitbox.Size.Y / 2, 0)
		hitbox.Parent = model

		local positionCast = workspace:Raycast(Vector3.new(position.X, 40, position.Y), -Vector3.yAxis * 200, params)
		model:PivotTo(CFrame.new(positionCast.Position + Vector3.new(0, model.PrimaryPart.Size.Y / 2, 0)))

		model:SetAttribute("Base", model.PrimaryPart.Position)

		local bonus = false

		if positionCast.Instance == workspace.BonusArea then
			bonus = true
			model:SetAttribute("Bonus", true)
		end

		local objectScope = scoped(Fusion, {
			OverHeadTag = Tag,
		})

		local _Tag = objectScope:OverHeadTag({
			Text = `{objectToSpawn.Points * if bonus then 2 else 1}`,
			Parent = model.PrimaryPart,
			Color = if bonus then GameConfig.Colors.Magenta else GameConfig.Colors.Yellow,
			Height = model.PrimaryPart.Size.Y / 2,
		})
		model.Destroying:Connect(function()
			objectScope:doCleanup()
		end)
	end,
	PlayerTouch = function(player, hitPart)
		if hitPart.Parent then
			if hitPart.Parent:HasTag("Object") then
				local bonus = hitPart.Parent:GetAttribute("Bonus") or false
				if
					objectTypes[hitPart.Parent.Name].Points
					and PointService:GetPoints(player)
						>= objectTypes[hitPart.Parent.Name].Points * if bonus then 2 else 1
				then
					if bonus then
						PointService:IncrementPoints(player, objectTypes[hitPart.Parent.Name].Points * 2)
					else
						PointService:IncrementPoints(player, objectTypes[hitPart.Parent.Name].Points)
					end
					AudioService.PlayGlobalSound({
						"Bite",
						"Bite2",
						"Bite3",
					}, 0.4, hitPart)
					hitPart.Parent:Destroy()
				end
			end

			local player2 = Players:GetPlayerFromCharacter(hitPart.Parent)
			if player2 then
				local p1Points = PointService:GetPoints(player)
				local p2Points = PointService:GetPoints(player2)

				if p1Points > p2Points then
					local character2 = player2.Character
					if not character2 then
						return
					end
					local humanoid = character2:FindFirstChildOfClass("Humanoid")
					if humanoid then
						if humanoid.Health > 0 then
							humanoid:TakeDamage(humanoid.Health)
							PointService:IncrementPoints(player, p2Points)
						end
					end
				end
			end
		end
	end,
}

task.spawn(function()
	for _ = 1, 100 do
		ObjectService:SpawnObject(
			ObjectService.GetRandomObject(),
			Vector2.new(
				math.random(-workspace.Baseplate.Size.X / 2, workspace.Baseplate.Size.X / 2),
				math.random(-workspace.Baseplate.Size.X / 2, workspace.Baseplate.Size.Z / 2)
			)
		)
	end

	while task.wait(SPAWN_TIME) do
		for _ = math.random(1, 5), 10 * #Players:GetPlayers() * 2 do
			ObjectService:SpawnObject(
				ObjectService.GetRandomObject(),
				Vector2.new(
					math.random(-workspace.Baseplate.Size.X / 2, workspace.Baseplate.Size.X / 2),
					math.random(-workspace.Baseplate.Size.X / 2, workspace.Baseplate.Size.Z / 2)
				)
			)
		end
	end
end)

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		local humanoidRootPart = character:WaitForChild("HumanoidRootPart") :: BasePart

		if playerConnections[player] then
			playerConnections[player]:Disconnect()
		end
		playerConnections[player] = humanoidRootPart.Touched:Connect(function(hitPart)
			ObjectService.PlayerTouch(player, hitPart)
		end)
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	if playerConnections[player] then
		playerConnections[player]:Disconnect()
		playerConnections[player] = nil
	end
end)

return ObjectService
