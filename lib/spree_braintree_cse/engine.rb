module Spree::BraintreeCSE
  class Engine < Rails::Engine
    require 'spree/core'
    isolate_namespace Spree
    engine_name 'spree_braintree_cse'

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end


    # sets the manifests / assets to be precompiled, even when initialize_on_precompile is false
    initializer "spree_braintree_cse.assets.precompile", :group => :all do |app|
      app.config.assets.precompile += %w[
        braintree.js
      ]
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')) do |c|
        require_dependency c
      end
    end

    config.to_prepare &method(:activate).to_proc
  end
end
