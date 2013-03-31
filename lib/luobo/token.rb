## this class holds a block of carrot source code tokenized by the parser.
class Token
  attr_accessor :ln, :line, :indent_level, # raw line and line number
    :processor_name, :line_code, :blocks, :indent_level

  def initialize ln, line, indent_level, processor_name, line_code = '', block_open = false
    @ln, @line, @indent_level, @processor_name, @line_code = ln, line, indent_level, processor_name, line_code
    @blocks = Array.new if block_open
  end

  # add a line to current block args, separate each line with "\n"
  def add_block_code line
    raise "block not opened in line #{:ln}" unless block_open?
    line.chomp.split("\n").each do |ln| 
      @blocks << ln
    end
  end

  def has_block? 
    (@blocks and @blocks.size > 0) ? true : false
  end

  def block_open?
    @blocks.is_a?(Array)
  end

  def block_code
    has_block? ? @blocks.join("\n") : ""
  end

  def block_args
    YAML.load(block_code)
  end

  def line_args
    YAML.load(line_code)
  end
end
