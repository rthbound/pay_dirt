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

          load_options(:the_question, :the_secret_to_life_the_universe_and_everything, options)
        end

        def execute!
          if @the_secret_to_life_the_universe_and_everything == 42
            return PayDirt::Result.new(data: @the_secret_to_life_the_universe_and_everything, success: true)
          else
            return PayDirt::Result.new(data: @the_secret_to_life_the_universe_and_everything, success: false)
          end
        end
      end
    end

    @use_case = UseCase::UltimateQuestion
  end

  it "must inherit from PayDirt::Base" do
    lineage = UseCase::UltimateQuestion.ancestors.map(&:to_s)
    assert lineage.include?("PayDirt::Base")
  end

  it "must error when initialized without required options" do
    proc { @use_case.new }.must_raise ArgumentError
  end

  it "it won't error if defaults were supplied for an omitted option" do
    @use_case.new(the_secret_to_life_the_universe_and_everything: :not_telling).must_respond_to :execute!
  end

  it "can execute successfully" do
    dependencies = {
      the_secret_to_life_the_universe_and_everything: 42
    }

    result = @use_case.new(dependencies).execute!

    result.successful?.must_equal true
    result.must_be_kind_of PayDirt::Result
  end

  it "can execute unsuccessfully" do
    dependencies = {
      the_secret_to_life_the_universe_and_everything: :i_dunno
    }

    result = @use_case.new(dependencies).execute!

    result.successful?.must_equal false
  end
end
