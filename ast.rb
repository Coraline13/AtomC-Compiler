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

  def const_val
    raise TypeException.new("Not a const value!", @line, @column) unless const?
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

  def type
    return @decl.type
  end

  def lval?
    return true
  end

  def to_s
    "var: #{@name}"
  end

  def validate(symbols, context)
    @decl = symbols.get(@name, @line, @column)
  end
end

class ConstantExpression < Expression
  attr_reader :value, :constant_type

  def initialize(line, column, value, constant_type)
    super(line, column)
    @value         = value
    @constant_type = constant_type
  end

  def type
    return @constant_type
  end

  def const?
    return true
  end

  def const_val
    return @value
  end

  def validate(symbols, context)
    # always valid
  end

  def to_s
    return "#{@constant_type}:#{@value}"
  end
end

class CastExpression < Expression
  attr_reader :target_type, :expression

  def initialize(line, column, target_type, expression)
    super(line, column)
    @target_type = target_type
    @expression  = expression
  end

  def type
    return @target_type
  end

  def const?
    return @expression.const?
  end

  def const_val
    super
    return const_cast(@expression.const_val, @expression.type, @target_type, @line, @column)
  end

  def to_s
    return "(#{@target_type})#{@expression}"
  end

  def validate(symbols, context)
    @expression.validate(symbols, context)
    @target_type.validate(@line, @column, symbols, context)
    check_explicit_cast(@expression.type, @target_type, @line, @column)
  end
end

class FunctionCallExpression < Expression
  attr_reader :function_name, :args

  def initialize(line, column, function_name, args)
    super(line, column)
    @function_name = function_name
    @args          = args
  end

  def type
    return @decl.type
  end

  def to_s
    return "#{@function_name}(#{args.join(", ")})"
  end

  def validate(symbols, context)
    @decl = symbols.get(@function_name, @line, @column)
    raise SymbolException.new("Arg count mismatch!", @line, @column) unless @args.size == @decl.params.size
    @args.each_with_index do |arg, index|
      arg.validate(symbols, context)
      check_implicit_cast(arg.type, @decl.params[index].type, @line, @column)
    end
  end
end

class UnaryExpression < Expression
  attr_reader :expression

  def initialize(expression)
    super(expression.line, expression.column)
    @expression = expression
  end

  def const?
    return @expression.const?
  end

  def validate(symbols, context)
    @expression.validate(symbols, context)
    check_arithmetic_type(@expression.type, @line, @column)
  end
end

class LogicalNegationExpression < UnaryExpression
  def type
    return INT
  end

  def const_val
    super
    return @expression.const_val == 0 ? 1 : 0
  end
end

class ArithmeticNegationExpression < UnaryExpression
  def type
    return @expression.type
  end

  def const_val
    super
    return -@expression.const_val
  end
end

class PostfixExpression < Expression
  def lval?
    return true
  end
end

class ArrayPostfixExpression < PostfixExpression
  attr_reader :base, :index

  def initialize(base, index)
    super(base.line, base.column)
    @base  = base
    @index = index
  end

  def type
    return @base.type.as_array(false, nil)
  end

  def validate(symbols, context)
    @base.validate(symbols, context)
    @index.validate(symbols, context)
    raise TypeException.new("Array index must be integer!", @line, @column) unless @index.type.is_a?(IntegerType)
    raise TypeException.new("Brackets require array!", @line, @column) unless @base.type.is_array
  end
end

class StructPostfixExpression < PostfixExpression
  attr_reader :struct, :member_name

  def initialize(struct, member_name)
    super(struct.line, struct.column)
    @struct      = struct
    @member_name = member_name
  end

  def type
    struct_type = @struct.type
    struct_decl = struct_type.struct_decl
    member_decl = struct_decl.symbols.get(@member_name, @line, @column)
    return member_decl.type
  end

  def validate(symbols, context)
    @struct.validate(symbols, context)
    raise TypeException.new("Dot requires struct!", @line, @column) unless @struct.type.is_a?(StructType)
    type
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

  def const?
    return lhs.const? && rhs.const?
  end

  def validate(symbols, context)
    @lhs.validate(symbols, context)
    @rhs.validate(symbols, context)
  end

  # TODO: eroare daca lipsesc membrul drept, nu ca astepta paranteza cu mesaj
end

class AssignExpression < BinaryExpression
  def type
    return @lhs.type
  end

  def validate(symbols, context)
    super
    raise TypeException.new("Non lval on left hand side of assignment operator!", @line, @column) unless @lhs.lval?
  end
end

class LogicalExpression < BinaryExpression
  def type
    return INT
  end

  def validate(symbols, context)
    super
    check_arithmetic_type(@lhs.type, @line, @column)
    check_arithmetic_type(@rhs.type, @line, @column)
  end
end

class OrExpression < LogicalExpression

end

class AndExpression < LogicalExpression

end

class EqualExpression < LogicalExpression
  def to_s
    return "#{lhs}==#{rhs}"
  end
