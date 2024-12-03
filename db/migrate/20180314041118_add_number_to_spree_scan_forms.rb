class AddNumberToSpreeScanForms < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_scan_forms, :number, :string
  end
end
