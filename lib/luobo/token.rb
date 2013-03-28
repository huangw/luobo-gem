module Luobo
  ## this class holds a block of carrot source code tokenized by the parser.
  class Token
    attr_accessor :ln, :line, :indent_level, :processor_name, :line_code, :block_code

    def initialize ln, line, indent_level, processor_name, line_code, block_code, proc_head = ''
      @ln, @line, @indent_level, @processor_name, @line_code, @block_code, @proc_head = ln, line, indent_level, processor_name, line_code, block_code, proc_head
    end
  
    # add a line to current block args, separate each line with "\n"
    def add_block_code line
      line.chomp!
      unless processor_name == '_raw'
        line.gsub!(/^#{@proc_head}/, '')
      end

      if self.block_code 
        self.block_code += "\n" + line
      else
        self.block_code = line
      end
    end

    def block_args
      YAML.load(block_code)
    end

    def line_args
      YAML.load(line_code)
    end
  end
end
