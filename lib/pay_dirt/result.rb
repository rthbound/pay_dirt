module PayDirt
  class Result
    # The response from a use case execution
    #
    # Every use case should return a Result after it runs.
    #
    # @param [options] options_hash
    #   A hash specifying the appropriate options
    #
    # @return [PayDirt::Result]
    #   the Result instance
    #
    # @example
    #   PayDirt::Result.new(success: true, data: {})
    #   # => <PayDirt::Result>
    #
    # @public
    def initialize(options)
      @success = options[:success]
      @data    = options[:data]
    end

    # @public
    def successful?
      !!@success
    end

    # @public
    def data
      @data
    end
  end
end
