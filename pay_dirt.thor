module PayDirt
  class ServiceObject < Thor
    include Thor::Actions

    desc "new FILE", "create a fully tested object (optionally, requires dependencies)"
    method_option :dependencies,
      type:         :array,
      aliases:      "-d",
      desc:         "specify required dependencies"
    method_option :test_framework,
      type:         :string,
      desc:         "choose a testing framework"
    method_option :defaults,
      type:         :hash,
      aliases:      "-D",
      desc:         "Specify default dependencies"
    method_option :validations,
      type:         :boolean,
      aliases:      "-V",
      lazy_default: true,
      desc:         "Add validations"
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

      create_object(file, class_names)
      create_tests(file, class_names)
    end

    private
    def close_class(class_names)
      append(@class_depth, "end\n") # Closes innermost class definition

      @class_depth.times { |i| append(@class_depth - (i + 1), "end\n") }
    end

    def open_class(class_names)
      @class_name  = class_names.last
      @class_depth = class_names.length - 1
      @inner_depth = class_names.length

      append(0, "require 'pay_dirt'\n\n")
      class_names[0..-2].each_with_index { |mod,i| append(i, "module #{mod}\n") }

      if options[:include]
        append(@class_depth, "class #{@class_name}\n")
        append(@inner_depth, "include PayDirt::UseCase\n")
      elsif options[:inherit]
        append(@class_depth, "class #{@class_name} < PayDirt::Base\n")
      end
    end

    def write_execute_method
      # The call method
      append(@inner_depth, "def call\n")
      append(@inner_depth.next, "return result(true)\n")
      append(@inner_depth, "end\n")
    end

    def write_initialize_method
      append(@inner_depth, "def initialize(options = {})\n")

      set_defaults if options[:defaults]
      call_load_options

      append(@inner_depth, "end\n\n")
    end

    def call_load_options
      append(@inner_depth.next, "# sets instance variables from key value pairs,\n")
      append(@inner_depth.next, "# will fail if any keys given before options aren't in options\n")
      append(@inner_depth.next, "load_options(")
      @dependencies.each { |dep| append(0, ":#{dep}, ") }
      append(0, "options)")

      if options[:validations]
        append(0, " do\n")
        append(@inner_depth.next, "end\n")
      else
        append(0,"\n")
      end

    end

    def set_defaults
      append(@inner_depth.next, "options = {\n")

      options[:defaults].each { |k,v| append(@inner_depth + 2, "#{k}: #{v}" + ",\n") }

      append(@inner_depth.next, "}.merge(options)\n\n")
    end

    # TESTS!
    def boiler_plate_test_classes(helper_name, file)
      append(0, "require '#{helper_name}'\n\n")

      File.file? "test/#{helper_name}.rb" or create_file "test/#{helper_name}.rb"

      prepend_to_file "test/#{helper_name}.rb" do
        "require \"minitest/autorun\"\n"
      end
      append_to_file "test/#{helper_name}.rb" do
        "require \"#{file}\"\n"
      end
    end

    def open_test_class(class_names, file)
      case options[:test_framework]
      when "minitest", "mini_test"
        boiler_plate_test_classes("minitest_helper", file)
      else
        boiler_plate_test_classes("test_helper", file)
      end

      append(0, "describe #{ class_string(class_names) } do\n")
    end

    def mock_test_dependencies
      append(2, "@params = {\n")

      @dependencies.each do |dep|
        append(3, "#{dep}: MiniTest::Mock.new,\n")
      end

      append(2, "}\n")
    end

    def add_before_hook(class_names)
      append(1, "before do\n")
      append(2, "@subject = #{ class_string(class_names) }\n")
      mock_test_dependencies
      append(1, "end\n")
    end

    def assert_this(assertion, asserts)
      append(2, "it \"#{assertion}\" do\n")

      asserts.each do |s|
        append(3, "#{s}\n")
      end

      append(2, "end\n")
    end

    def assert_error_without_dependencies
      assert_this("errors when initialized without required dependencies", @dependencies.reject { |d|
        options[:defaults] && options[:defaults].keys.include?(d)
      }.map { |required_dep|
        "-> { @subject.new(@params.reject { |k| k.to_s == '#{ required_dep }' }) }.must_raise RuntimeError"
      })
    end

    def assert_wont_error_with_all_dependencies
      assert_this("initializes properly", ["@subject.new(@params).must_respond_to :call"])
    end

    def assert_returns_a_successful_result
      assert_this("executes successfully", [
        "result = @subject.new(@params).call",
        "result.successful?.must_equal true",
        "result.must_be_kind_of PayDirt::Result"
      ])
    end

    def context_class
      append(1, "describe \"as a class\" do\n")
      assert_wont_error_with_all_dependencies
      append(0, "\n")
      assert_error_without_dependencies
      append(1, "end\n")
    end

    def context_instance
      append(1, "describe \"as an instance\" do\n")
      assert_returns_a_successful_result
      append(1, "end\n")
    end

    def close_test_class
      append(0, "end")
    end

    def create_object(file, class_names)
      @rets = nil
      create_file "lib/#{file}.rb" do
        open_class(class_names)
        write_initialize_method
        write_execute_method

        close_class(class_names)

        @rets
      end
    end

    def create_tests(file, class_names)
      @rets = nil
      create_file "test/unit/#{file}_test.rb" do
        open_test_class(class_names, file)
        add_before_hook(class_names)
        append(0, "\n")
        context_class
        append(0, "\n")
        context_instance
        close_test_class
        @rets
      end
    end

    def append(depth, string)
      (@rets ||= "") << ("  " * depth) + string
    end

    def class_string(names)
      names.map(&:to_s).join("::")
    end
  end
end
