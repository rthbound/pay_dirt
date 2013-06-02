## pay_dirt [![Gem Version](https://badge.fury.io/rb/pay_dirt.png)](http://badge.fury.io/rb/pay_dirt) [![Build Status](https://travis-ci.org/rthbound/pay_dirt.png?branch=master)](https://travis-ci.org/rthbound/pay_dirt) [![Coverage Status](https://coveralls.io/repos/rthbound/pay_dirt/badge.png?branch=master)](https://coveralls.io/r/rthbound/pay_dirt?branch=master)

#### A Ruby gem based on the "use case" pattern set forth in [opencurriculum-flashcards](https://github.com/isotope11/opencurriculum-flashcards)

Provides the basic building blocks of a pattern capable of reducing a towering codebase to modular rubble (or more Ruby gems)

There are two ways to employ the pattern: 

1. use a class that inherits from [PayDirt::Base](https://github.com/rthbound/pay_dirt/blob/master/test/unit/pay_dirt/base_test.rb#L6-L24)
2. use a class or module that includes [PayDirt::UseCase](https://github.com/rthbound/pay_dirt/blob/master/test/unit/pay_dirt/use_case_test.rb#L6-L26)

### Sample PayDirt use case
Example class:
```ruby
class UseCase
  include PayDirt::UseCase

  def initialize(options)
    options = {
      required_option_with_default_value: true
    }.merge(options)

    load_options(:required_option_with_default_value, :required_option, options)
  end

  def execute!
    if !@required_option_with_default_value
      return PayDirt::Result.new(data: return_value, success: true)
    else
      return PayDirt::Result.new(data: return_value, success: false)
    end
  end

  private
  def return_value
    {
      optional_option:  @optional_option,
      required_option1: @required_option_with_default_value,
      required_option2: @required_option
    }
  end
end
```

Example class usage:

```ruby
# Cheating by not injecting all dependencies
result = SomeThing.new(required_option: true).execute! # Returns a PayDirt::Result
!result.successful?                                    #=> false
result.data[:optional_option]                          #=> nil

# Playing nice and injecting all required dependencies
result = SomeThing.new(required_option: true, required_option_with_default_value: false).execute!
result.successful?                                     #=> true
result.data[:optional_option]                          #=> nil

# Making use of an optional option
result = SomeThing.new(required_option: true, optional_option: true).execute!
!result.successful?                                    #=> false
result.data[:optional_option]                          #=> true
```

### Other examples
1. [rubeuler](https://github.com/rthbound/rubeuler)
2. [protected_record](https://github.com/rthbound/protected_record)
3. [konamio](https://github.com/rthbound/konamio)
4. [eenie_meenie](https://github.com/rthbound/eenie_meenie)
