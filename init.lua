return setmetatable({}, {
	__index = function(t, modname)
		local status, result = pcall(require, "lithium." .. modname)
		if not status then
			error(result, 2)
		end
		t[modname] = result
		return result
	end
})