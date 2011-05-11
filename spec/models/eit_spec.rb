require 'spec_helper'

describe Eit do
  it "should have the type column eit after creation" do
    @eit = Eit.new()
    @eit.type.should be_eql("Eit")
  end
end
