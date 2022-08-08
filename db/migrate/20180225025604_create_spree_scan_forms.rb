class CreateSpreeScanForms < ActiveRecord::Migration[6.1]
  def change
    create_table :spree_scan_forms do |t|
      t.string :easy_post_scan_form_id
      t.belongs_to :stock_location, index: true
      t.text :scan_form
      t.timestamps null: false
    end
  end
end
