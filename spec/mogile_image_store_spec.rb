require 'spec_helper'
require 'mogilefs'

describe MogileImageStore do
  it "should be valid" do
    MogileImageStore.should be_a(Module)
  end

  it "should be configured" do
    MogileImageStore::Engine.config.mount_at.should_not be_nil
    MogileImageStore::Engine.config.mogile_fs.should_not be_nil
    MogileImageStore.backend.should_not be_nil
  end
end
