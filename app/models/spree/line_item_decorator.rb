Spree::LineItem.class_eval do
  has_one :tax_cloud_cart_item, :class_name => 'Spree::TaxCloudCartItem', :dependent => :destroy
end
