Spree::OrderUpdater.class_eval do

   def update_adjustments_with_taxcloudlookup 

      unless order.tax_cloud_transaction.nil?

	order.tax_cloud_transaction.lookup 

	Spree::Adjustment.where("originator_id = ?", order.tax_cloud_transaction.id)

      end

      update_adjustments_without_taxcloud_lookup 

   end

   alias_method :update_adjustments_without_taxcloud_lookup, :update_adjustments 
   alias_method :update_adjustments, :update_adjustments_with_taxcloudlookup 

end
