require "spec_helper"

describe Luobo::Base do
  class OutputHolder < IO
    attr_accessor :text
    def initialize; @text = {} end
    def print(str)
      str.split("\n").each {|t| @text[t] = true}
    end
    def close; end
  end

  class AstDriver < Luobo::Driver
    attr_accessor :asserts
    def initialize
      super()
      @asserts = []
    end

    def do_ast token
      str = ''
      if /(?<ident_>\d+),\s*(?<rm_>.+)/ =~ token.line_code
        str = " "*ident_.to_i + rm_
      else
        str = token.line_code
      end
      @asserts << str
      nil
    end

    def do_split token
      src = ""
      token.line_code.split(/\s+/).each do |line|
        src += line + "\n"
      end
      src
    end
    
    def do_spec token
      src = indent(token) + "spec \"#{token.line_code}\" do"
      src += token.block_code ? token.block_code : ""
      src += "\n" + indent(token) + "end\n"
      src
    end

    def do_hash token
      hash = token.line_args if token.line_code.size > 0
      if token.block_code.size > 0
        hash = hash.is_a?(Hash) ? hash.merge(token.block_args) : token.block_args
      end
      src = ""
      hash.each do |k,v|
        src += indent(token) + "key: #{k}\n"
        src += indent(token) + "value: #{v}\n"
      end
      src
    end
    
    register_driver :ast
  end

  describe "convert" do
    oh = OutputHolder.new
    base = Luobo::Base.new("example/parser.lub", oh).process

    it "base should have a AstDriver" do
      base.driver.is_a?(AstDriver)
      p oh.text
    end

    base.driver.asserts.each do |line|
      it "can parse #{line}" do
        oh.text[line].should be_true
      end
    end
  end

end
