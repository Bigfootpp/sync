--!strict
local Types = require(script.Parent.Types)

local Animation = {}
Animation.__index = Animation

function Animation.New(animation: AnimationTrack): Types.AnimationClass
	local self = setmetatable({}, Animation) :: Types.AnimationClass
	self.track = animation
	return self
end

function Animation:Play(fadeTime: number?, weight: number?, speed: number?)
	local object = self :: Types.AnimationClass
	
	object.track:Play(fadeTime or 0.1, weight or 1, speed or 1)
end

function Animation:Stop(fadeTime: number?)
	local object = self :: Types.AnimationClass
	
	object.track:Stop(fadeTime or 0.1)
end

function Animation:Blend(toAnim: Types.AnimationClass, fadeTime: number?, weight: number?, speed: number?)
	local object = self :: Types.AnimationClass
	
	object:Stop(fadeTime)
	toAnim:Play(fadeTime, weight, speed)
end

function Animation:SetSpeed(speed: number)
	local object = self :: Types.AnimationClass
	object.track:AdjustSpeed(speed)
end

function Animation:SetWeight(weight: number, fadeTime: number?)
	local object = self :: Types.AnimationClass
	object.track:AdjustWeight(weight, fadeTime)
end

function Animation:SetLooped(looped: boolean)
	local object = self :: Types.AnimationClass
	object.track.Looped = looped
end

function Animation:IsPlaying(): boolean
	local object = self :: Types.AnimationClass
	return object.track.IsPlaying
end

function Animation:GetLength(): number
	local object = self :: Types.AnimationClass
	return object.track.Length
end

function Animation:OnEnd(callback): RBXScriptConnection
	local object = self :: Types.AnimationClass
	return object.track.Stopped:Connect(callback)
end

return Animation