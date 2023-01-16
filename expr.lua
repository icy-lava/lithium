local comb = require('lithium.comb')
local Parser, identifier, pattern, proxy, digits, maybe_ws, eof, literal, sequence
Parser, identifier, pattern, proxy, digits, maybe_ws, eof, literal, sequence = comb.Parser, comb.identifier, comb.pattern, comb.proxy, comb.digits, comb.maybe_ws, comb.eof, comb.literal, comb.sequence
local map, unpack
do
  local _obj_0 = require('lithium.table')
  map, unpack = _obj_0.map, _obj_0.unpack
end
do
  local _with_0 = { }
  local empty = { }
  _with_0.plus = literal('+')
  _with_0.minus = literal('-')
  _with_0.multiply = literal('*')
  _with_0.divide = literal('/')
  _with_0.modulo = literal('%')
  _with_0.power = literal('^')
  _with_0.dot = literal('.')
  _with_0.binary_op = _with_0.plus + _with_0.minus + _with_0.multiply + _with_0.divide + _with_0.modulo + _with_0.power + _with_0.dot
  _with_0.integer = digits / tonumber
  _with_0.hex = pattern('0[xX][0-9a-fA-F]+') / function(result)
    return tonumber(result.match)
  end
  _with_0.octal = pattern('0[oO]([0-7]+)') / function(result)
    return tonumber(result.captures[1], 8)
  end
  _with_0.binary = pattern('0[bB][01]+') / function(result)
    return tonumber(result.match)
  end
  _with_0.decimal = (pattern('%d*%.%d+') + pattern('%d+%.%d*')):index('match') / tonumber
  _with_0.scientific = sequence({
    (_with_0.decimal + _with_0.integer) / tostring,
    pattern('[eE][%-%+]?%d+'):index('match')
  }) / table.concat / tonumber
  _with_0.number = _with_0.scientific + _with_0.decimal + _with_0.hex + _with_0.octal + _with_0.binary + _with_0.integer
  _with_0.number = _with_0.number:tag('number')
  _with_0.identifier = comb.identifier:tag('identifier')
  local maybe_call
  maybe_call = function(parser)
    local transform = parser.transform
    local params = _with_0.expr:delimited(pattern('%s*,%s*')):maybe():default({ }):surround(pattern('%s*%(%s*'), pattern('%s*%)%s*'))
    return Parser(function(state)
      local newState, err = transform(state)
      if not (newState) then
        return nil, err
      end
      state = newState
      newState, err = params(state)
      if newState then
        newState.result = {
          tag = 'call',
          func = state.result,
          params = newState.result
        }
        state = newState
      end
      return state
    end)
  end
  _with_0.expr = proxy(function()
    return _with_0.binary_expr
  end)
  _with_0.expr = maybe_call(_with_0.expr)
  _with_0.parens = _with_0.expr:surround(pattern('%s*%(%s*'), pattern('%s*%)%s*'))
  local negated_number = pattern('%-%s*') * _with_0.number
  negated_number = negated_number / function(result)
    result.value = result.value * -1
    return result
  end
  _with_0.atom = negated_number + _with_0.number + _with_0.identifier + _with_0.parens
  _with_0.atom = maybe_call(_with_0.atom)
  local wss
  wss = function(t)
    return map(t, function(v)
      return v:wss()
    end)
  end
  _with_0.binary_expr = comb.binary(_with_0.atom, {
    wss({
      _with_0.plus,
      _with_0.minus
    }),
    wss({
      _with_0.multiply,
      _with_0.divide,
      _with_0.modulo
    }),
    wss({
      _with_0.power
    }),
    wss({
      _with_0.dot
    })
  })
  local tag_binary
  tag_binary = function(result)
    if result.operator then
      result.tag = 'binary'
      tag_binary(result.left)
      tag_binary(result.right)
    end
    return result
  end
  _with_0.binary_expr = _with_0.binary_expr / tag_binary
  _with_0.compile = function(str)
    local state = {
      data = str,
      index = 1
    }
    local err
    state, err = _with_0.expr:surround(maybe_ws, maybe_ws * eof)(state)
    if not (state) then
      return nil, err
    end
    return state.result
  end
  _with_0.evalNode = function(node, env)
    local result
    local _exp_0 = node.tag
    if 'number' == _exp_0 then
      result = node.value
    elseif 'binary' == _exp_0 then
      if node.operator == '.' then
        local left = _with_0.evalNode(node.left, env)
        if not ('table' == type(left)) then
          error('trying to index a non-namespace value')
        end
        if not (node.right.tag == 'identifier') then
          error('right side of namespace operator must be an identifier')
        end
        local value = left[node.right.value]
        if value == nil then
          error("variable '" .. tostring(node.right.value) .. "' does not exist in namespace")
        end
        result = value
      else
        local left = _with_0.evalNode(node.left, env)
        local right = _with_0.evalNode(node.right, env)
        if not ('number' == type(left) and 'number' == type(right)) then
          error('attempted to add non-number value')
        end
        local _exp_1 = node.operator
        if '+' == _exp_1 then
          result = left + right
        elseif '-' == _exp_1 then
          result = left - right
        elseif '*' == _exp_1 then
          result = left * right
        elseif '/' == _exp_1 then
          result = left / right
        elseif '%' == _exp_1 then
          result = left % right
        elseif '^' == _exp_1 then
          result = left ^ right
        else
          result = error("unknown operator '" .. tostring(node.operator) .. "'")
        end
      end
    elseif 'identifier' == _exp_0 then
      local value = env[node.value]
      if value == nil then
        error("variable '" .. tostring(node.value) .. "' does not exist in namespace")
      end
      result = value
    elseif 'call' == _exp_0 then
      local func = _with_0.evalNode(node.func, env)
      if not ('function' == type(func)) then
        error('tried to call a non-function value')
      end
      local params = {
        n = #node.params
      }
      for i = 1, params.n do
        params[i] = _with_0.evalNode(node.params[i], env)
      end
      result = func(unpack(params, 1, params.n))
    end
    return result
  end
  _with_0.eval = function(str, env)
    if env == nil then
      env = require('lithium.math')
    end
    local ast = assert(_with_0.compile(str))
    return _with_0.evalNode(ast, env)
  end
  return _with_0
end