end

class NoteqExpression < LogicalExpression
  def to_s
    return "#{lhs}!=#{rhs}"
  end
end

class LessExpression < LogicalExpression
  def to_s
    return "#{lhs}<#{rhs}"
  end
end

class LesseqExpression < LogicalExpression
  def to_s
    return "#{lhs}<=#{rhs}"
  end
end

class GreaterExpression < LogicalExpression
  def to_s
    return "#{lhs}>#{rhs}"
  end
end

class GreatereqExpression < LogicalExpression
  def to_s
    return "#{lhs}>=#{rhs}"
  end
end

class ArithmeticExpression < BinaryExpression
  def type
    return larger_type(@lhs.type, @rhs.type, @line, @column)
  end

  def validate(symbols, context)
    super
    check_arithmetic_type(@lhs.type, @line, @column)
    check_arithmetic_type(@rhs.type, @line, @column)
  end
end

class AddExpression < ArithmeticExpression
  def to_s
    return "#{lhs}+#{rhs}"
  end

  def const_val
    return lhs.const_val + rhs.const_val
  end
end

class SubExpression < ArithmeticExpression
  def to_s
    return "#{lhs}-#{rhs}"
  end

  def const_val
    return lhs.const_val - rhs.const_val
  end
end

class MulExpression < ArithmeticExpression
  def to_s
    return "#{lhs}*#{rhs}"
  end

  def const_val
    return lhs.const_val * rhs.const_val
  end
end

class DivExpression < ArithmeticExpression
  def to_s
    return "#{lhs}/#{rhs}"
  end

  def const_val
    return lhs.const_val / rhs.const_val # TODO: float or int
  end
end

class StructDeclaration < Declaration
  attr_reader :members, :symbols

  def initialize(line, column, name, members)
    super(line, column, name)
    @members = members
  end

  def validate(symbols, context)
    @symbols = Symbols.new(symbols)
    @members.each { |member| member.validate(@symbols, context) }
    symbols.put(@name, self, @line, @column)
  end
end

class VariableDeclaration < Declaration
  attr_reader :type

  def initialize(line, column, name, type)
    super(line, column, name)
    @type = type
  end

  def validate(symbols, context)
    @type.validate(@line, @column, symbols, context)
    symbols.put(@name, self, @line, @column)
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
    @type.validate(@line, @column, symbols, context)
    local_symbols = Symbols.new(symbols)
    @params.each do |param|
      param.validate(local_symbols, context)
    end
    context[:in_function] = self
    @body.validate(local_symbols, context)
    context.delete(:in_function)
    symbols.put(@name, self, @line, @column)
  end
end

class CompoundStatement < Statement
  attr_reader :components

  def initialize(line, column, components)
    super(line, column)
    @components = components
  end

  def validate(symbols, context)
    local_symbols = Symbols.new(symbols)
    @components.each do |component|
      component.validate(local_symbols, context)
    end
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

  def validate(symbols, context)
    local_symbols = Symbols.new(symbols)
    @expr.validate(local_symbols, context) if @expr
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

  def validate(symbols, context)
    local_symbols = Symbols.new(symbols)
    @condition.validate(local_symbols, context)
    @if_body.validate(local_symbols, context)
    @else_body.validate(local_symbols, context) if @else_body
    check_arithmetic_type(@condition.type, @line, @column)
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

  def validate(symbols, context)
    local_symbols = Symbols.new(symbols)
    @condition.validate(local_symbols, context)
    context[:loop_level].nil? ? context[:loop_level] = 1 : context[:loop_level] += 1
    @body.validate(local_symbols, context)
    context[:loop_level] -= 1
    check_arithmetic_type(@condition.type, @line, @column)
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

  def validate(symbols, context)
    local_symbols = Symbols.new(symbols)
    @init.validate(local_symbols, context) if @init
    @condition.validate(local_symbols, context) if @condition
    @increment.validate(local_symbols, context) if @increment
    context[:loop_level].nil? ? context[:loop_level] = 1 : context[:loop_level] += 1
    @body.validate(local_symbols, context)
    context[:loop_level] -= 1
    check_arithmetic_type(@condition.type, @line, @column) if @condition
  end
end

class BreakStatement < Statement
  def validate(symbols, context)
    raise SymbolException.new("Break outside loop!", @line, @column) unless context.has_key?(:loop_level) && context[:loop_level] > 0
  end
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

  def validate(symbols, context)
    @value.validate(symbols, context) if @value
    raise SymbolException.new("Return outside function!", @line, @column) unless context.has_key?(:in_function)
    func_decl = context[:in_function]
    if func_decl.type.is_a?(VoidType) && !@value.nil?
      raise TypeException.new("Non-void return from void function!", @line, @column)
    end
    if !func_decl.type.is_a?(VoidType) && @value.nil?
      raise TypeException.new("Void return from non-void function!", @line, @column)
    end
    check_implicit_cast(@value.type, func_decl.type, @line, @column)
  end
end
