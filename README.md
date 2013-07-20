## pay_dirt [![Gem Version](https://badge.fury.io/rb/pay_dirt.png)](http://badge.fury.io/rb/pay_dirt) [![Build Status](https://travis-ci.org/rthbound/pay_dirt.png?branch=master)](https://travis-ci.org/rthbound/pay_dirt) [![Coverage Status](https://coveralls.io/repos/rthbound/pay_dirt/badge.png?branch=master)](https://coveralls.io/r/rthbound/pay_dirt?branch=master) [![Code Climate](https://codeclimate.com/github/rthbound/pay_dirt.png)](https://codeclimate.com/github/rthbound/pay_dirt)

#### A Ruby gem based on the "use case" pattern set forth in [opencurriculum-flashcards](https://github.com/isotope11/opencurriculum-flashcards)

Provides the basic building blocks of a pattern capable of reducing a towering codebase to modular rubble (or more Ruby gems)

There are two ways to employ the pattern:

1. use a class that inherits from [PayDirt::Base](https://github.com/rthbound/pay_dirt/blob/master/test/unit/pay_dirt/base_test.rb#L6-L24)
2. use a class or module that includes [PayDirt::UseCase](https://github.com/rthbound/pay_dirt/blob/master/test/unit/pay_dirt/use_case_test.rb#L6-L26)

service object generator
------------------------
pay_dirt now provides a service object generator,
powered by [thor](https://github.com/erikhuda/thor).
In order to use them in your rails app, you'll need to install the task. Here's how:

```
$ thor install https://raw.github.com/rthbound/pay_dirt/master/pay_dirt.thor
...
Do you wish to continue [y/N]? y
Please specify a name for https://raw.github.com/rthbound/pay_dirt/master/pay_dirt.thor in the system repository [pay_dirt.thor]: pay_dirt
Storing thor file in your system repository
$
```

After installing, you can use your new generator *anywhere* you can use thor. It'll tell you **how it's used**:

```
$ thor help pay_dirt:service_object:new
Usage:
  thor pay_dirt:service_object:new FILE -d, --dependencies=one two three

Options:
  -d, --dependencies=one two three  # specify required dependencies
  -D, [--defaults=key:value]        # specify default dependencies
  -i, [--inherit]                   # inherit from PayDirt::Base class
                                    # Default: true
  -m, [--include]                   # include the PayDirt::UseCase module (overrides --inherit)

create a service object
```

example
-------
```
$ thor pay_dirt:service_object:new digit_check -d fingers toes nose -D fingers:10 toes:10
      create  lib/service_objects/digit_check.rb
      create  test/unit/service_objects/digit_check_test.rb
      append  test/minitest_helper.rb
```

Running the above generator will create the following object

```ruby
require 'pay_dirt'

module ServiceObjects
  class DigitCheck < PayDirt::Base
    def initialize(options = {})
      options = {
        fingers: 10,
        toes: 10,
      }.merge(options)

      load_options(:fingers, :toes, :nose, options)
    end

    def execute!
      return result(true)
    end
  end
end
```

and the following unit test
```ruby
require 'minitest_helper'

describe ServiceObjects::DigitCheck do
  before do
    @subject = ServiceObjects::DigitCheck
    @params = {
      fingers: MiniTest::Mock.new,
      toes: MiniTest::Mock.new,
      nose: MiniTest::Mock.new,
    }
  end

  describe "as a class" do
    it "initializes properly" do
      @subject.new(@params).must_respond_to :execute!
    end

    it "errors when initialized without required dependencies" do
      -> { @subject.new(@params.reject { |k| k.to_s == 'nose' }) }.must_raise RuntimeError
    end
  end

  describe "as an instance" do
    it "executes successfully" do
      result = @subject.new(@params).execute!
      result.successful?.must_equal true
      result.must_be_kind_of PayDirt::Result
    end
  end
end
```

### Usage:
```ruby
require "service_objects/digit_check"  #=> true
ServiceObjects::DigitCheck.new.execute!
 #=> #<PayDirt::Result:0xa0be85c @data=nil, @success=true>
```
As you can see, we can now call `ServiceObjects::DigitCheck.new(fingers: 10, toes: 10).execute!`
and expect a successful return object. Where you take it from there is up to you.

more examples
-------------
1. [rubeuler](https://github.com/rthbound/rubeuler)
2. [protected_record](https://github.com/rthbound/protected_record)
3. [konamio](https://github.com/rthbound/konamio)
4. [eenie_meenie](https://github.com/rthbound/eenie_meenie)
