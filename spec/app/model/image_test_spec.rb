# coding: utf-8
require 'spec_helper'

describe ImageTest do
  it "should be valid" do
    lambda{ ImageTest.new }.should_not raise_error
  end
end

