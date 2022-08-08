class AddScanFormToShipments < ActiveRecord::Migration[6.1]
  def change
    add_reference :spree_shipments, :scan_form, index: true
  end
end
