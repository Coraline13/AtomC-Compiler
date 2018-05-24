class ASTNode
  # AST - abstract syntax tree
end

class Expression < ASTNode
  def type
    raise(NotImplementedError)
  end

  def lval?
    false
  end

  def const?
    false
  end
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