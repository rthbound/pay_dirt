module PayDirt
  module UseCase
    def self.included(base)
      # @overload load_options(keys, options)
      #   Sets instance variables for all provided key value pairs in +options+.
      #   Raises error if required keys cannot be fond in options.
      #   @param [List<String,Symbol>] keys a List of (Strings or Symbols) that must be contained in +options+
      #   @param [Hash] options hash of options (dependencies)
      # @overload load_options(options)
      #   Sets instance variables for all provided key value pairs in +options+
      #   @param [Hash] options hash of options (dependencies)
      # @api public
      def load_options(*option_names, options)
        # Load required options
        option_names.each { |o| options = load_option(o, options) }

        # Load remaining options
        options.each_key  { |o| options = load_option(o, options) }
      end

      private
      # @param [Symbol,String] option The option to load from the provided options hash.
      # @param [Hash] options The provided hash of options
      # @return [Hash] Deletes the key value pair at `option` and returns the remaining options hash
      # @api private
      def load_option(option, options)
        instance_variable_set("@#{option}", fetch(option, options))
        options.delete(option)

        return options
      end

      # @param [Symbol, String] opt the key to fetch from +opts+
      # @param [Hash] opts the hash of options from which +opt+ will be fetched
      # @api private
      def fetch(opt, opts)
        opts.fetch(opt.to_sym) { raise "Missing required option: #{opt}" }
      end
    end
  end
end
