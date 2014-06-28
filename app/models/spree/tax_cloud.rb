# Interface to the Tax Cloud SOAP API

# require 'savon'
# require 'spree/tax_cloud/savon_xml_override'

module Spree
	class TaxCloud

		def initialize
			::TaxCloud.configure do |config|
				config.api_login_id = Spree::Config.taxcloud_api_login_id
				config.api_key = Spree::Config.taxcloud_api_key
				if Spree::Config.taxcloud_usps_user_id
					config.usps_username = Spree::Config.taxcloud_usps_user_id
				else
					config.usps_username = nil
				end
			end
		end


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
												 'origin' => origin_address,
												 'destination' => destination_address(order.ship_address)
			})
		end

		def capture(tax_cloud_transaction)
			order = tax_cloud_transaction.order
			client.request(:authorized_with_capture) do
				soap.body = default_body.merge({
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
			@@client ||= Savon::Client.new('https://api.taxcloud.net/1.0/?wsdl')
		end

		def default_body
			{
				'apiLoginID' => Spree::Config.taxcloud_api_login_id,
				'apiKey'     => Spree::Config.taxcloud_api_key,
				'uspsUserID' => Spree::Config.taxcloud_usps_user_id
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
			address = ::TaxCloud::Address.new({
				:address1 => address.address1,
				:address2 => address.address2,
				:city     => address.city,
				:state    => address.state.abbr,
				:zip5     => address.zipcode[0..4]
			})
			# Only attempt to verify address if user has configured their USPS account.
			if Spree::Config.taxcloud_usps_user_id.present?
				address = address.verify
			end
			address.to_hash
		end

		def origin_address
			if JSON.parse(Spree::Config.taxcloud_origin).empty?
				# TODO: Need to refactor entire extension to lookup tax per shipment in order to properly lookup tax from actual stock location rather than the default.
				stock_location = Spree::StockLocation.active.where("city IS NOT NULL and state_id IS NOT NULL").first
				unless stock_location
					raise 'Please ensure you have at least one Stock Location with a valid address for your tax origin.'
				end
				{
					'Address1' => stock_location.address1,
					'Address2' => stock_location.address2,
					'City'     => stock_location.city,
					'State'    => stock_location.state.abbr,
					'Zip5'     => stock_location.zipcode[0..4]
				}
			else
				JSON.parse Spree::Config.taxcloud_origin
			end
		end

		def preference_cache_key(name)
			[self.class.name, name].join('::').underscore
		end

	end
end
