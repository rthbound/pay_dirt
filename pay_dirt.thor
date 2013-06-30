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
      class_names = file.split("/").map { |str| str.split("_").map{ |s| (s[0].upcase + s[1..-1]) }.join("") }
      @dependencies = options[:dependencies] || []

      # Favor 2 spaces
      @append = Proc.new { |depth, string| (@rets ||= "") << ("  " * depth) + string }

      create_file "lib/service_objects/#{file}.rb" do
        open_class(class_names)
        write_initialize_method
        write_execute_method

        close_class(class_names)

        @rets
      end
    end

    private
    desc "close_class CLASS_NAMES", "hide", hide: true
    def close_class(class_names)
      @append.call(@class_depth, "end\n") # Closes innermost class definition

      class_names[0..-1].each_with_index { |m,i| @append.call(@class_depth - (i + 1), "end\n") }
    end

    desc "open_class CLASS_NAMES", "hide", hide: true
    def open_class(class_names)
      @class_name  = class_names.last
      @class_depth = class_names.length
      @inner_depth = class_names.length + 1

      @append.call(0, "require 'pay_dirt'\n\nmodule ServiceObjects\n")
      class_names[0..-2].each_with_index { |mod,i| @append.call(i.next, "module #{mod}\n") }

      if options[:include]
        @append.call(@class_depth, "class #{@class_name}\n")
        @append.call(@class_depth.next, "include PayDirt::UseCase\n")
      elsif options[:inherit]
        @append.call(@class_depth, "class #{@class_name} < PayDirt::Base\n")
      end
    end

    def write_execute_method
      # The execute! method
      @append.call(@inner_depth, "def execute!\n")
      @append.call(@inner_depth.next, "return result(true)\n")
      @append.call(@inner_depth, "end\n")
    end

    def write_initialize_method
      @append.call(@inner_depth, "def initialize(options = {})\n")

      set_defaults if options[:defaults]
      call_load_options

      @append.call(@inner_depth, "end\n\n")
    end

    def call_load_options
      @append.call(@inner_depth.next, "load_options(")
      @dependencies.each { |dep| @append.call(0, ":#{dep}, ") }
      @append.call(0, "options)\n")
    end

    def set_defaults
      @append.call(@inner_depth.next, "options = {\n")

      options[:defaults].each { |k,v| @append.call(@inner_depth + 2, "#{k}: #{v}" + ",\n") }

      @append.call(@inner_depth.next, "}.merge(options)\n\n")
    end
  end
end
