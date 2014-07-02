require_dependency 'spree/calculator'


module Spree
  class Calculator::TaxCloud < Calculator
    class DummyCompute < StandardError; end
    class BogusAdjustments < StandardError; end

    def self.description
      Spree.t(:tax_cloud_stub_calculator)
    end

    def compute(computable)
      raise UnusedCompute.new("The tax cloud calculator should never use #compute")
    end
  end
end

