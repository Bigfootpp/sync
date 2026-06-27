local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Sync = require(ReplicatedStorage.Packages.Sync)

local function createMockAnim()
	local self = {
		playCount = 0,
		stopCount = 0,
		lastWeight = -1,
		isPlaying = false,
	}
	function self:Play(fadeTime: number?, weight: number?, speed: number?)
		self.playCount += 1
		self.isPlaying = true
	end
	function self:Stop(fadeTime: number?)
		self.stopCount += 1
		self.isPlaying = false
	end
	function self:SetWeight(weight: number, fadeTime: number?)
		self.lastWeight = weight
	end
	function self:IsPlaying(): boolean
		return self.isPlaying
	end
	return self
end

return function(): boolean | string
	-- 1. Setup mock animations and poses (out of order to test sorting)
	local anim1 = createMockAnim()
	local anim2 = createMockAnim()
	local anim3 = createMockAnim()

	local poses = {
		{ x = 10, animation = anim3 :: any },
		{ x = 0, animation = anim1 :: any },
		{ x = 5, animation = anim2 :: any },
	}

	-- 2. Construct BlendSpace1D
	local blendSpace = Sync.BlendSpace1D(poses, 0.05)
	if not blendSpace then
		return "Failed to construct BlendSpace1D"
	end

	-- Test sorting
	if blendSpace.poses[1].x ~= 0 or blendSpace.poses[2].x ~= 5 or blendSpace.poses[3].x ~= 10 then
		return "Poses were not sorted by their x values in ascending order"
	end

	-- 3. Test Play
	blendSpace:Play()
	if not blendSpace:IsPlaying() then
		return "Expected IsPlaying() to be true after Play()"
	end

	if anim1.playCount ~= 1 or anim2.playCount ~= 1 or anim3.playCount ~= 1 then
		return "Play was not called on all pose animations"
	end

	-- Play() triggers Update(0) internally.
	-- For x = 0: range is [0, 5]. lower = anim1, upper = anim2.
	-- weightUpper = (0 - 0)/5 = 0, weightLower = 1 - 0 = 1.
	-- anim1 weight should be 1.
	-- anim2 weight should be 0.
	-- anim3 weight should be 0.1 (inactive pose weight).
	if math.abs(anim1.lastWeight - 1) > 0.0001 then
		return `Expected anim1 weight to be 1 at x = 0, got {anim1.lastWeight}`
	end
	if math.abs(anim2.lastWeight - 0) > 0.0001 then
		return `Expected anim2 weight to be 0 at x = 0, got {anim2.lastWeight}`
	end
	if math.abs(anim3.lastWeight - 0.1) > 0.0001 then
		return `Expected anim3 weight to be 0.1 at x = 0, got {anim3.lastWeight}`
	end

	-- 4. Test Update(2.5) -> midpoint between 0 and 5
	blendSpace:Update(2.5)
	-- weightUpper = (2.5 - 0)/5 = 0.5, weightLower = 0.5.
	-- anim1 weight = 0.5
	-- anim2 weight = 0.5
	-- anim3 weight = 0.1
	if math.abs(anim1.lastWeight - 0.5) > 0.0001 or math.abs(anim2.lastWeight - 0.5) > 0.0001 then
		return "Midpoint interpolation incorrect for active poses"
	end
	if math.abs(anim3.lastWeight - 0.1) > 0.0001 then
		return "Inactive pose weight changed from 0.1 incorrectly"
	end

	-- 5. Test Update(7.5) -> midpoint between 5 and 10
	blendSpace:Update(7.5)
	-- lower = anim2 (x=5), upper = anim3 (x=10)
	-- weightUpper = (7.5 - 5)/5 = 0.5, weightLower = 0.5.
	-- anim1 weight = 0.1
	-- anim2 weight = 0.5
	-- anim3 weight = 0.5
	if math.abs(anim1.lastWeight - 0.1) > 0.0001 then
		return `Expected inactive anim1 weight to be 0.1, got {anim1.lastWeight}`
	end
	if math.abs(anim2.lastWeight - 0.5) > 0.0001 or math.abs(anim3.lastWeight - 0.5) > 0.0001 then
		return "Midpoint interpolation incorrect for active poses at higher range"
	end

	-- 6. Test clamping boundary (x = 12)
	blendSpace:Update(12)
	-- Should clamp x to 10. lower = anim2 (x=5), upper = anim3 (x=10).
	-- weightUpper = (10 - 5)/5 = 1.0, weightLower = 0.
	-- anim1 weight = 0.1
	-- anim2 weight = 0.0
	-- anim3 weight = 1.0
	if math.abs(anim1.lastWeight - 0.1) > 0.0001 then
		return `Expected anim1 weight at x=12 to be 0.1, got {anim1.lastWeight}`
	end
	if math.abs(anim2.lastWeight - 0) > 0.0001 then
		return `Expected anim2 weight at x=12 to be 0, got {anim2.lastWeight}`
	end
	if math.abs(anim3.lastWeight - 1) > 0.0001 then
		return `Expected anim3 weight at x=12 to be 1, got {anim3.lastWeight}`
	end

	-- 7. Test Stop
	blendSpace:Stop()
	if blendSpace:IsPlaying() then
		return "Expected IsPlaying() to be false after Stop()"
	end
	if anim1.stopCount ~= 1 or anim2.stopCount ~= 1 or anim3.stopCount ~= 1 then
		return "Stop was not called on all pose animations"
	end

	return true
end
