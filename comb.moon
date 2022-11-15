import pack, remove, copy from require 'lithium.table'
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
				
				newState = copy newState
				newState.result = mapper newState.result
				return newState
		mapError: (mapper) =>
			transform = @transform
			Parser (state) ->
				newState, err = transform state
				return newState if newState
				err = mapper err, state
				return nil, err
		opposite: =>
			transform = @transform
			Parser (state) ->
				newState, err = transform state
				return nil, "unexpected match #{.where state}" if newState
				newState = copy state
				return state
		atLeast: (num) =>
			transform = @transform
			Parser (state) ->
				results = {}
				count = 0
				local err
				while true
					newState, err = transform state
					break unless newState
					count += 1
					results[count] = newState.result
					state = newState
				
				return nil, "expected at least #{num} matches, got #{count}; #{err}" if count < num
				
				newState = copy state
				newState.result = results
				return newState
		atMost: (num) =>
			transform = @transform
			Parser (state) ->
				results = {}
				count = 0
				for i = 1, num
					newState, err = transform state
					break unless newState
					results[i] = newState.result
					state = newState
				
				newState = copy state
				newState.result = results
				return newState
		noConsume: =>
			transform = @transform
			Parser (state) ->
				newState, err = transform state
				return nil, err unless newState
				newState = copy newState
				newState.index = state.index
				return newState
		
		__unm: => @opposite!
		__add: (other) => .choice {@, other}
		__sub: (other) => .sequence({-other, @}) / (result) -> result[2]
		__mul: (other) => .sequence {@, other}
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

	.literal = (str) -> Parser (state) ->
		{:data, :index} = state
		strlen = #str
		if str == data\sub index, index + strlen - 1
			newState = copy state
			newState.index += strlen
			newState.result = str
			return newState
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
			newState = copy state
			newState.result = {:match, :captures}
			newState.index = stop + 1
			return newState
		return nil, "did not match pattern '#{str}' #{.where state}"
	
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
	
	.identifier = .pattern '[%a_][%w_]*'
	.identifier /= (result) -> result.match
	.identifier %= (err, state) -> "did not match identifier #{.where state}"
	
	.eof = .pattern '$'
	
	.sequence = (seq) -> Parser (state) ->
		results = {}
		for i, parser in ipairs seq
			newState, err = parser.transform state
			return nil, err unless newState
			state = newState
			results[i] = state.result
		newState = copy state
		newState.result = results
		return newState
	
	.choice = (opt) -> Parser (state) ->
		results = {}
		local firstErr
		for parser in *opt
			newState, err = parser.transform state
			return newState if newState
			firstErr = err unless firstErr
		return nil, "did not match any parser; #{firstErr}"