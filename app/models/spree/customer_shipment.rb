module Spree
  class CustomerShipment < Spree::Base
    include Spree::Core::NumberGenerator.new(prefix: 'CS', length: 11)

    extend FriendlyId
    friendly_id :number, slug_column: :number, use: :slugged

    before_create :generate_label
    before_destroy :refund_label

    belongs_to :return_authorization
    
    has_one :order, through: :return_authorization
    has_one :stock_location, through: :return_authorization

    self.whitelisted_ransackable_associations = %w[return_authorization]
    self.whitelisted_ransackable_attributes = %w[number tracking]

    def generate_label
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

      easyshipment = client.shipment.buy(easypost_shipment.id, :rate => easypost_shipment.lowest_rate, end_shipper_id: end_shipper.id) unless easypost_shipment.postage_label
      self.easypost_shipment_id = easyshipment.id
      self.tracking = easyshipment.tracking_code
      self.tracking_label = get_label_pdf
      self.weight = easyshipment.parcel.weight
    end

    def refund_label
      begin
        easypost_shipment.refund
      rescue
        puts 'could not refund label!'
      end
      return true
    end

    def get_label_pdf
      client = EasyPost::Client.new(api_key: SpreeEasypost::Config[:api_key])
      label = client.shipment.label(easypost_shipment.id, file_format: "PDF")
      label.postage_label.label_pdf_url
    end

    private

    def easypost_shipment
      client = EasyPost::Client.new(api_key: SpreeEasypost::Config[:api_key])
      if self.easypost_shipment_id
        @ep_shipment ||= client.shipment.retrieve(self.easypost_shipment_id)
      else
        @ep_shipment ||= build_easypost_shipment
      end
    end

    def carrier_accounts
      SpreeEasypost::Config[:carrier_accounts_returns].split(",")
    end

    def build_easypost_shipment
      client = EasyPost::Client.new(api_key: SpreeEasypost::Config[:api_key])
      client.shipment.create(
        from_address: stock_location.easypost_address,
        to_address: order.ship_address.easypost_address,
        reference: return_authorization.number,
        parcel: build_parcel,
        carrier_accounts: carrier_accounts,
        options: { print_custom_1: return_authorization.number,
                   print_custom_1_barcode: true,
                   print_custom_2: build_sku_list,
                   print_custom_2_barcode: false },
        is_return: true
      )
    end

    def build_parcel
      # The parcel should be the sum of all the items
      parcel_weight = 0

      if !return_authorization.custom_weight.nil? && return_authorization.custom_weight > 0
        parcel_weight = return_authorization.custom_weight
      else
        parcel_weight = return_authorization.inventory_units.joins(:variant).sum(:weight)
      end
      client = EasyPost::Client.new(api_key: SpreeEasypost::Config[:api_key])
      client.parcel.create(
        :weight => parcel_weight
      )
    end

    def build_sku_list
      inventory_units = return_authorization.inventory_units
      inventory_units.map{|v| v.variant.sku }.join("|")[0..35] # Most carriers have a 35 char limit
    end
  end
end
