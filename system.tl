local common = require 'lithium.common'
local isWindows = common.isWindows
local format = string.format
local concat = table.concat

local hasShell = os.execute() ~= 0

return {
	isWindows = isWindows,
	hasShell = hasShell,
	execute = hasShell and function(program: string, ...: string): boolean, string, integer
		local args = common.pack(program, ...)
		for i = 1, args.n do
			-- TODO: convert args correctly for Linux and Windows
			args[i] = format('"%s"', args[i])
		end
		local command = concat(args, ' ', 1, args.n)
		if isWindows() then
			command = format('"%s"', command)
		end
		return os.execute(command)
	end or nil
}