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

      append = Proc.new { |n_spaces, depth, string| (" " * depth * n_spaces) + string }

      create_file "lib/service_objects/#{file}.rb" do
        rets << append.call(2, 0, "require 'pay_dirt'\n\n")
        rets << append.call(2, 0, "module ServiceObjects\n")
        class_names[0..-2].each_with_index do |mod,i|
          rets << append.call(2, i + 1, "module #{mod}\n")
        end

        klass, klass_index = class_names[-1], class_names.length

        if options[:include]
          rets << append.call(2, klass_index, "class #{class_names[-1]}\n")
          rets << append.call(2, klass_index + 1, "include PayDirt::UseCase\n")
        elsif options[:inherit]
          rets << append.call(2, klass_index, "class #{class_names[-1]} < PayDirt::Base\n")
        end

        inner_index = klass_index + 1

        # The initialize method
        rets << append.call(2, inner_index, "def initialize(options = {})\n")

        # Configure dependencies' default values
        if options[:defaults]
          rets << append.call(2, inner_index + 1, "options = {\n")

          defaults.each do |k,v|
            rets << append.call(2, inner_index + 2, "#{k}: #{v}" + ",\n")
          end

          rets << append.call(2, inner_index + 1, "}.merge(options)\n\n")
        end

        rets << append.call(2, inner_index + 1, "load_options(:#{dependencies.join(', :')}, options)\n")
        rets << append.call(2, inner_index, "end\n\n")

        # The execute! method
        rets << append.call(2, inner_index, "def execute!\n")
        rets << append.call(2, inner_index + 1, "return PayDirt::Result.new(success: true, data: nil)\n")
        rets << append.call(2, inner_index, "end\n")

        rets << append.call(2, klass_index, "end\n")

        class_names[0..-1].each_with_index do |mod,i|
          rets << append.call(2, (class_names.length - (i + 1)).abs, "end\n")
        end

        rets
      end
    end
  end
end
