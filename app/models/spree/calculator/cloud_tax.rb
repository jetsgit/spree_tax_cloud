require_dependency 'spree/calculator'

# This is a no-op calculator that just returns the existing value.
# We hook our tax calculations in SpreeTaxCloud::TaxComputer at the order level instead of here at the line item level

module Spree
  class Calculator::CloudTax < Calculator
    class DummyCompute < StandardError; end
    class BogusAdjustments < StandardError; end

    def self.description
      Spree.t(:cloudtax_description)
    end

    def self.label
      Spree.t(:cloudtax_label)
    end

    def compute_shipping_rate(dummy)
    end

    def compute(computable)
      raise UnusedCompute.new("The tax cloud calculator should never use #compute")
    end
  end
end

