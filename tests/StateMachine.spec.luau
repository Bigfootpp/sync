--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Sync = require(ReplicatedStorage.Packages.Sync)

return function(): boolean | string
	-- 1. Setup states and transitions
	local manager = Sync.StateManager()
	local stateA = Sync.State("A")
	local stateB = Sync.State("B")
	manager:RegisterState(stateA)
	manager:RegisterState(stateB)

	local transitionFlag = false

	local transition = Sync.ConditionalLink(stateB, function()
		return transitionFlag
	end)
	manager:AddTransition("A", transition)

	-- 2. Construct StateMachine
	local sm = Sync.StateMachine(manager, "A")
	if not sm then
		return "Failed to construct StateMachine"
	end
	if sm.startingStateName ~= "A" then
		return "Expected startingStateName to be 'A'"
	end
	if manager:GetCurrentState() ~= stateA then
		return "Expected current state to be set to starting state"
	end

	-- Start playing state manager to track state entries
	manager:Play()

	-- 3. Test update without transitioning
	local stateBEntered = false
	stateB.Entered:Connect(function()
		stateBEntered = true
	end)

	sm:Update(0.1)
	if manager:GetCurrentState() ~= stateA then
		return "Expected state to remain A when transition function is false"
	end
	if stateBEntered then
		return "State B entered prematurely"
	end

	-- 4. Test transition triggering
	transitionFlag = true
	sm:Update(0.1)

	if manager:GetCurrentState() ~= stateB then
		return "Expected state to transition to B when transition condition met"
	end
	if not stateBEntered then
		return "State B Entered signal was not triggered upon transition"
	end

	-- 5. Test Reset
	sm:Reset()
	if manager:GetCurrentState() ~= stateA then
		return "Expected current state to be reset back to A"
	end

	return true
end
