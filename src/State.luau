--!strict
local Types = require(script.Parent.Types)
local Signal = require(script.Parent.Utils.Signal)

local Transition = {}
Transition.__index = Transition

local State = {}
State.__index = State

function State.New(
	name: string,
	transitions: {Types.LinkClass}?
): Types.StateClass
	local self = setmetatable({}, State) :: Types.StateClass
	self.name = name

	self.transitions = transitions or {}
	
	self.Entered = Signal.new()
	self.Exited = Signal.new()
	self.Updated = Signal.new()

	return self
end

function State:GetTransitions(): {Types.LinkClass}
	local stateObject = self :: Types.StateClass
	
	return stateObject.transitions
end

function State:Enter()
	local stateObject = self :: Types.StateClass

	stateObject.Entered:Fire()
	stateObject:OnEnter()
end

function State:Exit()
	local stateObject = self :: Types.StateClass

	stateObject.Exited:Fire()
	stateObject:OnExit()
end

function State:Update(dt: number)
	local stateObject = self :: Types.StateClass

	stateObject.Updated:Fire(dt)
	stateObject:OnUpdate(dt)
end

function State:OnEnter()
	-- To override
end

function State:OnExit()
	-- To override
end

function State:OnUpdate(dt: number)
	-- To override
end

return State