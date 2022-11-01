import pack from require 'lithium.common'

with {}
	.lex = (str, lexTypes) ->
		i = 1
		strlen = #str
		tokens = {}
		while i <= strlen
			success = false
			for lexType in *lexTypes
				ltype = lexType[1]
				for j = 2, #lexType
					parser = lexType[j]
					local values
					if 'string' == type parser
						pattern = parser\gsub '^%^?', '^', 1
						values = pack str\find pattern, i
					else
						values = pack parser str, i, strlen
					start, stop = values[1], values[2]
					if start and stop
						table.remove values, 2
						table.remove values, 1
						values.n -= 2
						values[0] = str\sub start, stop
						
						table.insert tokens, {type: ltype, :start, :stop, captures: values}
						
						i = stop + 1
						success = true
						break
				break if success
			return nil, "couldn't parse byte '#{str\sub i, i}' at index #{i}", i unless success
		return tokens