class Type
  attr_accessor :is_array, :array_size

  def initialize(is_array, array_size = nil)
    @is_array   = is_array
    @array_size = array_size
  end

  def array_to_s
    is_array ? "[#{array_size}]" : ""
  end
end

class VoidType < Type
  def initialize()
    super(false)
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

class StructType < Type
  attr_reader :struct_name

  def initialize(struct_name, is_array, array_size = nil)
    super(is_array, array_size)
    @struct_name = struct_name
  end

  def to_s
    return "struct#{array_to_s}"
  end
end
