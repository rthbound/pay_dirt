require_relative 'use_case'

module PayDirt
  # A developer can optionally inherit from this base class, rather than include the PayDirt::UseCase module --
  # this is obviously not possible if your service object's class is already inheriting from another class.
  #
  # @since 0.0.0
  class Base
    include PayDirt::UseCase
  end
end
