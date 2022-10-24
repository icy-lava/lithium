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
						values = pack str\find parser\gsub('^%^?', '^', 1), i
					else
						values = pack parser str, i, strlen
					start, stop = values[1], values[2]
					if start and stop
						table.remove values, 2
						table.remove values, 1
						values.n -= 2
						
						table.insert tokens, {type: ltype, value: str\sub(start, stop), :start, :stop, captures: values}
						
						i = stop + 1
						success = true
						break
				if success then break
			if not success
				return nil, "couldn't parse string at byte #{i}"
		return tokens