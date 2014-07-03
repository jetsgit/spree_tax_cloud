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
			)

			index = -1 
			order.line_items.each { |line_item| transaction.cart_items << cart_item_from_item(line_item, index += 1) }
			transaction.cart_items << shipping_item_from_order(order, index += 1)

			return transaction
		end

    def self.address_from_spree_address(address)
      ::TaxCloud::Address.new(
      address1:   address.address1,
      address2:   address.address2,
      city:       address.city,
      state:      address.try(:state).try(:abbr), # replace with state_text if possible
      zip5:       address.zipcode[0...5]
      )
    end
    def self.cart_item_from_item(item, index)
      if item.class.to_s == "Spree::LineItem"
        line_item = item
        ::TaxCloud::CartItem.new(
        index:      index,
        item_id:    line_item.try(:variant).try(:sku) || "LineItem " + line_item.id.to_s,
        tic:        line_item.product.tax_cloud_tic,
        price:      line_item.price,
        quantity:   line_item.quantity
        )

      elsif item.class.to_s == "Spree::Shipment"
        shipment = item
        ::TaxCloud::CartItem.new(
        index:      index,
        item_id:    "Shipment " + shipment.number,
        tic:        Spree::Config.taxcloud_shipping_tic,
        price:      shipment.cost,
        quantity:   1
        )

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
