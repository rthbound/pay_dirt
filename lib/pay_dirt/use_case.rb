require_relative "#{File.dirname(__FILE__)}/use_case.rb"
module PayDirt
  module UseCase
    def self.included(base)
      def load_option(option, options)
        instance_variable_set("@#{option}", options.fetch(option.to_sym) {
          raise "Missing required option: #{option}"
        })
      end

      def load_options(*option_names, options)
        option_names.each { |o| load_option(o, options) }
      end
    end
  end
end
