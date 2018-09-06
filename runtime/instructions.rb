class Instruction
  def execute(vm)
    raise NotImplementedError
  end
end

# [a, b] -> [a + b]
class ADD < Instruction
  def execute(vm)
    b = vm.stack.pop
    a = vm.stack.pop
    vm.stack.push(a + b)
    vm.ip += 1
    puts "ADD: #{a} + #{b} = #{a + b}"
  end
end

# [a, b] -> [a - b]
class SUB < Instruction
  def execute(vm)
    b = vm.stack.pop
    a = vm.stack.pop
    vm.stack.push(a - b)
    vm.ip += 1
    puts "SUB: #{a} - #{b} = #{a - b}"
  end
end

# [a, b] -> [a * b]
class MUL < Instruction
  def execute(vm)
    b = vm.stack.pop
    a = vm.stack.pop
    vm.stack.push(a * b)
    vm.ip += 1
    puts "MUL: #{a} * #{b} = #{a * b}"
  end
end

# [a, b] -> [a / b]
class DIV < Instruction
  def execute(vm)
    b = vm.stack.pop
    a = vm.stack.pop
    vm.stack.push(a / b)
    vm.ip += 1
    puts "DIV: #{a} / #{b} = #{a / b}"
  end
end

# [a, b] -> [a && b]
class AND < Instruction
  def execute(vm)
    b = vm.stack.pop
    a = vm.stack.pop
    if a && b
      vm.stack.push(1)
      puts "AND: #{a} && #{b} = 1"
    else
      vm.stack.push(0)
      puts "AND: #{a} && #{b} = 0"
    end
    vm.ip += 1
  end
end

# [a, b] -> [a || b]
class OR < Instruction
  def execute(vm)
    b = vm.stack.pop
    a = vm.stack.pop
    if a || b
      vm.stack.push(1)
      puts "OR: #{a} || #{b} = 1"
    else
      vm.stack.push(0)
      puts "OR: #{a} || #{b} = 0"
    end
    vm.ip += 1
  end
end

# [a, b] -> [a == b]
class EQ < Instruction
  def execute(vm)
    b = vm.stack.pop
    a = vm.stack.pop
    if a == b
      vm.stack.push(1)
      puts "EQ: #{a} == #{b} = 1"
    else
      vm.stack.push(0)
      puts "EQ: #{a} == #{b} = 0"
    end
    vm.ip += 1
  end
end

# [a, b] -> [a != b]
class NOTEQ < Instruction
  def execute(vm)
    b = vm.stack.pop
    a = vm.stack.pop
    if a != b
      vm.stack.push(1)
      puts "NOTEQ: #{a} != #{b} = 1"
    else
      vm.stack.push(0)
      puts "NOTEQ: #{a} != #{b} = 0"
    end
    vm.ip += 1
  end
end

# [a, b] -> [a > b]
class GREATER < Instruction
  def execute(vm)
    b = vm.stack.pop
    a = vm.stack.pop
    if a > b
      vm.stack.push(1)
      puts "GREATER: #{a} > #{b} = 1"
    else
      vm.stack.push(0)
      puts "GREATER: #{a} > #{b} = 0"
    end
    vm.ip += 1
  end
end

# [a, b] -> [a >= b]
class GREATEREQ < Instruction
  def execute(vm)
    b = vm.stack.pop
    a = vm.stack.pop
    if a >= b
      vm.stack.push(1)
      puts "GREATEREQ: #{a} >= #{b} = 1"
    else
      vm.stack.push(0)
      puts "GREATEREQ: #{a} >= #{b} = 0"
    end
    vm.ip += 1
  end
end

# [a, b] -> [a < b]
class LESS < Instruction
  def execute(vm)
    b = vm.stack.pop
    a = vm.stack.pop
    if a < b
      vm.stack.push(1)
      puts "LESS: #{a} < #{b} = 1"
    else
      vm.stack.push(0)
      puts "LESS: #{a} < #{b} = 0"
    end
    vm.ip += 1
  end
end

# [a, b] -> [a <= b]
class LESSEQ < Instruction
  def execute(vm)
    b = vm.stack.pop
    a = vm.stack.pop
    if a <= b
      vm.stack.push(1)
      puts "LESSEQ: #{a} <= #{b} = 1"
    else
      vm.stack.push(0)
      puts "LESSEQ: #{a} <= #{b} = 0"
    end
    vm.ip += 1
  end
end

# [a] -> [!a]
class NOT < Instruction
  def execute(vm)
    a = vm.stack.pop
    if a.zero?
      vm.stack.push(1)
      puts "NOT: #{a} => 1"
    else
      vm.stack.push(0)
      puts "NOT: #{a} => 0"
    end
    vm.ip += 1
  end
end

# [a] -> [-a]
class NEG < Instruction
  def execute(vm)
    a = vm.stack.pop
    vm.stack.push(-a)
    vm.ip += 1
    puts "NEG: #{a} => #{-a}"
  end
