require 'pay_dirt'

module ServiceObjects
  class DigitCheck
    include PayDirt::UseCase
    def initialize(options = {})
      options = {
        fingers: 10,
        toes: 10,
      }.merge(options)

      load_options(:fingers, :toes, :nose, options)
    end

    def call
      return result(true)
    end
  end
end
