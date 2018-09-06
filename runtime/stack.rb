class Stack
  attr_accessor :sp

  def initialize
    @data = []
    # sp - stack pointer
    @sp   = 0
  end

  def push(value)
    @data.push(value)
  end

  alias_method :"<<", :push

  def pop
    raise "Stack is empty" if is_empty?
    @data.pop
  end

  def is_empty?
    @data.length == 0
  end

  def sp
    @data.length
  end

  def sp=(value)
    @data = @data[0, value]
  end

  def read_from(addr, n)
    @data[addr, addr + n]
  end

  def write_at(addr, values)
    values.each do |value|
      @data[addr] = value
      addr        += 1
    end
  end

  def print
    puts("stack: #{@data}")
  end
end
