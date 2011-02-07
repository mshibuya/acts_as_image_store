# coding: utf-8
require 'spec_helper'

describe MogileImage do
  it "test" do
    lambda{ MogileImage.new }.should_not raise_error
  end
end

