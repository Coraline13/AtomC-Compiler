require_relative 'lexer/lexer'
require_relative 'syntax/parser'
require_relative 'runtime/builtin'

lexer = Lexer.new("tests/test.c")
lexer.tokenize
puts lexer

ast = Parser.parse(lexer.tokens)

$globals = Symbols.new(nil)
Builtin.add_builtin_functions($globals)

ast.validate($globals, {})

puts ast
