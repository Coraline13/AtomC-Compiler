module TokenType
  TK_ID = :ID

  TK_BREAK  = :BREAK
  TK_CHAR   = :CHAR
  TK_DOUBLE = :DOUBLE
  TK_ELSE   = :ELSE
  TK_FOR    = :FOR
  TK_IF     = :IF
  TK_INT    = :INT
  TK_RETURN = :RETURN
  TK_STRUCT = :STRUCT
  TK_VOID   = :VOID
  TK_WHILE  = :WHILE

  TK_CT_INT    = :CT_INT
  TK_CT_REAL   = :CT_REAL
  TK_CT_CHAR   = :CT_CHAR
  TK_CT_STRING = :CT_STRING

  TK_COMMA     = :COMMA
  TK_SEMICOLON = :SEMICOLON
  TK_LPAR      = :LPAR
  TK_RPAR      = :RPAR
  TK_LBRACKET  = :LBRACKET
  TK_RBRACKET  = :RBRACKET
  TK_LACC      = :LACC
  TK_RACC      = :RACC

  TK_ADD       = :ADD
  TK_SUB       = :SUB
  TK_MUL       = :MUL
  TK_DIV       = :DIV
  TK_DOT       = :DOT
  TK_AND       = :AND
  TK_OR        = :OR
  TK_NOT       = :NOT
  TK_ASSIGN    = :ASSIGN
  TK_EQUAL     = :EQUAL
  TK_NOTEQ     = :NOTEQ
  TK_LESS      = :LESS
  TK_LESSEQ    = :LESSEQ
  TK_GREATER   = :GREATER
  TK_GREATEREQ = :GREATEREQ

  TK_END = :END

  $space            = lambda { |x| " \t\n\r".include?(x) }
  $letter           = lambda { |x| "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_".include?(x) }
  $id               = lambda { |x| "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_0123456789".include?(x) }
  $digit            = lambda { |x| "0123456789".include?(x) }
  $nonzero_digit    = lambda { |x| "123456789".include?(x) }
  $e                = lambda { |x| "Ee".include?(x) }
  $plus_minus       = lambda { |x| "+-".include?(x) }
  $zero_to_seven    = lambda { |x| "01234567".include?(x) }
  $eight_nine       = lambda { |x| "89".include?(x) }
  $hexa             = lambda { |x| "0123456789abcdefABCDEF".include?(x) }
  $not_asterisk     = lambda { |x| x != "*" }
  $new_line         = lambda { |x| "\n\r\0".include?(x) }
  $not_new_line     = lambda { |x| !("\n\r\0".include?(x)) }
  $not_end_com      = lambda { |x| x != "/" }
  $special_char     = lambda { |x| "abfnrtv'?\"\\0".include?(x) }
  $not_quote        = lambda { |x| !("'\\".include?(x)) }
  $not_double_quote = lambda { |x| !("\"\\".include?(x)) }

  TRANSITIONS = {
      # space
      [0, $space] => [0, nil],
      # ID
      [0, $letter] => [1, nil],
      [1, $id]     => [1, nil],
      [1, nil]     => [2, TK_ID],
      # ASSIGN & EQUAL
      [0, '='] => [3, nil],
      [3, nil] => [4, TK_ASSIGN],
      [3, '='] => [5, TK_EQUAL],
      # ADD
      [0, '+'] => [6, TK_ADD],
      # SUB
      [0, '-'] => [7, TK_SUB],
      # MUL
      [0, '*'] => [8, TK_MUL],
      # DOT
      [0, '.'] => [9, TK_DOT],
      # AND
      [0, '&']  => [10, nil],
      [10, '&'] => [11, TK_AND],
      # OR
      [0, '|']  => [12, nil],
      [12, '|'] => [13, TK_OR],
      # NOT & NOTEQ
      [0, '!']  => [14, nil],
      [14, nil] => [15, TK_NOT],
      [14, '='] => [16, TK_NOTEQ],
      # LESS & LESSEQ
      [0, '<']  => [17, nil],
      [17, nil] => [18, TK_LESS],
      [17, '='] => [19, TK_LESSEQ],
      # GREATER & GREATEREQ
      [0, '>']  => [20, nil],
      [20, nil] => [21, TK_GREATER],
      [20, '='] => [22, TK_GREATEREQ],
      # COMMA
      [0, ','] => [23, TK_COMMA],
      # SEMICOLON
      [0, ';'] => [24, TK_SEMICOLON],
      # LPAR
      [0, '('] => [25, TK_LPAR],
      # RPAR
      [0, ')'] => [26, TK_RPAR],
      # LBRACKET
      [0, '['] => [27, TK_LBRACKET],
      # RBRACKET
      [0, ']'] => [28, TK_RBRACKET],
      # LACC
      [0, '{'] => [29, TK_LACC],
      # RACC
      [0, '}'] => [30, TK_RACC],
      # DIV & comment
      [0, '/']            => [31, nil],
      [31, nil]           => [32, TK_DIV],
      [31, '/']           => [33, nil],
      [33, $not_new_line] => [33, nil],
      [33, $new_line]     => [0, nil],
      [31, '*']           => [34, nil],
      [34, $not_asterisk] => [34, nil],
      [34, '*']           => [35, nil],
      [35, '*']           => [35, nil],
      [35, $not_end_com]  => [34, nil],
      [35, '/']           => [0, nil],
      # CT_CHAR
      [0, '\'']           => [36, nil],
      [36, '\\']          => [37, nil],
      [37, $special_char] => [38, nil],
      [36, $not_quote]    => [38, nil],
      [38, '\'']          => [39, TK_CT_CHAR],
      # CT_STRING
      [0, '"']                => [40, nil],
      [40, '\\']              => [41, nil],
      [41, $special_char]     => [40, nil],
      [40, $not_double_quote] => [40, nil],
      [40, '"']               => [42, TK_CT_STRING],
      # CT_INT
      [0, $nonzero_digit]  => [43, nil],
      [43, $digit]         => [43, nil],
      [43, nil]            => [44, TK_CT_INT],
      [0, '0']             => [45, nil],
      [45, nil]            => [46, nil],
      [46, $zero_to_seven] => [46, nil],
      [46, nil]            => [44, TK_CT_INT],
      [45, 'x']            => [47, nil],
      [47, $hexa]          => [48, nil],
      [48, $hexa]          => [48, nil],
      [48, nil]            => [44, TK_CT_INT],
      # CT_REAL
      [43, '.']         => [49, nil],
      [45, '.']         => [49, nil],
      [45, $eight_nine] => [50, nil],
      [46, $eight_nine] => [50, nil],
      [43, $e]          => [51, nil],
      [49, $digit]      => [50, nil],
      [50, $digit]      => [50, nil],
      [50, nil]         => [54, TK_CT_REAL],
      [50, $e]          => [51, nil],
      [51, $plus_minus] => [52, nil],
      [52, $digit]      => [53, nil],
      [51, $digit]      => [53, nil],
      [53, $digit]      => [53, nil],
      [53, nil]         => [54, TK_CT_REAL]
  }

  def self.transition(current_state, ch)
    default_transition = nil

    TRANSITIONS.each do |key, value|
      next unless key[0] == current_state

      if key[1].nil?
        default_transition = value
      elsif key[1].respond_to?(:call) && key[1].call(ch)
        return value, true
      elsif key[1] == ch
        return value, true
      end
    end

    return default_transition, false
  end
end