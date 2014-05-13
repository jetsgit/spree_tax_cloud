module Spree
  class Adjustment < ActiveRecord::Base
    scope :tax, -> { where(originator_type: 'Spree::TaxCloudTransaction', adjustable_type: 'Spree::Order') } 
  end
end
