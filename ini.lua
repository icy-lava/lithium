local lexer, table, string
do
  local _obj_0 = require('lithium')
  lexer, table, string = _obj_0.lexer, _obj_0.table, _obj_0.string
end
local lex
lex = lexer.lex
local ifilter, imap, icopy, set
ifilter, imap, icopy, set = table.ifilter, table.imap, table.icopy, table.set
local lineAt, trim, trimNonEmpty, split, delim
lineAt, trim, trimNonEmpty, split, delim = string.lineAt, string.trim, string.trimNonEmpty, string.split, string.delim
do
  local _with_0 = { }
  local types = {
    {
      'blank',
      '[^%S\r\n]*\r?\n'
    },
    {
      'whitespace',
      '[^%S\r\n]+'
    },
    {
      'section',
      '%[([^%]\r\n#;]*)%][^%S\r\n]*\r?\n?'
    },
    {
      'comment',
      '[#;]([^\r\n]*)\r?\n'
    },
    {
      'assign',
      '([^%[=\r\n#;]+)=([^#;\r\n]*)\r?\n?'
    }
  }
  local parseKey
  parseKey = function(key)
    local keys = { }
    for subkey in delim(key, '.') do
      subkey = trimNonEmpty(subkey)
      if not (subkey) then
        return nil, 'invalid key'
      end
      table.insert(keys, subkey:lower())
    end
    return keys
  end
  _with_0.parse = function(str)
    str = tostring(str) .. "\n"
    local tokens, err, pos = lex(str, types)
    if not (tokens) then
      local line = lineAt(str, pos)
      return nil, "failed to lex line " .. tostring(line), line
    end
    local currentSection = {
      'global'
    }
    local data = { }
    for _index_0 = 1, #tokens do
      local token = tokens[_index_0]
      local _exp_0 = token.type
      if 'section' == _exp_0 then
        local newSection = parseKey(token.captures[1])
        if not newSection then
          local line = lineAt(str, token.start)
          return nil, "invalid section at line " .. tostring(line), line
        end
        currentSection = newSection
      elseif 'assign' == _exp_0 then
        local keys = parseKey(token.captures[1])
        if not keys then
          local line = lineAt(str, token.start)
          return nil, "invalid assignment key at line " .. tostring(line), line
        end
        local setPath = icopy(currentSection)
        for _index_1 = 1, #keys do
          local key = keys[_index_1]
          table.insert(setPath, key)
        end
        table.insert(setPath, trim(token.captures[2]))
        set(data, unpack(setPath))
      end
    end
    return data
  end
  _with_0.parseFile = function(fileName)
    local stream, err = io.open(fileName, 'rb')
    if not (stream) then
      return nil, err
    end
    local data
    data, err = stream:read('*a')
    if not (data) then
      return nil, err
    end
    stream:close()
    local result, line
    result, err, line = _with_0.parse(data)
    if not (result) then
      return nil, tostring(fileName) .. ": " .. tostring(err), line
    end
    return result
  end
  return _with_0
end
