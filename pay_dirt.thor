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
      @rets = ""
      class_names = file.split("/").map { |str| str.split("_").map{ |s| (s[0].upcase + s[1..-1]) }.join("") }
      defaults     = options[:defaults] || []
      dependencies = options[:dependencies] || []

      # Favor 2 spaces
      append = Proc.new { |depth, string| (@rets ||= "") << ("  " * depth) + string }

      create_file "lib/service_objects/#{file}.rb" do
        append.call(0, "require 'pay_dirt'\n\nmodule ServiceObjects\n")
        class_names[0..-2].each_with_index do |mod,i|
          append.call(i.next, "module #{mod}\n")
        end

        class_name, class_depth = class_names.last, class_names.length

        if options[:include]
          append.call(class_depth, "class #{class_name}\n")
          append.call(class_depth.next, "include PayDirt::UseCase\n")
        elsif options[:inherit]
          append.call(class_depth, "class #{class_name} < PayDirt::Base\n")
        end

        inner_depth = class_depth.next

        # The initialize method
        append.call(inner_depth, "def initialize(options = {})\n")

        # Configure dependencies' default values
        if options[:defaults]
          append.call(inner_depth.next, "options = {\n")

          defaults.each do |k,v|
            append.call(inner_depth + 2, "#{k}: #{v}" + ",\n")
          end

          append.call(inner_depth.next, "}.merge(options)\n\n")
        end

        append.call(inner_depth.next, "load_options(")
        dependencies.each do |dep|
          append.call(0, ":#{dep}, ")
        end
        append.call(0, "options)\n")
        append.call(inner_depth, "end\n\n")

        # The execute! method
        append.call(inner_depth, "def execute!\n")
        append.call(inner_depth.next, "return PayDirt::Result.new(success: true, data: nil)\n")
        append.call(inner_depth, "end\n")

        append.call(class_depth, "end\n") # Closes innermost class definition

        class_names[0..-1].each_with_index do |mod,i|
          append.call(class_depth - (i + 1), "end\n")
        end

        @rets
      end
    end
  end
end
