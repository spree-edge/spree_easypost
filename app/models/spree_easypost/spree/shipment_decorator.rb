module SpreeEasypost
  module Spree
    module ShipmentDecorator

      def self.prepended(base)
        base.belongs_to :scan_form, class_name: 'Spree::ScanForm'

        base.state_machine.before_transition(
          to: :shipped,
          do: :buy_easypost_rate,
          if: -> { ::SpreeEasypost::Config[:buy_postage_when_shipped] }
        )
      end

      def easypost_shipment
        if selected_easy_post_shipment_id
           client = EasyPost::Client.new(api_key: SpreeEasypost::Config[:api_key])
          @ep_shipment ||= client.shipment.retrieve(selected_easy_post_shipment_id)
        else
          @ep_shipment = to_package.easypost_shipment
        end
      end


      def buy_easypost_rate
        return true unless selected_shipping_rate.easy_post_rate_id.present? # Handled for spree populates shipping rates

        raise "can only buy postage when order is ready" unless (self.state == 'ready' || self.state == 'shipped')

        refresh_rates(::Spree::ShippingMethod::DISPLAY_ON_BACK_END)

        client = EasyPost::Client.new(api_key: SpreeEasypost::Config[:api_key])
        end_shipper = client.end_shipper.create(
          name: stock_location[:name],
          company: stock_location[:company] || stock_location[:name],
          street1: stock_location[:address1] ,
          street2: stock_location[:address2],
          city: stock_location[:city],
          state: stock_location.state ? stock_location.state.abbr : stock_location[:state_name],
          zip: stock_location[:zipcode],
          country: stock_location.country[:iso],
          phone: stock_location[:phone],
          email: order.store.customer_support_email,
        )
        # Purchase the postage unless it was purchased before
        unless self.tracking?
          easy_post_shipment = client.shipment.buy(easypost_shipment.id, rate: easypost_shipment.lowest_rate, end_shipper_id: end_shipper.id,)
          self.tracking = easy_post_shipment.tracking_code
          self.tracking_label = easy_post_shipment.postage_label.label_url
        end
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