Spree::CheckoutController.class_eval do

  rescue_from TaxCloud::Errors::ApiError do |exception|
    flash[:error] = Spree.t("address_verification_failed")
    redirect_to checkout_state_path(:address)
  end

end
