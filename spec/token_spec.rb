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

    it "return a token with indent level 0" do
      token = lb.tokenize(1, "PROCNAME: proc line code")
      token.is_a?(Token).should be_true
      token.indent_level.should eq(0)
      token.ln.should eq(1)
      token.line.should eq("PROCNAME: proc line code")
      token.line_code.should eq("proc line code")
      token.has_block?.should be_false
      token.block_code.should eq("")
      token.block_open?.should be_false
    end
  end
end
