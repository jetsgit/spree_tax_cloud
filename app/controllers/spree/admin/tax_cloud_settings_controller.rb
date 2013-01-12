module Spree

  class Admin::TaxCloudSettingsController < Admin::BaseController

    def show
    end

    def update
      origin = params[:address]
      taxpref = params[:settings]
      Spree.config { :taxcloud_origin => {:Address1 =>  origin[:taxcloud_address1],
					    :Address2 => origin[:taxcloud_address2],
					    :City => origin[:taxcloud_city],
					    :State => origin[:taxcloud_state],
					    :Zip5 => origin[:taxcloud_zip5] }.to_json }  

      Spree.config { :taxcloud_api_login_id => taxpref[:taxcloud_api_login_id] }
      Spree.config { :taxcloud_api_key => taxpref[:taxcloud_api_key] }
      Spree.config { :taxcloud_product_tic => taxpref[:taxcloud_product_tic] }
      Spree.config { :taxcloud_shipping_tic => taxpref[:taxcloud_shipping_tic] }

      # Spree::Config.set(params[:preferences])


      respond_to do |format|
	format.html {
	  redirect_to admin_tax_cloud_settings_path
	}
      end
    end
  end
end
