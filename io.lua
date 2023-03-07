local common = require 'lithium.common'

local lio = setmetatable({
	read = common.read,
	write = common.write,
	append = common.append,
}, {__index = io})

return lio