end

# TODO: pentru chestii cu valoare de adevar, retin pe stiva 0 sau false?

# [a] -> []
# Daca pe stiva e o valoare adevarata (!= 0), transfera executia la adresa data (IP = addr).
# Altfel continua executia cu urmatoarea instructiune.
class JT < Instruction
  attr_reader :addr

  def initialize(addr)
    @addr = addr
  end

  def execute(vm)
    a = vm.stack.pop
    if a.zero?
      vm.ip += 1
      puts "JT: #{a} - false"
    else
      vm.ip = @addr
      puts "JT: #{a} - true"
    end
  end
end

# [a] -> []
# Daca pe stiva e o valoare falsa (== 0), transfera executia la adresa data (IP = addr).
# Altfel continua executia cu urmatoarea instructiune.
class JF < Instruction
  attr_reader :addr

  def initialize(addr)
    @addr = addr
  end

  def execute(vm)
    a = vm.stack.pop
    if a.zero?
      vm.ip = @addr
      puts "JF: #{a} - false"
    else
      vm.ip += 1
      puts "JF: #{a} - true"
    end
  end
end

#  Transfera executia la adresa data (IP = addr)
class JMP < Instruction
  attr_reader :addr

  def initialize(addr)
    @addr = addr
  end

  def execute(vm)
    vm.ip = @addr
    puts "JMP: addr = #{@addr}"
  end
end

# Nu face nimic, doar avanseaza la urmatoarea instructiune (no operation)
class NOP < Instruction
  def execute(vm)
    vm.ip += 1
  end
end

# [addr] -> [a]
# Pune pe stiva "a" de n octeti de la adresa "addr" (sizeof(a) = n)
class LOAD < Instruction
#TODO
end

# TODO: LEAFP?
# class LEAFP < Instruction
#
# end

# [] -> [ct]
# Depune constanta data ca argument
class PUSHCT < Instruction
  attr_reader :ct

  def initialize(ct)
    @ct = ct
  end

  def execute(vm)
    vm.stack.push(@ct)
    vm.ip += 1
    puts "PUSHCT: #{@ct}"
  end
end

# [addr, a] -> []
# Transfera de pe stiva "a" de n octeti in memorie la adresa "addr" (sizeof(a) = n)
class STORE < Instruction
  attr_reader :n

  def initialize(n)
    @n = n
  end

  def execute(vm)
#TODO
  end
end

# [] -> [retAddr]
# Depune adresa de revenire din apel (adresa urmatoarei instructiuni de dupa CALL)
# si transfera executia la "addr" (IP = addr)
class CALL < Instruction
  attr_reader :addr

  def initialize(addr)
    @addr = addr
  end

  def execute(vm)
    vm.stack.push(vm.ip + 1)
    vm.ip = @addr
  end
end

# [] -> [FP, a]
# Depune FP, atribuie lui FP valoarea lui SP (FP = SP), adauga n octeti la SP (SP += n) (sizeof(a) = n)
class ENTER < Instruction
  attr_reader :n

  def initialize(n)
    @n = n
  end

  def execute(vm)
#TODO
  end
end

# [a] -> []
# Sterge n octeti din varful stivei (sizeof(a) = n)
class DROP < Instruction
  attr_reader :n

  def initialize(n)
    @n = n
  end

  def execute(vm)
#TODO
  end
end

# [addr, n] -> [addr + n]
# Aduna la "addr" "n" octeti. "n" trebuie sa fie de tip "int"
class OFFSET < Instruction
#TODO
end

# [a, b] -> [b, a, b]
# Insereaza (duplica) la SP - i n octeti din varful stivei
# (sizeof(b) = n, sizeof(a) + sizeof(b) = i)
class INSERT < Instruction
#TODO
end

# [args, retAddr, oldFP, locals, retVal] -> [retVal]
# Elimina din stiva tot articolul de activare a unei functii (args...locals),
# pune valoarea de return "retVal" (daca nr == 0 inseamna ca functia este "void"),
# reface vechea valoare a lui FP (FP = oldFP) si transfera executia la "retAddr" (IP = retAddr)
# (sizeof(args) = na, sizeof(retVal) = nr)
class RET < Instruction
#TODO
end

# [arg1, arg2, ..., argn] -> [retValue]
# Apeleaza o functie C care este compilata in cadrul MV (functie predefinita).
# Functia trebuie sa fie de forma "void f()".
# Ea trebuie sa-si preia argumentele de pe stiva si daca e cazul sa depuna valoarea returnata
class CALLEXT < Instruction
  attr_reader :addr

  def initialize(addr)
    @addr = addr
  end

  def execute(vm)
#TODO
  end
end

# TODO: CAST?
# class CAST < Instruction
#
# end

# Incheie executia MV
class HALT < Instruction
  def execute(vm)
    vm.stopped = true

    puts "HALT"
  end
end
