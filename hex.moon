import format, char, byte from string

with {}
	.encode = (str) -> str\gsub '.', (char) -> format '%02x', byte char
	.decode = (str) ->
		error 'string length must be a multiple of 2', 2 if #str % 2 != 0
		-- NOTE: we don't do this check for performance reasons, hope it's ok :)
		-- error 'string contains non-hex character', 2 if str\match '[^%x]'
		(
			str\gsub '..', (byte) ->
				num = tonumber byte, 16
				error 'string contains non-hex character', 2 if num == nil
				char num
		)