module Spree
  class ScanForm < Spree::Base
    include Spree::Core::NumberGenerator.new(prefix: 'SF', length: 11)

    extend FriendlyId
    friendly_id :number, slug_column: :number, use: :slugged

    belongs_to :stock_location
    has_many :shipments, inverse_of: :scan_form

    self.whitelisted_ransackable_associations = %w[stock_location shipments]
    self.whitelisted_ransackable_attributes = %w[scan_form number]

    before_create :get_easy_post_shipments, :generate_scan_form
    after_save :update_shipments

    def update_shipments
      @shipments.update_all(scan_form_id: self.id) if @shipments
    end

    def generate_scan_form
      begin
        if @easy_post_shipments.empty?
          errors.add(:base, "No shipments to create a scan form.")
          return false
        end

        client = EasyPost::Client.new(api_key: SpreeEasypost::Config[:api_key])
        # @scan_form = client.scan_form.create(shipments: @easy_post_shipments)
        @scan_form = client.scan_form.create(shipments: [@easy_post_shipments.first.id])
        self.easy_post_scan_form_id = @scan_form.id
        self.scan_form = @scan_form.form_url
      rescue EasyPost::Errors => e
        errors.add(:base, e.message)
        false
      end
    end

    def get_easy_post_shipments
      time_in_zone = Time.now.in_time_zone(stock_location.time_zone)
      selected_carrier = "USPS" # only USPS does scan forms currently

      @shipments = Spree::Shipment.joins(shipping_rates: :shipping_method)
                                  .where(state: "shipped",
                                         shipped_at: time_in_zone.beginning_of_day..time_in_zone.end_of_day,
                                         stock_location: stock_location,
                                         scan_form_id: nil,
                                         spree_shipping_rates: { selected: true })
                                  .where("spree_shipping_methods.name LIKE ?", "#{selected_carrier}%")
                                  .where.not(tracking_label: nil)
                                  .distinct

      @easy_post_shipments = []
      @shipments.each do |shipment|
        easy_post_shipment = shipment.easypost_shipment
        @easy_post_shipments.push(easy_post_shipment)
      end
    end
  end
end
