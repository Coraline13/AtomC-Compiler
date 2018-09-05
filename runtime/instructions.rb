class Instruction
  def execute(vm)
    raise NotImplementedError
  end
end

class ADD < Instruction
  def execute(vm)
    b = vm.stack.pop
    a = vm.stack.pop
    vm.stack.push(a + b)
    vm.ip += 1

    puts "ADD: #{a} + #{b} = #{a + b}"
  end
end

class SUB < Instruction
  def execute(vm)
    b = vm.stack.pop
    a = vm.stack.pop
    vm.stack.push(a - b)
    vm.ip += 1

    puts "ADD: #{a} - #{b} = #{a - b}"
  end
end

class MUL < Instruction
  def execute(vm)
    b = vm.stack.pop
    a = vm.stack.pop
    vm.stack.push(a * b)
    vm.ip += 1

    puts "ADD: #{a} * #{b} = #{a * b}"
  end
end

class DIV < Instruction
  def execute(vm)
    b = vm.stack.pop
    a = vm.stack.pop
    vm.stack.push(a / b)
    vm.ip += 1

    puts "ADD: #{a} / #{b} = #{a / b}"
  end
end

class AND < Instruction

end

class OR < Instruction

end

class EQ < Instruction

end

class NOTEQ < Instruction

end

class GREATER < Instruction

end

class GREATEREQ < Instruction

end

class LESS < Instruction

end

class LESSEQ < Instruction

end

class NOT < Instruction

end

class NEG < Instruction

end

class JT < Instruction

end

class JF < Instruction

end

class JMP < Instruction

end

class NOP < Instruction

end

class LOAD < Instruction

end

class LEAFP < Instruction

end

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

class STORE < Instruction

end

class CALL < Instruction

end

class ENTER < Instruction

end

class DROP < Instruction

end

class OFFSET < Instruction

end

class INSERT < Instruction

end

class RETFP < Instruction

end

class CALLEXT < Instruction

end

class CAST < Instruction
  
end

class HALT < Instruction
  def execute(vm)
    vm.stopped = true

    puts "HALT"
  end
end
