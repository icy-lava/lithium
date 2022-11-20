import lines from require 'lithium.string'

with setmetatable {}, {__index: io}
	.readBytes = (path, bytes = -1) ->
		assert path
		
		-- TODO: don't assert, return error
		with assert io.open path, 'rb'
			local data
			if bytes < 0
				if bytes == -1
					data = \read '*a'
				else
					size = \seek 'end'
					\seek 'set'
					data = \read size + bytes + 1
			else
				data = \read bytes
				
			\close!
			
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