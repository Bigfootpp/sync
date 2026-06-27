--!strict
local Types = require(script.Parent.Types)
local Signal = require(script.Parent.Utils.Signal)

local Transition = {}
Transition.__index = Transition

local State = {}
State.__index = State

function State.New(
	name: string,
	transitions: {Types.TransitionClass}?
): Types.StateClass
	local self = setmetatable({}, State) :: Types.StateClass
	self.name = name

	self.transitions = transitions or {}
	
	self.Entered = Signal.new()
	self.Exited = Signal.new()
	self.Updated = Signal.new()

	return self
end

function State:GetTransitions(): {Types.TransitionClass}
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

function Transition._New(to: Types.StateClass, canPassFn: () -> boolean): Types.TransitionClass 
	local self = setmetatable({}, Transition) :: Types.TransitionClass

	self.to = to
	self._canPassFn = canPassFn

	return self
end

function Transition.CreateConditionalTransition(to: Types.StateClass, canPassFn: () -> boolean): Types.TransitionClass
	return Transition._New(to, canPassFn)
end

function Transition.CreateAutomaticTransition(to: Types.StateClass, anim: Types.BaseAnimation) 
	return Transition._New(to, function(): boolean 
		return not anim:IsPlaying()
	end)
end

function Transition:CanPassFn(): boolean
	local object = self :: Types.TransitionClass

	return object._canPassFn()
end

State.Transition = Transition

return State