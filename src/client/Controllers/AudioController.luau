local ReplicatedStorage = game:GetService("ReplicatedStorage")
type AudioControllerImpl = {
	playLocalSound: (soundName: string | { string }, volume: number?, parent: Instance?) -> (),
}

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local playSound: RemoteEvent = Remotes.PlaySound

local assets = ReplicatedStorage:WaitForChild("Assets")
local sounds = assets.Sounds
local sfx = sounds.SFX

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
			soundToPlay = sfx:FindFirstChild(soundName):Clone()
		elseif typeof(soundName) == "table" then
			soundToPlay = sfx:FindFirstChild(soundName[math.random(#soundName)]):Clone()
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

playSound.OnClientEvent:Connect(AudioController.playLocalSound)

return AudioController
