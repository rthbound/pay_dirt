require_relative 'use_case'

# Here's something you can inherit from
module PayDirt
  class Base
    include PayDirt::UseCase
  end
end
