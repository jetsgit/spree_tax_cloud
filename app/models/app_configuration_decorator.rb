Spree::AppConfiguration.class_eval do
  preference :preferred_taxcloud_api_login_id, :string 
  preference :preferred_taxcloud_api_key, :string  
  preference :taxcloud_origin, :string, :default => {}
  preference :preferred_taxcloud_product_tic, :string, :default => '20020'
  preference :preferred_taxcloud_shipping_tic, :string, :default => '11010'
end

