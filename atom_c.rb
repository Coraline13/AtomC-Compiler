require_relative 'lexer'
require_relative 'parser'

lexer = Lexer.new("tests/test.c")
lexer.tokenize
puts lexer

ast = Parser.parse(lexer.tokens)
puts ast
