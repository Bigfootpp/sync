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

return {}