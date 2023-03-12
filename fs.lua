local common = require 'lithium.common'
local fs = {}

if common.isWindows then
	
else
	local function escapePath(path)
		if path:match('^%-') then
			return './' .. path
		end
		return path
	end
	
	local modeMap = {
		[ 1] = 'named pipe',
		[ 2] = 'char device',
		[ 4] = 'directory',
		[ 6] = 'block device',
		[ 8] = 'file',
		[10] = 'link',
		[12] = 'socket',
	}
	
	local function attributes(follow, filepath, request)
		filepath = escapePath(filepath)
		local commandParams = {'stat', '-c', '%d\t%i\t%f\t%h\t%u\t%g\t%t\t%X\t%Y\t%Z\t%s\t%A\t%b\t%o', filepath}
		if follow then
			table.insert(commandParams, 2, '-L')
		end
		local commandLine = common.formCommand(common.unpack(commandParams))
		local params = {}
		for line in common.commandLines(commandLine .. ' 2>/dev/null') do
			for match in line:gmatch('[^\t]+') do
				table.insert(params, match)
			end
			break
		end
		
		if #params ~= 14 then
			return nil, 'could not get file attributes'
		end
		
		local info = (type(request) == 'table') and request or {}
		info.dev = tonumber(params[1])
		info.ino = tonumber(params[2])
		info.mode = modeMap[math.floor(tonumber(params[3], 16) / 2 ^ 12)] or 'other'
		info.nlink = tonumber(params[4])
		info.uid = tonumber(params[5])
		info.gid = tonumber(params[6])
		info.rdef = tonumber(params[7])
		info.access = tonumber(params[8])
		info.modification = tonumber(params[9])
		info.change = tonumber(params[10])
		info.size = tonumber(params[11])
		info.permissions = params[12]
		info.blocks = tonumber(params[13])
		info.blksize = tonumber(params[14])
		
		info.permissions = info.permissions:sub(-9) -- for compatibility with lfs
		
		if not follow and info.mode == 'link' then
			local commandLine = common.formCommand('readlink', filepath)
			for line in common.commandLines(commandLine .. ' 2>/dev/null') do
				info.target = line
				break
			end
		end
		
		if type(request) == 'string' then
			return assert(info[request])
		end
		return info
	end
	
	function fs.attributes(filepath, request)
		return attributes(true, filepath, request)
	end
	
	function fs.symlinkattributes(filepath, request)
		return attributes(false, filepath, request)
	end
	
	function fs.chdir()
		return nil, 'changing current directory is not implemented'
	end
	
	function fs.dir(filepath)
		if filepath == '' then
			error('could not list files', 2)
		end
		local commandLine = common.formCommand('ls', '-a', escapePath(filepath) .. '/')
		local nextLine = common.commandLines(commandLine .. ' 2>/dev/null ; echo "//$?"')
		return function()
			local line = nextLine()
			if not line then
				return nil
			end
			if line:match('^//%d+$') then
				if line ~= '//0' then
					error('could not list files', 2)
				end
				return nil
			end
			return line
		end
	end
	
	function fs.mkdir(dirname)
		local commandLine = common.formCommand('mkdir', escapePath(dirname))
		local status = 1
		for line in common.commandLines(commandLine .. ' 2>/dev/null ; echo $?') do
			status = tonumber(line) or 1
			break
		end
		if status ~= 0 then
			return nil, 'could not create directory', status
		end
		return true
	end
	
	function fs.rmdir(dirname)
		local commandLine = common.formCommand('rmdir', escapePath(dirname))
		local status = 1
		for line in common.commandLines(commandLine .. ' 2>/dev/null ; echo $?') do
			status = tonumber(line) or 1
			break
		end
		if status ~= 0 then
			return nil, 'could not remove directory', status
		end
		return true
	end
	
	function fs.currentdir()
		local path = ''
		for line in common.commandLines('ls -d "$PWD" 2>/dev/null') do
			path = line
			break
		end
		if path == '' then
			return nil, 'could not get current directory'
		end
		return path
	end
end

return fs