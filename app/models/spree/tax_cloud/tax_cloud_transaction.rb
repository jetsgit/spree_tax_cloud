# Designed to be the Originator for an Adjustment
# on an order

# require 'exceptional'
require 'spree/tax_cloud'
require 'spree/tax_cloud/tax_cloud_cart_item'
require_dependency 'spree/order'
module Spree

  class TaxCloudTransaction < ActiveRecord::Base

      belongs_to :order

      validates :order, :presence => true

      has_one :adjustment, :as => :originator

      has_many :cart_items, :class_name => 'TaxCloudCartItem', :dependent => :destroy

      # called when order updates adjustments

      def update_adjustment(adjustment, source)

	 adjustment.update_attribute_without_callbacks(:amount, amount)

      end

      def amount

	 cart_items.sum(&:amount)

      end

      def lookup

	 begin

	    create_cart_items

	    response = tax_cloud.lookup(self)

	    raise 'Tax Cloud Lookup Error' unless response.success?


	    transaction do

	       unless response.body[:lookup_response][:lookup_result][:messages].nil?

		  self.message = response.body[:lookup_response][:lookup_result][:messages][:response_message][:message]

	       end

	       self.save

	       response_cart_items = Array.wrap response.body[:lookup_response][:lookup_result][:cart_items_response][:cart_item_response]

	       response_cart_items.each do |response_cart_item|

		  cart_item = cart_items.find_by_index(response_cart_item[:cart_item_index].to_i)

		  cart_item.update_attribute(:amount, response_cart_item[:tax_amount].to_f)

	       end

	    end


	 end

      end

      def capture


	    tax_cloud.capture(self)

      end

      private

      def tax_cloud

	 @tax_cloud ||= TaxCloud.new

      end

      def create_cart_items

	 cart_items.clear

	 index = 0

	 order.line_items.each do |line_item|

	       cart_items.create!({

	       :index => (index += 1),

	       :tic => Spree::Config.taxcloud_product_tic , 

	       :sku => line_item.variant.sku.presence || line_item.variant.id,

	       :quantity => line_item.quantity,

	       :price => line_item.price.to_f,

	       :line_item => line_item

	    })

	 end

	    cart_items.create!({  

	    :index => (index += 1),

	    :tic =>  Spree::Config.taxcloud_shipping_tic ,  

	    :sku => 'SHIPPING',

	    :quantity => 1,

	    :price => order.ship_total.to_f

	 })

      end

   end

end
