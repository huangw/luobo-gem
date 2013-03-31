require "spec_helper"

class OpLuobo < Luobo
  attr_accessor :token_stack, :dumps

  def dump contents;
    p contents
    @dumps = Array.new unless @dumps 
    @dumps << contents 
  end

  def last_dump; @dumps[-1] if @dumps end
  
  def stack_size; @token_stack.size end

  def do_send token
    "send_out: " + token.line_code + "\n" + token.block_code 
  end
end

describe OpLuobo do
  
  context "no open block and no indent" do
    subject {OpLuobo.new('-', STDOUT).process_line(1, "Send out an output")}
      
    its(:stack_size) { should eq(0) }
    its(:last_dump) { should eq("Send out an output") }
  end

  context "with an open block and no indent" do
    subject(:lb) {OpLuobo.new('-', STDOUT).process_line(1, "SEND: out an output ->")}
      
    its(:stack_size) { should eq(1) }
    its(:last_dump) { should be_nil }

    it "holds a block line" do
      lb.process_line(2, "  block with indent")
      lb.stack_size.should eq(1)
      lb.last_dump.should be_nil

      lb.process_line(3, "This is in the outside")
      lb.stack_size.should eq(0)
      lb.last_dump.should eq("This is in the outside")
      lb.dumps[-2].should eq("send_out: out an output\n  block with indent")
    end
  end

  context "with two indented block" do
    subject(:lb) {OpLuobo.new('-', STDOUT).process_line(1, "SEND: out an output ->")}
    
    it "holds all block lines" do
      lb.process_line(2, "  block with indent")
      lb.process_line(3, "    block with more indent")
      lb.process_line(4, "This is in the outside")
      lb.stack_size.should eq(0)
      lb.last_dump.should eq("This is in the outside")
      lb.dumps[-2].should eq("send_out: out an output\n  block with indent\n    block with more indent")
    end
      
  end

  context "with nested indented block" do
    subject(:lb) {OpLuobo.new('-', STDOUT).process_line(1, "SEND: out an output ->")}

    it "process from the last block" do
      lb.process_line(2, "  block with indent")
      lb.process_line(3, "    SEND: more lines to send ->")
      lb.process_line(4, "      an inside send line")
      lb.process_line(5, "    still in the first block")      
      lb.process_line(6, "close all stack")

      lb.stack_size.should eq(0)
      lb.last_dump.should eq("close all stack")
      lb.dumps[-2].should eq("send_out: out an output\n  block with indent\nsend_out: more lines to send\n      an inside send line\n    still in the first block")
    end

  end

end
