class Stack
  def initialize
    @data = []
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

  def print
    puts("stack: #{@data}")
  end
end
