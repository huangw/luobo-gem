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

  # handle convert for each token
  def convert token
    pname = "do_" + token.processor_name.downcase
    if self.respond_to?(pname)
      self.send(pname.to_sym, token)
    else
      self.do__missing(token)
    end
  end

  # processor converters and dump callbacks
  def do_setup; "" end     # call before all tokens
  def do_cleanup; "" end   # call after all tokens

  def do__raw token
    if token.line_code and token.line_code.size > 0
      token.line_code#.gsub(/^\s*/, "") + "\n"
    else
      ""
    end
  end

  def do__missing token
    src = token.line
    src += token.block_code + "\n" if token.block_code
    src
  end

  # travel up through the token stack, close all token with
  # indent level larger or equal to the parameter
  def close_stack indent_level
    source = ''
    while @token_stack.size > 0 and @token_stack[-1].indent_level >= indent_level
      if @token_stack.size > 1 # if this is not the last token, add to parents
        @token_stack[-2].add_block_code self.convert(@token_stack[-1])
      else # this is the last token in the stack
        self.dump self.convert(@token_stack[-1])
      end
      @token_stack.pop
    end
  end

  # create a token from line
  def tokenize line, ln, loop_n

  end

  # add a new line to the existing token if it requires block codes
  # or write the last token out before a new token
  # this function invokes after a loop expansion or if the line
  # is not in any examples and loop templates.
  def process_line line, ln, loop_n = 0
    # create a token, with processor name
    token = self.tokenize(line, ln, loop_n)
  
    # based on the the token indent level, close token stack if any
    
    # add token and then close it unless it opens a block
    
  end

  def process_line_ line, ln, loop_n = 0
    indent_level = 0
    nline = line.gsub(/[\-#\/]/, '')
    if /^(?<head_space_>\s+)/ =~ nline
      indent_level = head_space_.size
    end

    # try to close stack if applicable
    self.close_stack indent_level

    # starts a named_processor or starts a raw_processor 
    processor_name = '_raw'
    line_code = line.gsub(/^\s*/,"")
    block_code = nil
    if matches = /#{regex_proc_line}/.match(line) 
      proc_head = matches["proc_head_"]
      processor_name = matches["proc_name_"]
      line_code = matches["line_code_"]
      block_code = '' if line_code.gsub!(/#{regex_block_start}/, '')  
    end
    
    @token_stack << Token.new(ln, line, indent_level, processor_name, line_code, block_code, proc_head)

    # unless it opens for block code close it soon, 
    # (dedicate the dump function to close_stack())
    self.close_stack indent_level unless block_code
  end

  # process 
  def process!    
    fh = File.open(@source_file, 'r:utf-8')
    in_loop = false
    in_example = false
    fh.each do |line|
      line.chomp!
      line.gsub!("\t", "  ") # convert tab to 2 spaces

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
    self # return self for method chains
  end

  # command handler
  def self.convert! file, output
    self.new(file, output).process!
  end

end
