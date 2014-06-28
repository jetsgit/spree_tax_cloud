Spree::AppConfiguration.class_eval do
  preference :taxcloud_api_login_id, :string
  preference :taxcloud_api_key, :string
  preference :taxcloud_default_product_tic, :string, default: '00000'
  preference :taxcloud_shipping_tic, :string, default: '11010'
  preference :taxcloud_usps_user_id, :string
  
  TaxCloud.configure do |config|
    config.api_login_id = Spree::Config.taxcloud_api_login_id
    config.api_key = Spree::Config.taxcloud_api_key
    config.usps_username = Spree::Config.taxcloud_usps_user_id
  end
  
  Rails.application.config.spree.calculators.tax_rates << Spree::Calculator::TaxCloudCalculator
end
