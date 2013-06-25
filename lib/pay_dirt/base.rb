require_relative 'use_case'

# Here's something to inherit from
module PayDirt
  class Base
    include PayDirt::UseCase
  end
end
