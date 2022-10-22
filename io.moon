with setmetatable {}, {__index: io}
	.readBytes = (path, bytes = -1) ->
		assert path
		
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