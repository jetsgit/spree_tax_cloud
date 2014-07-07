module Spree
  module Admin
    class TaxCloudSettingsController < Spree::Admin::BaseController
      
      def edit
        @preferences_login = [:taxcloud_api_login_id, :taxcloud_api_key, :taxcloud_usps_user_id]
        @preferences_tic = [:taxcloud_default_product_tic, :taxcloud_shipping_tic]
      end

      def update
        params.each do |name, value|
          next unless Spree::Config.has_preference? name
          Spree::Config[name] = value
        end
        flash[:success] = Spree.t(:successfully_updated, :resource => Spree.t(:tax_cloud_settings))

        redirect_to edit_admin_tax_cloud_settings_path
      end

      def dismiss_alert
        if request.xhr? and params[:alert_id]
          dismissed = Spree::Config[:dismissed_spree_alerts] || ''
          Spree::Config.set :dismissed_spree_alerts => dismissed.split(',').push(params[:alert_id]).join(',')
          filter_dismissed_alerts
          render :nothing => true
        end
      end
      
    end
  end
end

