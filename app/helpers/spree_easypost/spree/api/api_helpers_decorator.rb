module SpreeEasypost
  module Spree
    module Api
      module ApiHelpersDecorator
          mattr_reader :customer_shipment_attributes, :scan_form_attributes

          @@customer_shipment_attributes = [:id, :number, :return_authorization_id, :tracking, :tracking_label, :weight, :created_at, :updated_at]

          @@scan_form_attributes = [:stock_location_id]
      end
    end
  end
end
