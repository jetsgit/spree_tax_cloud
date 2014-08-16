require 'spec_helper'

describe 'Checkout', js: true do

  let!(:country) { create(:country, :name => "United States of America",:states_required => true) }
  let!(:state) { create(:state, :name => "Washington", abbr: "WA", :country => country) }
  
  let!(:stock_location) { create(:stock_location, address1: "322 Main St", city: "Langley", state_id: state.id, zipcode: "98117", country_id: country.id) }

  let!(:mug) { create(:product, :name => "RoR Mug") }
  let!(:payment_method) { create(:check_payment_method) }

  let!(:zone) do
      zone = create(:zone, name: "US")
      zone.members.create(zoneable: country)
      return zone
  end

  # let!(:shipping_calculator) { create(:calculator) } 
  let!(:shipping_method) { create(:shipping_method, tax_category_id: 1, zones: [zone]) } 

  let!(:tax_rate) { create(:tax_rate, amount: 0, name: "Sales Tax", zone: zone, calculator: Spree::Calculator::CloudTax.create, tax_category: Spree::TaxCategory.first, show_rate_in_label: false) } 

  # let!(:mug) { create(:product, name: "RoR Mug", price: 10) }

  before do
    Spree::Product.delete_all
    @product = create(:product, name:  "RoR Mug", price: 10.00, sku: "1#mug" )
    @product.shipping_category = shipping_method.shipping_categories.first
    @product.save!
    stock_location.stock_items.update_all(count_on_hand: 1)
    Spree::StockLocation.first.update_attributes(address1: '322 Main St.', city: 'Langley', state_id: state.id, zipcode: '98260')
  end

  before do
    visit spree.products_path
    click_link "RoR Mug"
    click_button "add-to-cart-button"
    click_button "Checkout"
  end

  it "should display tax lookup if valid zip code" do
    fill_in "order_email", :with => "test@example.com"
    fill_in_address(default_address)
    click_button "Save and Continue"
    page.should_not have_content("Address Verification Failed")
  end

  it "should display tax lookup error if invalid zip code" do
    fill_in "order_email", :with => "test@example.com"
    fill_in_address(default_address)
    fill_in "order_bill_address_attributes_zipcode", with: '12345' 
    click_button "Save and Continue"
    page.should have_content("Address Verification Failed")
  end
  

  it "should calculate and display tax on payment step and allow full checkout" do
    fill_in "order_email", with: "test@example.com"
    fill_in_address(default_address)
    find(:css, "#order_use_billing[value='1']").set(true)
    click_button "Save and Continue"
    click_on "Save and Continue"
    click_on "Save and Continue"
    expect(current_path).to match(spree.order_path(Spree::Order.last))
  end

  it 'should not break when removing all items from cart after a tax calculation has been created' do
    fill_in "order_email", :with => "test@example.com"
    fill_in_address(default_address)
    click_button "Save and Continue"
    click_button "Save and Continue"
    page.should have_content("Order Total: $21.90")
    visit spree.cart_path
    find('a.delete').click
    page.should have_content('Shopping Cart')
    page.should_not have_content('Internal Server Error')
  end

  def default_address
    address = Spree::Address.new()
    address.firstname = "John"
    address.lastname = "Doe"
    address.address1 = "329 N.W. 79th St."
    address.city = "Seattle"
    address.country = Spree::Country.where(name: "United States of America").first
    address.state = Spree::State.where(name: "Washington").first
    address.zipcode = "98117"
    address.phone = "(360) 789-1122"
    address
  end

  def stock_location_address
    address = Spree::Address.new()
    address.address1 = "329 N.W. 79th St."
    address.city = "Seattle"
    address.country = Spree::Country.where(name: "United States of America").first
    address.state = Spree::State.where(name: "Washington").first
    address.zipcode = "98117"
    address
  end
  
  def fill_in_address(address)
    fieldname = "order_bill_address_attributes"
    fill_in "#{fieldname}_firstname", with: address.first_name
    fill_in "#{fieldname}_lastname", with: address.last_name
    fill_in "#{fieldname}_address1", with: address.address1
    fill_in "#{fieldname}_city", with: address.city
    select address.country.name, from: "#{fieldname}_country_id"
    select address.state.name, from: "#{fieldname}_state_id"
    fill_in "#{fieldname}_zipcode", with: address.zipcode
    fill_in "#{fieldname}_phone", with: address.phone
  end
  
end
