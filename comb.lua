local pack, remove, insert, copy
do
  local _obj_0 = require('lithium.table')
  pack, remove, insert, copy = _obj_0.pack, _obj_0.remove, _obj_0.insert, _obj_0.copy
end
local positionAt
positionAt = require('lithium.string').positionAt
do
  local _with_0 = { }
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
            local _with_1 = copy(newState)
            _with_1.result = mapper(_with_1.result)
            return _with_1
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
        return _with_0.sequence({
          self,
          suf
        }):first()
      end,
      surround = function(self, prefix, suffix)
        if suffix == nil then
          suffix = prefix
        end
        return _with_0.sequence({
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
        return self:prefix(_with_0.maybe_ws)
      end,
      wsr = function(self)
        return self:suffix(_with_0.maybe_ws)
      end,
      wss = function(self)
        return self:surround(_with_0.maybe_ws)
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
            local _with_1 = copy(state)
            _with_1.result = results
            return _with_1
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
            return nil, "unexpected match " .. tostring(_with_0.where(state))
          end
          return copy(state)
        end)
      end,
      atLeast = function(self, num)
        local transform = self.transform
        return Parser(function(state)
          local results = { }
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
            local _with_1 = copy(state)
            _with_1.result = results
            return _with_1
          end
        end)
      end,
      atMost = function(self, num)
        local transform = self.transform
        return Parser(function(state)
          local results = { }
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
            local _with_1 = copy(state)
            _with_1.result = results
            return _with_1
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
            local _with_1 = copy(newState)
            _with_1.index = state.index
            return _with_1
          end
        end)
      end,
      __unm = function(self)
        return self:opposite()
      end,
      __add = function(self, other)
        return _with_0.choice({
          self,
          other
        })
      end,
      __sub = function(self, other)
        return _with_0.sequence({
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
  _with_0.Parser = Parser
  _with_0.pinpoint = function(state)
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
  _with_0.where = function(state)
    return "at " .. tostring(_with_0.pinpoint(state).message)
  end
  _with_0.sequence = function(seq)
    return Parser(function(state)
      local results = { }
      for i, parser in ipairs(seq) do
        local newState, err = parser.transform(state)
        if not (newState) then
          return nil, err
        end
        state = newState
        results[i] = state.result
      end
      do
        local _with_1 = copy(state)
        _with_1.result = results
        return _with_1
      end
    end)
  end
  _with_0.choice = function(opt)
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
  _with_0.binary = function(atom, precDef)
    local precMap = { }
    local allParsers = { }
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
  _with_0.proxy = function(getParser)
    local parser = nil
    return Parser(function(state)
      if parser == nil then
        parser = getParser()
      end
      return parser.transform(state)
    end)
  end
  _with_0.literal = function(str)
    return Parser(function(state)
      local data, index
      data, index = state.data, state.index
      local strlen = #str
      if str == data:sub(index, index + strlen - 1) then
        do
          local _with_1 = copy(state)
          _with_1.index = _with_1.index + strlen
          _with_1.result = str
          return _with_1
        end
      end
      return nil, "did not match literal '" .. tostring(str) .. "' " .. tostring(_with_0.where(state))
    end)
  end
  _with_0.pattern = function(str)
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
          local _with_1 = copy(state)
          _with_1.result = {
            match = match,
            captures = captures
          }
          _with_1.index = stop + 1
          return _with_1
        end
      end
      return nil, "did not match pattern '" .. tostring(str) .. "' " .. tostring(_with_0.where(state))
    end)
  end
  _with_0.uptoLiteral = function(str)
    return Parser(function(state)
      local data, index
      data, index = state.data, state.index
      local start = data:find(str, index, true)
      if not (start) then
        start = #data + 1
      end
      do
        local _with_1 = copy(state)
        _with_1.index = start
        _with_1.result = data:sub(index, start - 1)
        return _with_1
      end
    end)
  end
  _with_0.uptoPattern = function(str)
    return Parser(function(state)
      local data, index
      data, index = state.data, state.index
      local start = data:find(str, index)
      if not (start) then
        start = #data + 1
      end
      do
        local _with_1 = copy(state)
        _with_1.index = start
        _with_1.result = data:sub(index, start - 1)
        return _with_1
      end
    end)
  end
  _with_0.digit = _with_0.pattern('%d'):index('match')
  _with_0.digit = _with_0.digit % function(err, state)
    return "did not match digit " .. tostring(_with_0.where(state))
  end
  _with_0.digits = _with_0.pattern('%d+'):index('match')
  _with_0.digits = _with_0.digits % function(err, state)
    return "did not match digits " .. tostring(_with_0.where(state))
  end
  _with_0.letter = _with_0.pattern('%a'):index('match')
  _with_0.letter = _with_0.letter % function(err, state)
    return "did not match letter " .. tostring(_with_0.where(state))
  end
  _with_0.letters = _with_0.pattern('%a+'):index('match')
  _with_0.letters = _with_0.letters % function(err, state)
    return "did not match letters " .. tostring(_with_0.where(state))
  end
  _with_0.whitespace = _with_0.pattern('%s+'):index('match')
  _with_0.whitespace = _with_0.whitespace % function(err, state)
    return "did not match whitespace " .. tostring(_with_0.where(state))
  end
  _with_0.maybe_ws = _with_0.whitespace:maybeBlank()
  _with_0.cr = _with_0.literal('\r')
  _with_0.cr = _with_0.cr % function(err, state)
    return "did not match carriage return " .. tostring(_with_0.where(state))
  end
  _with_0.lf = _with_0.literal('\n')
  _with_0.lf = _with_0.lf % function(err, state)
    return "did not match line feed " .. tostring(_with_0.where(state))
  end
  _with_0.crlf = _with_0.literal('\r\n')
  _with_0.crlf = _with_0.crlf % function(err, state)
    return "did not match CRLF " .. tostring(_with_0.where(state))
  end
  _with_0.newline = _with_0.pattern('\r?\n')
  _with_0.newline = _with_0.newline / function(result)
    return result.match
  end
  _with_0.newline = _with_0.newline % function(err, state)
    return "did not match newline " .. tostring(_with_0.where(state))
  end
  _with_0.eof = _with_0.pattern('$')
  _with_0.eof = _with_0.eof % function(err, state)
    return "did not match EOF " .. tostring(_with_0.where(state))
  end
  _with_0.endline = _with_0.newline + _with_0.eof
  _with_0.endline = _with_0.endline % function(err, state)
    return "did not match end of line " .. tostring(_with_0.where(state))
  end
  _with_0.identifier = _with_0.pattern('[%a_][%w_]*'):index('match')
  _with_0.identifier = _with_0.identifier % function(err, state)
    return "did not match identifier " .. tostring(_with_0.where(state))
  end
  return _with_0
end
