local common = require 'lithium.common'

local lio = setmetatable({
	readFile = common.readFile,
	writeFile = common.writeFile,
	appendFile = common.appendFile,
	pprint = common.pprint,
}, {__index = io})

function lio.fprint(file, ...)
	local t = {...}
	local tlen = select('#', ...)
	for i = 1, tlen do
		t[i] = tostring(t[i])
	end
	file:write(table.concat(t, ' ', 1, tlen), '\n')
end

function lio.print(...)
	lio.fprint(io.stdout, ...)
end

function lio.eprint(...)
	lio.fprint(io.stderr, ...)
end

function lio.fprintf(file, format, ...)
	file:write(string.format(format, ...))
end

function lio.printf(format, ...)
	lio.fprintf(io.stdout, format, ...)
end

function lio.eprintf(format, ...)
	lio.fprintf(io.stderr, format, ...)
end

return lio