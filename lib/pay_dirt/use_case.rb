module PayDirt
  # Provides the basic functionality every PayDirt service object should have.
  # @since 0.0.2
  module UseCase
    # Load instance variables from the provided hash of dependencies.
    #
    # Raises if any required dependencies (+required_options+) are missing from +options+ hash.
    #
    # @param [List<String,Symbol>]
    #   option_names list of keys representing required dependencies
    #
    # @param [Hash]
    #   options A hash of dependencies
    #
    # @public
    def load_options(*required_options, options)
      # Load required options
      required_options.each { |o| options = load_option(o, options) }

      # Load remaining options
      options.each_key  { |k| options = load_option(k, options) }
    end

    # Returns a result object conveying success or failure (+success+)
    # and any +data+. See PayDirt::Result.
    #
    # @param [Boolean]
    #   success should the result be +#successful?+?
    #
    # @param [Object]
    #   data (nil) optional, an object containing information
    #
    # @public
    def result(success, data = nil)
      PayDirt::Result.new(success: success, data: data)
    end

    private
    # @private
    def load_option(option, options)
      instance_variable_set("@#{option}", fetch(option, options))
      options.delete(option)

      return options
    end

    # @private
    def fetch(opt, opts)
      opts.fetch(opt.to_sym) { raise "Missing required option: #{opt}" }
    end
  end
end
