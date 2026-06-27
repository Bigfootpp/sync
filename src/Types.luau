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
	new: (poses: {Pose}, fadeTime: number?) -> BlendSpace1DClass,
	Update: (self: BlendSpace1DClass, x: number) -> (),
	Play: (self: BlendSpace1DClass, fadeTime: number?, weight: number?, speed: number?) -> (),
	Stop: (self: BlendSpace1DClass, fadeTime: number?) -> (),
	IsPlaying: (self: BlendSpace1DClass) -> boolean,
}

export type TransitionClass = {
	to: StateClass,
	_canPassFn: () -> boolean,

	_New: (to: StateClass, canPassFn: () -> boolean) -> TransitionClass,
	CreateConditionnalTransition: (to: StateClass, canPassFn: () -> boolean) -> TransitionClass,
	CreateAutomaticTransition: (to: StateClass, anim: BaseAnimation) -> TransitionClass,

	CanPassFn: (self: TransitionClass) -> boolean,
}

export type StateClass = {
	name: string,
	transitions: {TransitionClass},

    New: (name: string, transition: {TransitionClass}) -> StateClass,
	Entered: Signal<>,
	Exited: Signal<>,
	Updated: Signal<number>,

	GetTransitions: (self: StateClass) -> {TransitionClass},
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
	AddTransitions: (self: StateManagerClass, stateName: string, transition: TransitionClass) -> (),
	GetCurrentState: (self: StateManagerClass) -> StateClass?,
	GetCurrentStateTransitions: (self: StateManagerClass) -> {TransitionClass}?,
	ChangeState: (self: StateManagerClass, stateName: string) -> (),
	Update: (self: StateManagerClass, dt: number) -> (),
	Stop: (self: StateManagerClass) -> (),
	Play: (self: StateManagerClass) -> (),
}


return {}