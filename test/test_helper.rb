require 'coveralls'
Coveralls.wear!

require "minitest/autorun"

# The gem
$: << File.dirname(__FILE__) + "/../lib"
$: << File.dirname(__FILE__)

require_relative "../lib/quick/digit_check" if File.file?("lib/quick/digit_check.rb")

MiniTest::Unit.after_tests do
  # Refresh generated code for next run
  `rm -rf lib/quick`       if File.file? "lib/quick/digit_check.rb"
  `rm -rf test/unit/quick` if File.file? "test/unit/quick/digit_check_test.rb"
  `thor pay_dirt:service_object:new quick/digit_check -d fingers toes nose -D fingers:10 toes:10`

  # Break build if test files are not generated
  (File.file?("lib/quick/digit_check.rb") && File.file?("test/unit/quick/digit_check_test.rb")) or raise
end
require "quick/digit_check"
