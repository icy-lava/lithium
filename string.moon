import insert from table
import wrap, yield from coroutine
import array from require 'lithium.common'

with setmetatable {}, {__index: string}
	delimIterator = (str, delim, plain) ->
		yield!
		i, strlen = 1, #str
		while true
			start, stop = str\find delim, i, plain
			if start
				if stop < start -- then error 'delimiter function did not advance', 2
					stop += 1
					start += 1
				
				yield str\sub i, start - 1
				i = stop + 1
				if i > strlen
					if start <= stop then yield ''
					break
			else
				yield str\sub i, strlen
				break
		while true do yield nil
	.delim = (str, delim, pattern) ->
		iter = wrap delimIterator
		iter str, delim, not pattern
		return iter
	.lines = (str) -> .delim str, '\r?\n', true
	.split = (str, delim, pattern) -> array .delim str, delim, pattern
	.startsWith = (str, prefix) -> prefix == str\sub 1, #prefix
	.endsWith = (str, suffix) -> suffix == str\sub -#suffix, -1