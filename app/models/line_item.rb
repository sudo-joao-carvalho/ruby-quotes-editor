class LineItem < ApplicationRecord
  belongs_to :line_item_date

  validates :name, presence: true
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :unit_price, presence: true, numericality: { greater_than: 0 }

  delegate :quote, to: :line_item_date

  def total_price
    quantity * unit_price
  end
end

=begin
  We also delegate the quote method to the LineItem#line_item_date method. That way, the two following lines are equivalent:

  line_item.line_item_date.quote
  line_item.quote
=end