class Type
  attr_accessor :is_array, :array_size

  def initialize(is_array, array_size = nil)
    @is_array   = is_array
    @array_size = array_size
  end

  def as_array(is_array, array_size)
    result = self.clone
    result.is_array = is_array
    result.array_size = array_size
    return result
  end

  def check_same_as(other, line, column)
    raise TypeException.new("Cast between array and non-array types!", line, column) if @is_array != other.is_array
    if !@array_size.nil? && !other.array_size.nil?
      size = @array_size.const_val
      other_size = other.array_size.const_val
      raise TypeException.new("Array size does not match (#{size}, #{other_size})!", line, column) if size != other_size
    end
    raise TypeException.new("Type mismatch (#{self}, #{other})!", line, column) unless self.class == other.class
  end

  def array_to_s
    @is_array ? "[#{@array_size}]" : ""
  end

  def validate(line, column, symbols, context)
    if @is_array && @array_size
      raise TypeException.new("Array size must be a constant expression!", @array_size.line, @array_size.column) unless @array_size.const?
      raise TypeException.new("Array size must be an integer!", @array_size.line, @array_size.column) unless @array_size.type.is_a?(IntegerType)
      size = @array_size.const_val
      raise TypeException.new("Array size must be greater than 0!", @array_size.line, @array_size.column) unless size > 0
    end
  end
end

class VoidType < Type
  def initialize()
    super(false)
  end

  def to_s
    return "void"
  end
end

class PrimitiveType < Type

end

class IntegerType < PrimitiveType
  def to_s
    return "int#{array_to_s}"
  end
end

class FloatType < PrimitiveType
  def to_s
    return "float#{array_to_s}"
  end
end

class CharType < PrimitiveType
  def to_s
    return "char#{array_to_s}"
  end
end

INT   = IntegerType.new(false)
FLOAT = FloatType.new(false)
CHAR  = CharType.new(false)

def const_cast(value, source_type, target_type, line, column)
  check_explicit_cast(source_type, target_type, line, column)
  return value.to_i if target_type.is_a?(IntegerType) || target_type.is_a?(CharType)
  return value.to_f if target_type.is_a?(FloatType)
  return value
end

def check_arithmetic_type(type, line, column)
  unless type.is_a?(CharType) || type.is_a?(IntegerType) || type.is_a?(FloatType)
    raise TypeException.new("Expected one of char, int or float!", line, column)
  end
  raise TypeException.new("Cannot use arrays in arithmetic!", line, column) if type.is_array
end

def check_implicit_cast(source_type, target_type, line, column)
  check_explicit_cast(source_type, target_type, line, column)
  # TODO: check implicit cast
end

def check_explicit_cast(source_type, target_type, line, column)
  begin
    larger_type(source_type, target_type, line, column)
  rescue TypeException
    source_type.check_same_as(target_type, line, column)
    if source_type.is_array && target_type.is_array
      if !target_type.array_size.nil? && source_type.array_size.nil?
        raise TypeException.new("Sized/unsized array mismatch!", line, column)
      end
    end
  end
end

def larger_type(type1, type2, line, column)
  check_arithmetic_type(type1, line, column)
  check_arithmetic_type(type2, line, column)
  return type2 if type1.is_a?(CharType)
  if type1.is_a?(IntegerType)
    if type2.is_a?(FloatType)
      return type2
    end
    return type1
  end
  return type1
end

class StructType < Type
  attr_reader :struct_name, :struct_decl

  def initialize(struct_name, is_array, array_size = nil)
    super(is_array, array_size)
    @struct_name = struct_name
  end

  def to_s
    return "struct#{array_to_s}"
  end

  def validate(line, column, symbols, context)
    @struct_decl = symbols.get(@struct_name, line, column)
    raise TypeException.new("#{@struct_name} is not a struct!", line, column) unless @struct_decl.is_a?(StructDeclaration)
    super
  end

  def check_same_as(other, line, column)
    super
    raise TypeException.new("Different struct types (#{@struct_name}, #{other.struct_name})!", line, column) unless @struct_name == other.struct_name
  end
end

class TypeException < Exception
  def initialize(msg, line, column)
    super("Type error at line #{line}, column #{column}: #{msg}")
  end
end
