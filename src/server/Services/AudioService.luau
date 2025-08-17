local ReplicatedStorage = game:GetService("ReplicatedStorage")

type AudioServiceImpl = {
	PlayGlobalSound: (soundName: string | { string }, volume: number?, parent: Instance?) -> (),
}

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local playSound: RemoteEvent = Remotes.PlaySound

local AudioService: AudioServiceImpl = {
	PlayGlobalSound = function(soundName, volume, parent)
		playSound:FireAllClients(soundName, volume, parent)
	end,
}

return AudioService
