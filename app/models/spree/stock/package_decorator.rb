module Spree
  module Stock
    module PackageDecorator

      US_STATES_REQUIRING_CUSTOMS = ["AS", "GU", "MP", "PR", "VI", "UM", "AP", "AE", "AA"]

      def easypost_parcel
        ::EasyPost::Parcel.create weight: weight
      end

      def use_easypost?
        order.ship_address.present? && shipping_categories.any? { |shipping_category| shipping_category.use_easypost }
      end

      def build_sku_list
        contents.map { |item| item.variant.sku }.join("|")[0..35] # Most carriers have a 35 char limit
      end

      def ref_number
        if shipment.nil?
          order.number
        else
          shipment.number
        end
      end

      def shipment
        contents.detect {|item| !!item.try(:inventory_unit).try(:shipment) }.try(:inventory_unit).try(:shipment)
      end

      def customs_required?
       shipping_address = order.ship_address
       (stock_location.country != shipping_address.country) ||
       (US_STATES_REQUIRING_CUSTOMS.any? { |i| 
         i[shipping_address.state&.abbr] if shipping_address.state.present?})
      end

      def stock_location_returns
        Spree::StockLocation.find_by(id: Spree::Config[:returns_stock_location_id])
      end

      def easypost_customs_info
        return if !customs_required?

        customs_items = contents.map do |item|
          variant = item.variant
          product = variant.product

          ::EasyPost::CustomsItem.create(
            description: product.taxons.map { |taxon| taxon.name }.join(" "),
            quantity: item.quantity,
            value: variant.price * item.quantity,
            weight: variant.weight,
            hs_tariff_number: product.easy_post_hs_tariff_number,
            origin_country: stock_location.country.try(:iso),
          )
        end

        raise "Contact Support For EEL/PFC" if order.total > 2500

        ::EasyPost::CustomsInfo.create(
          eel_pfc: Spree::Config[:customs_eel_pfc],
          customs_certify: true,
          customs_signer: Spree::Config[:customs_signer],
          contents_type: Spree::Config[:customs_contents_type],
          customs_items: customs_items,
        )
      end

      def carrier_accounts
        Spree::Config[:carrier_accounts_shipping].split(",")
      end

      def shipment_options
        {
          print_custom_1: ref_number,
          print_custom_1_barcode: true,
          print_custom_2: build_sku_list,
          print_custom_2_barcode: false,
          endorsement: Spree::Config[:endorsement_type]
        }
      end

      def easypost_shipment
        ::EasyPost::Shipment.create(
          to_address: order.ship_address.try(:easypost_address),
          from_address: stock_location.try(:easypost_address),
          return_address: stock_location_returns.try(:easypost_address),
          parcel: easypost_parcel,
          customs_info: easypost_customs_info,
          reference: ref_number,
          carrier_accounts: carrier_accounts,
          options: shipment_options
        )
      end
    end
  end
end

Spree::Stock::Package.prepend Spree::Stock::PackageDecorator
