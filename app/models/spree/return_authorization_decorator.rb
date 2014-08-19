module Spree 
  ReturnAuthorization.class_eval do
    def process_return_with_taxcloud_return
      transaction = Spree::TaxCloudTransaction.transaction_with_taxcloud(order, RMA)
      iu_groups = inventory_units.group_by(&:variant_id)
      index = -1
      iu_groups.each do |key,value|
        quantity = value.count
        transaction.cart_items << Spree::TaxCloudTransaction.cart_item_from_return(Spree::LineItem.find(value.first.line_item_id), quantity, index += 1) 
      end     
      response = transaction.lookup
      if !response.blank?
        response_cart_items = response.cart_items
        tax_return_amount = 0.00 
        response_cart_items.each do |cart_item|
          tax_return_amount += round_to_two_places( cart_item.tax_amount )
        end
        transaction.returned 
        Adjustment.create(adjustable: order, amount: tax_return_amount.abs * -1, label: Spree.t(:rma_tax_credit), source: self)
        order.update! 
      else
        raise ::SpreeTaxCloud::Error, 'TaxCloud response unsuccessful!'
      end
      process_return_without_taxcloud_return 
    end

    alias_method_chain :process_return, :taxcloud_return

    def round_to_two_places(amount)
      BigDecimal.new(amount.to_s).round(2, BigDecimal::ROUND_HALF_UP)
    end
     
  end
end
