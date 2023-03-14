local common = require 'lithium.common'

local record lio
	fprint: function(file: FILE, ...: any)
	print: function(...: any)
	eprint: function(...: any)
	fprintf: function(file: FILE, format: string, ...: any)
	printf: function(format: string, ...: any)
	eprintf: function(format: string, ...: any)
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
	read    = io.read,
	write   = io.write,
	
	-- lithium.common
	readFile   = common.readFile,
	writeFile  = common.writeFile,
	appendFile = common.appendFile,
	fileLines  = common.fileLines,
	fpprint    = common.fpprint,
	pprint     = common.pprint,
	epprint    = common.epprint,
	
	-- lithium.io.*
	fprint  = lio.fprint,
	print   = lio.print,
	eprint  = lio.eprint,
	fprintf = lio.fprintf,
	printf  = lio.printf,
	eprintf = lio.eprintf,
}