--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Sync = require(ReplicatedStorage.Packages.Sync)

return function(): boolean | string
	-- 1. Test state creation & properties
	local state = Sync.State("Idle")
	if not state then
		return "Sync.State returned nil"
	end
	if state.name ~= "Idle" then
		return `Expected state name to be 'Idle', got '{state.name}'`
	end

	-- 2. Test event signals
	local enteredCalled = 0
	local exitedCalled = 0
	local updatedVal = 0

	local c1 = state.Entered:Connect(function()
		enteredCalled += 1
	end)
	local c2 = state.Exited:Connect(function()
		exitedCalled += 1
	end)
	local c3 = state.Updated:Connect(function(dt)
		updatedVal += dt
	end)

	state:Enter()
	state:Update(0.5)
	state:Exit()

	c1:Disconnect()
	c2:Disconnect()
	c3:Disconnect()

	if enteredCalled ~= 1 then
		return `Expected Entered to fire 1 time, fired {enteredCalled}`
	end
	if exitedCalled ~= 1 then
		return `Expected Exited to fire 1 time, fired {exitedCalled}`
	end
	if updatedVal ~= 0.5 then
		return `Expected Updated to receive dt 0.5, got {updatedVal}`
	end

	-- 3. Test callback overrides
	local customState = Sync.State("Custom")
	local customEnter = false
	local customExit = false
	local customUpdate = 0

	function customState:OnEnter()
		customEnter = true
	end

	function customState:OnExit()
		customExit = true
	end

	function customState:OnUpdate(dt: number)
		customUpdate = dt
	end

	customState:Enter()
	customState:Update(42)
	customState:Exit()

	if not customEnter then
		return "OnEnter override was not called"
	end
	if not customExit then
		return "OnExit override was not called"
	end
	if customUpdate ~= 42 then
		return `Expected OnUpdate override to receive 42, got {customUpdate}`
	end

	return true
end
