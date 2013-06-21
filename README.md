## pay_dirt [![Gem Version](https://badge.fury.io/rb/pay_dirt.png)](http://badge.fury.io/rb/pay_dirt) [![Build Status](https://travis-ci.org/rthbound/pay_dirt.png?branch=master)](https://travis-ci.org/rthbound/pay_dirt) [![Coverage Status](https://coveralls.io/repos/rthbound/pay_dirt/badge.png?branch=master)](https://coveralls.io/r/rthbound/pay_dirt?branch=master) [![Code Climate](https://codeclimate.com/github/rthbound/pay_dirt.png)](https://codeclimate.com/github/rthbound/pay_dirt)

#### A Ruby gem based on the "use case" pattern set forth in [opencurriculum-flashcards](https://github.com/isotope11/opencurriculum-flashcards)

Provides the basic building blocks of a pattern capable of reducing a towering codebase to modular rubble (or more Ruby gems)

There are two ways to employ the pattern:

1. use a class that inherits from [PayDirt::Base](https://github.com/rthbound/pay_dirt/blob/master/test/unit/pay_dirt/base_test.rb#L6-L24)
2. use a class or module that includes [PayDirt::UseCase](https://github.com/rthbound/pay_dirt/blob/master/test/unit/pay_dirt/use_case_test.rb#L6-L26)

### Generators

PayDirt now provides a service object generator, powered by [thor](https://github.com/erikhuda/thor). It takes a few options

`--dependencies` or `-d` : An array of required dependencies (this option is required)

`--defaults` or `-D` : An optional hash of default values for dependencies

`--inherit` or `-i` : A boolean flag, raise it for an implementation that inherits from `PayDirt::Base` (this is default behavior)

`--include` or `-m` : A boolean flag, raise it for an implementation that includes `PayDirt::UseCase`

Example:

```
$ thor pay_dirt:service_object:new digit_check -d fingers toes -D fingers:10 toes:10
  create  lib/service_objects/digit_check.rb
```

Running the above generator will create the following file
```ruby
require 'pay_dirt'

module ServiceObjects
  class DigitCheck < PayDirt::Base
    def initialize(options = {})
      options = {
        fingers: 10,
        toes: 10,
      }.merge(options)

      load_options(:fingers, :toes, options)
    end

    def execute!
      return PayDirt::Result.new(success: true, data: nil)
    end
  end
end
```
We can now call `ServiceObjects::DigitCheck.new(fingers: 10, toes: 10).execute!`
and see a successful return object. Where you take it from there is up to you.

### Other examples
1. [rubeuler](https://github.com/rthbound/rubeuler)
2. [protected_record](https://github.com/rthbound/protected_record)
3. [konamio](https://github.com/rthbound/konamio)
4. [eenie_meenie](https://github.com/rthbound/eenie_meenie)
