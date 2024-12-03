class AddTimeZoneToStockLocations < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_stock_locations, :time_zone, :string, :default => "UTC"
  end
end
