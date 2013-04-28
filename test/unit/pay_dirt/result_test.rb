require 'test_helper'
require_relative "../../../lib/pay_dirt/result"

describe PayDirt::Result do
  it "knows whether it was successful or not" do
    pay_dirt = PayDirt::Result.new(success: true)
    pay_dirt.successful?.must_equal true
  end

  it "provides access to its data" do
    pay_dirt = PayDirt::Result.new(data: 'foo')
    pay_dirt.data.must_equal 'foo'
  end
end
