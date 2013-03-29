require "spec_helper"

class CommandConverter < Luobo
  def process!
    "OK"
  end
end

describe Luobo do
  it "exports a class method convert!" do
    CommandConverter.convert!('examples/hello_processor.rb', STDOUT).should eq("OK")
  end
end

