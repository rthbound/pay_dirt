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
      desc: "Specify default dependencies"
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
      class_names = file.split("/").map { |str| str.split("_").map(&:capitalize).join("") }
      dependencies = options[:dependencies] || []

      # Favor 2 spaces
      append = Proc.new { |string,depth=0| (@rets ||= "") << ("  " * depth) + string }

      create_file "lib/service_objects/#{file.chomp("\.rb")}.rb" do
        append.call("require 'pay_dirt'\n\nmodule ServiceObjects\n")
        class_names[0..-2].each_with_index { |mod,i| append.call("module #{mod}\n", i.next) }

        class_name, class_depth = class_names.last, class_names.length

        if options[:include]
          append.call("class #{class_name}\n", class_depth)
          append.call("include PayDirt::UseCase\n", class_depth.next)
        elsif options[:inherit]
          append.call("class #{class_name} < PayDirt::Base\n", class_depth)
        end

        inner_depth = class_depth.next

        # The initialize method
        append.call("def initialize(options = {})\n", inner_depth)

        # Configure dependencies' default values
        if options[:defaults]
          append.call("options = {\n", inner_depth.next)

          options[:defaults].each { |k,v| append.call("#{k}: #{v}" + ",\n", inner_depth + 2) }

          append.call("}.merge(options)\n\n", inner_depth.next)
        end

        append.call("load_options(", inner_depth.next)
        dependencies.each { |dep| append.call(":#{dep}, ") }
        append.call("options)\n")
        append.call("end\n\n", inner_depth)

        # The execute! method
        append.call("def execute!\n", inner_depth)
        append.call("return PayDirt::Result.new(success: true, data: nil)\n", inner_depth.next)
        append.call("end\n", inner_depth)

        append.call("end\n", class_depth) # Closes innermost class definition

        class_names[0..-1].each_with_index { |m,i| append.call("end\n", class_depth - (i + 1)) }

        @rets
      end
    end
  end
end
