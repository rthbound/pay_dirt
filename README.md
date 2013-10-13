## pay_dirt [![Gem Version](https://badge.fury.io/rb/pay_dirt.png)](http://badge.fury.io/rb/pay_dirt) [![Build Status](https://travis-ci.org/rthbound/pay_dirt.png?branch=master)](https://travis-ci.org/rthbound/pay_dirt) [![Coverage Status](https://coveralls.io/repos/rthbound/pay_dirt/badge.png?branch=master)](https://coveralls.io/r/rthbound/pay_dirt?branch=master) [![Code Climate](https://codeclimate.com/github/rthbound/pay_dirt.png)](https://codeclimate.com/github/rthbound/pay_dirt)

Provides the basic building blocks of a pattern capable of reducing a towering codebase to modular rubble (or more Ruby gems)

### What is PayDirt

PayDirt gets its name from an 18th century gold mining idiom. One was said to have "struck pay dirt" when his pick axe revealed a vein of ore.
I hit pay dirt when I discovered this pattern. It provides me the freedom to build quickly with the confidence of knowing that testing will be a breeze.

### What is the use case?

Its use case is gem making. It's for getting rid of callbacks and for shipping business logic off to the more suitable (and more portable) location.
It's for packaging use cases up in a modular fashion, where each unit expects to be provided certain dependencies and can be called to provide an expected result.
It makes sure you're using dependency injection so you can painlessly mock all your dependencies.

The basic idea:

1. Initialize an object by supplying ALL dependencies as a single options hash.
2. The object should have ONE public method, `#call`, which will return an expected result object.

What pay_dirt does to help:

1. It will set instance variables from the hash of dependencies, using top level key-value pairs.
2. It will not initialize (it WILL error) without all required dependencies.
3. It allows you to set default values for any dependencies (just merge the `options` argument into your defaults hash before calling `#load_options`)

PayDirt also provides a `PayDirt::Result` object for your service objects to return (it will respond to `#successful?` and `#data`, see some examples). This is entirely optional, as this object can return whatever you like.

### Getting on to it

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
$ thor pay_dirt:service_object:new quick/digit_check -d fingers toes nose -D fingers:10 toes:10
      create  lib/quick/digit_check.rb
      create  test/unit/quick/digit_check_test.rb
      append  test/minitest_helper.rb
```

Running the above generator will create the following object

```ruby
require 'pay_dirt'

module Quick
  class DigitCheck < PayDirt::Base
    def initialize(options = {})
      options = {
        fingers: 10,
        toes: 10,
      }.merge(options)

      load_options(:fingers, :toes, :nose, options)
    end

    def call
      return result(true)
    end
  end
end
```

and the following unit test
```ruby
require 'minitest_helper'

describe Quick::DigitCheck do
  before do
    @subject = Quick::DigitCheck
    @params = {
      fingers: MiniTest::Mock.new,
      toes: MiniTest::Mock.new,
      nose: MiniTest::Mock.new,
    }
  end

  describe "as a class" do
    it "initializes properly" do
      @subject.new(@params).must_respond_to :call
    end

    it "errors when initialized without required dependencies" do
      -> { @subject.new(@params.reject { |k| k.to_s == 'nose' }) }.must_raise RuntimeError
    end
  end

  describe "as an instance" do
    it "executes successfully" do
      result = @subject.new(@params).call
      result.successful?.must_equal true
      result.must_be_kind_of PayDirt::Result
    end
  end
end
```

### Usage:
The class generated can be used in the following manner:
```ruby
require "quick/digit_check"  #=> true
Quick::DigitCheck.new(nose: true).call
 #=> #<PayDirt::Result:0xa0be85c @data=nil, @success=true>
```
As you can see, we can now call `Quick::DigitCheck.new(nose: true).call`
and expect a successful return object. Where you take it from there is up to you.

more examples
-------------
1. [rubeuler](https://github.com/rthbound/rubeuler)
2. [protected_record](https://github.com/rthbound/protected_record)
3. [konamio](https://github.com/rthbound/konamio)
4. [eenie_meenie](https://github.com/rthbound/eenie_meenie)
5. [foaas](https://github.com/rthbound/foaas)
6. [konami-fo](https://github.com/rthbound/konami-fo)

#### PayDirt is a Ruby gem based on the "use case" pattern set forth in [opencurriculum-flashcards](https://github.com/isotope11/opencurriculum-flashcards)
