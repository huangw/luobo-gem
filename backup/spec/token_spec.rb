require "spec_helper"

describe Luobo::Token do
  subject (:token) do
    Luobo::Token.new(1, "line", 4, "Echo", "same: hash", "['block', 'in', 'array']") 
  end

  its :ln do 
    should eq(1) 
  end

  its :line do
    should eq("line")
  end

  its :indent_level do
    should eq(4)
  end

  its :processor_name do
    should eq("Echo")
  end

  its :line_args do
    token.line_args["same"].should eq("hash")
  end

  its :block_args do
    token.block_args[2].should eq("array")
  end

end
