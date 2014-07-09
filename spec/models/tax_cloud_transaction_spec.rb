require 'spec_helper'

describe Spree::TaxCloudTransaction do

  let(:order) { build(:order, :ship_address => build(:address)) }
  let(:tax_cloud_transaction) {
    tax_cloud_transaction = Spree::TaxCloudTransaction.new
    tax_cloud_transaction.order = order
    tax_cloud_transaction.cart_items = []
    tax_cloud_transaction
  }

  before :each do
    state = create(:state)
    @location = create(:stock_location, address1: '2301 Coliseum Pkwy', city: 'Montgomery', state_id: state.id, zipcode: '36110')
    @params = subject.lookup_params(tax_cloud_transaction)
  end

  it 'stock location address is used for origin' do
    @params['origin']['Address1'].should eq @location.address1
    @params['origin']['Address2'].should eq @location.address2
    @params['origin']['City'].should eq @location.city
    @params['origin']['Zip5'].should eq @location.zipcode
  end

  it 'uses order ship address for destination' do
    @params['destination']['Address1'].should eq order.ship_address.address1
    @params['destination']['Address2'].should eq order.ship_address.address2
    @params['destination']['City'].should eq order.ship_address.city
    @params['destination']['Zip5'].should eq order.ship_address.zipcode
  end

  it 'order number is used for cartID' do
    @params['CartID'].should eq order.number
  end
end
