require_relative 'type'

module Rules
  # unit: ( declStruct | declFunc | declVar )* END
  def self.unit
    declarations = Parser.parse_many(false) do
      Parser.parse_any -> do
        [decl_struct]
      end, -> do
        [decl_func]
      end, -> do
        decl_var
      end
    end
    Parser.consume(Tokenable::TK_END, "Expected end of file!")
    return UnitNode.new(1, 1, declarations.flatten(1))
  end

  # declStruct: STRUCT ID LACC declVar* RACC SEMICOLON
  def self.decl_struct
    tk   = Parser.consume(Tokenable::TK_STRUCT, "Expected 'struct'!")
    name = Parser.consume(Tokenable::TK_ID, "Expected struct name!", true)
    Parser.consume(Tokenable::TK_LACC, "Expected '{'!")
    members = Parser.parse_many do
      decl_var
    end
    Parser.consume(Tokenable::TK_RACC, "Expected '}'!", true)
    Parser.consume(Tokenable::TK_SEMICOLON, "Expected ';'!", true)
    return StructDeclaration.new(tk.line, tk.column, name.ct, members.flatten(1))
  end

  # declVar:  typeBase ID arrayDecl? ( COMMA ID arrayDecl? )* SEMICOLON
  def self.decl_var
    vars           = Array.new
    type           = type_base
    name           = Parser.consume(Tokenable::TK_ID, "Expected var name!", true)
    size, is_array = Parser.parse_maybe do
      array_decl
    end
    vars << VariableDeclaration.new(name.line, name.column, name.ct, type.as_array(is_array, size))
    Parser.parse_many do
      Parser.consume(Tokenable::TK_COMMA, "Expected ','!")
      name           = Parser.consume(Tokenable::TK_ID, "Expected var name!", true)
      size, is_array = Parser.parse_maybe do
        array_decl
      end
      vars << VariableDeclaration.new(name.line, name.column, name.ct, type.as_array(is_array, size))
    end
    Parser.consume(Tokenable::TK_SEMICOLON, "Expected ';'!", true)
    return vars
  end

  # typeBase: INT | DOUBLE | CHAR | STRUCT ID
  def self.type_base
    Parser.parse_any -> do
      Parser.consume(Tokenable::TK_INT, "Expected 'int'!")
      return IntegerType.new(false)
    end, -> do
      Parser.consume(Tokenable::TK_DOUBLE, "Expected 'double'!")
      return FloatType.new(false)
    end, -> do
      Parser.consume(Tokenable::TK_CHAR, "Expected 'char'!")
      return CharType.new(false)
    end, -> do
      Parser.consume(Tokenable::TK_STRUCT, "Expected 'struct'!")
      name = Parser.consume(Tokenable::TK_ID, "Expected struct name!", true)
      return StructType.new(name.ct, false)
    end
  end

  # arrayDecl: LBRACKET expr? RBRACKET
  def self.array_decl
    Parser.consume(Tokenable::TK_LBRACKET, "Expected '['!")
    size, _ = Parser.parse_maybe do
      expr
    end
    Parser.consume(Tokenable::TK_RBRACKET, "Expected ']'!", true)
    return size
  end

  # typeName: typeBase arrayDecl?
  def self.type_name
    type            = type_base
    size, is_array  = Parser.parse_maybe do
      array_decl
    end
    type.is_array   = is_array
    type.array_size = size
    return type
  end

  # declFunc: ( typeBase MUL? | VOID ) ID
  #   LPAR ( funcArg ( COMMA funcArg )* )? RPAR
  #   stmCompound
  def self.decl_func
    type = Parser.parse_any -> do
      type = type_base
      Parser.parse_maybe do
        Parser.consume(Tokenable::TK_MUL, "Expected '*'!")
        type.is_array = true
      end
      return type
    end, -> do
      Parser.consume(Tokenable::TK_VOID, "Expected 'void'!")
      return VoidType.new
    end
    name = Parser.consume(Tokenable::TK_ID, "Expected function name!", true)
    Parser.consume(Tokenable::TK_LPAR, "Expected '('!")
    params = Array.new
    Parser.parse_maybe do
      params << func_arg
      Parser.parse_many do
        Parser.consume(Tokenable::TK_COMMA, "Expected ','!")
        params << func_arg
      end
    end
    Parser.consume(Tokenable::TK_RPAR, "Expected ')'!", true)
    body = stm_compound
    return FunctionDeclaration.new(name.line, name.column, name.ct, type, params, body)
  end

  # funcArg: typeBase ID arrayDecl?
  def self.func_arg
    type            = type_base
    name            = Parser.consume(Tokenable::TK_ID, "Expected var name!", true)
    size, is_array  = Parser.parse_maybe do
      array_decl
    end
    type.is_array   = is_array
    type.array_size = size
    return VariableDeclaration.new(name.line, name.column, name.ct, type)
  end

  # stm: stmCompound
  #   | IF LPAR expr RPAR stm ( ELSE stm )?
  #   | WHILE LPAR expr RPAR stm
  #   | FOR LPAR expr? SEMICOLON expr? SEMICOLON expr? RPAR stm
  #   | BREAK SEMICOLON
  #   | RETURN expr? SEMICOLON
  #   | expr? SEMICOLON
  def self.stm
    Parser.parse_any -> do
      stm_compound
    end, -> do
      tk = Parser.consume(Tokenable::TK_IF, "Expected 'if'!")
      Parser.consume(Tokenable::TK_LPAR, "Expected '('!", true)
      condition = expr
      Parser.consume(Tokenable::TK_RPAR, "Expected ')'!", true)
      if_body   = stm
      else_body, _ = Parser.parse_maybe do
        Parser.consume(Tokenable::TK_ELSE, "Expected 'else'!")
        stm
      end
      return IfStatement.new(tk.line, tk.column, condition, if_body, else_body)
    end, -> do
      tk = Parser.consume(Tokenable::TK_WHILE, "Expected 'while'!")
      Parser.consume(Tokenable::TK_LPAR, "Expected '('!", true)
      condition = expr
      Parser.consume(Tokenable::TK_RPAR, "Expected ')'!", true)
      body = stm
      return WhileStatement.new(tk.line, tk.column, condition, body)
    end, -> do
      tk = Parser.consume(Tokenable::TK_FOR, "Expected 'for'!")
      Parser.consume(Tokenable::TK_LPAR, "Expected '('!", true)
      init, _ = Parser.parse_maybe do
        expr
      end
      Parser.consume(Tokenable::TK_SEMICOLON, "Expected ';'!", true)
      condition, _ = Parser.parse_maybe do
        expr
      end
      Parser.consume(Tokenable::TK_SEMICOLON, "Expected ';'!", true)
      increment, _ = Parser.parse_maybe do
        expr
      end
      Parser.consume(Tokenable::TK_RPAR, "Expected ')'!", true)
      body = stm
      return ForStatement.new(tk.line, tk.column, init, condition, increment, body)
    end, -> do
      tk = Parser.consume(Tokenable::TK_BREAK, "Expected 'break'!")
      Parser.consume(Tokenable::TK_SEMICOLON, "Expected ';'!", true)
      return BreakStatement.new(tk.line, tk.column)
    end, -> do
      tk    = Parser.consume(Tokenable::TK_RETURN, "Expected 'return'!")
      value, _ = Parser.parse_maybe do
        expr
      end
      Parser.consume(Tokenable::TK_SEMICOLON, "Expected ';'!", true)
      return ReturnStatement.new(tk.line, tk.column, value)
    end, -> do
      expression, _ = Parser.parse_maybe do
        expr
      end
      tk            = Parser.consume(Tokenable::TK_SEMICOLON, "Expected ';'!", expression != nil)
      return ExpressionStatement.new(tk.line, tk.column, expression)
    end
  end

  # stmCompound: LACC ( declVar | stm )* RACC
  def self.stm_compound
    tk         = Parser.consume(Tokenable::TK_LACC, "Expected '{'!")
    components = Parser.parse_many do
      Parser.parse_any -> do
        decl_var
      end, -> do
        [stm]
      end
    end
    Parser.consume(Tokenable::TK_RACC, "Expected '}'!", true)
    return CompoundStatement.new(tk.line, tk.column, components.flatten(1))
  end

  # expr: exprAssign
  def self.expr(syntax_error = false)
    expr_assign(syntax_error)
  end

  # exprAssign: exprUnary ASSIGN exprAssign | exprOr
  def self.expr_assign(syntax_error = false)
    Parser.parse_any -> do
      lhs = expr_unary
      Parser.consume(Tokenable::TK_ASSIGN, "Expected '=!'")
      rhs = expr_assign(true)
      return AssignExpression.new(lhs, rhs)
    end, -> do
      expr_or(syntax_error)
    end
  end

  # exprOr: exprOr OR exprAnd | exprAnd
  # => exprOr: exprAnd ( ( OR exprAnd )* )?
  def self.expr_or(syntax_error = false)
    lhs         = expr_and(syntax_error)
    expressions = Parser.parse_many do
      Parser.consume(Tokenable::TK_OR, "Expected '||'!")
      expr_and(true)
    end

    expressions.each do |expression|
      lhs = OrExpression.new(lhs, expression)
    end

    return lhs
  end

  # exprAnd: exprAnd AND exprEq | exprEq
  # => exprAnd: exprEq ( ( AND exprEq )* )?
  def self.expr_and(syntax_error = false)
    lhs         = expr_eq(syntax_error)
    expressions = Parser.parse_many do
      Parser.consume(Tokenable::TK_AND, "Expected '&&'!")
      expr_eq(true)
    end

    expressions.each do |expression|
      lhs = AndExpression.new(lhs, expression)
    end

    return lhs
  end

  # exprEq: exprEq ( EQUAL | NOTEQ ) exprRel | exprRel
  # => exprEq: exprRel ( ( ( EQUAL | NOTEQ ) exprRel )* )?
  def self.expr_eq(syntax_error = false)
    lhs         = expr_rel(syntax_error)
    expressions = Parser.parse_many do
      tk = Parser.parse_any -> do
        Parser.consume(Tokenable::TK_EQUAL, "Expected '=='!")
      end, -> do
        Parser.consume(Tokenable::TK_NOTEQ, "Expected '!='!")
      end
      [tk, expr_rel(true)]
    end

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
  # => exprRel: exprAdd ( ( ( LESS | LESSEQ | GREATER | GREATEREQ ) exprAdd )* )?
  def self.expr_rel(syntax_error = false)
    lhs         = expr_add(syntax_error)
    expressions = Parser.parse_many do
      tk = Parser.parse_any -> do
        Parser.consume(Tokenable::TK_LESS, "Expected '<'!")
      end, -> do
        Parser.consume(Tokenable::TK_LESSEQ, "Expected '<='!")
      end, -> do
        Parser.consume(Tokenable::TK_GREATER, "Expected '>'!")
      end, -> do
        Parser.consume(Tokenable::TK_GREATEREQ, "Expected '>='")
      end
      [tk, expr_add(true)]
    end

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
  # => exprAdd: exprMul ( ( ( ADD | SUB ) exprMul )* )?
  def self.expr_add(syntax_error = false)
    lhs         = expr_mul(syntax_error)
    expressions = Parser.parse_many do
      tk = Parser.parse_any -> do
        Parser.consume(Tokenable::TK_ADD, "Expected '+'!")
      end, -> do
        Parser.consume(Tokenable::TK_SUB, "Expected '-'!")
      end
      [tk, expr_mul(true)]
    end

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
  # => exprMul: exprCast ( ( ( MUL | DIV ) exprCast )* )?
  def self.expr_mul(syntax_error = false)
    lhs         = expr_cast(syntax_error)
    expressions = Parser.parse_many do
      tk = Parser.parse_any -> do
        Parser.consume(Tokenable::TK_MUL, "Expected '*'!")
      end, -> do
        Parser.consume(Tokenable::TK_DIV, "Expected '/'!")
      end
      [tk, expr_cast(true)]
    end

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
  def self.expr_cast(syntax_error = false)
    Parser.parse_any -> do
      tk   = Parser.consume(Tokenable::TK_LPAR, "Expected '('!")
      type = type_name
      Parser.consume(Tokenable::TK_RPAR, "Expected ')'!", true)
      expression = expr_cast(true)
      return CastExpression.new(tk.line, tk.column, type, expression)
    end, -> do
      return expr_unary(syntax_error)
    end
  end

  # exprUnary: ( SUB | NOT ) exprUnary | exprPostfix
  def self.expr_unary(syntax_error = false)
    Parser.parse_any -> do
      cls = Parser.parse_any -> do
        Parser.consume(Tokenable::TK_SUB, "Expected '-'!")
        return ArithmeticNegationExpression
      end, -> do
        Parser.consume(Tokenable::TK_NOT, "Expected '!'!")
        return LogicalNegationExpression
      end
      cls.new(expr_unary(true))
    end, -> do
      expr_postfix(syntax_error)
    end
  end

  # exprPostfix: exprPostfix LBRACKET expr RBRACKET
  #   | exprPostfix DOT ID
  #   | exprPrimary
  # => exprPostfix: exprPrimary ( ( ( LBRACKET expr RBRACKET ) | ( DOT ID ) ) * )?
  def self.expr_postfix(syntax_error = false)
    base        = expr_primary(syntax_error)
    expressions = Parser.parse_many do
      Parser.parse_any -> do
        tk    = Parser.consume(Tokenable::TK_LBRACKET, "Expected '['!")
        index = expr(true)
        Parser.consume(Tokenable::TK_RBRACKET, "Expected ']'!", true)
        return [tk, index]
      end, -> do
        tk          = Parser.consume(Tokenable::TK_DOT, "Expected '.'!")
        member_name = Parser.consume(Tokenable::TK_ID, "Expected member name!", true)
        return [tk, member_name]
      end
    end

    expressions.each do |tk, expression|
      if tk.code.eql?(Tokenable::TK_LBRACKET)
        base = ArrayPostfixExpression.new(base, expression)
      elsif tk.code.eql?(Tokenable::TK_DOT)
        base = StructPostfixExpression.new(base, expression.ct)
      end
    end
    return base
  end

  # exprPrimary: ID ( LPAR ( expr ( COMMA expr )* )? RPAR )?
  #   | CT_INT
  #   | CT_REAL
  #   | CT_CHAR
  #   | CT_STRING
  #   | LPAR expr RPAR
  def self.expr_primary(syntax_error = false)
    begin
      Parser.parse_any -> do
        id = Parser.consume(Tokenable::TK_ID, "Expected identifier!")
        if Parser.consume(Tokenable::TK_LPAR)
          args         = Array.new
          first_arg, _ = Parser.parse_maybe do
            expr
          end
          if first_arg
            args << first_arg
            args += Parser.parse_many do
              Parser.consume(Tokenable::TK_COMMA, "Expected ','!")
              expr
            end
          end
          Parser.consume(Tokenable::TK_RPAR, "Expected ')'!", true)
          return FunctionCallExpression.new(id.line, id.column, id.ct, args)
        end
        return VariableExpression.new(id.line, id.column, id.ct)
      end, -> do
        tk = Parser.consume(Tokenable::TK_CT_INT, "Expected integer constant!")
        return ConstantExpression.new(tk.line, tk.column, tk.ct, INT)
      end, -> do
        tk = Parser.consume(Tokenable::TK_CT_REAL, "Expected float constant!")
        return ConstantExpression.new(tk.line, tk.column, tk.ct, FLOAT)
      end, -> do
        tk = Parser.consume(Tokenable::TK_CT_CHAR, "Expected char constant!")
        return ConstantExpression.new(tk.line, tk.column, tk.ct, CHAR)
      end, -> do
        tk = Parser.consume(Tokenable::TK_CT_STRING, "Expected string constant!")
        return ConstantExpression.new(tk.line, tk.column, tk.ct, CharType.new(true, tk.ct.length + 1))
      end, -> do
        Parser.consume(Tokenable::TK_LPAR, "Expected '('!")
        result = expr
        Parser.consume(Tokenable::TK_RPAR, "Expected ')'!", true)
        return result
      end
    rescue ParserException => e
      raise ParserSyntaxError.new(e) if syntax_error
    end
  end
end
