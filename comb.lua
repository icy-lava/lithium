local ltable = require 'lithium.table'
local lstring = require 'lithium.string'
local common = require 'lithium.common'

local Parser = {}
Parser.__index = Parser

local comb = {
	Parser = Parser,
}

function Parser.new(transformer)
	return setmetatable({
		_transformer = transformer,
	}, Parser)
end

function Parser:run(state)
	return self._transformer(ltable.clone(state))
end

function Parser:__call(state)
	return self:run(state)
end

function Parser:parseData(data, source)
	local state = {
		source = source,
		data = data,
		index = 1,
	}
	
	local newState, err = self(state)
	if newState then
		return newState
	end
	
	local pointer = tostring(err.index)
	if type(data) == 'string' then
		local line, col = lstring.positionAt(data, err.index)
		pointer = string.format('%d:%d', line, col)
	end
	if source then
		source = source .. ':'
	else
		source = ''
	end
	
	return nil, string.format('%s%s: %s', source, pointer, err.message)
end

function Parser:parseFile(path)
	local data, err = common.readFile(path)
	if not data then
		return nil, err
	end
	return self:parseData(data, path)
end

function Parser:__add(other)
	return comb.choice {self, other}
end

function Parser:__sub(other)
	return comb.sequence {other:opposite(), self} :index(2)
end

function Parser:__mul(other)
	return comb.sequence {self, other} :index(2)
end

function Parser:__div(func)
	assert(type(func) == 'function')
	return self:map(func)
end

function Parser:__mod(func)
	assert(type(func) == 'function')
	return self:mapError(func)
end

function Parser:__len()
	return self:noConsume()
end

function Parser:__pow(exponent)
	if exponent >= 0 then
		return self:atLeast(exponent)
	end
	return self:atMost(-exponent)
end

function Parser:__unm()
	return self:opposite()
end

function Parser:map(mapper)
	return Parser.new(function(state)
		local newState, err = self(state)
		if not newState then
			return nil, err
		end
		newState.result = mapper(newState.result)
		return newState
	end)
end

function Parser:mapError(mapper)
	return Parser.new(function(state)
		local newState, err = self(state)
		if newState then
			return newState
		end
		err = mapper(err)
		if not comb.isError(err) then
			error('not an error object', 2)
		end
		return nil, err
	end)
end

function Parser:chain(resultToParser)
	return Parser.new(function(state)
		local newState, err = self(state)
		if not newState then
			return nil, err
		end
		local nextParser = resultToParser(newState.result)
		return nextParser(newState)
	end)
end

function Parser:noConsume()
	return Parser.new(function(state)
		local newState, err = self(state)
		if not newState then
			return nil, err
		end
		return state
	end)
end

function Parser:atLeast(num)
	return Parser.new(function(state)
		local results = {}
		local count = 0
		local err
		
		while true do
			local newState
			newState, err = self(state)
			if not newState then
				break
			end
			if newState.index == state.index then
				err = 'parser did not advance the index'
				break
			end
			state = newState
			count = count + 1
			table.insert(results, state.result)
		end
		
		if count < num then
			return nil, lstring.format('expected at least %d matches, got %d; %s', num, count, err)
		end
		
		state.result = results
		return state
	end)
end

function Parser:atMost(num)
	return Parser.new(function(state)
		local results = {}
		
		for _ = 1, num do
			local newState = self(state)
			if not newState or (newState.index == state.index) then
				break
			end
			state = newState
			table.insert(results, state.result)
		end
		
		state.result = results
		return state
	end)
end

function Parser:opposite(message)
	return Parser.new(function(state)
		local newState, _ = self(state)
		if newState then
			return nil, message or 'unexpected parser match'
		end
		return state
	end)
end

function Parser:tag(name)
	return self:map(function(result)
		return {
			tag = name,
			value = result,
		}
	end)
end

function Parser:delimited(delimiter)
	local delimParser = delimiter * self
	return Parser.new(function(state)
		local newState, err = self(state)
		if not newState then
			return nil, err
		end
		
		state = newState
		local results = {state.result}
		while true do
			newState = delimParser(state)
			if not newState then
				break
			end
			state = newState
			table.insert(results, state.result)
		end
		
		state.result = results
		return state
	end)
end

function Parser:enclosed(left, right)
	right = right or left
	return comb.sequence {left, self, right} :second()
end

function Parser:prefix(other)
	return other * self
end

function Parser:suffix(other)
	return comb.sequence {self, other} :first()
end

function Parser:optional()
	return Parser.new(function(state)
		local newState = self(state)
		if newState then
			state = newState
		else
			state.result = nil
		end
		return state
	end)
end

function Parser:wsl()
	return self:prefix(comb.mws)
end

function Parser:wsr()
	return self:suffix(comb.mws)
end

function Parser:wse()
	return self:enclosed(comb.mws)
end

function Parser:index(key)
	return self:map(function(result)
		return result[key]
	end)
end

function Parser:match()
	return self:index('match')
end

function Parser:captures()
	return self:index('captures')
end

function Parser:first()
	return self:index(1)
end

function Parser:second()
	return self:index(2)
end

function Parser:third()
	return self:index(3)
end

