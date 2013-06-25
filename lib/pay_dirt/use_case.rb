module PayDirt
  module UseCase
    def self.included(base)
      # Load instance variables from the provided hash of dependencies.
      #
      # Raises if any required dependencies are missing from +options+ hash.
      #
      # @param [List<String,Symbol>]
      #   option_names list of keys representing required dependencies
      #
      # @param [Hash]
      #   options A hash of dependencies
      #
      # @public
      def load_options(*option_names, options)
        # Load required options
        option_names.each { |o| options = load_option(o, options) }

        # Load remaining options
        options.each_key  { |o| options = load_option(o, options) }
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
end
