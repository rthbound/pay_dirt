# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "pay_dirt/version"

Gem::Specification.new do |s|
  s.name        = "pay_dirt"
  s.version     = PayDirt::VERSION
  s.authors     = ["Tad Hosford"]
  s.email       = ["tad.hosford@gmail.com"]
  s.homepage    = "http://github.com/rthbound/pay_dirt"
  s.description = %q{
                      Provides the basic building blocks
                      of a pattern capable of reducing a
                      towering codebase to modular rubble
                      (or more Ruby gems)
                    }
  s.summary     = %q{
                      Based on a pattern introduced to me
                      by knewter.
                    }

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "minitest"
  s.add_development_dependency "rake"
  s.add_development_dependency "pry"
end
