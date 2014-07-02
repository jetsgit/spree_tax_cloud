Spree::LineItem.class_eval do
  has_one :tax_cloud_cart_item, :class_name => 'Spree::TaxCloudCartItem', :dependent => :destroy
  # attr_accessor :additional_tax_total

  # DELETE_ME
  # def update_adjustments
  #   if quantity_changed?
  #     # update_tax_charge. Called to ensure pre_tax_amount is updated.
  #     # recalculate_adjustments
  #     unless self.order.tax_cloud_transaction.nil?
  #       total_tax = 0.0 
  #       transaction = Spree::TaxCloudTransaction.transaction_from_order(self.order)
  #       response = transaction.lookup
  #       unless response.blank?
  #         response_cart_items = response.cart_items
  #         index = -1
  #         self.order.line_items.each do |line_item|
  #           tax = self.order.round_to_two_places( response_cart_items[index += 1].tax_amount ) 
  #           line_item.additional_tax_total = tax
  #           total_tax += tax
  #         end
  #         self.order.tax_cloud_adjustment(total_tax)
  #       else
  #         raise ::SpreeTaxCloud::Error, 'TaxCloud response unsuccessful!'
  #       end
  #     end
  #   end
  # end
end
