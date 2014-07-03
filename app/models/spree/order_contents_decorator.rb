Spree::OrderContents.class_eval do
  def add_with_tax_cloud(variant, quantity = 1, currency = nil, shipment = nil)
    add_without_tax_cloud(variant, quantity, currency, shipment).tap do
      tax_cloud_compute_tax
    end
  end

  def remove_with_tax_cloud(variant, quantity = 1, shipment = nil)
    remove_without_tax_cloud(variant, quantity, shipment).tap do
      tax_cloud_compute_tax
    end
  end

  def update_cart_with_tax_cloud(params)
    if update_cart_without_tax_cloud(params)
      tax_cloud_compute_tax
      true
    else
      false
    end
  end

  def tax_cloud_compute_tax
    SpreeTaxCloud::TaxComputer.new(order).compute
  end

  alias_method_chain :update_cart, :tax_cloud
  alias_method_chain :add, :tax_cloud
  alias_method_chain :remove, :tax_cloud
end

