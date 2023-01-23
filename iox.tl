return {
	readBytes = function(path: string, bytes: integer): string, string
		assert(path)
		if bytes is nil then bytes = -1 end
		
		local stream, err = io.open(path, 'rb')
		if stream is nil then return nil, err end
		local result : string
		if bytes < 0 then
			if bytes == -1 then
				result, err = stream:read '*a'
			else
				local size = stream:seek 'end'
				stream:seek 'set'
				result, err = stream:read(size + bytes + 1)
			end
		else
			result, err = stream:read(bytes)
		end
		
		stream:close()
		
		if result is nil then return nil, err or 'could not read file' end
		return result
	end
}