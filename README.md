## pay_dirt
#### A Ruby gem based on the "use case" pattern set forth in [opencurriculum-flashcards](https://github.com/isotope11/opencurriculum-flashcards)

Provides the basic building blocks of a pattern capable of reducing a towering codebase to modular rubble (or more Ruby gems)

The [pay_dirt/base_test](https://github.com/rthbound/pay_dirt/blob/master/test/unit/pay_dirt/base_test.rb) provides a complete working example. It's all plain old Ruby, but you can require any dependency you like to be injected as an option via [load_options](https://github.com/rthbound/pay_dirt/blob/master/test/unit/pay_dirt/base_test.rb#L8)

    describe PayDirt::Base do
      before do

        # A sample use case
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
