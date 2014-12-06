
class SingyoFuck
  require 'yaml'

  @@singyo  = File.read("./singyo.txt").gsub("\n","")
  @@table   = @@singyo.split("").sort.uniq.unshift(" ")

  attr_accessor :code
  attr_reader :pointer, :memory, :out

  def initialize(opts = {})
    @code = opts[:code] || ""
    @pointer = 0
    @memory = Array.new((opts[:memory_size] || 300), 0)
    @loops = []
    @grammer = YAML.load(File.read((opts[:grammer_file] || "./grammer.yml")))
  end

  def char_to_command(char)
    @grammer.each do |command, chars|
      return command.to_sym if chars.include? char
    end
    return nil
  end

  def run
    @ip = 0
    @out = ""
    
    while @ip < @code.length
      cmd = char_to_command(@code[@ip])

      if cmd.nil?
        next_ip
      else
        self.send(cmd)
      end
    end
    
    @out
  end

  private

  def plus
    @memory[@pointer] += 1
    next_ip
  end
  
  def minus
    @memory[@pointer] -= 1
    next_ip
  end
  
  def forward
    @pointer += 1
    next_ip
  end
  
  def backward
    @pointer -= 1
    next_ip
  end
  
  def begin_loop
    if @memory[@pointer] == 0
      loop_count = 1
      while loop_count > 0
        next_ip
        case char_to_command(@code[@ip])
        when :begin_loop
          loop_count += 1
        when :end_loop
          loop_count -= 1
        end
      end
      next_ip
    else
      @loops.push(@ip)
      next_ip
    end
  end
  
  def end_loop
    if @memory[@pointer] == 0
      @loops.pop
      next_ip
    else
      @ip = @loops.pop
    end
  end
  
  def output
    ch = @memory[@pointer].chr
    print ch
    @out << ch
    next_ip
  end
  
  def input
    @memory[@pointer] = gets[0].ord
    next_ip
  end

  def output_singyo
    ch = @@table[@memory[@pointer]]
    print ch
    @out << ch
    next_ip
  end

  def input_singyo
    @memory[@pointer] = @@table.index(gets[0]) || 0
    next_ip
  end

  def next_ip
    @ip += 1
  end
end

