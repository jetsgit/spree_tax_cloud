class SpreeTaxCloud::TaxComputer

  DEFAULT_TAX_AMOUNT = 0.0
  DEFAULT_STATUS_FIELD = :tax_cloud_response_at
  NewOrder = true


  class MissingTaxAmountError < StandardError; end

  attr_reader :order, :status_field

  def initialize(order, options = {})
    @status_field = options[:status_field] || DEFAULT_STATUS_FIELD
    @order = order
  end

  def compute
    return unless order.tax_cloud_eligible?
    reset_tax_attributes(order)

    transaction = Spree::TaxCloudTransaction.transaction_with_taxcloud(order, NewOrder) 
    response = transaction.lookup 
    logger.debug(response)
    unless response.blank?
      response_cart_items = response.cart_items
      index = -1
       
      order.line_items.each do |line_item|
        tax_amount = round_to_two_places( response_cart_items[index += 1].tax_amount )
        raise MissingTaxAmountError if tax_amount.nil?

        line_item.update_column(:pre_tax_amount, line_item.discounted_amount)

        line_item.adjustments.tax.create!({
          :adjustable => line_item,
          :amount => tax_amount,
          :order => @order,
          :label => Spree.t(:cloudtax_label),
          :included => false, # true for VAT
          :source => Spree::TaxRate.tax_cloud_single_rate,
          :state => 'closed', # this tells spree not to automatically recalculate tax_cloud tax adjustments
        })
        Spree::ItemAdjustments.new(line_item).update
        line_item.save!
      end

      unless order.shipments.first.blank?
        tax_amount = round_to_two_places( response_cart_items.last.tax_amount ) 
        shipment = order.shipments.first
        shipment.adjustments.tax.create!({
          :adjustable => shipment,
          :adjustable_id => order.shipments.first.id,
          :amount => tax_amount,
          :order => @order,
          :label => "Shipping Tax",
          :included => false,
          :source => Spree::TaxRate.tax_cloud_single_rate,
          :state => 'closed'
        })
        Spree::ItemAdjustments.new(shipment).update
        shipment.save!
      end
    else
      raise ::SpreeTaxCloud::Error, 'TaxCloud response unsuccessful!'
    end

    Spree::OrderUpdater.new(order).update
    order[status_field] = Time.now
    order.save!
  rescue SpreeTaxCloud::Error => e
    handle_spree_tax_cloud_error(e)
  end

  # Clean out old taxes and update 
  def reset_tax_attributes(order)
    order.all_adjustments.tax.destroy_all
    order.line_items.each do |line_item|
      line_item.update_attributes!({
        additional_tax_total: 0,
        adjustment_total: 0,
        pre_tax_amount: 0,
        included_tax_total: 0,
      })

      Spree::ItemAdjustments.new(line_item).update
      line_item.save!
    end

    order.update_attributes!({
      additional_tax_total: 0,
      adjustment_total: 0,
      included_tax_total: 0,
    })

    Spree::OrderUpdater.new(order).update
    order.save!
  end

  def handle_tax_cloud_error(e)
    logger.error(e)
    Honeybadger.notify(e) if defined?(Honeybadger)
    order.update_column(status_field, nil)
  end

	def round_to_two_places(amount)
		BigDecimal.new(amount.to_s).round(2, BigDecimal::ROUND_HALF_UP)
	end
   
  def logger
    @logger ||= Logger.new("#{Rails.root}/log/tax_cloud.log")
  end
end

