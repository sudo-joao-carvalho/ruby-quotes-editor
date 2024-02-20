class QuotesController < ApplicationController
    before_action :set_quote, only: [:show, :edit, :update, :destroy]

    def index
        @quotes = current_company.quotes.ordered
    end

    def show
        @line_item_dates = @quote.line_item_dates.includes(:line_items).ordered
        #with the .includes(:line_items) we solve a perfomance issue
        #when a line_items_date was rendered its line_items were also rendered so we would query
        #the database as many time as line_item_dates exist, so if we include
        #it will only query once
    end

    def new
        @quote = Quote.new
    end

    def create
        @quote = current_company.quotes.build(quote_params)

        if @quote.save
            respond_to do |format|
                format.html { redirect_to quotes_path, notice: "Quote was successfully created." }
                format.turbo_stream { flash.now[:notice] = "Quote was successfully created." }

                #We use flash.now[:notice] here and not flash[:notice] because 
                #Turbo Stream responses don't redirect to other locations,
                #so the flash has to appear on the page right now.
            end
            
        else
            render :new, status: :unprocessable_entity
        end
    end

    def edit
    end

    def update
        if @quote.update(quote_params)
            respond_to do |format|
              format.html { redirect_to quotes_path, notice: "Quote was successfully updated." }
              format.turbo_stream { flash.now[:notice] = "Quote was successfully updated." }
            end
          else
            render :edit, status: :unprocessable_entity
          end
    end

    def destroy
        @quote.destroy

        respond_to do |format|
            format.html { redirect_to quotes_path, notice: "Quote was successfully destroyed" }
            format.turbo_stream { flash.now[:notice] = "Quote was successfully destroyed." }
        end
        
    end

    private
        def set_quote
            @quote = current_company.quotes.find(params[:id])
        end

        def quote_params
            params.require(:quote).permit(:name)
        end
end
