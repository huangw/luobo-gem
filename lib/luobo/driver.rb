

module Luobo
  class Driver 
    
    ## implements the factory pattern
    @@drivers = {}

    def self.create type
      c = @@drivers[type.to_sym]
      raise "No registered driver for type #{type.to_s}" unless c
      c.new
    end
  
    def self.register_driver type
      raise "Driver for #{type.to_s} already registed." if @@drivers[type.to_sym]
      @@drivers[type.to_sym] = self
    end

    ## cross-drivers methods and callbacks
    def convert token
      pname = "do_" + token.processor_name.downcase
      if self.respond_to?(pname)
        self.send(pname.to_sym, token)
      else
        self.do__missing(token)
      end
    end

    def dump output, contents
      output.print contents if contents
    end

    def exit; end
    def setup; end

    def indent token
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
  end
end
