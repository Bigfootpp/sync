export type AnimationClass = {
    track: AnimationTrack,
    New: (animation: AnimationTrack) -> AnimationClass,
    Play: (self: AnimationClass, fadeTime: number?, weight: number?, speed: number?) -> (),
    Stop: (self: AnimationClass, fadeTime: number?) -> (),
    Blend: (self: AnimationClass, toAnim: AnimationClass, fadeTime: number?, weight: number?, speed: number?) -> (),
    SetSpeed: (self: AnimationClass, speed: number) -> (),
    SetWeight: (self: AnimationClass, weight: number, fadeTime: number?) -> (),
    SetLooped: (self: AnimationClass, looped: boolean) -> (),
    IsPlaying: (self: AnimationClass) -> boolean,
    GetLength: (self: AnimationClass) -> number,
    OnEnd: (self: AnimationClass, callback: (...any) -> any) -> RBXScriptConnection,
}

return {}