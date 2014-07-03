class AddAvataxResponseAtToOrders < ActiveRecord::Migration
  def change
    add_column :spree_orders, :taxcloud_response_at, :datetime
  end
end

