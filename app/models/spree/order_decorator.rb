require_relative 'tax_cloud/tax_cloud_transaction'

Spree::Order.class_eval do

   has_one :tax_cloud_transaction


   self.state_machine.after_transition :to => :payment,
					      :do => :lookup_tax_cloud,
					      :if => :tax_cloud_eligible?
  
   self.state_machine.after_transition :to => :complete,
					     :do => :capture_tax_cloud,
					     :if => :tax_cloud_eligible?


   def tax_cloud_eligible?

       ship_address.try(:state_id?)

   end


   def lookup_tax_cloud

      unless tax_cloud_transaction.nil?

	tax_cloud_transaction.lookup

	Spree::Adjustment.where("originator_id = ?", tax_cloud_transaction.id)


      else

	 create_tax_cloud_transaction

	 tax_cloud_transaction.lookup

	 adjustments.create do |adjustment|

	    adjustment.source = self

	    adjustment.originator = tax_cloud_transaction

	    adjustment.label = 'Tax'

	    adjustment.mandatory = true

	    adjustment.eligible = true

	    unless adjustments.eligible.promotion.sum(&:amount).blank?

	       matched_line_items = order.line_items.select do |line_item|
		    line_item.product.tax_category == rate.tax_category
	       end

	       line_items_total = matched_line_items.sum(&:total) 
	       
	       promo_rate = tax_cloud_transaction.amount / line_items_total
	       
	       adjusted_total = line_items_total + order.promotions_total 

	       adjustment.amount = order.line_items.empty? ? 0 : adjusted_total * promo_rate

	    else

	       adjustment.amount = tax_cloud_transaction.amount
	    
	    end

	 end

      end

   end

 

   def capture_tax_cloud

      return unless tax_cloud_transaction

      tax_cloud_transaction.capture

   end

end
