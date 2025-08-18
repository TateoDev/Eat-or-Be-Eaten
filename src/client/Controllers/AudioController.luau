local ReplicatedStorage = game:GetService("ReplicatedStorage")

type AudioControllerImpl = {
	playLocalSound: (soundName: string | { string }, volume: number?, parent: Instance?) -> (),
}

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local playSound: RemoteEvent = Remotes.PlaySound

local assets = ReplicatedStorage:WaitForChild("Assets")
local sounds = assets.Sounds
local sfx: Folder = sounds.SFX
local music: Folder = sounds.Music

local lastParent = nil

local AudioController: AudioControllerImpl = {
	playLocalSound = function(soundName, volume, parent)
		if lastParent and parent == lastParent then
			return
		end

		local soundToPlay: Sound = nil

		local newP
		if parent then
			lastParent = parent
			newP = parent:Clone()
			newP.Transparency = 1
			newP.Parent = workspace
		end

		if typeof(soundName) == "string" then
			local potentialsound = sfx:FindFirstChild(soundName)
			if potentialsound then
				soundToPlay = potentialsound:Clone()
			else
				error(`Unable to find sound {soundName}`)
			end
		elseif typeof(soundName) == "table" then
			local ran = soundName[math.random(#soundName)]

			local potentialsound = sfx:FindFirstChild(ran)
			if potentialsound then
				soundToPlay = potentialsound:Clone()
			else
				error(`Unable to find sound {ran}`)
			end
		end

		soundToPlay.Volume = volume or 1
		soundToPlay.Parent = newP or workspace
		soundToPlay:Play()

		task.delay(soundToPlay.TimeLength, function()
			if soundToPlay then
				soundToPlay:Destroy()
				if newP then
					newP:Destroy()
				end
			end
		end)
	end,
}

--handle music
local lastSong = nil
task.spawn(function()
	while true do
		local potentialMusic = music:GetChildren()
		local chosenSong: Sound = nil
		repeat
			chosenSong = potentialMusic[math.random(#potentialMusic)]
		until chosenSong ~= nil and chosenSong ~= lastSong
		lastSong = chosenSong
		chosenSong:Play()
		chosenSong.Ended:Wait()
	end
end)

playSound.OnClientEvent:Connect(AudioController.playLocalSound)

return AudioController
