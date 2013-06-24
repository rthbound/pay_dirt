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

      # Favor 2 spaces, default to 0 depth
      append = Proc.new { |string,depth=0| (@rets ||= "") << ("  " * depth) + string }

      ending = Proc.new { |n_newlines, base_depth|
        append.call("end" + ("\n" * n_newlines), base_depth)
      }

      # The execute! method
      execute_method = Proc.new { |base_depth|
        append.call("def execute!\n", base_depth)
        append.call("return PayDirt::Result.new(success: true, data: nil)\n", base_depth.next)
        ending.call(1, base_depth)
      }

      load_options_method = Proc.new { |base_depth, options|
        append.call("load_options(", base_depth)
        (options[:dependencies] || []).each { |dep| append.call(":#{dep}, ") }
        append.call("options)\n")
      }


      add_pay_dirt = if options[:include]
        Proc.new { |class_name, class_depth|
          append.call("class #{class_name}\n", class_depth)
          append.call("include PayDirt::UseCase\n", class_depth.next)
        }
      else
        Proc.new { |class_name, class_depth|
          append.call("class #{class_name} < PayDirt::Base\n", class_depth)
        }
      end

      # The initialize method
      initialize_method = Proc.new { |base_depth, options|
        append.call("def initialize(options = {})\n", base_depth)

        if options[:defaults]
          append.call("options = {\n", base_depth.next)
          options[:defaults].each { |k,v| append.call("#{k}: #{v}" + ",\n", base_depth + 2) }
          append.call("}.merge(options)\n\n", base_depth.next)
        end

        load_options_method.call(base_depth.next, options)

        ending.call(2, base_depth)
      }

      output_file = Proc.new { |class_names, options|
        append.call("require 'pay_dirt'\n\nmodule ServiceObjects\n")

        class_names[0..-2].each_with_index { |mod,i| append.call("module #{mod}\n", i.next) }

        class_name, class_depth = class_names.last, class_names.length
        inner_depth = class_depth.next

        add_pay_dirt.call(class_name, class_depth)

        initialize_method.call(inner_depth, options)

        execute_method.call(inner_depth)

        ending.call(1, class_depth)

        class_names[0..-1].each_with_index { |m,i| ending.call(1, class_depth - (i + 1)) }
      }

      create_file "lib/service_objects/#{file.chomp("\.rb")}.rb" do
        output_file.call(class_names, options)
        @rets
      end
    end
  end
end
