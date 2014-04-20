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
    adjustments.create do |adjustment|
      adjustment.source    = tax_cloud_transaction
      adjustment.label     = 'Tax'
      adjustment.mandatory = true
      adjustment.eligible  = true
      adjustment.amount    = tax_cloud_transaction.amount
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
