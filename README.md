## pay_dirt
#### A Ruby gem based on the "use case" pattern set forth in [opencurriculum-flashcards](https://github.com/isotope11/opencurriculum-flashcards)

Provides the basic building blocks of a pattern capable of reducing a towering codebase to modular rubble (or more Ruby gems)

The [pay_dirt/use_case_test](https://github.com/rthbound/pay_dirt/blob/master/test/unit/pay_dirt/base_test.rb) provides a complete working example. It's all plain old Ruby, but you can require any dependency you like to be injected as an option via [load_options](https://github.com/rthbound/pay_dirt/blob/master/test/unit/pay_dirt/base_test.rb#L8)

```ruby
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
            return PayDirt::Result.new(data: @the_secret_to_life_the_universe_and_everything, success: true)
          else
            return PayDirt::Result.new(data: @the_secret_to_life_the_universe_and_everything, success: false)
          end
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
```
