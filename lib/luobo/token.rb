## this class holds a block of carrot source code tokenized by the parser.
class Token
  attr_accessor :ln, :line, # raw codes without heading line comment marker
    :processor_name, :line_code, :blocks, :indent_level

  def initialize ln, line, processor_name, line_code = '', block_open = false
    @ln, @line, @processor_name, @line_code, @block_open = ln, line, processor_name, line_code, block_open
    @indent_level = 0
    @indent_level = space_.size if /^(?<space_>\s+)/ =~ line
    @blocks = Array.new if block_open
  end

  # add a line to current block args, separate each line with "\n"
  def add_block_code line
    raise "block not opened in line #{:ln}" unless block_open?
    @blocks << line.chomp
  end

  def block_open?
    @block_open
  end

  def block_code
    @blocks ? @blocks.join("\n") : ""
  end

  def block_args
    YAML.load(block_code)
  end

  def line_args
    YAML.load(line_code)
  end
end
