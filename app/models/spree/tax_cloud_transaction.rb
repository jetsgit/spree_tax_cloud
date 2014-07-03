require_dependency 'spree/order'

module Spree
  class TaxCloudTransaction < ActiveRecord::Base

    belongs_to :order

    validates :order, :presence => true

		def self.transaction_from_order(order)
			stock_location = Spree::StockLocation.active.where("city IS NOT NULL and state_id IS NOT NULL").first
			unless stock_location
				raise 'Please ensure you have at least one Stock Location with a valid address for your tax origin.'
			end

			transaction = ::TaxCloud::Transaction.new(
				customer_id: order.user_id || order.email,
				order_id: order.number,
				cart_id: order.number,
				origin: address_from_spree_address(stock_location),
				destination: address_from_spree_address(order.ship_address)

      else
        raise 'TaxCloud::CartItem cannot be made from this item.'
      end
    end

    def self.shipping_item_from_order(order, index)
      ::TaxCloud::CartItem.new(
      index:      index,
      item_id:    "SHIPPING",
      tic:        Spree::Config.taxcloud_shipping_tic,
      price:      order.ship_total,
      quantity:   1
      )
    end    
  end
end
  end
end