function Parser:last()
	return self:map(function(result)
		return result[#result]
	end)
end

function Parser:concat(sep)
	return self:map(function(result)
		local len = result.n or #result
		for i = 1, len do
			result[i] = tostring(result[i])
		end
		return table.concat(result, sep, 1, len)
	end)
end

function Parser:default(value)
	return self:map(function(result)
		if result == nil then
			result = value
		end
		return result
	end)
end

function Parser:value(value)
	return self:map(function(_)
		return value
	end)
end

function Parser:null()
	return self:value(nil)
end

function Parser:gsub(pattern, repl, n)
	return self:map(function(result)
		return result:gsub(pattern, repl, n)
	end)
end

local errorKey = {}

function comb.isError(value)
	return type(value) == 'table' and value[errorKey] or false
end

function comb.error(state, message)
	return {
		[errorKey] = true,
		message = message,
		index = state.index,
	}
end

function comb.literal(str)
	return Parser.new(function(state)
		local data, index = state.data, state.index
		if data:sub(index, index + #str - 1) == str then
			state.index = index + #str
			state.result = str
			return state
		end
		
		return nil, comb.error(state, 'did not match literal ' .. lstring.quote(str))
	end)
end

function comb.pattern(str)
	return Parser.new(function(state)
		local data, index = state.data, state.index
		local start, stop, captures = common.packCaptures(data:find(str:gsub('^%^?', '^', 1), index))
		if start then
			captures.n = nil
			local match = data:sub(start, stop)
			state.result = {
				match = match,
				captures = captures,
			}
			state.index = stop + 1
			return state
		end
		
		return nil, comb.error(state, 'did not match pattern ' .. lstring.quote(str))
	end)
end

function comb.uptoLiteral(str)
	return Parser.new(function(state)
		local data, index = state.data, state.index
		local start = data:find(str, index, true)
		if not start then
			start = #data + 1
		end
		
		state.index = start
		state.result = data:sub(index, start - 1)
		return state
	end)
end

function comb.uptoPattern(str)
	return Parser.new(function(state)
		local data, index = state.data, state.index
		local start = data:find(str, index)
		if not start then
			start = #data + 1
		end
		
		state.index = start
		state.result = data:sub(index, start - 1)
		return state
	end)
end

function comb.sequence(parsers)
	return Parser.new(function(state)
		local results = {}
		for _, parser in ipairs(parsers) do
			local newState, err = parser(state)
			if not newState then
				return nil, err
			end
			state = newState
			table.insert(results, state.result)
		end
		state.result = results
		return state
	end)
end

function comb.choice(parsers)
	return Parser.new(function(state)
		for _, parser in ipairs(parsers) do
			local newState, _ = parser(state)
			if newState then
				return newState
			end
		end
		return nil, comb.error(state, 'choice didn\'t match any parser')
	end)
end

function comb.proxy(getParser)
	return Parser.new(function(state)
		return getParser()(state)
	end)
end

function comb.delimited(delimiter)
	return function(parser)
		return parser:delimited(delimiter)
	end
end

function comb.enclosed(left, right)
	return function(parser)
		return parser:enclosed(left, right)
	end
end

-- Big chonker, but this is a really helpful function for parsing binary expressions with precedence
function comb.binary(atom, precDef)
	local precMap = {}
	local allParsers = {}
	for prec, parsers in ipairs(precDef) do
		for i = 1, #parsers do
			local parser = parsers[i]
			precMap[parser] = prec
			table.insert(allParsers, parser)
		end
	end
	
	local function maybe_binary(state, prec)
		local oldState = state
		local matched = false
		local otherPrec
		for i = 1, #allParsers do
			local parser = allParsers[i]
			local newState = parser(state)
			if newState then
				state = newState
				matched = true
				otherPrec = precMap[parser]
				break
			end
		end
		if matched and otherPrec > prec then
			local operator = state.result
			local newState, err = atom(state)
			if not newState then
				return nil, err
			end
			state = newState
			newState, err = maybe_binary(state, otherPrec)
			if not newState then
				return nil, err
			end
			state = newState
			state.result = {
				operator = operator,
				left = oldState.result,
				right = state.result
			}
			return maybe_binary(state, prec)
		end
		return oldState
	end
	
	return Parser(function(state)
		local newState, err = atom(state)
		if not newState then
			return nil, err
		end
		state = newState
		return maybe_binary(state, 0)
	end)
end

comb.digit = comb.pattern('%d'):index('match')
comb.digit = comb.digit % function(err)
	err.message = "did not match digit"
	return err
end

comb.digits = comb.pattern('%d+'):index('match')
comb.digits = comb.digits % function(err)
	err.message = "did not match digits"
	return err
end

comb.letter = comb.pattern('%a'):index('match')
comb.letter = comb.letter % function(err)
	err.message = "did not match letter"
	return err
end

comb.letters = comb.pattern('%a+'):index('match')
comb.letters = comb.letters % function(err)
	err.message = "did not match letters"
	return err
end

comb.whitespace = comb.pattern('%s+'):index('match')
comb.whitespace = comb.whitespace % function(err)
	err.message = "did not match whitespace"
	return err
end

comb.mws = comb.pattern('%s*'):index('match')

comb.cr = comb.literal('\r')
comb.cr = comb.cr % function(err)
	err.message = "did not match carriage return"
	return err
end

comb.lf = comb.literal('\n')
comb.lf = comb.lf % function(err)
	err.message = "did not match line feed"
	return err
end

comb.crlf = comb.literal('\r\n')
comb.crlf = comb.crlf % function(err)
	err.message = "did not match CRLF"
	return err
end

comb.newline = comb.pattern('\r?\n'):index 'match'
comb.newline = comb.newline % function(err)
	err.message = "did not match newline"
	return err
end

comb.eof = Parser.new(function(state)
	if state.index > #state.data then
		return state
	end
	return nil, 'did not match EOF'
end)

comb.endline = comb.newline + comb.eof
comb.endline = comb.endline % function(err)
	err.message = "did not match end of line"
	return err
end

comb.identifier = comb.pattern('[%a_][%w_]*'):index('match')
comb.identifier = comb.identifier % function(err)
	err.message = "did not match identifier"
	return err
end


return comb