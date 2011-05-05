require 'spec_helper'

describe ActsAsImageStore do
  it "should be valid" do
    ActsAsImageStore.should be_a(Module)
  end

  it "should be counfigured" do
    ActsAsImageStore.backend.should_not == {}
  end
end
