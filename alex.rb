require_relative 'token'
require_relative 'token_type'

class Alex
  # state - current state
  # line - current line in file
  # column - current column in file
  def initialize(input_file)
    @tokens       = Array.new
    @input_buffer = File.read(input_file) << "\n"
    @state        = 0
    @line         = 1
    @column       = 1
  end

  # show_tokens method
  def to_s
    str = ""
    @tokens.each do |tk|
      str += "#{tk.code}: #{tk.ct} (line: #{tk.line}, column: #{tk.column})\n"
    end
    str
  end

  # converts ID to specific type
  def convert_id(token_ct)
    case token_ct
    when "break"
      return TokenType::TK_BREAK
    when "char"
      return TokenType::TK_CHAR
    when "double"
      return TokenType::TK_DOUBLE
    when "else"
      return TokenType::TK_ELSE
    when "for"
      return TokenType::TK_FOR
    when "if"
      return TokenType::TK_IF
    when "int"
      return TokenType::TK_INT
    when "return"
      return TokenType::TK_RETURN
    when "struct"
      return TokenType::TK_STRUCT
    when "void"
      return TokenType::TK_VOID
    when "while"
      return TokenType::TK_WHILE
    else
      return TokenType::TK_ID
    end
  end

  def convert_escape_char(ch)
    case ch
    when '\a'
      return "\a"
    when '\b'
      return "\b"
    when '\f'
      return "\f"
    when '\n'
      return "\n"
    when '\r'
      return "\r"
    when '\t'
      return "\t"
    when '\v'
      return "\v"
    when '\0'
      return "\0"
    else
      return ch[1] if ch.include?('\\')
      return ch
    end
  end

  # converts string to specific token type
  def create_ct(token_type, token_ct)
    case token_type
    when TokenType::TK_CT_INT
      if token_ct.start_with?("0")
        if token_ct.start_with?("0x")
          return token_ct.to_i(16)
        else
          return token_ct.to_i(8)
        end
      else
        return token_ct.to_i
      end
    when TokenType::TK_CT_REAL
      return token_ct.to_f
    when TokenType::TK_CT_CHAR
      token_ct = token_ct[1...-1]
      return self.convert_escape_char(token_ct)
    when TokenType::TK_CT_STRING
      token_ct = token_ct[1...-1]
      tmp      = ""
      index    = 0
      while index < token_ct.length do
        if token_ct[index].eql?('\\')
          tmp << convert_escape_char(token_ct[index..index + 1])
          index += 2
        else
          tmp << token_ct[index]
          index += 1
        end
      end
      return tmp
    else
      return token_ct
    end
  end

  def get_tokens
    # token_start - the first character in the current token
    # token_ct - used for ID, CT_STRING (text), CT_INT, CT_CHAR (int), CT_REAL (double)
    token_start = [@line, @column]
    token_ct    = ""

    @input_buffer.each_char do |c|
      @column  += 1
      consumed = false

      until consumed
        if @state.zero?
          token_start = [@line, @column]
          token_ct    = ""
        end

        result, consumed = TokenType.transition(@state, c)

        if consumed
          token_ct += c
        end

        self.token_err(@line, @column) if result.nil?

        tmp = result[1]

        if tmp.nil?
          @state = result[0]
        else
          tmp = self.convert_id(token_ct) if tmp.eql?(TokenType::TK_ID)
          @tokens.push(Token.new(tmp.to_s, self.create_ct(tmp, token_ct), token_start[0], token_start[1]))
          @state = 0
        end
      end

      if c == "\n"
        @line   += 1
        @column = 0
      end
    end

    @tokens.push(Token.new(TokenType::TK_END, "", @line, @column))
  end

  # err & token_err functions
  def token_err(line, column)
    abort("Error in line #{line}, column #{column}!")
  end
end

file = Alex.new("8.c")
file.get_tokens
puts file
