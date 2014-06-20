Spree::Order.class_eval do

	has_one :tax_cloud_transaction

	self.state_machine.after_transition :to => :payment, :do => :lookup_tax_cloud, :if => :tax_cloud_eligible?

	self.state_machine.after_transition :to => :complete, :do => :capture_tax_cloud, :if => :tax_cloud_eligible?

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
		binding.pry
		line_items.each do |line_item|
			line_item.adjustments.create({
				source:  self,
				label:  'Tax from TaxCloud',
				mandatory:  true,
				eligible:  true,
				amount:  line_item.tax_cloud_cart_item.amount
			}) 
		end
	end

	def promotions_total
		adjustments.eligible.promotion.map(&:amount).sum.abs
	end

	def capture_tax_cloud
		return unless tax_cloud_transaction
		tax_cloud_transaction.capture
	end
	end
