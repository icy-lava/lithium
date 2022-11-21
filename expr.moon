comb = require 'lithium.comb'
import Parser, identifier, pattern, proxy, digits, maybe_ws, eof, literal, sequence from comb
import map, unpack from require 'lithium.table'

with {}
	empty = {}
	
	.plus = literal '+'
	.minus = literal '-'
	.multiply = literal '*'
	.divide = literal '/'
	.modulo = literal '%'
	.power = literal '^'
	.dot = literal '.'
	
	.binary_op = .plus + .minus + .multiply + .divide + .modulo + .power + .dot
	
	.integer = digits / tonumber
	.hex = pattern'0[xX][0-9a-fA-F]+' / (result) -> tonumber result.match
	.octal = pattern'0[oO]([0-7]+)' / (result) -> tonumber result.captures[1], 8
	.binary = pattern'0[bB][01]+' / (result) -> tonumber result.match
	
	.decimal = (pattern'%d*%.%d+' + pattern'%d+%.%d*')\index'match' / tonumber
	.scientific = sequence({(.decimal + .integer) / tostring, pattern'[eE][%-%+]?%d+'\index'match'}) / table.concat / tonumber
	
	.number = .scientific + .decimal + .hex + .octal + .binary + .integer
	.number = .number\tag 'number'
	
	.identifier = comb.identifier\tag 'identifier'
	
	maybe_call = (parser) ->
		transform = parser.transform
		params = .expr\delimited(pattern'%s*,%s*')\maybe!\default({})\surround pattern'%s*%(%s*', pattern'%s*%)%s*'
		Parser (state) ->
			newState, err = transform state
			return nil, err unless newState
			state = newState
			newState, err = params state
			if newState
				newState.result = {tag: 'call', func: state.result, params: newState.result}
				state = newState
			return state
	
	.expr = proxy -> .binary_expr
	.expr = maybe_call .expr
	
	.parens = .expr\surround pattern'%s*%(%s*', pattern'%s*%)%s*'
	
	negated_number = pattern'%-%s*' * .number
	negated_number /= (result) ->
		result.value *= -1
		result
	.atom = negated_number + .number + .identifier + .parens
	.atom = maybe_call .atom
	
	wss = (t) -> map t, (v) -> v\wss!
	.binary_expr = comb.binary .atom, {
		wss { .plus, .minus }
		wss { .multiply, .divide, .modulo }
		wss { .power }
		wss { .dot }
	}
	
	tag_binary = (result) ->
		if result.operator
			result.tag = 'binary'
			tag_binary result.left
			tag_binary result.right
		return result
	.binary_expr = .binary_expr / tag_binary
	
	.compile = (str) ->
		state = {data: str, index: 1}
		state, err = .expr\surround(maybe_ws, maybe_ws * eof) state
		return nil, err unless state
		return state.result
	
	.evalNode = (node, env) ->
		result = switch node.tag
			when 'number' then node.value
			when 'binary'
				if node.operator == '.'
					left = .evalNode node.left, env
					error 'trying to index a non-namespace value' unless 'table' == type left
					error 'right side of namespace operator must be an identifier' unless node.right.tag == 'identifier'
					value = left[node.right.value]
					error "variable '#{node.right.value}' does not exist in namespace" if value == nil
					value
				else
					left = .evalNode node.left, env
					right = .evalNode node.right, env
					unless 'number' == type(left) and 'number' == type(right)
						error 'attempted to add non-number value'
					switch node.operator
						when '+' then left + right
						when '-' then left - right
						when '*' then left * right
						when '/' then left / right
						when '%' then left % right
						when '^' then left ^ right
						else error "unknown operator '#{node.operator}'"
			when 'identifier'
				value = env[node.value]
				error "variable '#{node.value}' does not exist in namespace" if value == nil
				value
			when 'call'
				func = .evalNode node.func, env
				error 'tried to call a non-function value' unless 'function' == type func
				params = {n: #node.params}
				for i = 1, params.n
					params[i] = .evalNode node.params[i], env
				func unpack params, 1, params.n
		result
	
	.eval = (str, env = require 'lithium.math') ->
		ast = assert .compile str
		return .evalNode ast, env