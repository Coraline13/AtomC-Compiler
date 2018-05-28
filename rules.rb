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
    Parser.parse_any -> do
      Parser.consume(Tokenable::TK_INT)
    end, -> do
      Parser.consume(Tokenable::TK_DOUBLE)
    end, -> do
      Parser.consume(Tokenable::TK_CHAR)
    end, -> do
      Parser.consume(Tokenable::TK_STRUCT)
    end
    # TODO: nod
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
    Parser.parse_any -> do
      lhs = expr_unary
      Parser.consume(Tokenable::TK_ASSIGN, "Expected '=!'")
      rhs = expr_assign
      return AssignExpression.new(lhs, rhs)
    end, -> do
      expr_or
    end
  end

  # exprOr: exprOr OR exprAnd | exprAnd
  # exprOr1: exprAnd exprOr2
  # exprOr2: (OR exprAnd exprOr2)?
  def self.expr_or
    lhs         = expr_and
    expressions = Parser.parse_many -> {
      Parser.consume(Tokenable::TK_OR, "Expected '||'!")
      expr_and
    }

    expressions.each do |expression|
      lhs = OrExpression(lhs, expression)
    end

    return lhs
  end

  # def self.expr_or1
  #   lhs = expr_and
  #   rhs = expr_or2
  #   return OrExpression(lhs, rhs)
  # end
  #
  # def self.expr_or2
  #   Parser.parse_maybe {
  #     Parser.consume(Tokenable::TK_OR, "Expected ||!")
  #     lhs = expr_and
  #     rhs = expr_or2
  #     rhs ? OrExpression(lhs, rhs) : lhs
  #   }
  # end

  # exprAnd: exprAnd AND exprEq | exprEq
  def self.expr_and
    lhs         = expr_eq
    expressions = Parser.parse_many {
      Parser.consume(Tokenable::TK_AND, "Expected '&&'!")
      expr_eq
    }

    expressions.each do |expression|
      lhs = AndExpression(lhs, expression)
    end

    return lhs
  end

  # exprEq: exprEq ( EQUAL | NOTEQ ) exprRel | exprRel
  def self.expr_eq
    lhs         = expr_rel
    expressions = Parser.parse_many {
      tk = Parser.parse_any -> {
        Parser.consume(Tokenable::TK_EQUAL, "Expected '=='!")
      }, -> {
        Parser.consume(Tokenable::TK_NOTEQ, "Expected '!='!")
      }
      [tk, expr_rel]
    }

    expressions.each do |tk, expression|
      if tk.code.eql?(Tokenable::TK_EQUAL)
        lhs = EqualExpression.new(lhs, expression)
      elsif tk.code.eql?(Tokenable::TK_NOTEQ)
        lhs = NoteqExpression.new(lhs, expression)
      end
    end

    return lhs
  end

  # exprRel: exprRel ( LESS | LESSEQ | GREATER | GREATEREQ ) exprAdd | exprAdd
  def self.expr_rel
    lhs         = expr_add
    expressions = Parser.parse_many {
      tk = Parser.parse_any -> {
        Parser.consume(Tokenable::TK_LESS, "Expected '<'!")
      }, -> {
        Parser.consume(Tokenable::TK_LESSEQ, "Expected '<='!")
      }, -> {
        Parser.consume(Tokenable::TK_GREATER, "Expected '>'!")
      }, -> {
        Parser.consume(Tokenable::TK_GREATEREQ, "Expected '>='")
      }
      [tk, expr_add]
    }

    expressions.each do |tk, expression|
      if tk.code.eql?(Tokenable::TK_LESS)
        lhs = LessExpression.new(lhs, expression)
      elsif tk.code.eql?(Tokenable::TK_LESSEQ)
        lhs = LesseqExpression.new(lhs, expression)
      elsif tk.code.eql?(Tokenable::TK_GREATER)
        lhs = GreaterExpression.new(lhs, expression)
      elsif tk.code.eql?(Tokenable::TK_GREATEREQ)
        lhs = GreatereqExpression.new(lhs, expression)
      end
    end

    return lhs
  end

  # exprAdd: exprAdd ( ADD | SUB ) exprMul | exprMul
  def self.expr_add
    lhs         = expr_mul
    expressions = Parser.parse_many {
      tk = Parser.parse_any -> {
        Parser.consume(Tokenable::TK_ADD, "Expected '+'!")
      }, -> {
        Parser.consume(Tokenable::TK_SUB, "Expected '-'!")
      }
      [tk, expr_mul]
    }

    expressions.each do |tk, expression|
      if tk.code.eql?(Tokenable::TK_ADD)
        lhs = AddExpression.new(lhs, expression)
      elsif tk.code.eql?(Tokenable::TK_SUB)
        lhs = SubExpression.new(lhs, expression)
      end
    end

    return lhs
  end

  # exprMul: exprMul ( MUL | DIV ) exprCast | exprCast
  def self.expr_mul
    lhs         = expr_cast
    expressions = Parser.parse_many {
      tk = Parser.parse_any -> {
        Parser.consume(Tokenable::TK_MUL, "Expected '*'!")
      }, -> {
        Parser.consume(Tokenable::TK_DIV, "Expected '/'!")
      }
      [tk, expr_cast]
    }

    expressions.each do |tk, expression|
      if tk.code.eql?(Tokenable::TK_MUL)
        lhs = MulExpression.new(lhs, expression)
      elsif tk.code.eql?(Tokenable::TK_DIV)
        lhs = DivExpression.new(lhs, expression)
      end
    end

    return lhs
  end

  # exprCast: LPAR typeName RPAR exprCast | exprUnary
  def self.expr_cast
    Parser.parse_any -> do
      Parser.consume(Tokenable::TK_LPAR, "Expected '('!")
      # TODO: typeName
      Parser.consume(Tokenable::TK_RPAR, "Expected ')'!")
      expr_cast
    end, -> do
      expr_unary
    end
    # TODO: nod
  end

  # exprUnary: ( SUB | NOT ) exprUnary | exprPostfix
  def self.expr_unary
    Parser.parse_any -> do
      tk = Parser.parse_any -> do
        Parser.consume(Tokenable::TK_SUB, "Expected '-'!") # TODO: afiseaza sau nu eroarea?
      end, -> do
        Parser.consume(Tokenable::TK_NOT, "Expected '!'!") # TODO: same
      end
      [tk, expr_unary]
    end, -> do
      expr_postfix
    end
    # TODO: nod + recursiv?
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
    Parser.parse_any -> do
      id = Parser.consume(Tokenable::TK_ID, "Expected identifier!").ct
      if Parser.consume(Tokenable::TK_LPAR)
        args      = Array.new
        first_arg = Parser.parse_maybe { expr }
        if first_arg
          args << first_arg
          args += Parser.parse_many {
            Parser.consume(Tokenable::TK_COMMA, "Expected ','!")
            expr
          }
        end
        Parser.consume(Tokenable::TK_RPAR, "Expected ')'!")
        return FunctionCallExpression.new(id, args)
      end
      return VariableExpression.new(id)
    end, -> do
      tk = Parser.consume(Tokenable::TK_CT_INT, "Expected integer constant!")
      return ConstantExpression.new(tk.ct, INT)
    end, -> do
      tk = Parser.consume(Tokenable::TK_CT_REAL, "Expected float constant!")
      return ConstantExpression.new(tk.ct, FLOAT)
    end, -> do
      tk = Parser.consume(Tokenable::TK_CT_CHAR, "Expected char constant!")
      return ConstantExpression.new(tk.ct, CHAR)
    end, -> do
      tk = Parser.consume(Tokenable::TK_CT_STRING, "Expected string constant!")
      return ConstantExpression.new(tk.ct, CharType.new(true, tk.ct.length + 1))
    end, -> do
      Parser.consume(Tokenable::TK_LPAR, "Expected '('!")
      result = expr
      Parser.consume(Tokenable::TK_RPAR, "Expected ')'!")
      return result
    end
  end
end
