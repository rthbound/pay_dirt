# Load use case files
Dir["#{File.dirname(__FILE__)}/pay_dirt/**/*.rb"].each { |f| require f }
require "#{File.dirname(__FILE__)}/pay_dirt/base.rb"
