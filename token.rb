class Token
    # code -> code/name
    # ct -> used for ID, CT_STRING (text), CT_INT, CT_CHAR (int), CT_REAL (double)
    # line -> the line in the input file
    attr_accessor @code, @ct, @line, @column

    def initialize(code, ct, line, column)
        @code = code
        @ct = ct
        @line = line
        @column = column
    end
end