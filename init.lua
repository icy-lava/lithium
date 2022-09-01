return setmetatable({}, {__index = function(t, module)
	local status, result = pcall(require, 'lithium.' .. module)
	if not status then
		error(result, 2)
	end
	t[module] = result
	return result
end})