Spree::Order.class_eval do

	has_one :tax_cloud_transaction

	self.state_machine.after_transition :to => :payment, :do => :lookup_tax_cloud, :if => :tax_cloud_eligible?

	self.state_machine.after_transition :to => :complete, :do => :capture_and_authorize_tax_cloud, :if => :tax_cloud_eligible?

	def tax_cloud_eligible?
		line_items.present? && ship_address.try(:state_id?)
	end

	# FIX_ME
	def lookup_tax_cloud
		if tax_cloud_transaction.nil?
			create_tax_cloud_transaction
		end
		update_with_taxcloudlookup
	end

	# DELETE_ME
	# def tax_cloud_adjustment(tax)
	# 	unless ( old_adj = adjustments.select(:id).where("order_id = ? and  source_type = ?", self.id, 'Spree::TaxCloudTransaction' )).blank? 
	# 		Spree::Adjustment.destroy( old_adj )
	# 	end
	# 	adjustments.create do |adjustment|
	# 		adjustment.source = tax_cloud_transaction
	# 		adjustment.label = 'Tax'
	# 		adjustment.mandatory = true
	# 		adjustment.eligible = true
	# 		adjustment.amount = tax
	# 		adjustment.order_id = self.id
	# 	end
	# end

	def capture_and_authorize_tax_cloud
		transaction = Spree::TaxCloudTransaction.transaction_from_order(self)
    transaction.authorized_with_capture 
	end

	# FIX_ME
	# def update_with_taxcloudlookup 
	# 	unless tax_cloud_transaction.nil?
	# 		total_tax = 0.0 
	# 		transaction = Spree::TaxCloudTransaction.transaction_from_order(self)
	# 		response = transaction.lookup
	# 		unless response.blank?
	# 			response_cart_items = response.cart_items
	# 			index = -1
	# 			self.line_items.each do |line_item|
	# 				tax = round_to_two_places( response_cart_items[index += 1].tax_amount ) 
	# 				Spree::LineItem.update( line_item.id, additional_tax_total: tax )
	# 				total_tax += tax
	# 			end
	# 			tax_cloud_adjustment(total_tax)
	# 		else
	# 			raise ::SpreeTaxCloud::Error, 'TaxCloud response unsuccessful!'
	# 		end
	# 	end
	# 	update_without_taxcloud_lookup 
	# end

	# alias_method :update_without_taxcloud_lookup, :update! 
	# alias_method :update!, :update_with_taxcloudlookup 

	#########################################################################
	#########################################################################
	
  def promotion_adjustment_total
    adjustments.promotion.eligible.sum(:amount).abs
  end


  ##
  # Compute  taxcloud, but do not save 
  def tax_cloud_compute_tax
     SpreeAvatax::TaxComputer.new(self).compute
  end

##########################################################################
#########################################################################

	# DELETE_ME
	# def round_to_two_places(amount)
	# 	BigDecimal.new(amount.to_s).round(2, BigDecimal::ROUND_HALF_UP)
	# end

end
