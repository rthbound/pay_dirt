require 'test_helper'
require_relative "../../../lib/pay_dirt/base"

describe PayDirt::Base do
  before do
    module UseCase
      class UltimateQuestion < PayDirt::Base
        def initialize(options)
          options = {
            the_question: "What is the secret to life, the universe, and everything?"
          }.merge(options)

          load_options(:the_question, :the_secret, options)
        end

        def call
          @the_secret == 42 and return result(true, @the_secret )
          return result(false)
        end
      end
    end

    @use_case = UseCase::UltimateQuestion
  end

  it "must inherit from PayDirt::Base" do
    lineage = UseCase::UltimateQuestion.ancestors.map(&:to_s)
    assert lineage.include?("PayDirt::Base")
  end

  it "will error when initialized without required options" do
    proc { @use_case.new }.must_raise ArgumentError
  end

  it "won't error if defaults were supplied for an omitted option" do
    @use_case.new(the_secret: :not_telling).must_respond_to :call
  end

  it "can be called successfully" do
    dependencies = {
      the_secret: 42
    }

    result = @use_case.new(dependencies).call

    result.successful?.must_equal true
    result.must_be_kind_of PayDirt::Result
  end

  it "can be called unsuccessfully" do
    dependencies = {
      the_secret: :i_dunno
    }

    result = @use_case.new(dependencies).call

    result.successful?.must_equal false
  end
end
