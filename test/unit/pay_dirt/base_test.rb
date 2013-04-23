require 'test_helper'

describe PayDirt::Base do
  before do
    module UseCase
      class UltimateQuestion < PayDirt::Base
        def initialize(options)
          load_options(:the_secret_to_life_the_universe_and_everything, options)
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
     assert_operator @use_case, :<, PayDirt::Base
  end

  it "must error when initialized without required options" do
    begin
      @use_case.new
    rescue => e
      e.must_be_kind_of ArgumentError
    end
  end

  it "can execute successfully" do
    dependencies = {
      the_secret_to_life_the_universe_and_everything: 42
    }

    result = @use_case.new(dependencies).execute!

    result.successful?.must_equal true
  end

  it "can execute successfully" do
    dependencies = {
      the_secret_to_life_the_universe_and_everything: :i_dunno
    }

    result = @use_case.new(dependencies).execute!

    result.successful?.must_equal false
  end
end
