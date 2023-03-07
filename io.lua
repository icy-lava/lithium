local common = require 'lithium.common'

local lio = setmetatable({
	readBytes = common.readBytes,
	writeBytes = common.writeBytes,
	appendBytes = common.appendBytes,
}, {__index = io})

return lio