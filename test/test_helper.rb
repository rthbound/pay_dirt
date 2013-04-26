# Set up simplecov
ENV["RAILS_ENV"] = "test"

require "minitest/spec"
require "minitest/autorun"

# Debugger
require "pry"

# The gem
$: << File.dirname(__FILE__) + "/../lib"
$: << File.dirname(__FILE__)

require "pay_dirt"
require "pay_dirt/base.rb"
