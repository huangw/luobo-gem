

  
  # extend a loop be examples
  def expand_loop
    raise "no examples found for loop start on line #{@loop_start_ln}" unless @loop_examples.size > 0
    loop_n = 0
    @loop_examples.each do |exa|
      loop_n += 1
      # treat each loop example as a yaml var definition for the template
      rslt = Erubis::Eruby.new(@loop_template).result(YAML.load(exa))
      li = 0
      rslt.split("\n").each do |line|
        li += 1
        self.process_line line, @loop_start_ln + li, loop_n
      end
    end
    
    # clear up holders
    self.reset_loop
  end

  # add a new line to the example, separate examples to array
  def add_example_line line
    if /#{regex_new_example}/.match(line)
      # start a new loop example with a placeholder nil        
      @loop_examples << nil
    else
      raise "you need use '#{regex_new_example}' to start a loop example" unless @loop_examples.size > 0
      line.gsub!(/#{regex_example_head}/, '')
      @loop_examples[-1] = @loop_examples[-1] ? @loop_examples[-1] + "\n" + line : line
    end
  end

  def dump contents
    @output.print contents if contents
  end

  # travel up through the token stack, close all token with
  # indent level larger or equal to the parameter
  def close_stack indent_level
    source = ''
    while @token_stack.size > 0 and @token_stack[-1].indent_level >= indent_level
      if @token_stack.size > 1 
        @token_stack[-2].add_block_code self.convert(@token_stack[-1])
      else # this is the last token in the stack
        self.dump(self.convert(@token_stack[-1]))
      end
      @token_stack.pop
    end
  end

  # add a new line to the existing token if it requires block codes
  # or write the last token out before a new token
  # this function invokes after a loop expansion.
  def process_line line, ln, loop_n = 0
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

  # regex definition
  # -------------------------------
  def regex_line_comments; "" end # if defined, all 

  def regex_proc_head
    regex_line_comments + '\s*'
  end

  def regex_proc_name
    "(?<proc_name_>[A-Z][A-Z0-9_]+)"
  end

  def regex_proc_end
    "\s*\:?\s*"
  end

  def regex_block_start
    "\s*(?<block_start_>\-\>)?\s*$"
  end

  # example loop related:
  def regex_loop_line
    "^" + regex_proc_head + "\%\s*\=\=\=\=+\s*"
  end

  def regex_new_example
    "^" + regex_proc_head + "\%\s*\-\-\-\-+\s*"
  end

  def regex_example_head
    "^" + regex_proc_head + "\%\s*"
  end

  def regex_example_line
    "^" + regex_proc_head + "\%\s*(?<example_>.+)\s*"
  end

  # ===============================

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
  # -------------------------------
  def do_setup; "" end     # call before all tokens
  def do_cleanup; "" end   # call after all tokens

  def indent token # TODO depreciate
    " " * token.indent_level
  end

  def do__raw token
    if token.line_code.size > 0
      indent(token) + token.line_code.gsub(/^\s*/, "") + "\n"
    else
      ""
    end
  end

  def do__missing token
    src = indent(token) + token.line
    src += token.block_code + "\n" if token.block_code
  end
  # ===============================

  # parse the file, whenever found a token, convert
  def process
    in_loop = false
    in_example = false

    fh = File.open(@source_file, 'r:utf-8')
    self.dump(self.do_setup)

    fh.each do |line|
      line.chomp!
      line.gsub!("\t", "  ") # convert tab to 2 spaces
      
      # interrupt for loops
      if /#{regex_loop_line}/.match(line) 
        in_loop = true
        @loop_start_ln = $.
        next # break further processing if detecting a loop
      end

      # expand and end current loop 
      if in_example
        unless /#{regex_example_head}/.match(line) # if the line not marked as an example
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

    # close all remain stacks (if any)
    self.close_stack 0

    self.dump(self.do_cleanup)
    @output.close if @output_file
    self
  end


