# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY

  s.name        = 'spree_tax_cloud'
  s.version     = '0.0.77'
  s.authors     = ["Jerrold Thompson"]
  s.email       = 'jet@whidbey.com'
  s.homepage    = 'https://github.com/bluehandtalking/spree_tax_cloud.git'
  s.summary     = 'Spree extension for providing Tax Cloud services in USA.'
  s.description = 'Spree extension for providing Tax Cloud services in USA.'
  s.required_ruby_version = '>= 1.9.3'

  s.add_dependency('spree_core', '~> 1.1.3')
  s.add_runtime_dependency 'savon', '1.2.0'


end
