Spree::AppConfiguration.class_eval do
  preference :taxcloud_api_login_id, :string, :default => '' 
  preference :taxcloud_api_key, :string, :default => ''  
  preference :taxcloud_origin, :string, :default => {}
  preference :taxcloud_product_tic, :string, :default => '20020'
  preference :taxcloud_shipping_tic, :string, :default => '11010'
end

