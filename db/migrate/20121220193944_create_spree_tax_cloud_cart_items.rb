class CreateSpreeTaxCloudCartItems < ActiveRecord::Migration
  def change
    create_table :spree_tax_cloud_cart_items do |t|
      t.integer :index
      t.integer :tic
      t.string  :sku
      t.integer :quantity 
      t.decimal :price, :precision => 8, :scale => 5, :default => 0
      t.decimal :amount, :precision => 8, :scale => 5, :default => 0
      t.decimal :ship_total, :precision => 8, :scale => 5, :default => 0
      t.references :line_item
      t.references :tax_cloud_transaction
      t.string :type
       
      t.timestamps
    end
    add_index :spree_tax_cloud_cart_items, :line_item_id
    add_index :spree_tax_cloud_cart_items, :tax_cloud_transaction_id
  end
end
