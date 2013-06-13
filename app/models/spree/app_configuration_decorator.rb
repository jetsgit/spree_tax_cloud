Spree::AppConfiguration.class_eval do
  preference :taxcloud_api_login_id, :string
  preference :taxcloud_api_key, :string
  preference :taxcloud_product_tic, :string, default: '00000'
  preference :taxcloud_shipping_tic, :string, default: '11010'
  preference :taxcloud_usps_user_id, :string
  preference :taxcloud_origin, :string, :default => {}.to_json
end
