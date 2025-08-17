--Disable reset code from:
-- https://devforum.roblox.com/t/resetbuttoncallback-has-not-been-registered-by-the-corescripts/78470/8
local RunService = game:GetService("RunService")

local coreCall
do
	local MAX_RETRIES = 8

	local StarterGui = game:GetService("StarterGui")

	function coreCall(method, ...)
		local result = {}
		for _retries = 1, MAX_RETRIES do
			result = { pcall(StarterGui[method], StarterGui, ...) }
			if result[1] then
				break
			end
			RunService.Stepped:Wait()
		end
		return unpack(result)
	end
end
if not RunService:IsStudio() then
	coreCall("SetCore", "ResetButtonCallback", false)
end

local controllers = script:WaitForChild("Controllers")
for _, controller in controllers:GetChildren() do
	if controller:IsA("ModuleScript") then
		local _c = require(controller)
	end
end
