module PayDirt
  class ServiceObject < Thor
    include Thor::Actions

    desc "new FILE", "create a service object"
    method_option :dependencies,
      type: :array,
      aliases: "-d",
      desc: "Specify required dependencies"

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
      class_names = file.split("/").map { |s| s[0].upcase + s[1..-1] }
      create_file "app/models/pay_dirt/#{file}.rb" do
        rets << "require 'pay_dirt'\n\n"
        rets << "module PayDirt\n"
        class_names[0..-2].each_with_index do |mod,i|
          rets << (" " * ( (i+1) * 2 )) + "module #{mod}\n"
        end

        klass, klass_index = class_names[-1], class_names.length

        if options[:inherit]
          rets << (" " * ( klass_index * 2)) + "class #{class_names[-1]} < PayDirt::Base\n"
        elsif options[:include]
          rets << (" " * ( klass_index * 2)) + "class #{class_names[-1]}\n"
          rets << (" " * ((klass_index + 1) * 2)) + "include PayDirt::UseCase\n"
        end

        inner_index = klass_index + 1

        rets << (" " * ( inner_index * 2 )) + "def initialize(options)\n"
        rets << (" " * ( (inner_index + 1) * 2 )) + "load_options(:#{options[:dependencies].join(', :')}, options)\n"
        rets << (" " * ( inner_index * 2 )) + "end\n\n"

        rets << (" " * ( inner_index * 2 )) + "def execute!\n"
        rets << (" " * ( (inner_index + 1) * 2 )) + "return PayDirt::Result.new(success: true, data: nil)\n"
        rets << (" " * ( inner_index * 2 )) + "end\n"

        rets << (" " * ( klass_index * 2)) + "end\n"

        class_names[0..-1].each_with_index do |mod,i|
          rets << (" " * ( (class_names.length - (i + 1)).abs * 2 )) + "end\n"
        end

        rets
      end
    end
  end
end
