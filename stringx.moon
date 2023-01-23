import insert from table
import wrap, yield from coroutine
import array from require 'lithium.common'

with stringx = setmetatable {}, {__index: string}
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
	.delim = (str, delim, isPattern) ->
		iter = wrap delimIterator
		iter str, delim, not isPattern
		return iter
	.lines = (str) -> .delim str, '\r?\n', true
	.lineAt = (str, i, newlinePattern = '\n') ->
		line = 1
		for _ in str\sub(1, i - 1)\gmatch newlinePattern
			line += 1
		return line
	.positionAt = (str, i, newlinePattern = '\n') ->
		return nil, 'index is out of range' if i > #str
		col = 1
		line = 1
		j = 1
		while j < i
			start, stop = str\find newlinePattern, j
			break if not start or stop >= i
			return nil, 'newline pattern matches empty string' if stop < j
			j = stop + 1
			col = 1
			line += 1
		return line, i - j + 1
	.split = (...) -> array .delim ...
	
	.startsWith = (str, prefix) -> prefix == str\sub 1, #prefix
	.endsWith = (str, suffix) -> suffix == str\sub -#suffix, -1
	.contains = (str, substr) -> not not str\find substr, 1, true
	
	.trimLeft = (str) -> (str\gsub '^%s+', '', 1)
	.trimRight = (str) -> (str\gsub '%s+$', '', 1)
	.trim = (str) -> .trimLeft .trimRight str
	.trimNonEmpty = (str) ->
		str = .trim str
		return nil if str == ''
		return str
	
	.patch = ->
		for k, v in pairs stringx
			string[k] = v