module PayDirt
  module UseCase
    def self.included(base)
      def load_options(*option_names, options)
        option_names.each { |o| options = load_option(o, options) }
        options.each_key      { |o| options = load_option(o, options) }
      end

      private
      def load_option(option, options)
        instance_variable_set("@#{option}", fetch(option, options))

        options.delete(option)

        return options
      end

      def fetch(opt, opts)
        opts.fetch(opt.to_sym) { raise "Missing required option: #{opt}" }
      end

    end
  end
end
