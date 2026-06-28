--!strict
local Types = require(script.Parent.Types)

local StateMachine = {}
StateMachine.__index = StateMachine

function StateMachine.New(stateManager: Types.StateManagerClass, startingState: Types.StateClass): Types.StateMachineClass
	local self = setmetatable({}, StateMachine) :: Types.StateMachineClass
	self.stateManager = stateManager
	self.links = {}
	self.startingStateName = startingState.name

	stateManager:ChangeState(startingState.name)
	return self
end

function StateMachine:AddLink(link: Types.LinkClass)
	local object = self :: Types.StateMachineClass

	if not object.links[link.from] then
		object.links[link.from] = {link}
	else
		table.insert(object.links[link.from], link)
	end
end

function StateMachine:GetCurrentStateLink(): {Types.LinkClass}?
	local object = self :: Types.StateMachineClass

	local currentState = object.stateManager:GetCurrentState()
	if currentState then
		return object.links[currentState]
	else
		return nil
	end
end

function StateMachine:Update(dt: number)
	local object = self :: Types.StateMachineClass
	
	local links = object:GetCurrentStateLink()
	if not links then return end

	for _, link in links do
		if link:CanPassFn() then
			object.stateManager:ChangeState(link.to.name)
			break
		end
	end

	object.stateManager:Update(dt)
end

function StateMachine:Restart()
	local object = self :: Types.StateMachineClass
	
	object.stateManager:ChangeState(object.startingStateName)
end

return StateMachine