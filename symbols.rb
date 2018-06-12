class Symbols
  def initialize(parent)
    @table  = {}
    @parent = parent
  end

  def put(key, value)
    raise SymbolError.new("Duplicate symbol #{key}!") if @table.has_key?(key)
    @table[key] = value
  end

  def get(key)
    return @table[key] if @table.has_key?(key)
    return @parent.get(key) if @parent
    raise SymbolError.new("Symbol #{key} doesn't exist!")
  end
end

class SymbolError < Exception

end
