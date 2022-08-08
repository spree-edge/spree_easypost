class RemoveNameFromSpreeShippingRates < ActiveRecord::Migration[6.1]
  def change
    remove_column :spree_shipping_rates, :name, :string
  end
end
