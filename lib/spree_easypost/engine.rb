module SpreeEasypost
  class Engine < Rails::Engine
    require 'spree/core'
    isolate_namespace Spree
    engine_name 'spree_easypost'

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    initializer 'spree.easypost.preferences', before: :load_config_initializers do |app|
     Spree::AppConfiguration.class_eval do
       preference :buy_postage_when_shipped, :boolean, default: false
       preference :validate_address_with_easypost, :boolean, default: false
       preference :use_easypost_on_frontend, :boolean, default: false
       preference :customs_signer, :string, default: ''
       preference :customs_contents_type, :string, default: 'merchandise'
       preference :customs_eel_pfc, :string, default: 'NOEEI 30.37(a)'
       preference :carrier_accounts_shipping, :string, default: ''
       preference :carrier_accounts_returns, :string, default: ''
       preference :endorsement_type, :string, default: 'RETURN_SERVICE_REQUESTED'
       preference :returns_stock_location_id, :integer, default: 0
     end

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
