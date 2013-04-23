# Load use case files
require "#{File.dirname(__FILE__)}/pay_dirt/base.rb"
Dir["#{File.dirname(__FILE__)}/pay_dirt/**/*.rb"].each { |f| require f }
