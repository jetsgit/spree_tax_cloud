Spree::PromotionHandler::Coupon.class_eval do
  def apply_with_tax_cloud
    apply_without_tax_cloud.tap do
      SpreeTaxCloud::TaxComputer.new(order).compute if successful?
    end
  end

  alias_method_chain :apply, :tax_cloud
end

