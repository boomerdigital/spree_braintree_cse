# encoding: UTF-8
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_braintree_cse'
  s.version     = '3.0.0'
  s.summary     = 'Braintree for Spree with Client-Side Encryption support'
  s.description = ''
  s.required_ruby_version = '>= 2.1.0'

  s.author    = 'Corey Woodcox'
  s.email     = 'corey@railsdog.com'
  s.homepage  = 'http://www.boomer.digital'

  #s.files       = `git ls-files`.split("\n")
  #s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'solidus_core', '~> 1.2'
  s.add_dependency 'activemerchant', '~> 1.48.0'
  s.add_dependency 'braintree', '~> 2.46.0'

  s.add_development_dependency 'capybara'
  s.add_development_dependency 'coffee-rails'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'factory_girl'
  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'sass-rails'
  s.add_development_dependency 'selenium-webdriver'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'sqlite3'
end
