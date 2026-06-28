# Sync

A lightweight animation and motion framework for Luau and Roblox.

---

> [!WARNING]
> This project is currently in **Beta**. Expect breaking changes.

---

## Installation

Add to your `wally.toml`:

```toml
Sync = "bigfootpp/sync@0.2.0"
```

---

## Quick Start

### 1. Wrapping Animations

```luau
local Sync = require(ReplicatedStorage.Packages.Sync)

local track = animator:LoadAnimation(animationInstance)
local anim = Sync.Animation(track)

anim:Play(0.2, 1.0, 1.0) -- fadeTime, weight, speed
anim:Stop(0.2)
anim:SetSpeed(1.5)
anim:SetWeight(0.5, 0.1)
```

---

### 2. 1D Blendspace

Blend between animations using a single parameter (speed, slope, etc.):

```luau
local Sync = require(ReplicatedStorage.Packages.Sync)

local blendSpace = Sync.BlendSpace1D({
    { x = 0,   animation = idleAnim },
    { x = 8,   animation = walkAnim },
    { x = 16,  animation = runAnim  },
}, 0.1) -- fadeTime

blendSpace:Play()

RunService.Heartbeat:Connect(function()
    local speed = character.PrimaryPart.AssemblyLinearVelocity.Magnitude
    blendSpace:Update(speed)
end)
```

---

### 3. State Machine

States are simple containers with Enter/Exit/Update signals. Links are defined on the StateMachine

```luau
local Sync = require(ReplicatedStorage.Packages.Sync)

-- 1. Create manager and states
local manager = Sync.StateManager()
local idle = Sync.State("Idle")
local run  = Sync.State("Run")

manager:RegisterState(idle)
manager:RegisterState(run)

-- 2. Create links
local toRun = Sync.ConditionalLink(idle, run, function()
    return character:GetAttribute("IsRunning") == true
end)

local toIdle = Sync.ConditionalLink(run, idle, function()
    return character:GetAttribute("IsRunning") == false
end)

-- 3. Create state machine, add links
local sm = Sync.StateMachine(manager, idle) -- startingState is a StateClass
sm:AddLink(toRun)
sm:AddLink(toIdle)

-- 4. Run
manager:Play()

RunService.Heartbeat:Connect(function(dt)
    sm:Update(dt)
end)
```

#### Link Types

| Function | Description |
|----------|-------------|
| `Sync.ConditionalLink(from, to, fn)` | Transition when `fn()` returns true |
| `Sync.AutomaticLink(from, to, anim)` | Transition when `anim` finishes playing |

#### StateMachine API

| Method | Description |
|--------|-------------|
| `StateMachine.New(manager, startingState)` | `startingState` is a `StateClass` |
| `sm:AddLink(link)` | Register a transition link |
| `sm:GetCurrentStateLink()` | Get links for current state |
| `sm:Update(dt)` | Evaluate links, update current state |
| `sm:Restart()` | Return to starting state (keeps playing) |

#### StateManager API

| Method | Description |
|--------|-------------|
| `manager:RegisterState(state)` | Add a state |
| `manager:GetState(name)` | Retrieve state by name |
| `manager:ChangeState(name)` | Force state change |
| `manager:Play()` | Start the machine (triggers Enter) |
| `manager:Stop()` | Stop the machine (triggers Exit) |
| `manager:Update(dt)` | Forward dt to current state |

#### State Signals

Each state exposes: `Entered`, `Exited`, `Updated(dt)`.

Override `OnEnter()`, `OnExit()`, `OnUpdate(dt)` on the state instance for custom logic.

---

## License
MIT License. See `LICENSE`.