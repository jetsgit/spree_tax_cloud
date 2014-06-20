Spree::Adjustment.class_eval do
  scope :taxcloud, -> { where(source_type: 'Spree::TaxCloudTransaction') } 
end

