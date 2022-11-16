comb = require 'lithium.comb'
import literal, pattern, uptoPattern, whitespace, sequence, eof from comb
import concat, insert, imap from require 'lithium.table'

with {}
	maybe_ws = whitespace\maybe!\default ''
	comma = literal','
	comma_ws = comma\surround maybe_ws
	
	fals = literal'false' / -> false
	tru = literal'true' / -> true
	boolean = tru + fals
	boolean = boolean\tag 'boolean'
	
	null = literal'null' / -> nil
	null = null\tag 'null'
	
	number = sequence({
		pattern'%-?%d+'\index'match'
		pattern'%.%d+'\index'match'\maybe!\default ''
		pattern'[Ee][%-%+]?%d+'\index'match'\maybe!\default ''
	}) / concat / tonumber
	number = number\tag 'number'
	
	escape = literal'\\' * (pattern'["\\/bfnrt]' + pattern'u%x%x%x%x')\index'match'
	escape /= (result) ->
		if 'u' == result\sub 1, 1
			-- FIXME: need to decode unicode escape
			return '?'
		switch result
			when 'b' then '\b'
			when 'f' then '\f'
			when 'n' then '\n'
			when 'r' then '\r'
			when 't' then '\t'
			else result
	
	strin = sequence({
		literal '"'
		(escape + uptoPattern'["\\%c]') ^ 0 / concat
		literal '"'
	})\second!
	strin = strin\tag 'string'
	
	local array, object
	value = comb.proxy -> array + object + boolean + null + number + strin
	
	array = sequence({
		literal '['
		maybe_ws
		(value\delimited comma_ws)\maybe!\default {}
		maybe_ws
		literal ']'
	})\third!
	array = array\tag 'array'
	
	record = sequence({
		strin\index'value'
		maybe_ws
		literal ':'
		maybe_ws
		value
	}) / (result) -> {key: result[1], value: result[5]}
	
	object = sequence({
		literal '{'
		maybe_ws
		(record\delimited comma_ws)\maybe!\default {}
		maybe_ws
		literal '}'
	})\third!
	object = object\tag 'object'
	
	.parse = (str) ->
		state = {data: str, index: 1}
		state, err = value\surround(maybe_ws, maybe_ws * eof)\run state
		return nil, err unless state
		return state.result
	
	decodeValue = (val) ->
		switch val.tag
			when 'array'
				imap val.value, decodeValue
			when 'object'
				obj = {}
				for rec in *val.value
					obj[rec.key] = decodeValue rec.value
				obj
			else
				val.value
	
	.decode = (str) ->
		result, err = .parse str
		return nil, err unless result
		decodeValue result
	
	ind = (level = 0) -> '\t'\rep level
	
	encodeValue = (val, indent = 0) ->
		switch type val
			when 'string'
				val = val\gsub '[%z\1-\31\\"]', (char) ->
					switch char
						when '\\' then '\\\\'
						when '"' then '\\"'
						when '\r' then '\\r'
						when '\n' then '\\n'
						when '\t' then '\\t'
						when '\b' then '\\b'
						else string.format '\\u%04x', char\byte!
				'"' .. val .. '"'
			when 'table'
				maxIndex = 0
				isArray = true
				for k, v in pairs val
					kt = type k
					return nil, 'object key may only be a string or a number' if kt != 'number' and kt != 'string'
					if isArray and kt == 'number' and k >= 1
						maxIndex = k if k > maxIndex
					else
						isArray = false
						break
				if isArray
					t = {}
					for i = 1, maxIndex
						t[i], err = encodeValue val[i]
						return nil, err unless t[i]
					"[#{concat t, ', ', 1, maxIndex}]"
				else
					t = {}
					for k, v in pairs val
						k = tostring k
						return nil, 'number - string object key name clash' if t[k]
						t[k] = true
						k, err = encodeValue k, indent + 1
						return nil, err unless k
						v, err = encodeValue v, indent + 1
						return nil, err unless v
						insert t, "#{ind indent + 1}#{k}: #{v}"
					"{\n#{concat t, ',\n'}\n#{ind(indent)}}"
			when 'nil'
				'null'
			else tostring val
	
	.encode = (val) -> encodeValue val