require "yaml"
require "erubis"
#require "luobo/token"
# converter class
class Luobo

  def initialize file, output
    @source_file = file
      
    # handle output file or output IO 
    if output.is_a?(IO)
      @output = output
    elsif output.is_a?(String)
      @output_file = output
      @output = File.open(output, "w")
    end

    # initialize a array to hold tokens waiting for process:
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

  # command handler
  def self.convert! file, output
    self.new(file, output).process!
  end

end
