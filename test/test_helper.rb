require 'coveralls'
Coveralls.wear!

require "minitest/autorun"

# The gem
$: << File.dirname(__FILE__) + "/../lib"
$: << File.dirname(__FILE__)

`thor pay_dirt:service_object:new quick/digit_check     -d fingers toes nose -D fingers:10 toes:10`
`thor pay_dirt:service_object:new quick/digit_guarantee -d fingers toes nose -D fingers:10 toes:10 -V`
