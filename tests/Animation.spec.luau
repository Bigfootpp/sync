--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Sync = require(ReplicatedStorage.Packages.Sync)

local function createMockTrack()
	local track = {
		playParams = nil :: { fadeTime: number, weight: number, speed: number }?,
		stopParams = nil :: { fadeTime: number }?,
		adjustedSpeed = nil :: number?,
		adjustedWeight = nil :: number?,
		adjustedWeightFadeTime = nil :: number?,
		Looped = false,
		IsPlaying = false,
		Length = 2.5,
		Stopped = {} :: any,
	}

	function track:Play(fadeTime: number, weight: number, speed: number)
		self.playParams = { fadeTime = fadeTime, weight = weight, speed = speed }
		self.IsPlaying = true
	end

	function track:Stop(fadeTime: number)
		self.stopParams = { fadeTime = fadeTime }
		self.IsPlaying = false
	end

	function track:AdjustSpeed(speed: number)
		self.adjustedSpeed = speed
	end

	function track:AdjustWeight(weight: number, fadeTime: number?)
		self.adjustedWeight = weight
		self.adjustedWeightFadeTime = fadeTime
	end

	return track
end

return function(): boolean | string
	-- 1. Create a mock track and construct Sync.Animation
	local mockTrack = createMockTrack()
	local anim = Sync.Animation(mockTrack :: any)
	
	if not anim then
		return "Failed to construct Animation wrapper"
	end
	if anim.track ~= (mockTrack :: any) then
		return "Animation track reference mismatch"
	end

	-- 2. Test Play with default arguments
	anim:Play()
	if not mockTrack.playParams then
		return "Track:Play was not called"
	end
	if mockTrack.playParams.fadeTime ~= 0.1 or mockTrack.playParams.weight ~= 1 or mockTrack.playParams.speed ~= 1 then
		return `Play defaults incorrect: fadeTime={mockTrack.playParams.fadeTime}, weight={mockTrack.playParams.weight}, speed={mockTrack.playParams.speed}`
	end
	if anim:IsPlaying() ~= true then
		return "IsPlaying() should return true after Play()"
	end

	-- 3. Test Play with custom arguments
	anim:Play(0.5, 0.8, 1.5)
	if not mockTrack.playParams then
		return "Track:Play parameter storage is nil"
	end
	if mockTrack.playParams.fadeTime ~= 0.5 or mockTrack.playParams.weight ~= 0.8 or mockTrack.playParams.speed ~= 1.5 then
		return "Play parameters were not passed correctly to track"
	end

	-- 4. Test Stop with default arguments
	anim:Stop()
	if not mockTrack.stopParams then
		return "Track:Stop was not called"
	end
	if mockTrack.stopParams.fadeTime ~= 0.1 then
		return `Stop defaults incorrect: fadeTime={mockTrack.stopParams.fadeTime}`
	end
	if anim:IsPlaying() ~= false then
		return "IsPlaying() should return false after Stop()"
	end

	-- 5. Test Stop with custom argument
	anim:Stop(0.3)
	if not mockTrack.stopParams or mockTrack.stopParams.fadeTime ~= 0.3 then
		return "Stop parameter was not passed correctly to track"
	end

	-- 6. Test Blend
	local mockTrack2 = createMockTrack()
	local anim2 = Sync.Animation(mockTrack2 :: any)
	anim:Play()
	anim:Blend(anim2, 0.4, 0.7, 1.2)

	if anim:IsPlaying() ~= false then
		return "Blend did not stop the original animation"
	end
	if not mockTrack.stopParams or mockTrack.stopParams.fadeTime ~= 0.4 then
		return "Blend did not stop original animation with correct fadeTime"
	end
	if anim2:IsPlaying() ~= true then
		return "Blend did not play target animation"
	end
	if not mockTrack2.playParams or mockTrack2.playParams.fadeTime ~= 0.4 or mockTrack2.playParams.weight ~= 0.7 or mockTrack2.playParams.speed ~= 1.2 then
		return "Blend did not play target animation with correct parameters"
	end

	-- 7. Test adjust methods
	anim:SetSpeed(2.2)
	if mockTrack.adjustedSpeed ~= 2.2 then
		return "SetSpeed did not adjust track speed correctly"
	end

	anim:SetWeight(0.65, 0.25)
	if mockTrack.adjustedWeight ~= 0.65 or mockTrack.adjustedWeightFadeTime ~= 0.25 then
		return "SetWeight did not adjust track weight or fadeTime correctly"
	end

	-- 8. Test loop status and length
	anim:SetLooped(true)
	if mockTrack.Looped ~= true then
		return "SetLooped(true) did not set track Looped property"
	end

	if anim:GetLength() ~= 2.5 then
		return `Expected GetLength() to return 2.5, got {anim:GetLength()}`
	end

	-- 9. Test OnEnd
	if anim:OnEnd() ~= mockTrack.Stopped then
		return "OnEnd did not return Stopped event/property of track"
	end

	return true
end
