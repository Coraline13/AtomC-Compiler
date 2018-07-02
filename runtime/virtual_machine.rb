class VirtualMachine
  # sp - stack pointer
  attr_reader :stack, :sp, :stack_after

  def initialize
    @stack = Stack.new
    @sp = 0
  end

  def pushd

  end
end
