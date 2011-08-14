require_relative '../spec_helper.rb'

describe MyZip do

  describe "#remove_root_path" do
    it "should return the path when the root path is nil" do
      MyZip.remove_root_path("a/b.txt", nil).should == "a/b.txt"
    end
    it "should return the path when the root path is empty" do
      MyZip.remove_root_path("a/b.txt", "").should == "a/b.txt"
    end
    it "should return b.txt when given 'a/b.txt' and a root 'a'" do
      MyZip.remove_root_path("a/b.txt", "a").should == "b.txt"
    end
    it "should return 'b/c.txt' when given 'a/b/c.txt and a root 'a/b'" do
      MyZip.remove_root_path("a/b/c.txt", "a").should == "b/c.txt"
    end
    it "should return 'c/d' when given 'a/b/c/d' and a root 'a/b'" do
      MyZip.remove_root_path("a/b/c/d", "a/b").should == "c/d"
    end
  end
end
