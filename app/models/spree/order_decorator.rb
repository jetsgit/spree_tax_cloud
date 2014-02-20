require_relative 'tax_cloud/tax_cloud_transaction'

Spree::Order.class_eval do

  has_one :tax_cloud_transaction


  # We do the tax lookup when transitioning from the address state
  # so that if the address is invalid and Tax Cloud cannot determine appropriate taxes,
  # the developer can optionally stop the transition.
  # By stopping the transition, a user can correct their address information.
  self.state_machine.before_transition :from => :address,
      :do => :lookup_tax_cloud,
      :if => :tax_cloud_eligible?


  self.state_machine.after_transition :to => :complete,
      :do => :capture_tax_cloud,
      :if => :tax_cloud_eligible?


  def tax_cloud_eligible?

    ship_address.try(:state_id?)

  end


  def lookup_tax_cloud

    begin

      if tax_cloud_transaction.present?
        # UPDATE
        tax_cloud_transaction.cart_items.destroy
        tax_cloud_transaction.lookup

	tax_cloud_transaction.adjustment.try(:destroy)
        tax_cloud_adjustment

      else
        # CREATE
        create_tax_cloud_transaction
        tax_cloud_transaction.lookup
        tax_cloud_adjustment

      end


    rescue Spree::TaxCloudLookupError => e
      rescue_tax_cloud_lookup_error(e)

    rescue => e
      handle_unknown_lookup_error(e)
    end

  end

  def tax_cloud_adjustment
    #if Tax adjustment already exists then just update the amount

    begin

      tax_adjustments = adjustments.where(:label => :Tax)

      if tax_adjustments.present?
        #UPDATE
        tax_adjustments.first.amount = tax_cloud_transaction.amount

      else
        #CREATE
        adjustments.create do |adjustment|
          adjustment.source = self
          adjustment.originator = tax_cloud_transaction
          adjustment.label = 'Tax'
          adjustment.mandatory = true
          adjustment.eligible = true
          adjustment.amount = tax_cloud_transaction.amount
        end
      end
    rescue => e
      handle_unknown_lookup_error(e)
    end
  end

  def capture_tax_cloud

    begin

      return unless tax_cloud_transaction

      tax_cloud_transaction.capture

    rescue Spree::TaxCloudCaptureError => e
      rescue_tax_cloud_capture_error(e)

    rescue => e
      handle_unknown_capture_error(e)
    end
  end



  def tax_cloud_total(order)

    line_items_total = order.line_items.sum(&:total)

    cloud_rate = order.tax_cloud_transaction.amount / ( line_items_total + order.ship_total )

    adjusted_total = line_items_total + order.promotions_total

    round_to_two_places( adjusted_total * cloud_rate ) 

  end



  def round_to_two_places(amount)
    BigDecimal.new(amount.to_s).round(2, BigDecimal::ROUND_HALF_UP)
  end

  def promotions_total
    promotions = adjustments.eligible.select do |adjustment|
      adjustment.originator_type == "Spree::PromotionAction"  
    end
    
    promotions.map(&:amount).sum 
  end


  private


  def handle_unknown_capture_error(e)
    # By default, we allow the order to continue by returning true.
    # Feel free to override!
    return true
  end


  def handle_unknown_lookup_error(e)
    # By default, we allow the order to continue by returning true.
    # Feel free to override!
    return true
  end

  def rescue_tax_cloud_lookup_error(e)
    # By default, we allow the order to continue by returning true.
    # Feel free to override!
    return true
  end 

  def rescue_tax_cloud_capture_error(e)
    # By default, show the error message to the user and prevent the
    # Feel free to override!
    return true
  end
end
