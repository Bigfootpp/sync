--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Sync = require(ReplicatedStorage.Packages.Sync)

return function(): boolean | string
	-- 1. Test initialization
	local manager = Sync.StateManager()
	if not manager then
		return "Failed to construct StateManager"
	end
	if manager.playing ~= false then
		return "Expected state manager playing to initially be false"
	end
	if manager.currentState ~= nil then
		return "Expected current state to be nil initially"
	end
	if #manager:GetStates() ~= 0 then
		return "Expected initial state list to be empty"
	end

	-- 2. Test registration & retrieval
	local stateA = Sync.State("A")
	local stateB = Sync.State("B")
	manager:RegisterState(stateA)
	manager:RegisterState(stateB)

	if #manager:GetStates() ~= 2 then
		return "Expected 2 registered states"
	end
	if manager:GetState("A") ~= stateA then
		return "GetState('A') did not return stateA"
	end
	if manager:GetState("B") ~= stateB then
		return "GetState('B') did not return stateB"
	end
	if manager:GetState("C") ~= nil then
		return "GetState('C') should be nil"
	end

	-- 3. Test ChangeState when playing is false
	local enterCountA = 0
	local exitCountA = 0
	local enterCountB = 0

	stateA.Entered:Connect(function()
		enterCountA += 1
	end)
	stateA.Exited:Connect(function()
		exitCountA += 1
	end)
	stateB.Entered:Connect(function()
		enterCountB += 1
	end)

	manager:ChangeState("A")
	if manager:GetCurrentState() ~= stateA then
		return "Current state should be stateA after ChangeState"
	end
	if enterCountA ~= 0 then
		return "Enter should not be triggered if manager is not playing"
	end

	-- 4. Test Play/Stop flow
	manager:Play()
	if manager.playing == false then
		return "Manager playing state should be true"
	end
	if enterCountA ~= 1 then
		return "State A Enter should have been called upon Play"
	end

	-- Test transition when playing is true
	manager:ChangeState("B")
	if manager:GetCurrentState() ~= stateB then
		return "Current state should be stateB"
	end
	if exitCountA ~= 1 then
		return "State A Exit should have been called"
	end
	if enterCountB ~= 1 then
		return "State B Enter should have been called"
	end

	-- Test Update
	local updateDt = 0
	stateB.Updated:Connect(function(dt)
		updateDt = dt
	end)
	manager:Update(0.123)
	if updateDt ~= 0.123 then
		return `Expected state update with dt 0.123, got {updateDt}`
	end

	-- Test Stop
	local exitCountB = 0
	stateB.Exited:Connect(function()
		exitCountB += 1
	end)
	manager:Stop()
	if manager.playing ~= false then
		return "Manager playing state should be false after Stop"
	end
	if exitCountB ~= 1 then
		return "State B Exit should have been called on Stop"
	end

	return true
end
