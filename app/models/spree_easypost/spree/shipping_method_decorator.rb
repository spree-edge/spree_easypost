module SpreeEasypost
  module Spree
    module ShippingMethodDecorator

      # Some shipping methods are only meant to be set via backend
      def frontend?
        self.display_on != "back_end" && !none?
      end

      # Some shipping methods should not be displayed at all
      def none?
        self.display_on == "none"
      end

      # Only should shipping methods that need to be displayed
      def available_to_display(display_filter)
        (frontend? && display_filter == ::Spree::ShippingMethod::DISPLAY_ON_FRONT_END) ||
        (!frontend? && display_filter == ::Spree::ShippingMethod::DISPLAY_ON_BACK_END)
      end

    end
  end
end

Spree::ShippingMethod.prepend SpreeEasypost::Spree::ShippingMethodDecorator