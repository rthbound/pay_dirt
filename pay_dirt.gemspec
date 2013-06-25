# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "pay_dirt/version"

Gem::Specification.new do |s|
  s.name        = "pay_dirt"
  s.version     = PayDirt::VERSION
  s.authors     = ["Tad Hosford"]
  s.email       = ["tad.hosford@gmail.com"]
  s.homepage    = "http://ea.rthbound.com/pay_dirt"

  s.description = <<-description
    Provides the basic building blocks
    of a pattern capable of reducing a
    towering codebase to modular rubble
    (or more Ruby gems)
  description
  s.summary     = <<-summary
    Reduce a towering codebase to modular
    rubble (or more rubygems) with pay_dirt
  summary

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "minitest"
  s.add_development_dependency "thor"
  s.add_development_dependency "coveralls"
  s.add_development_dependency "rake"
end
