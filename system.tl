local common = require 'lithium.common'
local format = string.format
local concat = table.concat

global record jit os: string end
global love: table
local type love_system = record
	getOS: function(): string
end

local isWindows : boolean
if jit then
	isWindows = jit.os == 'Windows'
elseif love then
	isWindows = ((require as function)('love.system') as love_system).getOS() == 'Windows'
else
	isWindows = os.getenv('OS') == 'Windows_NT'
end

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
		if isWindows then
			command = format('"%s"', command)
		end
		return os.execute(command)
	end or nil
}