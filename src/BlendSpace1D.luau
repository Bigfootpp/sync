--!strict
local Types = require(script.Parent.Types)
local Blend1DSpace = {}
Blend1DSpace.__index = Blend1DSpace

local MINIMUM_WEIGHT = 0.1 -- 0.1 because roblox automatically stop the animation when the weight is 0
local DEFAULT_FADE_TIME = 0.1

function Blend1DSpace.new(
	poses: {Types.Pose},
	fadeTime: number?
): Types.BlendSpace1DClass
	local self = setmetatable({}, Blend1DSpace) :: Types.BlendSpace1DClass
	self.poses = poses or {}
	self.fadeTime = fadeTime or 0.01
	self.playing = false

	table.sort(self.poses, function(a: Types.Pose, b: Types.Pose)
		return a.x < b.x
	end)

	return self
end

function Blend1DSpace:Update(x: number)
	local object = self :: Types.BlendSpace1DClass
	
	if not object.playing or #object.poses == 0 then return end

	x = math.clamp(x, object.poses[1].x, object.poses[#object.poses].x)

	local lowerPose: Types.Pose = object.poses[1]
	local upperPose: Types.Pose = object.poses[1]
	for i = 1, #object.poses - 1 do
		local a, b = object.poses[i], object.poses[i + 1]
		if x >= a.x and x <= b.x then
			lowerPose, upperPose = a, b
			break
		end
	end

	local weightLower = 1
	local weightUpper = 0
	if lowerPose ~= upperPose then
		local range = upperPose.x - lowerPose.x
		if range == 0 then
			weightLower = 1
			weightUpper = MINIMUM_WEIGHT
		else
			weightUpper = (x - lowerPose.x) / range
			weightLower = 1 - weightUpper
		end
	end

	for _, pose in ipairs(object.poses) do
		if pose == lowerPose then
			pose.animation:SetWeight(weightLower, object.fadeTime)
		elseif pose == upperPose then
			pose.animation:SetWeight(weightUpper, object.fadeTime)
		else
			pose.animation:SetWeight(MINIMUM_WEIGHT, object.fadeTime)
		end
	end
end

function Blend1DSpace:Play(fadeTime: number?, weight: number?, speed: number?)
	local object = self :: Types.BlendSpace1DClass
	
	for _, pose in ipairs(object.poses) do
		pose.animation:Play(fadeTime or DEFAULT_FADE_TIME, 0, speed or 1)
	end
	
	object.playing = true

	object:Update(0)
end

function Blend1DSpace:Stop(fadeTime: number?)
	local object = self :: Types.BlendSpace1DClass
	
	for _, pose in ipairs(object.poses) do
		pose.animation:Stop(fadeTime or DEFAULT_FADE_TIME)
	end
	object.playing = false
end

function Blend1DSpace:IsPlaying(): boolean
	local object = self :: Types.BlendSpace1DClass
	
	return object.playing
end

return Blend1DSpace