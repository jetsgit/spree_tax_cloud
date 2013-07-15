# Interface to the Tax Cloud SOAP API

require 'savon'
require 'spree/tax_cloud/savon_xml_override'

module Spree

  class TaxCloud

    def lookup(tax_cloud_transaction)
      client.request(:lookup) do
        soap.body = lookup_params(tax_cloud_transaction)
      end
    end


    def lookup_params(tax_cloud_transaction)
      order = tax_cloud_transaction.order
      default_body.merge({ 'customerID' => order.user_id || order.number,
                           'cartID' => order.number,
                           'cartItems' => {'CartItem' => tax_cloud_transaction.cart_items.map(&:to_hash)},
                           'origin' =>   JSON.parse( Spree::Config.taxcloud_origin ),
                           'destination' => destination_address(order.ship_address)
                          })
    end


    def capture(tax_cloud_transaction)
      order = tax_cloud_transaction.order
      client.request(:authorized_with_capture) do
        soap.body = default_body.merge({ 'customerID' => order.user_id,
                                         'cartID' => order.number,
                                         'orderID' => order.number,
                                         'dateAuthorized' => DateTime.now,
                                         'dateCaptured' => DateTime.now
                                       })
      end
    end


    def ping
      client.request(:ping) do
        soap.body = default_body
      end
    end


    private


    def client
      @client ||= Savon::Client.new("https://api.taxcloud.net/1.0/?wsdl")
    end


    def default_body
      {
        'apiLoginID' => Spree::Config.taxcloud_api_login_id,
        'apiKey' => Spree::Config.taxcloud_api_key
      }
    end


    def cart_items(line_items)
      line_items.map do |line_item|
        {
          'CartItem' => {
            'Index' => index,
            'ItemID' => line_item.variant_id,
            'Price' => line_item.price.to_f.to_s,
            'Qty' => line_item.quantity
          }
        }
      end
    end


    def destination_address(address)
      {
        'Address1' =>  address.address1 ,
        'Address2' =>  address.address2 ,
        'City' =>  address.city ,
        'State' =>  address.state_text,
        'Zip5' => address.zipcode[0..4] ,
        'Zip4' =>  nil
      }
    end


    def preference_cache_key(name)
      [self.class.name, name].join('::').underscore
    end

  end #class TaxCloud
end #module Spree
