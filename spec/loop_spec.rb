require "spec_helper"

class LoopLuobo < Luobo
  attr_accessor :token_stack, :dumps

  def regex_line_comment; "\s*#+\s?" end # use # as line comments

  def dump contents;
    # p contents
    @dumps = Array.new unless @dumps 
    @dumps << contents 
  end

  def last_dump; @dumps[-1] if @dumps end
  
  def stack_size; @token_stack.size end

  def do_send token
    "send_out: " + token.line_code + "\n" + token.block_code 
  end
end

describe LoopLuobo do

  context "Simple examples" do
    subject(:lb){ LoopLuobo.new('examples/loop_example.rb', STDOUT) }
    it "expands variables inside" do
      lb.process!
      lb.dumps[-3].should eq("var = good!")
      lb.dumps[-2].should eq("var = also good!")
    end

  end

end
