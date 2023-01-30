local pack, remove, insert, copy
do
	local _obj_0 = require('lithium.tablex')
	pack, remove, insert, copy = _obj_0.pack, _obj_0.remove, _obj_0.insert, _obj_0.copy
end
local positionAt
positionAt = require('lithium.stringx').positionAt
do
	local comb = {}
	local Parser
	do
		local _class_0
		local _base_0 = {
			run = function(self, state)
				return self.transform(state)
			end,
			map = function(self, mapper)
				local transform = self.transform
				return Parser(function(state)
					local newState, err = transform(state)
					if not (newState) then
						return nil, err
					end
					do
						local _with_0 = copy(newState)
						_with_0.result = mapper(_with_0.result)
						return _with_0
					end
				end)
			end,
			mapError = function(self, mapper)
				local transform = self.transform
				return Parser(function(state)
					local newState, err = transform(state)
					if newState then
						return newState
					end
					err = mapper(err, state)
					return nil, err
				end)
			end,
			tag = function(self, name)
				return self / function(result)
					return {
						tag = name,
						value = result
					}
				end
			end,
			prefix = function(self, pre)
				return pre * self
			end,
			suffix = function(self, suf)
				return comb.sequence({
					self,
					suf
				}):first()
			end,
			surround = function(self, prefix, suffix)
				if suffix == nil then
					suffix = prefix
				end
				return comb.sequence({
					prefix,
					self,
					suffix
				}):second()
			end,
			index = function(self, idx)
				return self / function(result)
					return result[idx]
				end
			end,
			first = function(self)
				return self:index(1)
			end,
			second = function(self)
				return self:index(2)
			end,
			third = function(self)
				return self:index(3)
			end,
			fourth = function(self)
				return self:index(4)
			end,
			maybe = function(self)
				return (self ^ -1):first()
			end,
			maybeBlank = function(self)
				return self:maybe():default('')
			end,
			default = function(self, value)
				return self / function(result)
					if result == nil then
						result = value
					end
					return result
				end
			end,
			wsl = function(self)
				return self:prefix(comb.maybe_ws)
			end,
			wsr = function(self)
				return self:suffix(comb.maybe_ws)
			end,
			wss = function(self)
				return self:surround(comb.maybe_ws)
			end,
			delimited = function(self, delimiter)
				local rest = (delimiter * self) ^ 0
				local transform = self.transform
				return Parser(function(state)
					local newState, err = transform(state)
					if not (newState) then
						return nil, err
					end
					state = newState
					local results = {
						state.result
					}
					newState, err = rest(state)
					if newState then
						state = newState
						local _list_0 = state.result
						for _index_0 = 1, #_list_0 do
							local result = _list_0[_index_0]
							insert(results, result)
						end
					end
					do
						local _with_0 = copy(state)
						_with_0.result = results
						return _with_0
					end
				end)
			end,
			precede = function(self, other)
				local transform = self.transform
				return Parser(function(state)
					local newState, err = transform(state)
					if not (newState) then
						return nil, err
					end
					state = newState
					newState, err = other(state)
					if not (newState) then
						return nil, err
					end
					return copy(newState)
				end)
			end,
			opposite = function(self)
				local transform = self.transform
				return Parser(function(state)
					local newState, err = transform(state)
					if newState then
						return nil, "unexpected match " .. tostring(comb.where(state))
					end
					return copy(state)
				end)
			end,
			atLeast = function(self, num)
				local transform = self.transform
				return Parser(function(state)
					local results = {}
					local count = 0
					local err
					while true do
						local newState
						newState, err = transform(state)
						if not newState or state.index == newState.index then
							break
						end
						count = count + 1
						results[count] = newState.result
						state = newState
					end
					results.n = count
					if count < num then
						return nil, "expected at least " .. tostring(num) .. " matches, got " .. tostring(count) .. "; " .. tostring(err)
					end
					do
						local _with_0 = copy(state)
						_with_0.result = results
						return _with_0
					end
				end)
			end,
			atMost = function(self, num)
				local transform = self.transform
				return Parser(function(state)
					local results = {}
					local count = 0
					for i = 1, num do
						local newState, err = transform(state)
						if not (newState) then
							break
						end
						results[i] = newState.result
						results.n = i
						state = newState
					end
					do
						local _with_0 = copy(state)
						_with_0.result = results
						return _with_0
					end
				end)
			end,
			noConsume = function(self)
				local transform = self.transform
				return Parser(function(state)
					local newState, err = transform(state)
					if not (newState) then
						return nil, err
					end
					do
						local _with_0 = copy(newState)
						_with_0.index = state.index
						return _with_0
					end
				end)
			end,
			__unm = function(self)
				return self:opposite()
			end,
			__add = function(self, other)
				return comb.choice({
					self,
					other
				})
			end,
			__sub = function(self, other)
				return comb.sequence({
					-other,
					self
				}) / function(result)
					return result[2]
				end
			end,
			__mul = function(self, other)
				return self:precede(other)
			end,
			__len = function(self)
				return self:noConsume()
			end,
			__pow = function(self, exponent)
				if exponent >= 0 then
					return self:atLeast(exponent)
				else
					return self:atMost(-exponent)
				end
			end,
			__div = function(self, divisor)
				return self:map(divisor)
			end,
			__mod = function(self, divisor)
				return self:mapError(divisor)
			end,
			__call = function(self, ...)
				return self:run(...)
			end
		}
		_base_0.__index = _base_0
		_class_0 = setmetatable({
			__init = function(self, transform)
				self.transform = transform
			end,
			__base = _base_0,
			__name = "Parser"
		}, {
			__index = _base_0,
			__call = function(cls, ...)
				local _self_0 = setmetatable({}, _base_0)
				cls.__init(_self_0, ...)
				return _self_0
			end
		})
		_base_0.__class = _class_0
		Parser = _class_0
	end
	comb.Parser = Parser
	comb.pinpoint = function(state)
		if state.pinpoint then
			return state:pinpoint()
		end
		local line, col = positionAt(state.data, state.index)
		return {
			message = tostring(line) .. ":" .. tostring(col),
			line = line,
			col = col
		}
	end
	comb.where = function(state)
		return "at " .. tostring(comb.pinpoint(state).message)
	end
	comb.sequence = function(seq)
		return Parser(function(state)
			local results = {}
			for i, parser in ipairs(seq) do
				local newState, err = parser.transform(state)
				if not (newState) then
					return nil, err
				end
				state = newState
				results[i] = state.result
			end
			do
				local _with_0 = copy(state)
				_with_0.result = results
				return _with_0
			end
		end)
	end
	comb.choice = function(opt)
		return Parser(function(state)
			local firstErr
			for _index_0 = 1, #opt do
				local parser = opt[_index_0]
				local newState, err = parser.transform(state)
				if newState then
					return newState
				end
				if firstErr ~= nil then
					firstErr = err
				end
			end
			return nil, "did not match any parser; " .. tostring(firstErr)
		end)
	end
	comb.binary = function(atom, precDef)
		local precMap = {}
		local allParsers = {}
		for i, parsers in ipairs(precDef) do
			for _index_0 = 1, #parsers do
				local parser = parsers[_index_0]
				precMap[parser] = i
				table.insert(allParsers, parser)
			end
		end
		local maybe_binary
		maybe_binary = function(state, prec)
			local oldState = state
			local matched = false
			local otherPrec
			for _index_0 = 1, #allParsers do
				local parser = allParsers[_index_0]
				local newState, err = parser(state)
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
				if not (newState) then
					return nil, err
				end
				state = newState
				newState, err = maybe_binary(state, otherPrec)
				if not (newState) then
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
			if not (newState) then
				return nil, err
			end
			state = newState
			return maybe_binary(state, 0)
		end)
	end
	comb.proxy = function(getParser)
		local parser = nil
		return Parser(function(state)
			if parser == nil then
				parser = getParser()
			end
			return parser.transform(state)
		end)
	end
	comb.literal = function(str)
		return Parser(function(state)
			local data, index
			data, index = state.data, state.index
			local strlen = #str
			if str == data:sub(index, index + strlen - 1) then
				do
					local _with_0 = copy(state)
					_with_0.index = _with_0.index + strlen
					_with_0.result = str
					return _with_0
				end
			end
			return nil, "did not match literal '" .. tostring(str) .. "' " .. tostring(comb.where(state))
		end)
	end
	comb.pattern = function(str)
		return Parser(function(state)
			local data, index
			data, index = state.data, state.index
			local captures = pack(data:find(str:gsub('^%^?', '^', 1), index))
			local start, stop = captures[1], captures[2]
			if start then
				remove(captures, 2)
				remove(captures, 1)
				captures.n = captures.n - 2
				local match = data:sub(start, stop)
				do
					local _with_0 = copy(state)
					_with_0.result = {
						match = match,
						captures = captures
					}
					_with_0.index = stop + 1
					return _with_0
				end
			end
			return nil, "did not match pattern '" .. tostring(str) .. "' " .. tostring(comb.where(state))
		end)
	end
	comb.uptoLiteral = function(str)
		return Parser(function(state)
			local data, index
			data, index = state.data, state.index
			local start = data:find(str, index, true)
			if not (start) then
				start = #data + 1
			end
			do
				local _with_0 = copy(state)
				_with_0.index = start
				_with_0.result = data:sub(index, start - 1)
				return _with_0
			end
		end)
	end
	comb.uptoPattern = function(str)
		return Parser(function(state)
			local data, index
			data, index = state.data, state.index
			local start = data:find(str, index)
			if not (start) then
				start = #data + 1
			end
			do
				local _with_0 = copy(state)
				_with_0.index = start
				_with_0.result = data:sub(index, start - 1)
				return _with_0
			end
		end)
	end
	comb.digit = comb.pattern('%d'):index('match')
	comb.digit = comb.digit % function(err, state)
		return "did not match digit " .. tostring(comb.where(state))
	end
	comb.digits = comb.pattern('%d+'):index('match')
	comb.digits = comb.digits % function(err, state)
		return "did not match digits " .. tostring(comb.where(state))
	end
	comb.letter = comb.pattern('%a'):index('match')
	comb.letter = comb.letter % function(err, state)
		return "did not match letter " .. tostring(comb.where(state))
	end
	comb.letters = comb.pattern('%a+'):index('match')
	comb.letters = comb.letters % function(err, state)
		return "did not match letters " .. tostring(comb.where(state))
	end
	comb.whitespace = comb.pattern('%s+'):index('match')
	comb.whitespace = comb.whitespace % function(err, state)
		return "did not match whitespace " .. tostring(comb.where(state))
	end
	comb.maybe_ws = comb.whitespace:maybeBlank()
	comb.cr = comb.literal('\r')
	comb.cr = comb.cr % function(err, state)
		return "did not match carriage return " .. tostring(comb.where(state))
	end
	comb.lf = comb.literal('\n')
	comb.lf = comb.lf % function(err, state)
		return "did not match line feed " .. tostring(comb.where(state))
	end
	comb.crlf = comb.literal('\r\n')
	comb.crlf = comb.crlf % function(err, state)
		return "did not match CRLF " .. tostring(comb.where(state))
	end
	comb.newline = comb.pattern('\r?\n')
	comb.newline = comb.newline / function(result)
		return result.match
	end
	comb.newline = comb.newline % function(err, state)
		return "did not match newline " .. tostring(comb.where(state))
	end
	comb.eof = comb.pattern('$')
	comb.eof = comb.eof % function(err, state)
		return "did not match EOF " .. tostring(comb.where(state))
	end
	comb.endline = comb.newline + comb.eof
	comb.endline = comb.endline % function(err, state)
		return "did not match end of line " .. tostring(comb.where(state))
	end
	comb.identifier = comb.pattern('[%a_][%w_]*'):index('match')
	comb.identifier = comb.identifier % function(err, state)
		return "did not match identifier " .. tostring(comb.where(state))
	end
	return comb
end
