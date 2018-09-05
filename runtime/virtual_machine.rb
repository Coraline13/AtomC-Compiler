require_relative 'instructions'
require_relative 'stack'

class VirtualMachine
  # sp - stack pointer
  # fp - frame pointer
  # ip - instruction pointer
  attr_reader :stack, :sp
  attr_accessor :ip, :stopped

  def initialize(instructions)
    @instructions = instructions
    @stack = Stack.new
    @fp    = 0
    @ip    = 0
    @stopped = false
  end

  def run
    until @stopped do
      @instructions[@ip].execute(self)
    end

    @stack.print
  end
end

test = [PUSHCT.new(5), PUSHCT.new(69), ADD.new, HALT.new]
vm = VirtualMachine.new(test)
vm.run
