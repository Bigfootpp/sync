--!strict
local Types = require(script.Parent.Types)
local StateManager = {}
StateManager.__index = StateManager


function StateManager.New(): Types.StateManagerClass
    local self = setmetatable({}, StateManager) :: Types.StateManagerClass
    self.states = {}
    self.playing = false
    self.currentState = nil

    return self
end

function StateManager:RegisterState(state: Types.StateClass) 
    local object = self :: Types.StateManagerClass

    table.insert(object.states, state)
end

function StateManager:GetState(stateName: string): Types.StateClass?
    local object = self :: Types.StateManagerClass

    for _, state in object.states do
        local name = state.name

        if name == stateName then
            return state :: Types.StateClass
        end
    end

    return nil
end

function StateManager:GetStates(): {Types.StateClass}
    local object = self :: Types.StateManagerClass

    return object.states
end

function StateManager:AddTransition(stateName: string, transition: Types.LinkClass) 
    local object = self :: Types.StateManagerClass

    local class = object:GetState(stateName)

    if class then 
        table.insert(class.transitions, transition)
    end
end

function StateManager:GetCurrentState(): Types.StateClass?
    local object = self :: Types.StateManagerClass

    return object.currentState
end

function StateManager:GetCurrentStateTransitions(): {Types.LinkClass}?
    local object = self :: Types.StateManagerClass

    if not object.currentState then return nil end

    return object.currentState.transitions
end

function StateManager:ChangeState(stateName: string)
    local object = self :: Types.StateManagerClass

    local state = object:GetState(stateName)
    if not state then return end

    local previousState = object.currentState
    object.currentState = state

    if object.playing then
        if previousState then
            previousState:Exit()
        end
        state:Enter()
    end
end

function StateManager:Update(dt: number)
    local object = self :: Types.StateManagerClass

    if not object.playing then return end
    if not object.currentState then return end

    object.currentState:Update(dt)
end

function StateManager:Stop() 
    local object = self :: Types.StateManagerClass

    if not object.playing then return end
    object.playing = false

    if object.currentState then 
        object.currentState:Exit()
    end
end

function StateManager:Play() 
    local object = self :: Types.StateManagerClass

    if not object.currentState then return end
    if object.playing then return end
    object.playing = true

    object.currentState:Enter()
end

return StateManager