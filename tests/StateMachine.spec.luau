--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Sync = require(ReplicatedStorage.Packages.Sync)

return function(): boolean | string
	-- 1. Setup states and manager
	local manager = Sync.StateManager()
	local stateA = Sync.State("A")
	local stateB = Sync.State("B")
	manager:RegisterState(stateA)
	manager:RegisterState(stateB)

	-- 2. Create links
	local transitionFlag = false
	local link = Sync.ConditionalLink(stateA, stateB, function()
		return transitionFlag
	end)

	if link.from ~= stateA then
		return "Link from should be stateA"
	end
	if link.to ~= stateB then
		return "Link to should be stateB"
	end
	if link:CanPassFn() ~= false then
		return "ConditionalLink CanPassFn should return false when condition is false"
	end

	-- 3. Construct StateMachine with starting state reference
	local sm = Sync.StateMachine(manager, stateA)
	if not sm then
		return "Failed to construct StateMachine"
	end
	if sm.startingStateName ~= "A" then
		return "Expected startingStateName to be 'A'"
	end
	if manager:GetCurrentState() ~= stateA then
		return "Expected current state to be set to starting state"
	end

	-- 4. Add link to state machine
	sm:AddLink(link)
	local stateALinks = sm:GetCurrentStateLink()
	if not stateALinks or #stateALinks ~= 1 then
		return "Expected 1 link for current state A"
	end
	if stateALinks[1] ~= link then
		return "Link reference mismatch"
	end

	-- Start playing state manager to track state entries
	manager:Play()

	-- 5. Test update without transitioning
	local stateBEntered = false
	stateB.Entered:Connect(function()
		stateBEntered = true
	end)

	sm:Update(0.1)
	if manager:GetCurrentState() ~= stateA then
		return "Expected state to remain A when link condition is false"
	end
	if stateBEntered then
		return "State B entered prematurely"
	end

	-- 6. Test transition triggering
	transitionFlag = true
	sm:Update(0.1)

	if manager:GetCurrentState() ~= stateB then
		return "Expected state to transition to B when link condition met"
	end
	if not stateBEntered then
		return "State B Entered signal was not triggered upon transition"
	end

	-- 7. After transition, current state links should be for stateB (nil if none added)
	local stateBLinks = sm:GetCurrentStateLink()
	if stateBLinks ~= nil then
		return "Expected nil links for stateB since none were added"
	end

	-- 8. Test Reset
	sm:Reset()
	if manager:GetCurrentState() ~= stateA then
		return "Expected current state to be reset back to A"
	end

	-- 9. Test AutomaticLink
	local mockAnimIsPlaying = true
	local mockAnim = {
		IsPlaying = function(): boolean
			return mockAnimIsPlaying
		end,
		Play = function() end,
		Stop = function() end,
		Blend = function() end,
		SetSpeed = function() end,
		SetWeight = function() end,
	} :: any

	local autoLink = Sync.AutomaticLink(stateA, stateB, mockAnim)
	if autoLink.from ~= stateA then
		return "AutomaticLink from should be stateA"
	end
	if autoLink.to ~= stateB then
		return "AutomaticLink to should be stateB"
	end
	if autoLink:CanPassFn() == true then
		return "AutomaticLink should not pass while animation is playing"
	end

	mockAnimIsPlaying = false
	if autoLink:CanPassFn() == false then
		return "AutomaticLink should pass when animation stopped playing"
	end

	return true
end
