import lines from require 'lithium.string'

with setmetatable {}, {__index: io}
	.readBytes = (path, bytes = -1) ->
		assert path
		
		stream, err = io.open path, 'rb'
		return nil, err unless stream
		with stream
			local data
			if bytes < 0
				if bytes == -1
					data, err = \read '*a'
				else
					size = \seek 'end'
					\seek 'set'
					data, err = \read size + bytes + 1
			else
				data, err = \read bytes
			
			\close!
			
			return nil, err or 'could not read file' unless data
			return data
	
	stringFile = with {}
		.write = (...) =>
			len = select '#', ...
			for i = 1, len
				value = select i, ...
				switch type value
					when 'string', 'number'
						@content ..= value
					else
						error "bad argument ##{i} to 'write' (string expected, got #{type value})"
		.lines = => lines @content
		.setvbuf = -> -- Ignore buffering mode
		.tostring = => @content
		.__tostring = => @content
	
	stringFile.__index = stringFile
	
	-- TODO: unfinished
	.openString = (str = '', mode = 'r') ->
		local modeEnum
		if mode\find 'r'
			modeEnum = 'read'
		elseif mode\find 'w'
			modeEnum = 'write'
		else
			error "unknown mode: '#{mode}'"
		return setmetatable {content: str, mode: modeEnum}, stringFile