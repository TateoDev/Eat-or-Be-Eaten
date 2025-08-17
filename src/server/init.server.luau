local services = script.Services

local loadedServices: { [string]: any } = {}

for _, service in services:GetChildren() do
	if service:IsA("ModuleScript") then
		loadedServices[service.Name] = require(service)
	end
end
