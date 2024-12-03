module Spree
  module Admin
    class EasypostSettingsController < Spree::Admin::BaseController
      before_action :load_stock_locations, only: [:edit, :update]

      def edit
      end

      def update
        update_easypost_settings

        redirect_to admin_easypost_setting_path
      end

      private

      def load_stock_locations
        @stock_locations = Spree::StockLocation.all
      end

      def update_easypost_settings
        easypost_settings_params.each do |key, value|
          SpreeEasypost::Config[key] = value
        end
      end

      def easypost_settings_params
        params.require(:settings).permit(
            :buy_postage_when_shipped,
            :validate_address_with_easypost,
            :use_easypost_on_frontend,
            :customs_signer,
            :customs_contents_type,
            :customs_eel_pfc,
            :carrier_accounts_shipping,
            :carrier_accounts_returns,
            :endorsement_type,
            :returns_stock_location_id,
            :api_key
        )
      end
    end
  end
end
