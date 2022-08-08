module SpreeEasypost
  module Spree
    module StockLocationDecorator
      #alias the company name to the name of the stock location
      def self.prepended(base)
        base.alias_attribute :company, :name

        base.has_many :scan_forms

        base.whitelisted_ransackable_associations = %w[shipments scan_forms]
        base.whitelisted_ransackable_attributes = %w[id time_zone admin_name]
      end
    end
  end
end

Spree::StockLocation.prepend SpreeEasypost::Spree::StockLocationDecorator