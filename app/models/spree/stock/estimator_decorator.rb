module Spree
  module Stock
    module EstimatorDecorator
      def shipping_rates(package, shipping_method_filter = ShippingMethod::DISPLAY_ON_FRONT_END)

        # Only use easypost on the FrontEnd if the flag is set and the package
        # flag allows for it to be used. Otherwise use the default spree methods.
        # This allows for faster load times on the front end if we dont want to do dyanmic shipping

        if use_easypost_to_calculate_rate?(package, shipping_method_filter)
          shipment = package.easypost_shipment
          rates = shipment.rates.sort_by { |r| r.rate.to_i }

          shipping_rates = []

          if rates.any?
            rates.each do |rate|
              # See if we can find the shipping method otherwise create it
              shipping_method = find_or_create_shipping_method(rate)
              # Get the calculator to see if we want to use easypost rate
              calculator = shipping_method.calculator
              # Create the easypost rate
              spree_rate = Spree::ShippingRate.new(
                cost: calculator == Spree::Calculator::Shipping::EasypostRate ? rate.rate : calculator.compute(package),
                easy_post_shipment_id: rate.shipment_id,
                easy_post_rate_id: rate.id,
                shipping_method: shipping_method
              )
              # Save the rates that we want to show the customer
              shipping_rates << spree_rate if shipping_method.available_to_display(shipping_method_filter)
            end

            # Sets cheapest rate to be selected by default
            if shipping_rates.any?
              shipping_rates.min_by(&:cost).selected = true
            end

            shipping_rates
          else
            []
          end
        else
          rates = calculate_shipping_rates(package, shipping_method_filter)
          choose_default_shipping_rate(rates)
          sort_shipping_rates(rates)
        end
      end

      private

      def use_easypost_to_calculate_rate?(package, shipping_method_filter)
        package.use_easypost? && package.weight > 0 &&
        (ShippingMethod::DISPLAY_ON_BACK_END == shipping_method_filter ||
        ShippingMethod::DISPLAY_ON_BACK_END == shipping_method_filter ||
        is_shipping_rate_dynamic_on_front_end?(shipping_method_filter))
      end

      def is_shipping_rate_dynamic_on_front_end?(shipping_method_filter)
        Spree::Config[:use_easypost_on_frontend] &&
        (ShippingMethod::DISPLAY_ON_FRONT_END == shipping_method_filter)
      end

      # Cartons require shipping methods to be present, This will lookup a
      # Shipping method based on the admin(internal)_name. This is not user facing
      # and should not be changed in the admin.
      def find_or_create_shipping_method(rate)
        method_name = "#{ rate.carrier } #{ rate.service }"
        Spree::ShippingMethod.find_or_create_by(admin_name: method_name) do |r|
          r.name = method_name
          r.display_on = 'back_end'
          r.code = rate.service
          r.calculator = Spree::Calculator::Shipping::FlatRate.create
          r.shipping_categories = [Spree::ShippingCategory.first]
        end
      end
    end
  end
end

Spree::Stock::Estimator.prepend Spree::Stock::EstimatorDecorator
