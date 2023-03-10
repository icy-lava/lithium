local common = require 'lithium.common'

return {
	isWindows    = common.isWindows,
	commandLine  = common.commandLine,
	execute      = common.execute,
	readProcess  = common.readProcess,
	writeProcess = common.writeProcess,
}