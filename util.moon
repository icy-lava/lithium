import pack, lazy from require 'lithium.common'
import concat from table
import format from string
inspect = lazy require, 'inspect'

with {}
	.lazyloader = (prefix = '') -> setmetatable({}, {
		__index: (t, key) ->
			status, result = pcall require, prefix .. key
			if status
				t[key] = result
				return result
			return nil
	})
	
	.printf = (...) -> print format ...
	
	-- Some options for inspect, to avoid unnecessary noise
	inspectOptions = {
		indent: '    '
		process: (item, path) -> return item if path[#path] != inspect.METATABLE
	}
	.printi = (...) ->
		t = pack ...
		for i = 1, t.n
			t[i] = inspect(t[i], inspectOptions)
		str = concat t, ', '
		print str
		return ...
	
	mapLineNumber = (fileName, lineNumber, cache) ->
		-- import readBytes from require 'lithium.io'
		import reverse_line_number from require 'moonscript.errors'
		line_tables = require 'moonscript.line_tables'
		
		-- cache[fileName] = readBytes fileName if not cache[fileName]
		line_table = assert line_tables["@#{fileName}"]
		newLineNumber = reverse_line_number fileName, line_table, lineNumber, cache
		assert newLineNumber != 'unknown'
		return newLineNumber
	.rewriteTraceback = (traceback) ->
		cache = {}
		newLines = traceback\gsub '[^\r\n]+', (line) ->
			whitespace, fileName, lineNumber, message = line\match '^(%s*)(.-):(%d+):(.*)$'
			return line if not whitespace or not fileName\match '%.moon$'
			lineNumber = mapLineNumber fileName, lineNumber, cache
			message = message\gsub 'in function <([^<>]+%.moon):(%d+)>', (file, line) ->
				line = mapLineNumber file, line, cache
				return "in function <#{file}:#{line}(*)>"
			return "#{whitespace}#{fileName}:#{lineNumber}(*):#{message}"
		return newLines