module Spree
  module EasyPost
    module AddressDecorator
      def easypost_address
        attributes = {
          verify: ["zip4", "delivery"],
          street1: address1,
          street2: address2,
          city: city,
          zip: zipcode,
          phone: phone
        }

        attributes[:company] = company if respond_to?(:company)
        attributes[:name] = full_name if respond_to?(:full_name)
        attributes[:state] = state ? state.abbr : state_name
        attributes[:country] = country.try(:iso)

        ::EasyPost::Address.create attributes
      end

      def easypost_address_validate
        return true if !Spree::Config.validate_address_with_easypost

        ep_address = easypost_address
        verifications = ep_address.verifications

        unless success?(verifications.delivery) && success?(verifications.zip4)
          return { errors: get_errors(verifications) }
        else
          return { suggestions: address_suggestions(ep_address) }
        end
      end

      private

      def success?(verification)
        no_errors = !contains_errors_despite_success?(verification.errors)
        successful = verification.success
        no_errors && successful
      end

      def contains_errors_despite_success?(errors)
        unacceptable_errors = [
          "E.SECONDARY_INFORMATION.INVALID",
          "E.SECONDARY_INFORMATION.MISSING"
        ]

        errors.select { |e| unacceptable_errors.include? e.code }.any?
      end

      def get_errors(verifications)
        zip4_errors = add_validation_errors(verifications.zip4.errors)
        delivery_errors = add_validation_errors(verifications.delivery.errors)
        zip4_errors.concat delivery_errors
      end

      def address_suggestions(ep_address)
        {
          address1: ep_address.street1,
          address2: ep_address.street2,
          city: ep_address.city,
          zipcode: ep_address.zip
        }
      end

      def add_validation_errors(verification_errors)
        verification_errors.inject([]) do |prev, err|
          err_code = err.try(:code)
          err_key_name = easypost_errors[err_code]

          prev.push(err_key_name, err.message) if err_key_name
        end
      end

      def easypost_errors
        {
          "E.HOUSE_NUMBER.MISSING" =>          :address1,
          "E.HOUSE_NUMBER.INVALID" =>          :address1,
          "E.STREET.MISSING" =>                :address1,
          "E.STREET.INVALID" =>                :address1,
          "E.BOX_NUMBER.MISSING" =>            :address1,
          "E.BOX_NUMBER.INVALID" =>            :address1,
          "E.SECONDARY_INFORMATION.INVALID" => :address2,
          "E.SECONDARY_INFORMATION.MISSING" => :address2,
          "E.ZIP.NOT_FOUND" =>                 :zipcode,
          "E.ZIP.INVALID" =>                   :zipcode,
          "E.ZIP.PLUS4.NOT_FOUND" =>           :zipcode,
          "E.CITY_STATE.INVALID" =>            :city,
          "E.STATE.INVALID" =>                 :state,
          "E.ADDRESS.DELIVERY.INVALID" =>      :address,
          "E.ADDRESS.INVALID" =>               :address,
          "E.ADDRESS.NOT_FOUND" =>             :address
        }
      end

    end
  end
end

Spree::Address.prepend Spree::EasyPost::AddressDecorator
Spree::StockLocation.prepend Spree::EasyPost::AddressDecorator
