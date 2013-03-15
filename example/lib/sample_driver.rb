module Luobo
  class SampleDriver < Driver
    def pda
      DATA.each_line.map {|line| puts line}
    end
  end
end

__END__

@@ data

for fun!
