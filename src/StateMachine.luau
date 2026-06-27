--!strict
local Types = require(script.Parent.Types)

local StateMachine = {}
StateMachine.__index = StateMachine

function StateMachine.New(stateManager: Types.StateManagerClass, startingStateName: string): Types.StateMachineClass
	local self = setmetatable({}, StateMachine) :: Types.StateMachineClass
	self.stateManager = stateManager
	self.startingStateName = startingStateName

	stateManager:ChangeState(startingStateName)
	return self
end

function StateMachine:Update(dt: number)
	local object = self :: Types.StateMachineClass
	
	local transitions = object.stateManager:GetCurrentStateTransitions()
	if not transitions then return end

	for _, transition in transitions do
		if transition:CanPassFn() then
			object.stateManager:ChangeState(transition.to.name)
			break
		end
	end

	object.stateManager:Update(dt)
end

function StateMachine:Reset()
	local object = self :: Types.StateMachineClass
	
	object.stateManager:ChangeState(object.startingStateName)
end

return StateMachine