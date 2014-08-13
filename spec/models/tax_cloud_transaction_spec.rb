require 'spec_helper'

describe Spree::TaxCloudTransaction do

  let(:order) { build(:order, :ship_address => build(:address)) }
  let(:tax_cloud_transaction) {
    tax_cloud_transaction = Spree::TaxCloudTransaction.transaction_from_order(order)
    tax_cloud_transaction
  }

  before :each do
    state = create(:state)
    @location = create(:stock_location, address1: '2301 Coliseum Pkwy', city: 'Montgomery', state_id: state.id, zipcode: '36110')
    @transaction = tax_cloud_transaction
  end

  it 'has a stock location address which is used for origin' do
    @transaction.origin.address1.should eq @location.address1
    @transaction.origin.address2.should eq @location.address2
    @transaction.origin.city.should eq @location.city
    @transaction.origin.zip5.should eq @location.zipcode
  end

  it 'uses order ship address for destination' do
    @transaction.destination.address1.should eq order.ship_address.address1
    @transaction.destination.address2.should eq order.ship_address.address2
    @transaction.destination.city.should eq order.ship_address.city
    @transaction.destination.zip5.should eq order.ship_address.zipcode
  end

  it 'has an order number which is used for cartID' do
    @transaction.cart_id.should eq order.number
  end
end
