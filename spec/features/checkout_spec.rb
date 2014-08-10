require 'spec_helper'

describe 'Checkout', js: true do

  let!(:country) { create(:country, :name => "United States of America",:states_required => true) }
  let!(:state) { create(:state, :name => "Alabama", :country => country) }
  let!(:shipping_method) { create(:shipping_method) }
  let!(:stock_location) { create(:stock_location, country_id: country.id, state_id: state.id) }
  let!(:mug) { create(:product, :name => "RoR Mug") }
  let!(:payment_method) { create(:check_payment_method) }
  let!(:zone) { create(:zone) }

  before do
    Spree::Product.delete_all
    @product = create(:product, :name => "RoR Mug")
    # Not sure if we should fix spree core to not require a shipping category on products...
    @product.shipping_category = shipping_method.shipping_categories.first
    @product.save!

    stock_location.stock_items.update_all(count_on_hand: 1)
    # Ensure it's configured for tax:
    Spree::StockLocation.first.update_attributes(address1: '2301 Coliseum Pkwy', city: 'Montgomery', zipcode: '36110')

    create(:zone)
    # tax_rate = Spree::TaxRate.create(amount: 0, name: "Sales Tax", zone: Spree::Zone.first, calculator: Spree::Calculator::CloudTax.create, tax_category: Spree::TaxCategory.first)
  end

  before do
    visit spree.products_path
    click_link "RoR Mug"
    click_button "add-to-cart-button"
    click_button "Checkout"
  end

  it "should display tax lookup error if invalid zip code" do
    fill_in "order_email", :with => "test@example.com"
    click_button "Continue"

    fill_in_address(default_address)
    fill_in "order_bill_address_attributes_zipcode", with: '12345'

    click_button "Save and Continue"
    click_button "Save and Continue"

    click_button "Save and Continue"
    page.should have_content("Address Verification Failed")
  end

  it "should calculate and display tax on payment step and allow full checkout" do
    fill_in "order_email", with: "test@example.com"
    click_button "Continue"
    fill_in_address(default_address)
    click_button "Save and Continue"
    click_button "Save and Continue"
    # TODO update seeds to make an order with actual tax
    page.should have_content("Tax: $1.74")

    # click_on "Save and Continue"
    # expect(current_path).to match(spree.order_path(Spree::Order.last))
  end

  it 'should not break when removing all items from cart after a tax calculation has been created' do
    fill_in "order_email", :with => "test@example.com"
    click_button "Continue"
    fill_in_address(default_address)
    click_button "Save and Continue"
    click_button "Save and Continue"
    # TODO update seeds to make an order with actual tax
    page.should have_content("Order Total: $19.99")
    visit spree.cart_path
    find('a.delete').click
    page.should have_content('Shopping Cart')
    page.should_not have_content('Internal Server Error')
  end

  def default_address
    address = Spree::Address.new()
    address.firstname = "John"
    address.lastname = "Doe"
    address.address1 = "143 Swan Street"
    address.city = "Montgomery"
    address.country = Spree::Country.where(name: "United States of America").first
    address.state = Spree::State.where(name: "Alabama").first
    address.zipcode = "98260"
    address.phone = "(555) 5555-555"
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
