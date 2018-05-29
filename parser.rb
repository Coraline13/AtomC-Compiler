require_relative 'tokenable'
require_relative 'ast'
require_relative 'rules'
require_relative 'parser_exception'

module Parser
  def self.parse(tokens)
    @tokens = tokens
    @index  = 0

    begin
      return Rules.unit
    rescue ParserException => e
      puts e
      puts e.backtrace
    rescue ParserSyntaxError => err
      puts err
      puts err.backtrace
    end
  end

  def self.consume(code, msg = nil, syntax_error = false)
    if @tokens[@index].code == code
      @index += 1
      return @tokens[@index - 1]
    end
    if msg
      exception = ParserException.new(@tokens[@index], msg)
      if syntax_error
        raise ParserSyntaxError.new(exception)
      end
      raise exception
    end
  end

  # implements *
  def self.parse_many(optional = true, &rule)
    results = Array.new
    loop do
      old_index = @index
      begin
        results << rule.call
      rescue ParserException
        @index = old_index

        if !optional && results.empty?
          raise
        end

        break
      end
    end
    return results
  end

  # implements ?
  def self.parse_maybe(&rule)
    old_index = @index
    begin
      return rule.call, true
    rescue ParserException
      @index = old_index
      return nil, false
    end
  end

  # implements |
  def self.parse_any(*rules)
    exceptions = Array.new
    old_index  = @index

    rules.each do |rule|
      begin
        return rule.call
      rescue ParserException => e
        exceptions << e
        @index = old_index
      end
    end

    raise MultiParserException.new(exceptions)
  end
end
