Spree::Product.class_eval do
  validates_format_of :tax_cloud_tic, with: /\A\d{5}\z/, message: "should be in the standard TaxCloud TIC five-digit form"
  
  def tax_cloud_tic
    # Use the store-default TaxCloud product TIC if none is defined for this product
    read_attribute(:tax_cloud_tic) || Spree::Config.taxcloud_default_product_tic
  end
  
  def tax_cloud_tic=(tic)
    # Empty strings are written as nil (which avoids the format validation)
    write_attribute(:tax_cloud_tic, tic.present? ? tic : nil)
  end
  
end