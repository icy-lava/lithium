local common = require 'lithium.common'

local iox = setmetatable({
	read = common.read,
	write = common.write,
	append = common.append,
}, {__index = io})

return iox