require 'test_helper'
require_relative '../../lib/service_objects/digit_check'
require_relative "../../../lib/pay_dirt/use_case"

# Test Case generated by
# thor pay_dirt:service_object:new digit_check -m -d fingers toes nose -D fingers:10 toes:10
#
# People with digits usually have 10 fingers and 10 toes
# If we were doing an actual digit check, we wouldn't require the nose. For the sake of args, we will
#
#   -m                    module         generated SO will include the PayDirt::UseCase module
#   -d nose fingers toes  dependencies   generated SO will fail to initialize without dependencies
#   -D fingers:10 toes:10 defaults       generated SO will provide defaults
describe PayDirt::UseCase do
  describe "when included" do
    before do
      @subject = ServiceObjects::DigitCheck
      @params  = { nose: true }


      # quick check
      assert @subject.new(@params).call.successful?

      # lemme add a method or two
      module ServiceObjects
        class DigitCheck
          def has_ten?(digits)
            digits == 10
          end

          def call
            result(@nose && has_ten?(@fingers) && has_ten?(@toes), {
              fingers: @fingers,
              toes:    @toes,
              nose:    @nose
            })
          end
        end
      end
    end

    describe "as a class" do
      it "must error before initializing without a :nose" do
        -> { @subject.new(@params.reject { |k| k.to_s == 'nose' }) }.must_raise RuntimeError
      end

      it "initializes properly" do
        @subject.new(@params).must_respond_to :call
      end
    end

    describe "as an instance" do
      before do
        # lemme add a method or two
        module ServiceObjects
          class DigitCheck
            def has_ten?(digits)
              digits == 10
            end

            def call
              result(@nose && has_ten?(@fingers) && has_ten?(@toes), {
                fingers: @fingers,
                toes:    @toes,
                nose:    @nose
              })
            end
          end
        end
      end

      it "can be called successfully" do
        result = @subject.new(@params).call
        result.successful?.must_equal true
        result.must_be_kind_of PayDirt::Result
      end

      describe "being called unsuccessfully" do
        it "will fail if :fingers is anything but 10" do
          @subject.new(@params.merge(fingers: rand(9))).call.successful?.must_equal false
        end

        it "will fail if :toes is anything but 10" do
          @subject.new(@params.merge(toes: rand(9))).call.successful?.must_equal false
        end

        it "will fail if :nose is false" do
          @subject.new(nose: false).call.successful?.must_equal false
        end
      end
    end
  end
end
