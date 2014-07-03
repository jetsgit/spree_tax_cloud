class AddTaxCloudResponseAtToOrders < ActiveRecord::Migration
  def change
    add_column :spree_orders, :tax_cloud_response_at, :datetime
  end
end

