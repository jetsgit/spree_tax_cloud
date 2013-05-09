require_relative 'tax_cloud/tax_cloud_transaction'
# require 'spree/calculator/promotion_tax'

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

      else

	 create_tax_cloud_transaction

	 tax_cloud_transaction.lookup

	 tax_cloud_adjustment

      end

   end
   
   def tax_cloud_adjustment

      adjustments.create do |adjustment|

	 adjustment.source = self

	 adjustment.originator = tax_cloud_transaction

	 adjustment.label = 'Tax'

	 adjustment.mandatory = true

	 adjustment.eligible = true

	 adjustment.amount = tax_cloud_transaction.amount 

      end
   end
    


 
   def capture_tax_cloud

      return unless tax_cloud_transaction

      tax_cloud_transaction.capture

   end

   def tax_cloud_total(order)

     line_items_total = order.line_items.sum(&:total)

     cloud_rate = order.tax_cloud_transaction.amount / ( line_items_total + order.ship_total )  

     adjusted_total = line_items_total + order.adjustment_total

     round_to_two_places( adjusted_total * cloud_rate ) 
      
   end

   def round_to_two_places(amount)
     BigDecimal.new(amount.to_s).round(2, BigDecimal::ROUND_HALF_UP)
   end


   def update_with_taxcloudlookup 

      unless tax_cloud_transaction.nil?

	tax_cloud_transaction.lookup 

      end

      update_without_taxcloud_lookup 

   end

   # alias_method :update_without_taxcloud_lookup, :update! 
   # alias_method :update!, :update_with_taxcloudlookup 



end
