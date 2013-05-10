Spree::AppConfiguration.class_eval do
  preference :taxcloud_api_login_id, :string 
  preference :taxcloud_api_key, :string  
  preference :taxcloud_product_tic, :string
  preference :taxcloud_shipping_tic, :string
  preference :taxcloud_usps_user_id, :string
  preference :taxcloud_origin, :string, :default => {}.to_json
end

