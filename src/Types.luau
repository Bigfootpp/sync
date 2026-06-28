local SignalModule = require(script.Parent.Utils.Signal)

export type Signal<T...> = SignalModule.Signal<T...>
export type Connection = SignalModule.Connection

export type BaseAnimation = {
    Play: (self: BaseAnimation, fadeTime: number?, weight: number?, speed: number?) -> (),
    Stop: (self: BaseAnimation, fadeTime: number?) -> (),
    Blend: (self: AnimationClass, toAnim: AnimationClass, fadeTime: number?, weight: number?, speed: number?) -> (),
    SetSpeed: (self: BaseAnimation, speed: number) -> (),
    SetWeight: (self: BaseAnimation, weight: number, fadeTime: number?) -> (),
    IsPlaying: (self: BaseAnimation) -> boolean,
}

export type AnimationClass = {
    track: AnimationTrack,
    New: (animation: AnimationTrack) -> AnimationClass,
    SetLooped: (self: AnimationClass, looped: boolean) -> (),
    GetLength: (self: AnimationClass) -> number,
    OnEnd: (self: AnimationClass) -> RBXScriptSignal,
} & BaseAnimation

export type Pose = {
	x: number,
	animation: BaseAnimation,
}

export type BlendSpace1DClass = {
	poses: {Pose},
	fadeTime: number,
	playing: boolean,
	x: number,

	New: (poses: {Pose}, fadeTime: number?) -> BlendSpace1DClass,
	Update: (self: BlendSpace1DClass, x: number) -> (),
	Play: (self: BlendSpace1DClass, fadeTime: number?, weight: number?, speed: number?) -> (),
	Stop: (self: BlendSpace1DClass, fadeTime: number?) -> (),
	IsPlaying: (self: BlendSpace1DClass) -> boolean,
}

export type LinkClass = {
	from: StateClass,
	to: StateClass,
	_canPassFn: () -> boolean,

	ConditionnalLink: (from: StateClass, to: StateClass, canPassFn: () -> boolean) -> LinkClass,
	AutomaticLink: (from: StateClass, to: StateClass, anim: BaseAnimation) -> LinkClass,

	CanPassFn: (self: LinkClass) -> boolean,
}

export type StateClass = {
	name: string,

    New: (name: string) -> StateClass,
	Entered: Signal<>,
	Exited: Signal<>,
	Updated: Signal<number>,

	Enter: (self: StateClass) -> (),
	Exit: (self: StateClass) -> (),
	Update: (self: StateClass, dt: number) -> (),

	OnEnter: (self: StateClass) -> (),
	OnExit: (self: StateClass) -> (),
	OnUpdate: (self: StateClass, dt: number) -> (),
}

export type StateManagerClass = {
	states: {StateClass},
	playing: boolean,
	currentState: StateClass?,

	New: () -> StateManagerClass,
	RegisterState: (self: StateManagerClass, state: StateClass) -> (),
	GetState: (self: StateManagerClass, stateName: string) -> StateClass?,
	GetStates: (self: StateManagerClass) -> {StateClass},
	GetCurrentState: (self: StateManagerClass) -> StateClass?,
	ChangeState: (self: StateManagerClass, stateName: string) -> (),
	Update: (self: StateManagerClass, dt: number) -> (),
	Stop: (self: StateManagerClass) -> (),
	Play: (self: StateManagerClass) -> (),
}

export type StateMachineClass = {
	startingStateName: string,
	stateManager: StateManagerClass,
	links: {[StateClass]: {LinkClass}},

    New: (stateManager: StateManagerClass, startingState: StateClass) -> StateMachineClass,
	GetCurrentStateLink: (self: StateMachineClass) -> {LinkClass}?,
	AddLink: (self: StateMachineClass, link: LinkClass) -> (),
    Update: (self: StateMachineClass, dt: number) -> (),
    Reset: (self: StateMachineClass) -> ()
}


return {}