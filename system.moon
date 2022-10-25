import pack from require 'lithium.common'
import concat from table
import execute from os

with system = {}
	.isWindows = if jit
		jit.os == 'Windows'
	elseif love
		require('love.system').getOS! == 'Windows'
	else
		os.getenv('OS') == 'Windows_NT'
	
	.hasShell = os.execute! != 0
	
	if .hasShell
		.execute = (program, ...) ->
			args = pack program, ...
			for i = 1, args.n
				-- TODO: convert args correctly for Linux and Windows
				args[i] = "\"#{args[i]}\""
			command = concat args, ' ', 1, args.n
			os.execute command
	