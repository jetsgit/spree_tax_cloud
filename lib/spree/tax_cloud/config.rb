module Spree::TaxCloud
  class Config < Spree::Config
    class << self
      def instance
        return nil unless ActiveRecord::Base.connection.tables.include?('configurations')
        TaxCloudConfiguration.find_or_create_by_name("TaxCloud configuration")
      end
    end
  end
end

