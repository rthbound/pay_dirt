# Set up simplecov
require 'simplecov'
require 'simplecov-rcov'
ENV["RAILS_ENV"] = "test"
SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
SimpleCov.start 'rails'

require 'minitest/autorun'
require 'minitest/reporters'

require 'mocha'

require 'ostruct'

# Set up minitest
MiniTest::Unit.runner = MiniTest::SuiteRunner.new
MiniTest::Unit.runner.reporters << MiniTest::Reporters::SpecReporter.new
if ENV['JENKINS']
  require "#{File.dirname(__FILE__)}/support/minitest_junit"
  MiniTest::Unit.runner.reporters << MiniTest::Reporters::JUnitReporter.new
end

require "#{File.dirname(__FILE__)}/../app/models/flashcards"

# NOTE: This file does not load all of the libraries necessary to run any given
# tests.  That falls to rails_helper, pay_dirt_helper, etc.  This way, we can
# keep our dependencies low when running tests that don't depend on the whole
# application
