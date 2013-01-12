module Spree

  class Admin::TaxCloudSettingsController < Admin::BaseController

    def show
    end

    def update
      preference = params[:preferences]
      Spree::Config.set(:taxcloud_origin => {:Address1 =>  preference[:taxcloud_address1],
					    :Address2 => preference[:taxcloud_address2],
					    :City => preference[:taxcloud_city],
					    :State => preference[:taxcloud_state],
					    :Zip5 => preference[:taxcloud_zipcode] }.to_json  )

      Spree::Config.set(preference[:taxcloud_api_login_id])
      Spree::Config.set(preference[:taxcloud_api_key])
      Spree::Config.set(preference[:taxcloud_product_tic])
      Spree::Config.set(preference[:taxcloud_shipping_tic])

      respond_to do |format|
	format.html {
	  redirect_to admin_mail_chimp_settings_path
	}
      end
    end
  end
end

