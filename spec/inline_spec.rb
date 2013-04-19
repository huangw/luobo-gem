require "spec_helper"

class InlineLuobo < Luobo
  attr_accessor :token_stack, :dumps

  def dump contents;
    # p contents
    @dumps = Array.new unless @dumps 
    @dumps << contents 
  end

  def last_dump; @dumps[-1] if @dumps end
  
  def stack_size; @token_stack.size end

  def do_mark token
    "small mark"
  end

  def do_double token
    rslt = token.line_code.to_i * 2
    rslt.to_s
  end
end

describe InlineLuobo do
  
  context "convert inline content" do
    subject {InlineLuobo.new('-', STDOUT).process_line(1, 'upcase name ##MARK##')}
      
    its(:stack_size) { should eq(0) }
    its(:last_dump) { should eq("upcase name small mark") }
  end

  context "process inline argument" do
    subject {InlineLuobo.new('-', STDOUT).process_line(1, 'calculate ##DOUBLE: 4##')}
      
    its(:last_dump) { should eq("calculate 8") }
  end

  context "process tow inline processor" do
    subject {InlineLuobo.new('-', STDOUT).process_line(1, '##MARK## ##DOUBLE: 4##')}
      
    its(:last_dump) { should eq("small mark 8") }
  end
end
