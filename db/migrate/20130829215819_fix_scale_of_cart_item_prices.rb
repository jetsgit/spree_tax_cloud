class FixScaleOfCartItemPrices < ActiveRecord::Migration
  def up
    change_column :spree_tax_cloud_cart_items, :price,      :decimal, :precision => 8,  :scale => 2
    change_column :spree_tax_cloud_cart_items, :ship_total, :decimal, :precision => 10, :scale => 2
    change_column :spree_tax_cloud_cart_items, :amount,     :decimal, :precision => 13, :scale => 5
  end

  def down
    change_column :spree_tax_cloud_cart_items, :price,      :decimal, :precision => 8, :scale => 5
    change_column :spree_tax_cloud_cart_items, :ship_total, :decimal, :precision => 8, :scale => 5
    change_column :spree_tax_cloud_cart_items, :amount,     :decimal, :precision => 8, :scale => 5
  end
end
