local comb = require('lithium.comb')
local literal, pattern, uptoPattern, whitespace, sequence, eof
literal, pattern, uptoPattern, whitespace, sequence, eof = comb.literal, comb.pattern, comb.uptoPattern, comb.whitespace, comb.sequence, comb.eof
local concat, insert, imap
do
  local _obj_0 = require('lithium.table')
  concat, insert, imap = _obj_0.concat, _obj_0.insert, _obj_0.imap
end
do
  local _with_0 = { }
  local maybe_ws = whitespace:maybe():default('')
  local comma = literal(',')
  local comma_ws = comma:surround(maybe_ws)
  local fals = literal('false') / function()
    return false
  end
  local tru = literal('true') / function()
    return true
  end
  local boolean = tru + fals
  boolean = boolean:tag('boolean')
  local null = literal('null') / function()
    return nil
  end
  null = null:tag('null')
  local number = sequence({
    pattern('%-?%d+'):index('match'),
    pattern('%.%d+'):index('match'):maybe():default(''),
    pattern('[Ee][%-%+]?%d+'):index('match'):maybe():default('')
  }) / concat / tonumber
  number = number:tag('number')
  local escape = literal('\\') * (pattern('["\\/bfnrt]') + pattern('u%x%x%x%x')):index('match')
  escape = escape / function(result)
    if 'u' == result:sub(1, 1) then
      return '?'
    end
    local _exp_0 = result
    if 'b' == _exp_0 then
      return '\b'
    elseif 'f' == _exp_0 then
      return '\f'
    elseif 'n' == _exp_0 then
      return '\n'
    elseif 'r' == _exp_0 then
      return '\r'
    elseif 't' == _exp_0 then
      return '\t'
    else
      return result
    end
  end
  local strin = sequence({
    literal('"'),
    (escape + uptoPattern('["\\%c]')) ^ 0 / concat,
    literal('"')
  }):second()
  strin = strin:tag('string')
  local array, object
  local value = comb.proxy(function()
    return array + object + boolean + null + number + strin
  end)
  array = sequence({
    literal('['),
    maybe_ws,
    (value:delimited(comma_ws)):maybe():default({ }),
    maybe_ws,
    literal(']')
  }):third()
  array = array:tag('array')
  local record = sequence({
    strin:index('value'),
    maybe_ws,
    literal(':'),
    maybe_ws,
    value
  }) / function(result)
    return {
      key = result[1],
      value = result[5]
    }
  end
  object = sequence({
    literal('{'),
    maybe_ws,
    (record:delimited(comma_ws)):maybe():default({ }),
    maybe_ws,
    literal('}')
  }):third()
  object = object:tag('object')
  _with_0.parse = function(str)
    local state = {
      data = str,
      index = 1
    }
    local err
    state, err = value:surround(maybe_ws, maybe_ws * eof):run(state)
    if not (state) then
      return nil, err
    end
    return state.result
  end
  local decodeValue
  decodeValue = function(val)
    local _exp_0 = val.tag
    if 'array' == _exp_0 then
      return imap(val.value, decodeValue)
    elseif 'object' == _exp_0 then
      local obj = { }
      local _list_0 = val.value
      for _index_0 = 1, #_list_0 do
        local rec = _list_0[_index_0]
        obj[rec.key] = decodeValue(rec.value)
      end
      return obj
    else
      return val.value
    end
  end
  _with_0.decode = function(str)
    local result, err = _with_0.parse(str)
    if not (result) then
      return nil, err
    end
    return decodeValue(result)
  end
  local ind
  ind = function(level)
    if level == nil then
      level = 0
    end
    return ('\t'):rep(level)
  end
  local encodeValue
  encodeValue = function(val, indent)
    if indent == nil then
      indent = 0
    end
    local _exp_0 = type(val)
    if 'string' == _exp_0 then
      val = val:gsub('[%z\1-\31\\"]', function(char)
        local _exp_1 = char
        if '\\' == _exp_1 then
          return '\\\\'
        elseif '"' == _exp_1 then
          return '\\"'
        elseif '\r' == _exp_1 then
          return '\\r'
        elseif '\n' == _exp_1 then
          return '\\n'
        elseif '\t' == _exp_1 then
          return '\\t'
        elseif '\b' == _exp_1 then
          return '\\b'
        else
          return string.format('\\u%04x', char:byte())
        end
      end)
      return '"' .. val .. '"'
    elseif 'table' == _exp_0 then
      local maxIndex = 0
      local isArray = true
      for k, v in pairs(val) do
        local kt = type(k)
        if kt ~= 'number' and kt ~= 'string' then
          return nil, 'object key may only be a string or a number'
        end
        if isArray and kt == 'number' and k >= 1 then
          if k > maxIndex then
            maxIndex = k
          end
        else
          isArray = false
          break
        end
      end
      if isArray then
        local t = { }
        for i = 1, maxIndex do
          local err
          t[i], err = encodeValue(val[i])
          if not (t[i]) then
            return nil, err
          end
        end
        return "[" .. tostring(concat(t, ', ', 1, maxIndex)) .. "]"
      else
        local t = { }
        for k, v in pairs(val) do
          k = tostring(k)
          if t[k] then
            return nil, 'number - string object key name clash'
          end
          t[k] = true
          local err
          k, err = encodeValue(k, indent + 1)
          if not (k) then
            return nil, err
          end
          v, err = encodeValue(v, indent + 1)
          if not (v) then
            return nil, err
          end
          insert(t, tostring(ind(indent + 1)) .. tostring(k) .. ": " .. tostring(v))
        end
        return "{\n" .. tostring(concat(t, ',\n')) .. "\n" .. tostring(ind(indent)) .. "}"
      end
    elseif 'nil' == _exp_0 then
      return 'null'
    else
      return tostring(val)
    end
  end
  _with_0.encode = function(val)
    return encodeValue(val)
  end
  return _with_0
end
