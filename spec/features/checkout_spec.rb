require 'spec_helper'

describe 'Checkout', js: true do

  let!(:country) { create(:country, :name => "United States of America",:states_required => true) }
  let!(:state) { create(:state, :name => "Alabama", :country => country) }
  let!(:shipping_method) { create(:shipping_method) }
  let!(:stock_location) { create(:stock_location, country_id: country.id, state_id: state.id) }
  let!(:mug) { create(:product, :name => "RoR Mug") }
  let!(:payment_method) { create(:payment_method) }
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
  end

  before do
    visit spree.products_path
    click_link "RoR Mug"
    click_button "add-to-cart-button"
    click_button "Checkout"
  end

  it "should display tax lookup error if invalid address" do
    fill_in "order_email", :with => "test@example.com"
    click_button "Continue"

    address = "order_bill_address_attributes"
    fill_in "#{address}_firstname", :with => "John"
    fill_in "#{address}_lastname", :with => "Doe"
    fill_in "#{address}_address1", :with => "143 Swan Street"
    fill_in "#{address}_city", :with => "Montgomery"
    select "United States of America", :from => "#{address}_country_id"
    select "Alabama", :from => "#{address}_state_id"
    fill_in "#{address}_zipcode", :with => "12345"
    fill_in "#{address}_phone", :with => "(555) 5555-555"
    click_button "Save and Continue"
    click_button "Save and Continue"
    page.should have_content("The Ship To zip code (12345) is not valid for this state (AL)")
  end

  it "should calculate and display tax on payment step" do
    fill_in "order_email", :with => "test@example.com"
    click_button "Continue"
    fill_in_address
    click_button "Save and Continue"
    click_button "Save and Continue"
    # TODO update seeds to make an order with actual tax
    page.should have_content("Tax: $0.00")
  end

  def fill_in_address
    address = "order_bill_address_attributes"
    fill_in "#{address}_firstname", :with => "John"
    fill_in "#{address}_lastname", :with => "Doe"
    fill_in "#{address}_address1", :with => "143 Swan Street"
    fill_in "#{address}_city", :with => "Montgomery"
    select "United States of America", :from => "#{address}_country_id"
    select "Alabama", :from => "#{address}_state_id"
    fill_in "#{address}_zipcode", :with => "36110"
    fill_in "#{address}_phone", :with => "(555) 5555-555"
  end

end
