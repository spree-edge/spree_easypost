module Spree
  module Api
    module ApiHelpersDecorator
        mattr_reader :customer_shipment_attributes, :scan_form_attributes

        @@customer_shipment_attributes = [:id, :number, :return_authorization_id, :tracking, :tracking_label, :weight, :created_at, :updated_at]

        @@scan_form_attributes = [:stock_location_id]
        
        # @@shipment_attributes.push(:tracking_label)

        # @@stock_location_attributes.push(:time_zone)
    end
  end
end
