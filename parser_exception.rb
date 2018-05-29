class ParserException < Exception
  attr_reader :tk

  def initialize(tk, msg)
    @tk = tk
    super("#{msg}, #{tk}")
  end
end

class MultiParserException < ParserException
  def initialize(exceptions)
    super(nil, "Failed to parse any of:\n\t#{exceptions.join("\n\t")}")
  end
end

class ParserSyntaxError < Exception
  def initialize(exception)
    super(exception.to_s)
  end
end
