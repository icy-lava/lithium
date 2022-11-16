import pack, remove, insert, copy from require 'lithium.table'
import positionAt from require 'lithium.string'

with {}
	class Parser
		new: (@transform) =>
		run: (state) =>
			newState, err = @.transform state
			return nil, err unless newState
			return newState
		map: (mapper) =>
			transform = @transform
			Parser (state) ->
				newState, err = transform state
				return nil, err unless newState
				with copy newState
					.result = mapper .result
		mapError: (mapper) =>
			transform = @transform
			Parser (state) ->
				newState, err = transform state
				return newState if newState
				err = mapper err, state
				return nil, err
		tag: (name) => @ / (result) -> {tag: name, value: result}
		prefix: (pre) => pre * @
		suffix: (suf) => .sequence({@, suf})\first!
		surround: (prefix, suffix = prefix) => .sequence({prefix, @, suffix})\second!
		
		index: (idx) => @ / (result) -> result[idx]
		first: => @index 1
		second: => @index 2
		third: => @index 3
		fourth: => @index 4
		
		maybe: => (@ ^ -1)\first!
		default: (value) => @ / (result = value) -> result
		
		delimited: (delimiter) =>
			rest = (delimiter * @) ^ 0
			transform = @transform
			Parser (state) ->
				newState, err = transform state
				return nil, err unless newState
				state = newState
				results = {state.result}
				newState, err = rest state
				if newState
					state = newState
					for result in *state.result
						insert results, result
				with copy state
					.result = results
		
		precede: (other) =>
			transform = @transform
			Parser (state) ->
				newState, err = transform state
				return nil, err unless newState
				state = newState
				newState, err = other.transform state
				return nil, err unless newState
				copy newState
		
		opposite: =>
			transform = @transform
			Parser (state) ->
				newState, err = transform state
				return nil, "unexpected match #{.where state}" if newState
				copy state
		atLeast: (num) =>
			transform = @transform
			Parser (state) ->
				results = {}
				count = 0
				local err
				while true
					newState, err = transform state
					-- NOTE: I don't know if it's desirable to break when index doesn't change, but we enter an infinite loop otherwise
					break if not newState or state.index == newState.index
					count += 1
					results[count] = newState.result
					state = newState
				results.n = count
				
				return nil, "expected at least #{num} matches, got #{count}; #{err}" if count < num
				
				with copy state
					.result = results
		atMost: (num) =>
			transform = @transform
			Parser (state) ->
				results = {}
				count = 0
				for i = 1, num
					newState, err = transform state
					break unless newState
					results[i] = newState.result
					results.n = i
					state = newState
				
				with copy state
					.result = results
		noConsume: =>
			transform = @transform
			Parser (state) ->
				newState, err = transform state
				return nil, err unless newState
				with copy newState
					.index = state.index
		__unm: => @opposite!
		__add: (other) => .choice {@, other}
		__sub: (other) => .sequence({-other, @}) / (result) -> result[2]
		__mul: (other) => @\precede other
		__len: => @noConsume!
		__pow: (exponent) => if exponent >= 0 then @atLeast exponent else @atMost -exponent
		__div: (divisor) => @map divisor
		__mod: (divisor) => @mapError divisor
		__call: (...) => @run ...
	.Parser = Parser
	
	.pinpoint = (state) ->
		return state\pinpoint! if state.pinpoint
		line, col = positionAt state.data, state.index
		return {
			message: "#{line}:#{col}",
			:line
			:col
		}
	.where = (state) -> "at #{.pinpoint(state).message}"
	
	.sequence = (seq) -> Parser (state) ->
		results = {}
		for i, parser in ipairs seq
			newState, err = parser.transform state
			return nil, err unless newState
			state = newState
			results[i] = state.result
		with copy state
			.result = results
	
	.choice = (opt) -> Parser (state) ->
		local firstErr
		for parser in *opt
			newState, err = parser.transform state
			return newState if newState
			firstErr = err if firstErr != nil
		return nil, "did not match any parser; #{firstErr}"
	
	.proxy = (getParser) ->
		parser = nil
		Parser (state) ->
			parser = getParser! if parser == nil
			return parser.transform state
	
	.literal = (str) -> Parser (state) ->
		{:data, :index} = state
		strlen = #str
		if str == data\sub index, index + strlen - 1
			return with copy state
				.index += strlen
				.result = str
		return nil, "did not match literal '#{str}' #{.where state}"

	.pattern = (str) -> Parser (state) ->
		{:data, :index} = state
		captures = pack data\find str\gsub('^%^?', '^', 1), index
		start, stop = captures[1], captures[2]
		if start
			remove captures, 2
			remove captures, 1
			captures.n -= 2
			match = data\sub start, stop
			return with copy state
				.result = {:match, :captures}
				.index = stop + 1
		return nil, "did not match pattern '#{str}' #{.where state}"
	
	.uptoLiteral = (str) -> Parser (state) ->
		{:data, :index} = state
		start = data\find str, index, true
		start = #data + 1 unless start
		with copy state
			.index = start
			.result = data\sub index, start - 1
	
	.uptoPattern = (str) -> Parser (state) ->
		{:data, :index} = state
		start = data\find str, index
		start = #data + 1 unless start
		with copy state
			.index = start
			.result = data\sub index, start - 1
	
	.digit = .pattern '%d'
	.digit /= (result) -> result.match
	.digit %= (err, state) -> "did not match digit #{.where state}"
	
	.digits = .pattern '%d+'
	.digits /= (result) -> result.match
	.digits %= (err, state) -> "did not match digits #{.where state}"
	
	.letter = .pattern '%a'
	.letter /= (result) -> result.match
	.letter %= (err, state) -> "did not match letter #{.where state}"
	
	.letters = .pattern '%a+'
	.letters /= (result) -> result.match
	.letters %= (err, state) -> "did not match letters #{.where state}"
	
	.whitespace = .pattern '%s+'
	.whitespace /= (result) -> result.match
	.whitespace %= (err, state) -> "did not match whitespace #{.where state}"
	
	.cr = .literal '\r'
	.cr %= (err, state) -> "did not match carriage return #{.where state}"
	.lf = .literal '\n'
	.lf %= (err, state) -> "did not match line feed #{.where state}"
	.crlf = .literal '\r\n'
	.crlf %= (err, state) -> "did not match CRLF #{.where state}"
	
	.newline = .pattern '\r?\n'
	.newline /= (result) -> result.match
	.newline %= (err, state) -> "did not match newline #{.where state}"
	
	.eof = .pattern '$'
	.eof %= (err, state) -> "did not match EOF #{.where state}"
	
	.endline = .newline + .eof
	.endline %= (err, state) -> "did not match end of line #{.where state}"
	
	.identifier = .pattern '[%a_][%w_]*'
	.identifier /= (result) -> result.match
	.identifier %= (err, state) -> "did not match identifier #{.where state}"