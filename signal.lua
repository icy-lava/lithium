local weak = {__mode = 'k'}

local Signal = {}
Signal.__index = Signal

function Signal.isSignal(value)
	if rawequal(value, Signal) then return false end
	return getmetatable(value) == Signal
end

function Signal.new()
	return setmetatable({
		funcHooks = {},
		objHooks = setmetatable({}, weak),
	}, Signal)
end

function Signal:connect(funcOrEvent, obj)
	if type(obj) == 'table' then
		self.objHooks[obj] = funcOrEvent
	else
		self.funcHooks[funcOrEvent] = true
	end
end

function Signal:disconnect(funcOrObj)
	self.funcHooks[funcOrObj] = nil
	self.objHooks[funcOrObj] = nil
end

function Signal:emit(...)
	for func in pairs(self.funcHooks) do
		func(...)
	end
	for obj, event in pairs(self.objHooks) do
		local callback = obj[event]
		if callback then
			callback(obj, ...)
		end
	end
end

return Signal