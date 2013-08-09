require 'coveralls'
Coveralls.wear!

require "minitest/autorun"

# The gem
$: << File.dirname(__FILE__) + "/../lib"
$: << File.dirname(__FILE__)

require "quick/digit_check"
