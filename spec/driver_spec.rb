require "spec_helper"

describe Luobo::Driver do
  class TestDriver < Luobo::Driver 
    def do_test_met(tk) 
      "test method" 
    end
    register_driver :test_driver
  end

  describe "create test driver" do
    subject(:test_driver) do
      Luobo::Driver.create(:test_driver)
    end

    it "is a test driver object" do
      test_driver.is_a?(TestDriver).should be_true
    end

    its :class do
      should eq(TestDriver)
    end

    it "inherit driver methods" do
      tk = Luobo::Token.new(1, '', 1, 'test_met', '', '')
      test_driver.convert(tk).should eq("test method")
    end
  end

end
