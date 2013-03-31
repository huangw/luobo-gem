require "spec_helper"

class LuaLoopLuobo < Luobo
  attr_accessor :token_stack, :dumps

  def regex_line_comment; "\s*--+\s?" end # use # as line comments

  def dump contents;
    # p contents
    @dumps = Array.new unless @dumps 
    @dumps << contents 
  end

  def last_dump; @dumps[-1] if @dumps end
  
  def stack_size; @token_stack.size end

  def do_spec token
    "spec (#{token.line_code}, function()\n" + token.block_code + "\nend)"
  end
end

describe LuaLoopLuobo do

  context "Simple examples" do
    subject(:lb){ LuaLoopLuobo.new('examples/lua_loop.lua', STDOUT) }
    it "expands variables inside" do
      lb.process!
      lb.dumps[-3].should eq("spec (\"first test\", function()\n   local name = \"first\"\n   do_test()\nend)")
      lb.dumps[-2].should eq("spec (\"second test\", function()\n   local name = \"last\"\n   do_test()\nend)")
    end

  end

end
