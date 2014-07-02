Spree::Order.class_eval do

	has_one :tax_cloud_transaction

	self.state_machine.after_transition :to => :payment, :do => :lookup_tax_cloud, :if => :tax_cloud_eligible?

	self.state_machine.after_transition :to => :complete, :do => :capture_and_authorize_tax_cloud, :if => :tax_cloud_eligible?

	def tax_cloud_eligible?
		line_items.present? && ship_address.try(:state_id?)
	end

	def lookup_tax_cloud
		if tax_cloud_transaction.nil?
			create_tax_cloud_transaction
		end
		tax_cloud_compute_tax
	end

	def capture_and_authorize_tax_cloud
		transaction = Spree::TaxCloudTransaction.transaction_from_order(self)
    transaction.authorized_with_capture 
	end

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

#########################################################################
#########################################################################

end
