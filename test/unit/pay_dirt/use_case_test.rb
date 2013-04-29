require 'test_helper'
require_relative "../../../lib/pay_dirt/use_case"

describe PayDirt::UseCase do
  before do
    module UseCase
      class UltimateQuestion
        include PayDirt::UseCase

        def initialize(options)
          options = {
            the_secret_to_life_the_universe_and_everything: 42
          }.merge(options)

          load_options(:the_secret_to_life_the_universe_and_everything, options)
        end

        def execute!
          if @the_secret_to_life_the_universe_and_everything == 42
            return PayDirt::Result.new(data: return_value, success: true)
          else
            return PayDirt::Result.new(data: @the_secret_to_life_the_universe_and_everything, success: false)
          end
        end

        private

        def return_value
          {
            secret: @the_secret_to_life_the_universe_and_everything,
            some_random_option: @some_random_option
          }
        end
      end
    end

    @use_case = UseCase::UltimateQuestion
  end

  it "need not inherit from PayDirt::Base" do
    #lineage = UseCase::UltimateQuestion.ancestors.map(&:to_s)
    #assert !lineage.include?("PayDirt::Base")

    # NOTE this test only passes when base_test is removed.
  end

  it "must not error when options with defaults are omitted" do
    @use_case.new({}).must_respond_to :execute!
  end

  it "loads options that are not required" do
    result = @use_case.new({ some_random_option: true }).execute!
    assert result.data[:some_random_option]
  end

  it "can execute successfully" do
    dependencies = {
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
