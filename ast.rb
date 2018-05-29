class ASTNode
  # AST - abstract syntax tree
end

class UnitNode
  attr_reader :declarations

  def initialize(declarations)
    @declarations = declarations
  end
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

  def initialize(name)
    @name = name
  end
end

class Statement < ASTNode

end

class VariableExpression < Expression
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def to_s
    "var: #{@name}"
  end
end

class ConstantExpression < Expression
  attr_reader :value, :type

  def initialize(value, type)
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

  def initialize(target_type, expression)
    @target_type = target_type
    @expression  = expression
  end

  def to_s
    return "(#{@target_type})#{@expression}"
  end
end

class FunctionCallExpression < Expression
  attr_reader :function_name, :args

  def initialize(function_name, args)
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
    @base  = base
    @index = index
  end
end

class StructPostfixExpression < PostfixExpression
  attr_reader :struct, :member_name

  def initialize(struct, member_name)
    @struct      = struct
    @member_name = member_name
  end
end

class BinaryExpression < Expression
  # lhs - left hand side
  # rhs - right hand side
  attr_reader :lhs, :rhs

  def initialize(lhs, rhs)
    @lhs = lhs
    @rhs = rhs
  end
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

  def initialize(name, members)
    super(name)
    @members = members
  end
end

class VariableDeclaration < Declaration
  attr_reader :type

  def initialize(name, type)
    super(name)
    @type = type
  end
end

class FunctionDeclaration < Declaration
  attr_reader :type, :params, :body

  def initialize(name, type, params, body)
    super(name)
    @type   = type
    @params = params
    @body   = body
  end
end

class CompoundStatement < Statement
  attr_reader :components

  def initialize(components)
    @components = components
  end
end
