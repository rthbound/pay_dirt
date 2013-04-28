require_relative "#{File.dirname(__FILE__)}/use_case.rb"
require_relative "#{File.dirname(__FILE__)}/base.rb"


# Here's something you can inherit from
module PayDirt
  class Base
    include PayDirt::UseCase
  end
end
