import insert from table

with setmetatable {}, {__index: string}
	.split = (str, delim, plain) ->
		assert str
		assert delim
		if type(delim) == 'number'
			left = str\sub 1, delim
			right = str\sub delim + 1, -1
			return left, right
		else
			i, strlen, values = 1, #str, {}
			while i <= strlen
				start, stop = str\find delim, i, plain
				if start
					insert values, str\sub i, start - 1
					i = stop + 1
				else
					insert values, str\sub i, strlen
					break
			return values