require_relative 'type'

module Rules
  # unit: ( declStruct | declFunc | declVar )* END
  def self.unit

  end

  # declStruct: STRUCT ID LACC declVar* RACC SEMICOLON
  def self.decl_struct

  end

  # declVar:  typeBase ID arrayDecl? ( COMMA ID arrayDecl? )* SEMICOLON
  def self.decl_var

  end

  # typeBase: INT | DOUBLE | CHAR | STRUCT ID
  def self.type_base
    start_index = @index
    if consume(Tokenable::TK_INT)
      type = Tokenable::TK_INT
    end
    if consume(Tokenable::TK_DOUBLE)
      type = Tokenable::TK_DOUBLE
    end
    if consume(Tokenable::TK_CHAR)
      type = Tokenable::TK_CHAR
    end
    if consume(Tokenable::TK_STRUCT)
      type = Tokenable::TK_STRUCT
    end
    type
  end

  # arrayDecl: LBRACKET expr? RBRACKET
  def self.array_decl

  end

  # typeName: typeBase arrayDecl?
  def self.type_name

  end

  # declFunc: ( typeBase MUL? | VOID ) ID
  #   LPAR ( funcArg ( COMMA funcArg )* )? RPAR
  #   stmCompound
  def self.decl_func

  end

  # funcArg: typeBase ID arrayDecl?
  def self.func_arg

  end

  # stm: stmCompound
  #   | IF LPAR expr RPAR stm ( ELSE stm )?
  #   | WHILE LPAR expr RPAR stm
  #   | FOR LPAR expr? SEMICOLON expr? SEMICOLON expr? RPAR stm
  #   | BREAK SEMICOLON
  #   | RETURN expr? SEMICOLON
  #   | expr? SEMICOLON
  def self.stm

  end

  # stmCompound: LACC ( declVar | stm )* RACC
  def self.stm_compound

  end

  # expr: exprAssign
  def self.expr
    expr_assign
  end

  # exprAssign: exprUnary ASSIGN exprAssign | exprOr
  def self.expr_assign
    Parser.parse_any -> { expr_primary }
  end

  # exprOr: exprOr OR exprAnd | exprAnd
  def self.expr_or
    if expr_and
      if expr_or1
        true
      end
    end
    false
  end

  # exprAnd: exprAnd AND exprEq | exprEq
  def self.expr_and

  end

  # exprEq: exprEq ( EQUAL | NOTEQ ) exprRel | exprRel
  def self.expr_eq

  end

  # exprRel: exprRel ( LESS | LESSEQ | GREATER | GREATEREQ ) exprAdd | exprAdd
  def self.expr_rel

  end

  # exprAdd: exprAdd ( ADD | SUB ) exprMul | exprMul
  def self.expr_add

  end

  # exprMul: exprMul ( MUL | DIV ) exprCast | exprCast
  def self.expr_mul

  end

  # exprCast: LPAR typeName RPAR exprCast | exprUnary
  def self.expr_cast

  end

  # exprUnary: ( SUB | NOT ) exprUnary | exprPostfix
  def self.expr_unary

  end

  # exprPostfix: exprPostfix LBRACKET expr RBRACKET
  #   | exprPostfix DOT ID
  #   | exprPrimary
  def self.expr_postfix

  end

  # exprPrimary: ID ( LPAR ( expr ( COMMA expr )* )? RPAR )?
  #   | CT_INT
  #   | CT_REAL
  #   | CT_CHAR
  #   | CT_STRING
  #   | LPAR expr RPAR
  def self.expr_primary
    Parser.parse_any(lambda do
      id = Parser.consume(Tokenable::TK_ID, "Expected identifier!").ct
      if Parser.consume(Tokenable::TK_LPAR)
        args      = Array.new
        first_arg = Parser.parse_maybe { expr }
        if first_arg
          args << first_arg
          args += Parser.parse_many {
            Parser.consume(Tokenable::TK_COMMA, "Expected comma!")
            expr
          }
        end
        Parser.consume(Tokenable::TK_RPAR, "Expected closing parenthesis!")
        return FunctionCallExpression.new(id, args)
      end
      return VariableExpression.new(id)
    end, lambda do
      tk = Parser.consume(Tokenable::TK_CT_INT, "Expected integer constant!")
      return ConstantExpression.new(tk.ct, INT)
    end, lambda do
      tk = Parser.consume(Tokenable::TK_CT_REAL, "Expected float constant!")
      return ConstantExpression.new(tk.ct, FLOAT)
    end, lambda do
      tk = Parser.consume(Tokenable::TK_CT_CHAR, "Expected char constant!")
      return ConstantExpression.new(tk.ct, CHAR)
    end, lambda do
      tk = Parser.consume(Tokenable::TK_CT_STRING, "Expected string constant!")
      return ConstantExpression.new(tk.ct, CharType.new(true, tk.ct.length + 1))
    end, lambda do
      Parser.consume(Tokenable::TK_LPAR, "Expected opening parenthesis!")
      result = expr
      Parser.consume(Tokenable::TK_RPAR, "Expected closing parenthesis!")
      return result
    end)
  end
end
