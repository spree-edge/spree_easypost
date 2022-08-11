module SpreeEasypost
  module Spree
    module ShipmentDecorator

      def self.prepended(base)
        base.belongs_to :scan_form, class_name: 'Spree::ScanForm'

        base.state_machine.before_transition(
          to: :shipped,
          do: :buy_easypost_rate,
          if: -> { ::Spree::Config[:buy_postage_when_shipped] }
        )
      end

      def easypost_shipment
        if selected_easy_post_shipment_id
          @ep_shipment ||= ::EasyPost::Shipment.retrieve(selected_easy_post_shipment_id)
        else
          @ep_shipment = to_package.easypost_shipment
        end
      end


      def buy_easypost_rate
        raise "can only buy postage when order is ready" unless (self.state == 'ready' || self.state == 'shipped')

        # regenerate the rates so we get updated data
        refresh_rates(::Spree::ShippingMethod::DISPLAY_ON_BACK_END)
        @ep_shipment = nil

        # Get the selected rate
        rate = easypost_shipment.rates.find do |rate|
          rate.id == selected_easy_post_rate_id
        end

        # Purchase the postage unless it was purchased before
        easypost_shipment.buy(rate) unless self.tracking?
        self.tracking = easypost_shipment.tracking_code
        self.tracking_label = easypost_shipment.postage_label.label_url
      end

      private

      def selected_easy_post_rate_id
        self.selected_shipping_rate.easy_post_rate_id
      end

      def selected_easy_post_shipment_id
        self.selected_shipping_rate.easy_post_shipment_id
      end
    end
  end
end

Spree::Shipment.prepend SpreeEasypost::Spree::ShipmentDecorator