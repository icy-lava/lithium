local common = require 'lithium.common'

local record lio
	
end

return {
	-- io.*
	close   = io.close,
	flush   = io.flush,
	input   = io.input,
	lines   = io.lines,
	open    = io.open,
	output  = io.output,
	popen   = io.popen,
	stderr  = io.stderr,
	stdin   = io.stdin,
	stdout  = io.stdout,
	tmpfile = io.tmpfile,
	type    = io.type,
	-- read    = io.read,
	-- write   = io.write,
	
	-- lithium.common
	readBytes   = common.readBytes,
	writeBytes  = common.writeBytes,
	appendBytes = common.appendBytes,
	pprint      = common.pprint,
}