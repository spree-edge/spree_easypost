module SpreeEasypost
  class Configuration < Spree::Preferences::Configuration
    preference :enabled, :boolean, default: true
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
    preference :api_key, :string
  end
end
