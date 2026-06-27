--!strict

-- Import Sync
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Sync = require(ReplicatedStorage.Packages.Sync)

-- Return either a string or a boolean
return function(): boolean | string
    -- Return an error
	if 1 == 2 then return "1 is equal to 2" end
    if not Sync.Animation then return "Animation constructor does not exist" end

    -- Test passed
	return true
end