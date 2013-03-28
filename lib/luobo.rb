require "yaml"
require "erubis"

require "luobo/token"

class Luobo
  
  def initialize file, output
    @source_file = file
      
    if output.is_a?(IO)
      @output = output
    elsif output.is_a?(String)
      @output_file = output
      @output = File.open(output, "w")
    end

    # initialize:
    @token_stack = Array.new

    # initialize loop template and examples
    self.reset_loop
  end

  # initialize the holders for a example based loop,
  # or reset after a loop expansion
  def reset_loop
    @loop_start_ln = 0
    @loop_template = nil
    @loop_examples = Array.new
  end

  # extend a loop be examples
  def expand_loop
    raise "no examples found for loop start on line #{@loop_start_ln}" unless @loop_examples.size > 0
    loop_n = 0
    @loop_examples.each do |exa|
      loop_n += 1
      vars = YAML.load(exa)
      # erubie the template
      rslt = Erubis::Eruby.new(@loop_template).result(vars)
      li = 0
      rslt.split("\n").each do |line|
        li += 1
        self.process_line line, @loop_start_ln + li, loop_n
      end
    end
    
    # clear up holders
    self.reset_loop
  end

  def dump contents
    @output.print contents if contents
  end

  # regex definition
  # ----------------------------------------------------------------
  def regex_line_comments; "" end # if defined, all 

  # ================================================================

  # parse the file, whenever found a token, use driver to convert
  # it and send to output
  def process
    in_loop = false
    in_example = false

    fh = File.open(@source_file, 'r:utf-8')
    fh.each do |line|
      line.chomp!
      line.gsub!("\t", "  ") # convert tab to 2 spaces
      
      # interrupt for loops
      if matches = /#{regex_loop_line}/.match(line)
        in_loop = true
        @loop_start_ln = $.
        next
      end

      # expand and end current loop 
      if in_example
        unless /#{regex_example_head}/.match(line)
          self.expand_loop
          in_example = false
          in_loop = false
        end
      end

      # end a loop template and start a loop example
      if in_loop
        in_example = true if /#{regex_example_head}/.match(line)
      end

      # dispatch the current line to different holders
      if in_example
        self.add_example_line line
      elsif in_loop
        @loop_template = @loop_template ? @loop_template + "\n" + line : line
      else
        self.process_line line, $.
      end
    end
    fh.close

    # do not forget expand last loop if it reaches over EOF.
    self.expand_loop if @loop_start_ln > 0

    # close all remain stacks
    self.close_stack 0

    self.dump(@driver.exit)
    @output.close if @output_file
    self
  end

  # command handler
  def self.convert file, output
    lb = self.new(file, output).process
  end

end
