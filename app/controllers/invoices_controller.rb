class InvoicesController < ApplicationController
  load_and_authorize_resource


  # GET /invoices/1
  # GET /invoices/1.json
  def show
    @invoice = Invoice.find(params[:id])
  
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @invoice }
    end
  end
  
end