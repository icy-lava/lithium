import pack from require 'lithium.common'
import concat from table
import execute, getenv from os

with system = {}
	.isWindows = if jit
		jit.os == 'Windows'
	elseif love
		require('love.system').getOS! == 'Windows'
	else
		getenv('OS') == 'Windows_NT'
	
	.hasShell = execute! != 0
	
	if .hasShell
		.execute = (program, ...) ->
			args = pack program, ...
			for i = 1, args.n
				-- TODO: convert args correctly for Linux and Windows
				args[i] = "\"#{args[i]}\""
			command = concat args, ' ', 1, args.n
			command = "\"#{command}\"" if .isWindows
			execute command
	