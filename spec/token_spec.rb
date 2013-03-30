require "spec_helper"

class LuaToken < Luobo
  def regex_line_comment; "\s*\-\-+\s" end
  def dump contents; contents end # directly return
end

class RubyToken < Luobo
  def regex_line_comment; "\s*#+\s" end
  def dump contents; contents end
end

describe Luobo do
  context "without line comment marker" do
    subject (:lb) do
      Luobo.new('-', STDOUT)
    end

    it "return a token without indent" do
      token = lb.tokenize(1, "PROCNAME: proc line code")
      token.is_a?(Token).should be_true
      token.processor_name.should eq("PROCNAME")
      token.indent_level.should eq(0)
      token.ln.should eq(1)
      token.line.should eq("PROCNAME: proc line code")
      token.line_code.should eq("proc line code")
      token.has_block?.should be_false
      token.block_code.should eq("")
      token.block_open?.should be_false
    end

    it "return a token with indent" do
      token = lb.tokenize(1, "  PROCNAME: proc line code")
      token.processor_name.should eq("PROCNAME")
      token.indent_level.should eq(2)
      token.line_code.should eq("proc line code")
      token.has_block?.should be_false
      token.block_code.should eq("")
      token.block_open?.should be_false
    end

    it "return a token with block open" do
      token = lb.tokenize(1, "PROCNAME2: proc line code ->")
      token.processor_name.should eq("PROCNAME2")
      token.line.should eq("PROCNAME2: proc line code ->")
      token.line_code.should eq("proc line code")
      token.block_code.should eq("")
      token.block_open?.should be_true
      token.has_block?.should be_false # no block added yet
      token.add_block_code("Should\nBe True\n")
      token.has_block?.should be_true
      token.blocks.size.should eq(2)
    end
  end

  context "lua comment with no indent" do
    subject do
      LuaToken.new('-', STDOUT).tokenize(2, " -- SPEC: what ever ->")
    end
  
    its :processor_name do
      should eq("SPEC")
    end

    its :line_code do
      should eq("what ever")
    end

    its :block_open? do
      should be_true
    end

    its :indent_level do
      should eq(0)
    end
  end


  context "lua comment with indent" do
    subject do
      LuaToken.new('-', STDOUT).tokenize(2, " --   SPEC: what ever ->")
    end
  
    its :indent_level do
      should eq(2)
    end
  end

  context "ruby comment with indent" do
    subject do
      RubyToken.new('-', STDOUT).tokenize(2, " #     INSIDE: what ever ->")
    end
  
    its :processor_name do
      should eq("INSIDE")
    end

    its :indent_level do
      should eq(4)
    end
  end

  context "plain raw line" do
    subject do
      Luobo.new('-', STDOUT).tokenize(20, "What a wonderful spirit")
    end

    its :processor_name do
      should eq("_raw")
    end
  end

  context "ruby comment with raw line" do
    subject do
      Luobo.new('-', STDOUT).tokenize(20, "# What a wonderful spirit")
    end

    its :processor_name do
      should eq("_raw")
    end
  end

end
