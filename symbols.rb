class Symbols
  def initialize(parent)
    @table  = {}
    @parent = parent
  end

  def put(key, value, line, column)
    raise SymbolException.new("Duplicate symbol #{key}!", line, column) if @table.has_key?(key)
    @table[key] = value
  end

  def get(key, line, column)
    return @table[key] if @table.has_key?(key)
    return @parent.get(key, line, column) if @parent
    raise SymbolException.new("Symbol #{key} doesn't exist!", line, column)
  end
end

class SymbolException < Exception
  def initialize(msg, line, column)
    super("Domain error at line #{line}, column #{column}: #{msg}")
  end
end
