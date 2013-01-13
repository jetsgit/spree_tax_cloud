# Interface to the Tax Cloud SOAP API

require 'savon'
require 'spree/tax_cloud/savon_xml_override'

module Spree

    class TaxCloud


      # include Spree::Preferences::Preferable


      def lookup(tax_cloud_transaction)
puts "I am at top of lookup"
	client.request(:lookup) do

	    soap.body = lookup_params(tax_cloud_transaction)

	end
   puts "I am at bottom of lookup" 
      end

      def lookup_params(tax_cloud_transaction)
puts "I am at top of lookup params"
	 order = tax_cloud_transaction.order
	 default_body.merge({ 'customerID' => order.user_id || order.number,

                              'cartID' => order.number,

                              'cartItems' => {'CartItem' => tax_cloud_transaction.cart_items.map(&:to_hash)},

                             'origin' =>   JSON.parse( Spree::Config.get( :taxcloud_origin )) , 
			       
				# 'origin' => { 'Address1' =>  "P.O. Box 944" ,

                                           # 'Address2' =>  nil ,

                                           # 'City' =>  "Langley",

                                           # 'State' =>  "Wa",

                                           # 'Zip5' =>  "98260" ,

                                           # 'Zip4' =>  nil  },	

                             'destination' => destination_address(order.ship_address)
                           })
                   puts "I am at bottom of lookup params" 
			   

      end

      def capture(tax_cloud_transaction)

	 order = tax_cloud_transaction.order

	 client.request(:authorized_with_capture) do

	 soap.body =default_body.merge({

	    'customerID' => order.user_id,

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
puts "I am at top of lookup body"
	 { 'apiLoginID' => Spree::Config.get( :taxcloud_api_login_id ),

	 'apiKey' => Spree::Config.get( :taxcloud_api_key ) }

	 # { 'apiLoginID' => 'B0866E0',

	 # 'apiKey' => 'DD7CC8D4-A508-40D7-B22A-A0F7546F81AF' }
	  
	puts "I am at bottom of lookup body" 

      end


      def cart_items(line_items)
puts "I am at top of cart_items"
	 index = 0

	 line_items.map do |line_item|

	    { 'CartItem' => { 'Index' => index,

	    'ItemID' => line_item.variant_id,

	    'Price' => line_item.price.to_f.to_s,

	    'Qty' => line_item.quantity }}
puts "I am at bottom of cart_items"
	 end

      end


      def destination_address(address)
puts "I am at top of destination_address"
	 { 'Address1' =>  address.address1 ,

	 'Address2' =>  address.address2 ,

	 'City' =>  address.city ,

	 'State' =>  address.state_text,

	 'Zip5' => address.zipcode[0..4] ,

	 'Zip4' =>  nil  }
puts "I am at bottom of destination_address"
      end

      def origin_address(address)

	 { 'Address1' => address["Address1"],
	   'Address2' =>  address["Address2"],
	   'City' => address["City"],
	   'State' => address["State"],
	   'Zip5' => address["Zip5"],
	   'Zip4' => nil }
      end

      def preference_cache_key(name)

	[self.class.name, name].join('::').underscore

      end


    end

end

