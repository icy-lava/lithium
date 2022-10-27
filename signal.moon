weak = {__mode = 'k'}

class Signal
	new: =>
		@funcHooks = {}
		@objHooks = setmetatable {}, weak
	connect: (funcOrObj, event = true) =>
		if event == true
			@funcHooks[funcOrObj] = true
		else
			@objHooks[funcOrObj] = event
	disconnect: (funcOrObj) =>
		@funcHooks[funcOrObj] = nil
		@objHooks[funcOrObj] = nil
	emit: (...) =>
		for func in pairs @funcHooks
			func ...
		for obj, event in pairs @objHooks
			obj[event] obj, ...
		return ...