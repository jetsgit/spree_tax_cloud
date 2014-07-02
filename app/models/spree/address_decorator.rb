Spree::Address.class_eval do
  after_save :tax_cloud_compute_tax

  def tax_cloud_compute_tax
    Spree::Order.incomplete.where(ship_address_id: id).find_each(&:tax_cloud_compute_tax)
  end
end

