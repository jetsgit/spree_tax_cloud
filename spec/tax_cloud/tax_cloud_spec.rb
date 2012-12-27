require 'spec_helper'


module Spree

  describe TaxCloud do

    let(:order) { Factory.build(:order, :ship_address => Factory.build(:address)) }

    let(:tax_cloud_transaction) {

    tax_cloud_transaction = TaxCloudTransaction.new

    tax_cloud_transaction.order = order

    tax_cloud_transaction.cart_items = []

    tax_cloud_transaction

    }

     

    before :each do

      @account = Account.first_or_default

      @account.address = Factory.build(:address,

      :zipcode => '90120')

      @account.save

       

      @params = subject.lookup_params(tax_cloud_transaction)

    end

     

    it 'store account address is used for origin' do

      @params['origin']['Address1'].should eq @account.address.address1

      @params['origin']['Address2'].should eq @account.address.address2

      @params['origin']['City'].should eq @account.address.city

      @params['origin']['Zip5'].should eq @account.address.zipcode

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

end
