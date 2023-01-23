local format, char, byte = string.format, string.char, string.byte

return {
	encode = function(str: string): string
		local result = str:gsub('.', function(c: string): string
			return format('%02x', byte(c))
		end)
		return result
	end,
	decode = function(str: string): string
		if #str % 2 ~= 0 then
			error 'string length must be a multiple of 2'
		end
		local result = str:gsub('..', function(b: string): string
			local num = tonumber(b, 16)
			if num == nil then
				error('string contains non-hex character', 2)
			end
			return char(num)
		end)
		return result
	end
}