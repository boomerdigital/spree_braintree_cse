module Spree::BraintreeCSE
  class Engine < Rails::Engine
    require 'spree/core'
    isolate_namespace Spree
    engine_name 'spree_braintree_cse'

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    def self.activate
      Spree::PermittedAttributes.source_attributes << :device_data

      Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')) do |c|
        require_dependency c
      end
    end

    config.to_prepare &method(:activate).to_proc
  end
end
