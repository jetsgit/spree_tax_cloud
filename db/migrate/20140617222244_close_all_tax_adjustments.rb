class CloseAllTaxAdjustments < ActiveRecord::Migration
  def up
    Spree::Adjustment.tax.update_all(state: 'closed')
  end
end

