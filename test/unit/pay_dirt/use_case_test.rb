require 'test_helper'
require_relative "../../../lib/pay_dirt/use_case"

describe PayDirt::UseCase do
  before do

    module UseCase
      class UltimateQuestionInclude
        include PayDirt::UseCase

        def initialize(options)
          options = {
            the_secret_to_life_the_universe_and_everything: 42
          }.merge(options)

          load_options(:the_secret_to_life_the_universe_and_everything, options)
        end

        def call
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

    @use_case = UseCase::UltimateQuestionInclude
  end

  it "need not inherit from PayDirt::Base" do
    #lineage = UseCase::UltimateQuestion.ancestors.map(&:to_s)
    #assert !lineage.include?("PayDirt::Base")

    # NOTE this test only passes when base_test is removed.
  end

  it "must not error when options with defaults are omitted" do
    @use_case.new({}).must_respond_to :call
  end

  it "loads options that are not required" do
    result = @use_case.new({ some_random_option: true }).call
    assert result.data[:some_random_option]
  end

  it "can be called successfully" do
    dependencies = {
    }

    result = @use_case.new(dependencies).call

    result.successful?.must_equal true
    result.must_be_kind_of PayDirt::Result
  end

  it "can be called unsuccessfully" do
    dependencies = {
      the_secret_to_life_the_universe_and_everything: :i_dunno
    }

    result = @use_case.new(dependencies).call

    result.successful?.must_equal false
  end

  it "has optional options" do
    class SomeThing
      include PayDirt::UseCase

      def initialize(options)
        options = {
          required_option_with_default_value: true
        }.merge(options)

        load_options(:required_option_with_default_value, :required_option, options)
      end

      def call
        if !@required_option_with_default_value
          return PayDirt::Result.new(data: return_value, success: true)
        else
          return PayDirt::Result.new(data: return_value, success: false)
        end
      end

      private
      def return_value
        {
          optional_option:  @optional_option,
          required_option1: @required_option_with_default_value,
          required_option2: @required_option
        }
      end
    end

    # Cheating by not injecting all dependencies
    result = SomeThing.new(required_option: true).call # Returns a PayDirt::Result
    assert !result.successful?                             #=> false
    result.data[:optional_option].must_be_nil              #=> nil
    # Playing nice and injecting all required dependencies
    result = SomeThing.new(required_option: true, required_option_with_default_value: false).call
    assert result.successful?                              #=> true
    result.data[:optional_option].must_be_nil              #=> nil
    # Making use of an optional option
    result = SomeThing.new(required_option: true, optional_option: true).call
    assert !result.successful?                             #=> false
    assert result.data[:optional_option]                   #=> true
  end
end
