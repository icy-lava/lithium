return setmetatable({}, {__index = function(t, module)
	local status, result = pcall(require, 'lithium.' .. module)
	if status then
		t[module] = result
		return result
	end
	return nil
end})