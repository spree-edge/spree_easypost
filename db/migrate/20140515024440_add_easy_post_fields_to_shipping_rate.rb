class AddEasyPostFieldsToShippingRate < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_shipping_rates, :name, :string
    add_column :spree_shipping_rates, :easy_post_shipment_id, :string
    add_column :spree_shipping_rates, :easy_post_rate_id, :string
    add_column :spree_shipments, :tracking_label, :text
  end
end
