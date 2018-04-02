require_relative 'token_type'

class Alex
    @tokens = Array.new

    # line - current line in file
    @line = 1
    @current_position = 0

    # read file
    input_buffer = File.read("0.c")
    # puts input_buffer

    private
    def add_token(code, ct, line, column)
        @tokens.push(Token.new(code, ct, line, column))
    end

    # err & token_err functions
    private
    def token_err(errors, tk = nil)
        tk.nil? ? abort("Error: #{errors}") : abort("Error in line #{tk.line}: #{errors}")
    end

    private
    def get_next_token
        state = 0

    end

    public
    def show_tokens
        @tokens.each {|tk| puts "#{tk.code}: #{tk.ct}"}
    end
end