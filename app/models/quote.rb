class Quote < ApplicationRecord
    belongs_to :company
    has_many :line_item_dates, dependent: :destroy
    has_many :line_items, through: :line_item_dates
    validates :name, presence: true

    scope :ordered, -> { order(id: :desc) }

    #after_create_commit -> { broadcast_prepend_later_to "quotes" }
    #after_update_commit -> { broadcast_replace_later_to "quotes" }
    #after_destroy_commit -> { broadcast_remove_to "quotes" }

    broadcasts_to ->(quote) { [quote.company, "quotes"] }, inserts_by: :prepend

    def total_price
        line_items.sum(&:total_price)
    end
end

=begin
    after_create_commit -> { broadcast_prepend_to "quotes", partial: "quotes/quote", locals: { quote: self }, target: "quotes" }

    -- First, we use an after_create_commit callback to instruct our Ruby on Rails application that the expression in the lambda should be executed every time a new quote is inserted into the database.

    -- The second part of the expression in the lambda is more complex. It instructs our Ruby on Rails application that the HTML of the created quote should be broadcasted to users subscribed to the "quotes" stream and prepended to the DOM node with the id of "quotes".

    -- As instructed, the broadcast_prepend_to method will render the quotes/_quote.html.erb partial in the Turbo Stream format with the action prepend and the target "quotes" as specified with the target: "quotes" option:
    <turbo-stream action="prepend" target="quotes">
        <template>
            <turbo-frame id="quote_123">
            <!-- The HTML for the quote partial -->
            </turbo-frame>
        </template>
    </turbo-stream>

    -- The only difference is that the HTML is delivered via WebSocket this time instead of in response to an AJAX request!

    -- As we can see above, we specify the target name to be "quotes" thanks to the target: "quotes" option. By default, the target option will be equal to model_name.plural, which is equal to "quotes" in the context of our Quote model. Thanks to this convention, we can remove the target: "quotes" option:
        -> after_create_commit -> { broadcast_prepend_to "quotes", partial: "quotes/quote", locals: { quote: self } }

    -- There are two other conventions we can use to shorten our code. Under the hood, Turbo has a default value for both the partial and the locals option.

    -- The partial default value is equal to calling to_partial_path on an instance of the model, which by default in Rails for our Quote model is equal to "quotes/quote".
    -- The locals default value is equal to { model_name.element.to_sym => self } which, in in the context of our Quote model, is equal to { quote: self }.        
        - after_create_commit -> { broadcast_prepend_to "quotes" }

    -- Changig from:
        - after_create_commit -> { broadcast_prepend_to "quotes" }
        after_update_commit -> { broadcast_replace_to "quotes" }
        after_destroy_commit -> { broadcast_remove_to "quotes" }

        To:

        after_create_commit -> { broadcast_prepend_later_to "quotes" }
        after_update_commit -> { broadcast_replace_later_to "quotes" }
        after_destroy_commit -> { broadcast_remove_to "quotes" }

        Makes it asynchronous

    -- The 3 lines above are the same as: broadcasts_to ->(quote) { "quotes" }, inserts_by: :prepend
=end