local common = require 'lithium.common'

return {
	isWindows    = common.isWindows,
	formCommand  = common.formCommand,
	execute      = common.execute,
	readProcess  = common.readProcess,
	writeProcess = common.writeProcess,
	processLines = common.processLines,
	readCommand  = common.readCommand,
	writeCommand = common.writeCommand,
	commandLines = common.commandLines,
}