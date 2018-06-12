require_relative 'symbols'

class ASTNode
  # AST - abstract syntax tree
  attr_reader :line, :column

  def initialize(line, column)
    @line   = line
    @column = column
  end

  def validate(symbols, context)
    raise NotImplementedError
  end
end

class UnitNode < ASTNode
  attr_reader :declarations

  def initialize(line, column, declarations)
    super(line, column)
    @declarations = declarations
  end

  def validate(symbols, context)
    @declarations.each { |declaration| declaration.validate(symbols, context) }
  end

  # TODO: all to_s methods
end

class Expression < ASTNode
  def type
    raise NotImplementedError
  end

  def lval?
    return false
  end

  def const?
    return false
  end
end

class Declaration < ASTNode
  attr_reader :name

  def initialize(line, column, name)
    super(line, column)
    @name = name
  end
end

class Statement < ASTNode

end

class VariableExpression < Expression
  attr_reader :name

  def initialize(line, column, name)
    super(line, column)
    @name = name
  end

  def to_s
    "var: #{@name}"
  end
end

class ConstantExpression < Expression
  attr_reader :value, :type

  def initialize(line, column, value, type)
    super(line, column)
    @value = value
    @type  = type
  end

  def const?
    return true
  end

  def to_s
    return "#{@type}:#{@value}"
  end
end

class CastExpression < Expression
  attr_reader :target_type, :expression

  def initialize(line, column, target_type, expression)
    super(line, column)
    @target_type = target_type
    @expression  = expression
  end

  def to_s
    return "(#{@target_type})#{@expression}"
  end
end

class FunctionCallExpression < Expression
  attr_reader :function_name, :args

  def initialize(line, column, function_name, args)
    super(line, column)
    @function_name = function_name
    @args          = args
  end

  def to_s
    return "#{@function_name}(#{args.join(", ")})"
  end
end

class UnaryExpression < Expression
  attr_reader :expression

  def initialize(expression)
    super(expression.line, expression.column)
    @expression = expression
  end
end

class LogicalNegationExpression < UnaryExpression

end

class ArithmeticNegationExpression < UnaryExpression

end

class PostfixExpression < Expression

end

class ArrayPostfixExpression < PostfixExpression
  attr_reader :base, :index

  def initialize(base, index)
    super(base.line, base.column)
    @base  = base
    @index = index
  end
end

class StructPostfixExpression < PostfixExpression
  attr_reader :struct, :member_name

  def initialize(struct, member_name)
    super(struct.line, struct.column)
    @struct      = struct
    @member_name = member_name
  end
end

class BinaryExpression < Expression
  # lhs - left hand side
  # rhs - right hand side
  attr_reader :lhs, :rhs

  def initialize(lhs, rhs)
    super(lhs.line, lhs.column)
    @lhs = lhs
    @rhs = rhs
  end

  # TODO: eroare daca lipsesc membrul drept, nu ca astepta paranteza cu mesaj
end

class AssignExpression < BinaryExpression

end

class OrExpression < BinaryExpression

end

class AndExpression < BinaryExpression

end

class EqualExpression < BinaryExpression
  def to_s
    return "#{lhs}==#{rhs}"
  end
end

class NoteqExpression < BinaryExpression
  def to_s
    return "#{lhs}!=#{rhs}"
  end
end

class LessExpression < BinaryExpression
  def to_s
    return "#{lhs}<#{rhs}"
  end
end

class LesseqExpression < BinaryExpression
  def to_s
    return "#{lhs}<=#{rhs}"
  end
end

class GreaterExpression < BinaryExpression
  def to_s
    return "#{lhs}>#{rhs}"
  end
end

class GreatereqExpression < BinaryExpression
  def to_s
    return "#{lhs}>=#{rhs}"
  end
end

class AddExpression < BinaryExpression
  def to_s
    return "#{lhs}+#{rhs}"
  end
end

class SubExpression < BinaryExpression
  def to_s
    return "#{lhs}-#{rhs}"
  end
end

class MulExpression < BinaryExpression
  def to_s
    return "#{lhs}*#{rhs}"
  end
end

class DivExpression < BinaryExpression
  def to_s
    return "#{lhs}/#{rhs}"
  end
end

class StructDeclaration < Declaration
  attr_reader :members

  def initialize(line, column, name, members)
    super(line, column, name)
    @members = members
  end
end

class VariableDeclaration < Declaration
  attr_reader :type

  def initialize(line, column, name, type)
    super(line, column, name)
    @type = type
  end

  def validate(symbols, context)


    symbols.put(@name, self)
  end
end

class FunctionDeclaration < Declaration
  attr_reader :type, :params, :body

  def initialize(line, column, name, type, params, body)
    super(line, column, name)
    @type   = type
    @params = params
    @body   = body
  end

  def validate(symbols, context)
    symbols.put(@name, self)
    local_symbols = Symbols.new(symbols)
    @params.each { |param| param.validate(local_symbols, context) }
    @body.validate(local_symbols, context)
  end
end

class CompoundStatement < Statement
  attr_reader :components

  def initialize(line, column, components)
    super(line, column)
    @components = components
  end
end

class ExpressionStatement < Statement
  attr_reader :expr

  def initialize(line, column, expr)
    super(line, column)
    @expr = expr
  end

  def to_s
    return "#{@expr};"
  end
end

class IfStatement < Statement
  attr_reader :condition, :if_body, :else_body

  def initialize(line, column, condition, if_body, else_body)
    super(line, column)
    @condition = condition
    @if_body   = if_body
    @else_body = else_body
  end

  def to_s
    str = "if(#{@condition}) #{@if_body};"
    str += "\nelse(#{@else_body};" if @else_body
    return str
  end
end

class WhileStatement < Statement
  attr_reader :condition, :body

  def initialize(line, column, condition, body)
    super(line, column)
    @condition = condition
    @body      = body
  end

  def to_s
    return "while(#{@condition}) #{@body};"
  end
end

class ForStatement < Statement
  attr_reader :init, :condition, :increment, :body

  def initialize(line, column, init, condition, increment, body)
    super(line, column)
    @init      = init
    @condition = condition
    @increment = increment
    @body      = body
  end

  def to_s
    return "for(#{@init};#{@condition};#{@increment}) #{@body};"
  end
end

class BreakStatement < Statement

end

class ReturnStatement < Statement
  attr_reader :value

  def initialize(line, column, value)
    super(line, column)
    @value = value
  end

  def to_s
    return "return #{@value};"
  end
end
