local comb = require('lithium.comb')
local Parser, identifier, pattern, proxy, digits, maybe_ws, eof, literal, sequence
Parser, identifier, pattern, proxy, digits, maybe_ws, eof, literal, sequence = comb.Parser, comb.identifier, comb.pattern, comb.proxy, comb.digits, comb.maybe_ws, comb.eof, comb.literal, comb.sequence
local map, unpack
do
	local _obj_0 = require('lithium.tablex')
	map, unpack = _obj_0.map, _obj_0.unpack
end
do
	local expr = {}
	local empty = {}
	expr.plus = literal('+')
	expr.minus = literal('-')
	expr.multiply = literal('*')
	expr.divide = literal('/')
	expr.modulo = literal('%')
	expr.power = literal('^')
	expr.dot = literal('.')
	expr.binary_op = expr.plus + expr.minus + expr.multiply + expr.divide + expr.modulo + expr.power + expr.dot
	expr.integer = digits / tonumber
	expr.hex = pattern('0[xX][0-9a-fA-F]+') / function(result)
		return tonumber(result.match)
	end
	expr.octal = pattern('0[oO]([0-7]+)') / function(result)
		return tonumber(result.captures[1], 8)
	end
	expr.binary = pattern('0[bB][01]+') / function(result)
		return tonumber(result.match)
	end
	expr.decimal = (pattern('%d*%.%d+') + pattern('%d+%.%d*')):index('match') / tonumber
	expr.scientific = sequence({
		(expr.decimal + expr.integer) / tostring,
		pattern('[eE][%-%+]?%d+'):index('match')
	}) / table.concat / tonumber
	expr.number = expr.scientific + expr.decimal + expr.hex + expr.octal + expr.binary + expr.integer
	expr.number = expr.number:tag('number')
	expr.identifier = comb.identifier:tag('identifier')
	local maybe_call
	maybe_call = function(parser)
		local transform = parser.transform
		local params = expr.expr:delimited(pattern('%s*,%s*')):maybe():default({}):surround(pattern('%s*%(%s*'), pattern('%s*%)%s*'))
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
	expr.expr = proxy(function()
		return expr.binary_expr
	end)
	expr.expr = maybe_call(expr.expr)
	expr.parens = expr.expr:surround(pattern('%s*%(%s*'), pattern('%s*%)%s*'))
	local negated_number = pattern('%-%s*') * expr.number
	negated_number = negated_number / function(result)
		result.value = result.value * -1
		return result
	end
	expr.atom = negated_number + expr.number + expr.identifier + expr.parens
	expr.atom = maybe_call(expr.atom)
	local wss
	wss = function(t)
		return map(t, function(v)
			return v:wss()
		end)
	end
	expr.binary_expr = comb.binary(expr.atom, {
		wss({
			expr.plus,
			expr.minus
		}),
		wss({
			expr.multiply,
			expr.divide,
			expr.modulo
		}),
		wss({
			expr.power
		}),
		wss({
			expr.dot
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
	expr.binary_expr = expr.binary_expr / tag_binary
	expr.compile = function(str)
		local state = {
			data = str,
			index = 1
		}
		local err
		state, err = expr.expr:surround(maybe_ws, maybe_ws * eof)(state)
		if not (state) then
			return nil, err
		end
		return state.result
	end
	expr.evalNode = function(node, env)
		local result
		local _exp_0 = node.tag
		if 'number' == _exp_0 then
			result = node.value
		elseif 'binary' == _exp_0 then
			if node.operator == '.' then
				local left = expr.evalNode(node.left, env)
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
				local left = expr.evalNode(node.left, env)
				local right = expr.evalNode(node.right, env)
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
			local func = expr.evalNode(node.func, env)
			if not ('function' == type(func)) then
				error('tried to call a non-function value')
			end
			local params = {
				n = #node.params
			}
			for i = 1, params.n do
				params[i] = expr.evalNode(node.params[i], env)
			end
			result = func(unpack(params, 1, params.n))
		end
		return result
	end
	expr.eval = function(str, env)
		if env == nil then
			env = require('lithium.math')
		end
		local ast = assert(expr.compile(str))
		return expr.evalNode(ast, env)
	end
	return expr
end
