local Animation = require(script.Animation)
local BlendSpace1D = require(script.BlendSpace1D)
local State = require(script.State)
local StateManager = require(script.StateManager)
local StateMachine = require(script.StateMachine)

local Sync = {}

Sync.Animation = Animation.New
Sync.BlendSpace1D = BlendSpace1D.New
Sync.State = State.New
Sync.StateManager = StateManager.New
Sync.StateMachine = StateMachine.New

return Sync