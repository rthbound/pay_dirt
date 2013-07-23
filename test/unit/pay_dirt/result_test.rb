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

  describe "has a little helper method" do
    before do
      class Subject < PayDirt::Base
        def initialize(options)
          load_options(:success, :data, options)
        end

        def call
          result(@success, @data)
        end
      end

      @pay_dirt = Subject
    end

    it "can succeed" do
      @pay_dirt.new(success: true, data: "yum").call.successful?.must_equal true
    end

    it "can be unsuccessful" do
      @pay_dirt.new(success: false, data: "gross").call.successful?.must_equal false
    end

    it "provides access to data" do
      @pay_dirt.new(success: true, data: "yum").call.data.must_equal "yum"
    end
  end
end
