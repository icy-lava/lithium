local common = require 'lithium.common'

local lio = setmetatable({
	readBytes = common.readBytes,
	writeBytes = common.writeBytes,
	appendBytes = common.appendBytes,
	pprint = common.pprint,
}, {__index = io})

return lio