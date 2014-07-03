class SpreeTaxCloud::TaxRateInvalidOperation < StandardError; end

Spree::TaxRate.class_eval do
  validate :tax_cloud_singleton, on: :create

  class << self
    def match(order)
      [tax_cloud_single_rate]
    end

    # This should never be called. 
    def adjust(order, items)
    end

    # This should never be called. 
    def store_pre_tax_amount
    end

    # Require exactly one tax rate. 
    def tax_cloud_single_rate
      rates = all.to_a
      if rates.size != 1
        if defined?(Honeybadger)
          Honeybadger.notify("#{rates.size} Multiple tax rates detected and there should be only one")
        end
      end
      rates.sort_by(&:id).first
    end
  end

  def adjust(order, item)
    raise SpreeTaxCloud::TaxRateInvalidOperation.new("Spree::TaxRate#adjust should never be called when TaxCloud is present")
  end

  # This should never be called
  def compute_amount(item)
    raise SpreeTaxCloud::TaxRateInvalidOperation.new("Spree::TaxRate#compute_amount should never be called when TaxCloud is present")
  end

  private

  def tax_cloud_singleton
    if Spree::TaxRate.count > 0
      errors.add(:base, "Only one tax rate is allowed.")
    end
  end
end

