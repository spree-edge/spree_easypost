class AddEasyPostFieldsToShippingCategory < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_shipping_categories, :use_easypost, :boolean, default: false
  end
end
