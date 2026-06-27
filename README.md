# Sync

A lightweight animation and motion framework for Luau and Roblox.

---

## Installation

Add this to your `wally.toml` dependencies:

```toml
Sync = "bigfootpp/sync@0.1.0"
```

---

## Quick Start

### 1. Wrapping Animations

```luau
local Sync = require(ReplicatedStorage.Packages.Sync)

local myTrack = animator:LoadAnimation(myAnimationInstance)
local animation = Sync.Animation(myTrack)

-- Play with optional fadeTime, weight, speed
animation:Play(0.2, 1.0, 1.0)
```

### 2. State Machine & Transitions

Create states, register them to a state manager, and run a state machine:

```luau
local Sync = require(ReplicatedStorage.Packages.Sync)

-- Initialize Manager and States
local manager = Sync.StateManager()
local idleState = Sync.State("Idle")
local runState = Sync.State("Run")

manager:RegisterState(idleState)
manager:RegisterState(runState)

-- Setup transitions
local isRunning = false
local runTransition = Sync.State.Transition.CreateConditionnalTransition(runState, function()
    return isRunning
end)
manager:AddTransitions("Idle", runTransition)

-- Run State Machine
local stateMachine = Sync.StateMachine(manager, "Idle")
manager:Play()

-- Tick in your run loop
RunService.Heartbeat:Connect(function(dt)
    stateMachine:Update(dt)
end)
```

### 3. 1D Blendspace

Blend between multiple animations dynamically using a single parameter:

```luau
local Sync = require(ReplicatedStorage.Packages.Sync)

local blendSpace = Sync.BlendSpace1D({
    { x = 0, animation = idleAnimation },
    { x = 8, animation = walkAnimation },
    { x = 16, animation = runAnimation }
}, 0.1)

blendSpace:Play()

-- Dynamically adjust speed based on character velocity
RunService.Heartbeat:Connect(function()
    local speed = character.PrimaryPart.AssemblyLinearVelocity.Magnitude
    blendSpace:Update(speed)
end)
```
