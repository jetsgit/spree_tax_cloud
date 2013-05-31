require 'spec_helper'

 

describe Spree::TaxCloudCartItem do

  let(:line_item) { create(:line_item) }

  it "builds a hash with the line_item properties" do

    cart_item = Spree::TaxCloudCartItem.new(:index => 1,

                                            :tic => 0,

                                            :sku => 'SKU-001',

                                            :quantity => 2,

                                            :price => 5.99,

                                            :line_item => line_item)

    hash = cart_item.to_hash

    hash['Index'].should eq 1

    hash['Price'].should eq "5.99"

    hash['Qty'].should eq 2

    hash['ItemID'].should eq 'SKU-001'

  end

end
