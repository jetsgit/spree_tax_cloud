Spree::Adjustment.class_eval do
  # Tax adjustments to be "closed" so Spree will not to try to recalculate them automatically.
  validates(
    :state,
    {
      inclusion: {
        in: ['closed'],
        message: "Tax adjustments must always be closed for TaxCloud",
      },
      if: 'source == "Spree::TaxRate"',
    }
  )
end

