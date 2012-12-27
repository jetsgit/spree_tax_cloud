class CreateSpreeTaxCloudTransactions < ActiveRecord::Migration
  def change
    create_table :spree_tax_cloud_transactions do |t|
      t.references :order
      t.string :message

      t.timestamps
    end
    add_index :spree_tax_cloud_transactions, :order_id
  end
end
