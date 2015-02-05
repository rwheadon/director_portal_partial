class ReservationsController < ApplicationController

  load_and_authorize_resource  
  
  # GET /reservations
  # GET /reservations.json
  def index
    # @reservations = Reservation.joins(:person => :reservations).where(:people => {:user_id => current_user.id})
      # @reservations = Reservation.joins(:person).where(:people => {:user_id => current_user.id})
    # if current_user.role? :admin  or current_user.role? :registrar
      # @reservations = Reservation.all
    # end   
  
    # @reservations = Reservation.all
    @reservations = Reservation.where('event_id = ?' , 2).where('is_deleted = ?', false )

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @reservations }
    end
  end
  # GET /reservations/1
  # GET /reservations/1.json
  def show
    @reservation = Reservation.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @reservation }
    end
  end 

  # GET /reservations/1/edit
  def edit
    @reservation = Reservation.find(params[:id])
  end

  # PUT /reservations/1
  # PUT /reservations/1.json
  def update
    @reservation = Reservation.find(params[:id])

    respond_to do |format|
      if @reservation.update_attributes(params[:reservation])
        format.html { redirect_to @reservation, notice: 'Reservation was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @reservation.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def filter
    puts params[:reservation][:event]
    puts "our event id is #{params[:reservation][:event]}"
    event_to_filter=params[:reservation][:event]
    if event_to_filter=="" || event_to_filter==nil 
      @reservations = Reservation.all
    else
      @reservations = Reservation.where('event_id = ?' , event_to_filter).where('is_deleted = ?', false )
    end
    puts "got #{@reservations.count} reservations"
    respond_to do |format|
      format.html #index.html.erb
      format.json { render json: @reservations }
    end    
  end
 
 
  
  def check_in_reservation
    puts "checking in : #{params}"
    @reservation = Reservation.find(params[:id])
    puts "reservation id is #{@reservation.id}"
    if @reservation.reservation_cart && @reservation.reservation_cart.invoice && @reservation.reservation_cart.invoice.status=='paid'    
      @reservation.checked_in=true
      @reservation.save
    end
    puts "checking reservation.id"
    if @reservation.id.to_i > 0
      puts "we have an id to filter with"
      filter_be( @reservation.event.id )
    else
      puts "we are making up an id"
      filter_be( 1 )
    end    
  end
  
  private
  def filter_be( reservationId )
     event_to_filter=reservationId
     if event_to_filter=="" || event_to_filter==nil 
       @reservations = Reservation.all
     else
       @reservations = Reservation.where('event_id = ?' , event_to_filter).where('is_deleted = ?', false )
     end
     redirect_to "/reservations" 
   end  
end