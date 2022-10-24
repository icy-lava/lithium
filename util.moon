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
				