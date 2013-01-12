module Spree

  class Admin::TaxCloudSettingsController < Admin::BaseController

    def show
    end

    def update
      origin = params[:address]
      Spree::Config.set(:taxcloud_origin => {:Address1 =>  origin[:taxcloud_address1],
					    :Address2 => origin[:taxcloud_address2],
					    :City => origin[:taxcloud_city],
					    :State => origin[:taxcloud_state],
					    :Zip5 => origin[:taxcloud_zip5] }.to_json  )

      # Spree::Config.set(:taxcloud_api_login_id => origin[:taxcloud_api_login_id])
      # Spree::Config.set(:taxcloud_api_key => origin[:taxcloud_api_key])
      # Spree::Config.set(:taxcloud_product_tic => origin[:taxcloud_product_tic])
      # Spree::Config.set(:taxcloud_shipping_tic => origin[:taxcloud_shipping_tic])

      Spree::Config.set(params[:preferences])


      respond_to do |format|
	format.html {
	  redirect_to admin_tax_cloud_settings_path
	}
      end
    end
  end
end

