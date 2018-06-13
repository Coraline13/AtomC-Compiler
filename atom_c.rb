require_relative 'lexer'
require_relative 'parser'

lexer = Lexer.new("tests/test.c")
lexer.tokenize
puts lexer

ast = Parser.parse(lexer.tokens)

$globals = Symbols.new(nil)

def add_builtin(name, return_type, param_types)
  params = param_types.map do |param_name, param_type|
    VariableDeclaration.new(-1, -1, param_name, param_type)
  end
  decl   = FunctionDeclaration.new(-1, -1, "put_s",
                                   return_type, params,
                                   CompoundStatement.new(-1, -1, []))
  $globals.put(name, decl, -1, -1)
end

add_builtin("put_s", VoidType.new, [["s", CharType.new(true)]])
add_builtin("put_i", VoidType.new, [["i", INT]])
add_builtin("put_d", VoidType.new, [["d", FLOAT]])
add_builtin("put_c", VoidType.new, [["c", CHAR]])
add_builtin("get_s", VoidType.new, [["s", CharType.new(true)]])
add_builtin("get_i", INT, [])
add_builtin("get_d", FLOAT, [])
add_builtin("get_c", CHAR, [])
add_builtin("seconds", FLOAT, [])

ast.validate($globals, {})

puts ast
