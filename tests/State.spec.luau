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
	if type(state.transitions) ~= "table" or #state.transitions ~= 0 then
		return "Expected state.transitions to be an empty table"
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

	-- 4. Test Transition Creation
	-- Get the Transition module via the State module's Transition field
	local StateModule = require(ReplicatedStorage.Packages.Sync.State)
	local Transition = StateModule.Transition

	local stateB = Sync.State("StateB")

	-- A conditional transition
	local condTransition = Transition.CreateConditionalTransition(stateB, function()
		return true
	end)

	if condTransition.to ~= stateB then
		return "Conditional transition target mismatch"
	end
	if condTransition:CanPassFn() ~= true then
		return "Conditional transition CanPassFn returned false when expected true"
	end

	-- An automatic transition with a mock animation
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

	local autoTransition = Transition.CreateAutomaticTransition(stateB, mockAnim)
	if autoTransition.to ~= stateB then
		return "Automatic transition target mismatch"
	end

	-- Since the mock animation is playing, transition shouldn't pass
	if autoTransition:CanPassFn() == true then
		return "Automatic transition passed while animation was playing"
	end

	mockAnimIsPlaying = false
	-- Now that animation has stopped, the automatic transition should pass
	if autoTransition:CanPassFn() == false then
		return "Automatic transition did not pass when animation stopped playing"
	end

	-- 5. Test State construction with transitions
	local stateA = Sync.State("StateA", { condTransition, autoTransition })
	local transitions = stateA:GetTransitions()
	if #transitions ~= 2 then
		return `Expected 2 transitions, got {#transitions}`
	end
	if transitions[1] ~= condTransition then
		return "First transition mismatch"
	end
	if transitions[2] ~= autoTransition then
		return "Second transition mismatch"
	end

	return true
end
