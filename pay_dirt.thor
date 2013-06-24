module PayDirt
  class ServiceObject < Thor
    include Thor::Actions

    desc "new FILE", "create a service object"
    method_option :dependencies,
      type: :array,
      aliases: "-d",
      desc: "specify required dependencies"
    method_option :defaults,
      type: :hash,
      aliases: "-D",
      desc: "specify default dependencies"
    method_option :inherit,
      type:         :boolean,
      desc:         "inherit from PayDirt::Base class",
      aliases:      "-i",
      default:      true,
      lazy_default: true
    method_option :include,
      type:         :boolean,
      desc:         "include the PayDirt::UseCase module (overrides --inherit)",
      aliases:      "-m",
      lazy_default: true
    def new(file)
      @rets = ""
      class_names = file.split("/").map { |str| str.split("_").map{ |s| (s[0].upcase + s[1..-1]) }.join("") }
      options[:dependencies] ||= []

      # Favor 2 spaces
      append = Proc.new { |depth, string| (@rets ||= "") << ("  " * depth) + string }

      create_file "lib/service_objects/#{file}.rb" do
        append.call(0, "require 'pay_dirt'\n\nmodule ServiceObjects\n")
        class_names[0..-2].each_with_index { |mod,i| append.call(i.next, "module #{mod}\n") }

        class_depth = class_names.length

        if options[:include]
          append.call(class_depth, "class #{class_names.last}\n")
          append.call(class_depth.next, "include PayDirt::UseCase\n")
        elsif options[:inherit]
          append.call(class_depth, "class #{class_names.last} < PayDirt::Base\n")
        end

        # The initialize method
        append.call(class_depth + 1, "def initialize(options = {})\n")

        # Configure dependencies' default values
        if options[:defaults]
          append.call(class_depth + 2, "options = {\n")

          options[:defaults].each { |k,v| append.call(class_depth + 3, "#{k}: #{v}" + ",\n") }

          append.call(class_depth + 2, "}.merge(options)\n\n")
        end

        append.call(class_depth + 2, "load_options(")
        options[:dependencies].each { |dep| append.call(0, ":#{dep}, ") }
        append.call(0, "options)\n")
        append.call(class_depth + 1, "end\n\n")

        # The execute! method
        append.call(class_depth + 1, "def execute!\n")
        append.call(class_depth + 2, "return PayDirt::Result.new(success: true, data: nil)\n")
        append.call(class_depth + 1, "end\n")

        append.call(class_depth, "end\n") # Closes innermost class definition

        class_names[0..-1].each_with_index { |m,i| append.call(class_depth - (i + 1), "end\n") }

        @rets
      end
    end
  end
end
