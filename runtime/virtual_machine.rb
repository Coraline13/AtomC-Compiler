require_relative 'instructions'
require_relative 'stack'

class VirtualMachine
  # fp - frame pointer
  # ip - instruction pointer
  attr_reader :stack
  attr_accessor :ip, :stopped

  def initialize(instructions)
    @instructions = instructions
    @stack        = Stack.new
    @fp           = 0
    @ip           = 0
    @stopped      = false
  end

  def run
    until @stopped do
      @instructions[@ip].execute(self)
    end

    @stack.print
  end
end

ex = [PUSHCT.new(50), PUSHCT.new(12), DIV.new, PUSHCT.new(4), SUB.new, NOT.new, HALT.new]

test = []
v    = 0
test << PUSHCT.new(v)
test << PUSHCT.new(3)
test << STORE.new(1)
loop_start = test.length
test << LOAD.new(1)
test << CALLEXT.new("put_i")
test << PUSHCT.new(v)
test << PUSHCT.new(v)
test << LOAD.new(1)
test << PUSHCT.new(1)
test << SUB.new
test << STORE.new(1)
test << PUSHCT.new(v)
test << LOAD.new(1)
test << JT.new(loop_start)
test << HALT.new

vm = VirtualMachine.new(test)
100.times { vm.stack << 0 }
vm.run
