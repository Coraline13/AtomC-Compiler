require_relative 'lexer'
require_relative 'parser'
require_relative 'runtime/builtin'

lexer = Lexer.new("tests/test.c")
lexer.tokenize
puts lexer

ast = Parser.parse(lexer.tokens)

$globals = Symbols.new(nil)
add_builtin_functions($globals)

ast.validate($globals, {})

puts ast
