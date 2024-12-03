module Spree
  module PermittedAttributesDecorator
    mattr_reader :customer_shipment_attributes
    mattr_reader :scan_form_attributes

    @@customer_shipment_attributes = [:tracking, :tracking_label, :weight]
    @@shipment_attributes.push(:tracking_label)

    @@stock_location_attributes.push(:time_zone)

    @@scan_form_attributes = [:stock_location_id]
  end
end

Spree::PermittedAttributes.prepend Spree::PermittedAttributesDecorator