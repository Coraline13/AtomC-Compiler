class ASTNode
  # AST - abstract syntax tree
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

class FunctionCallExpression < Expression
  attr_reader :function_name, :args

  def initialize(function_name, args)
    @function_name = function_name
    @args = args
  end

  def to_s
    return "#{@function_name}(#{args.join(", ")})"
  end
end
