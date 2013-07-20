module PayDirt
  class ServiceObject < Thor
    include Thor::Actions

    desc "new FILE", "create a service object... with tests :)"
    method_option :dependencies,
      type: :array,
      aliases: "-d",
      desc:    "specify required dependencies"
    method_option :test_framework,
      type: :string,
      default: "minitest",
      desc:    "choose a testing framework"
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

      # Call for the class string
      @class_string = Proc.new do |names|
        "ServiceObjects::#{ names.map(&:to_s).join("::") }"
      end

      create_file "lib/service_objects/#{file}.rb" do
        open_class(class_names)
        write_initialize_method
        write_execute_method

        close_class(class_names)

        @rets
      end

      @rets = nil

      create_file "test/unit/service_objects/#{file}_test.rb" do
        open_test_class(class_names, file)
        add_before_hook(class_names)
        @append.call(0, "\n")
        context_class
        @append.call(0, "\n")
        context_instance
        close_test_class
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

    # TESTS!
    def open_test_class(class_names, file)
      case options[:test_framework]
      when "minitest", "mini_test"
        @append.call(0, "require 'minitest_helper'\n\n")
        append_to_file "test/minitest_helper.rb" do
          "require 'service_objects/#{file}'\n"
        end
      else
        @append.call(0, "require 'test_helper'\n\n")
        append_to_file "test/test_helper.rb" do
          "require 'service_objects/#{file}'\n"
        end
      end
      @append.call(0, "describe #{ @class_string.call(class_names) } do\n")
    end

    def mock_test_dependencies
      @append.call(2, "@params = {\n")

      @dependencies.each do |dep|
        @append.call(3, "#{dep}: MiniTest::Mock.new,\n")
      end

      @append.call(2, "}\n")
    end

    def add_before_hook(class_names)
      @append.call(1, "before do\n")
      @append.call(2, "@subject = #{ @class_string.call(class_names) }\n")
      mock_test_dependencies
      @append.call(1, "end\n")
    end

    def assert_this(assertion, asserts)
      @append.call(2, "it \"#{assertion}\" do\n")

      asserts.each do |s|
        @append.call(3, "#{s}\n")
      end

      @append.call(2, "end\n")
    end

    def assert_error_without_dependencies
      assert_this("errors when initialized without required dependencies", @dependencies.reject { |d|
        options[:defaults] && options[:defaults].keys.include?(d)
      }.map { |required_dep|
        "-> { @subject.new(@params.reject { |k| k.to_s == '#{ required_dep }' }) }.must_raise RuntimeError"
      })
    end

    def assert_wont_error_with_all_dependencies
      assert_this("initializes properly", ["@subject.new(@params).must_respond_to :execute!"])
    end

    def assert_returns_a_successful_result
      assert_this("#execute! returns a successful result", [
        "result = @subject.new(@params).execute!",
        "result.successful?.must_equal true",
        "result.must_be_kind_of PayDirt::Result"
      ])
    end

    def context_class
      @append.call(1, "describe \"the class\" do\n")
      assert_wont_error_with_all_dependencies
      @append.call(0, "\n")
      assert_error_without_dependencies
      @append.call(1, "end\n")
    end

    def context_instance
      @append.call(1, "describe \"the class\" do\n")
      assert_returns_a_successful_result
      @append.call(1, "end\n")
    end

    def close_test_class
      @append.call(0, "end")
    end
  end
end
