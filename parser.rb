require_relative 'tokenable'
require_relative 'ast'

module Parser
  def self.parse(tokens)
    @tokens = tokens
    @index  = 0
    # TODO: return nod principal
    return expr_primary
  end

  def self.consume(code)
    if @tokens[@index].code == code
      @last_token = @tokens[@index]
      @index      += 1
      return true
    end
    false
  end

  # unit: ( declStruct | declFunc | declVar )* END

  # typeBase: INT | DOUBLE | CHAR | STRUCT ID
  def type_base
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

  # exprOr: exprOr OR exprAnd | exprAnd
  # def expr_or
  #   if expr_and
  #     if expr_or1
  #       true
  #     end
  #   end
  #   false
  # end

  # exprPrimary: ID ( LPAR ( expr ( COMMA expr )* )? RPAR )?
  # | CT_INT
  # | CT_REAL
  # | CT_CHAR
  # | CT_STRING
  # | LPAR expr RPAR
  def self.expr_primary
    start_index = @index
    if consume(Tokenable::TK_ID)
      id = @last_token.ct
      if consume(Tokenable::TK_LPAR)
        params = Array.new
        if true # TODO: expr
          params << 1 # TODO: adaugat nod in lista
          while tokens[index].code == Tokenable::TK_COMMA
            index += 1
            if true # TODO: expr
              params << 1 # TODO: adaugat nod in lista
            end
          end
        end
        if tokens[index].code == Tokenable::TK_RPAR
          return true
        end
      end
      VariableExpression.new(id)
    end
    # return bla if consume(Tokenable::TK_CT_INT)
  end
end