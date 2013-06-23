module PayDirt
  class ServiceObject < Thor
    include Thor::Actions

    desc "new FILE", "create a service object"
    method_option :defaults,
      type: :hash,
      aliases: "-D",
      desc: "Specify default dependencies"

    method_option :dependencies,
      type: :array,
      aliases: "-d",
      desc: "Specify required dependencies",
      required: true

    method_option :inherit,
      type:         :boolean,
      desc:         "Should inherit from PayDirt::Base (default)",
      aliases:      "-i",
      default:      true,
      lazy_default: true

    method_option :include,
      type:         :boolean,
      desc:         "Should include the PayDirt::UseCase module",
      aliases:      "-m",
      lazy_default: true

    def new(file)
      rets = ""
      class_names = file.split("/").map { |str| str.split("_").map{ |s| (s[0].upcase + s[1..-1]) }.join("") }
      defaults     = options[:defaults] || []
      dependencies = options[:dependencies]

      # Favor 2 spaces
      append = Proc.new { |depth, string, rets| rets << ("  " * depth) + string }

      create_file "lib/service_objects/#{file}.rb" do
        rets = append.call(0, "require 'pay_dirt'\n\nmodule ServiceObjects\n", rets)
        class_names[0..-2].each_with_index do |mod,i|
          rets = append.call(i.next, "module #{mod}\n", rets)
        end

        class_name, class_depth = class_names.last, class_names.length

        if options[:include]
          rets = append.call(class_depth, "class #{class_name}\n", rets)
          rets = append.call(class_depth.next, "include PayDirt::UseCase\n", rets)
        elsif options[:inherit]
          rets = append.call(class_depth, "class #{class_name} < PayDirt::Base\n", rets)
        end

        inner_depth = class_depth.next

        # The initialize method
        rets = append.call(inner_depth, "def initialize(options = {})\n", rets)

        # Configure dependencies' default values
        if options[:defaults]
          rets = append.call(inner_depth.next, "options = {\n", rets)

          defaults.each do |k,v|
            rets = append.call(inner_depth + 2, "#{k}: #{v}" + ",\n", rets)
          end

          rets = append.call(inner_depth.next, "}.merge(options)\n\n", rets)
        end

        rets = append.call(inner_depth.next, "load_options(:#{dependencies.join(', :')}, options)\n", rets)
        rets = append.call(inner_depth, "end\n\n", rets)

        # The execute! method
        rets = append.call(inner_depth, "def execute!\n", rets)
        rets = append.call(inner_depth.next, "return PayDirt::Result.new(success: true, data: nil)\n", rets)
        rets = append.call(inner_depth, "end\n", rets)

        rets = append.call(class_depth, "end\n", rets) # Closes innermost class definition

        class_names[0..-1].each_with_index do |mod,i|
          rets = append.call(class_depth - (i + 1), "end\n", rets)
        end

        rets
      end
    end
  end
end
