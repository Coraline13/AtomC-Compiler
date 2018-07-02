module Builtin
  def self.add_builtin(globals, name, return_type, param_types)
    params = param_types.map do |param_name, param_type|
      VariableDeclaration.new(-1, -1, param_name, param_type)
    end
    decl   = FunctionDeclaration.new(-1, -1, "put_s",
                                     return_type, params,
                                     CompoundStatement.new(-1, -1, []))
    globals.put(name, decl, -1, -1)
  end

  def self.add_builtin_functions(globals)
    # void put_s(char s[]): prints the given string
    add_builtin(globals, "put_s", VoidType.new, [["s", CharType.new(true)]])

    # void get_s(char s[]): asks for a string input from keyboard and saves it in 's'
    add_builtin(globals, "get_s", VoidType.new, [["s", CharType.new(true)]])

    # void put_i(int i): prints the integer 'i'
    add_builtin(globals, "put_i", VoidType.new, [["i", INT]])

    # int get_i(): asks for an integer input from keyboard
    add_builtin(globals, "get_i", INT, [])

    # void put_d(double d): prints the float number 'd'
    add_builtin(globals, "put_d", VoidType.new, [["d", FLOAT]])

    # double get_d(): asks for a float input from keyboard
    add_builtin(globals, "get_d", FLOAT, [])

    # void put_c(char c): prints the character 'c'
    add_builtin(globals, "put_c", VoidType.new, [["c", CHAR]])

    # char get_c(): asks for a character input from keyboard
    add_builtin(globals, "get_c", CHAR, [])

    # double seconds(): returns a number of seconds (possibly decimal for a better precision)
    add_builtin(globals, "seconds", FLOAT, [])
  end
end
