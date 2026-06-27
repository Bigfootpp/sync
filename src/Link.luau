--!strict
local Types = require(script.Parent.Types)
local Link = {}
Link.__index = Link

function Link.ConditionalLink(to: Types.StateClass, canPassFn: () -> boolean): Types.LinkClass
    local self = setmetatable({}, Link) :: Types.LinkClass

    self.to = to
	self._canPassFn = canPassFn

	return self
end

function Link.AutomaticLink(to: Types.StateClass, anim: Types.BaseAnimation) : Types.LinkClass
	return Link.ConditionalLink(to, function(): boolean
		return not anim:IsPlaying()
	end)
end

function Link:CanPassFn(): boolean
	local object = self :: Types.LinkClass

	return object._canPassFn()
end

return Link