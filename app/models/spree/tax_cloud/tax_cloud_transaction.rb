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
    # This version will tax shipping, which is in cart_price

    def update_adjustment(adjustment, source)

      if cart_price.present? && cart_price != 0
        tax_rate =  amount / cart_price
      else
        tax_rate = 0
      end

      taxable = ( cart_price + order.promotions_total )

      tax = round_to_two_places( taxable * tax_rate) 

      adjustment.update_attribute_without_callbacks(:amount, tax)

    end



    def lookup

      create_cart_items

      response = tax_cloud.lookup(self)

      if response.nil?
        return false
      else
        transaction do
          update_attribute :message, response.body.dig(:lookup_response, :lookup_result, :messages, :response_message, :message)

          response_cart_items = Array.wrap(response.body.dig(:lookup_response, :lookup_result, :cart_items_response, :cart_item_response))

          response_cart_items.each do |response_cart_item|
            cart_item = cart_items.find_by_index(response_cart_item[:cart_item_index].to_i)
            cart_item.update_attribute(:amount, response_cart_item[:tax_amount].to_f)
          end

        end #transaction
      end
    end 


    def capture
      tax_cloud.capture(self)
    end


    def amount
      cart_items.map(&:amount).sum
    end


    private


    def cart_price
      total = 0
      cart_items.each do |item|
        total += ( item.price * item.quantity )
      end

      total

    end


    def round_to_two_places(amount)
      BigDecimal.new(amount.to_s).round(2, BigDecimal::ROUND_HALF_UP)
    end


    def tax_cloud
      @tax_cloud ||= TaxCloud.new
    end


    def create_cart_items
      raise TaxCloudProductTicMissing.new unless Spree::Config.taxcloud_product_tic.present?
      raise TaxCloudShippingTicMissing.new unless Spree::Config.taxcloud_shipping_tic.present?
      cart_items.clear
      index = 0
      order.line_items.each do |line_item|
        cart_items.create!({
         :index => (index += 1),
         :tic => Spree::Config.taxcloud_product_tic,
         :sku => line_item.variant.sku.presence || line_item.variant.id,
         :quantity => line_item.quantity,
         :price => line_item.price.to_f,
         :line_item => line_item
        })
       end

      cart_items.create!({  
        :index => (index += 1),
        :tic =>  Spree::Config.taxcloud_shipping_tic,
        :sku => 'SHIPPING',
        :quantity => 1,
        :price => order.ship_total.to_f
      })
    end
  end #TaxCloudTransaction class
end #Spree module
