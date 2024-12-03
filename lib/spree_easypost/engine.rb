module SpreeEasypost
  class Engine < Rails::Engine
    require 'spree/core'
    isolate_namespace Spree
    engine_name 'spree_easypost'

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    initializer 'spree_easypost.environment', before: 'spree.environment' do |app|
      require File.join(File.dirname(__FILE__), '../../app/models/spree_easypost/configuration.rb')
    end

    initializer 'spree_easypost.environment', before: :load_config_initializers do |app|
      SpreeEasypost::Config = SpreeEasypost::Configuration.new

     #  Spree::ShippingMethod::DISPLAY += [:none]
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

    config.to_prepare &method(:activate).to_proc
  end
end
