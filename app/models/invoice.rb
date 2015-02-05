class Invoice < ActiveRecord::Base
  belongs_to :user
  has_many :reservation_carts
  has_many :payment_notifications
  has_many :payments
  accepts_nested_attributes_for :payments
  
  
  def discount_total
    #TODO: MOVE THIS LOGIC INTO THE APPLY COUPON PIECE SINCE THAT'S REALLY WHERE IT BELONGS
    #   NOW THAT WE HAVE PRICE AND DISCOUNT FIELDS ON THE RESERVATION_CART OBJECT
    # ** THIS IS PRETTY MUCH A DUPLICATE OF APPLY COUPON'S LOGIC **
    # TODO: I think that doing self.commit_invoice_prices and then returning self.paid_discount_total will do the trick
    #get all the items that match this coupon
    @discount_amount = 0.00
    unless self.user_coupon_code.nil?
      # puts "we will apply discount for #{self.user_coupon_code} "
      coupon_collection = Coupon.where( "code = ?", self.user_coupon_code)
      unless coupon_collection.empty?
        coupon_object=coupon_collection.first
        # puts "we have a coupon : #{coupon_object.code}"
        if ((coupon_object.use_limit.to_i<1) or (coupon_object.use_limit.to_i>0 and coupon_object.has_remaining?)) and (coupon_object.is_valid_today?)
          @num_remaining=coupon_object.number_remaining      
            if coupon_object.event_restricted?
              self.reservation_carts.joins(:reservation => :event).where( :events => {:id => coupon_object.event_id}).each do |ci|
                @line_discount=0
                @line_price = 0
                if @num_remaining > 0
                  # puts "applying an event restricted coupon to a reservation : #{ci.reservation.event.eventname}"
                  if coupon_object.discount_type=='FIXED'
                    @line_discount = coupon_object.discount_value
                    @discount_amount += @line_discount #coupon_object.discount_value
                  else
                    @line_discount = (ci.reservation.event.price*(coupon_object.discount_value/100).round(2))
                    @discount_amount += @line_discount #(ci.reservation.event.price*(coupon_object.discount_value/100).round(2))
                  end
                  @num_remaining=@num_remaining-1
                end        
              end #end loop
            else
              self.reservation_carts.each do |ci| 
                @line_discount = 0
                @line_price = 0         
                if @num_remaining > 0
                  # puts "applying a coupon to a reservation : #{ci.reservation.event.eventname}"
                  if coupon_object.discount_type=='FIXED'
                    @line_discount = coupon_object.discount_value
                    @discount_amount += @line_discount #coupon_object.discount_value
                  else
                    @line_discount = (ci.reservation.event.price*(coupon_object.discount_value/100).round(2))
                    @discount_amount += @line_discount #(ci.reservation.event.price*(coupon_object.discount_value/100).round(2))
                  end

                  @num_remaining=@num_remaining-1
                end
                
              end #end loop
            end

        end
      end
    end
    # puts "applying a discount amount : #{@discount_amount}"
    @discount_amount
  end
  
  def payment_total
    @admin_payment_total = 0.00
    self.payments.each do |ap|
      unless ap.payment_amount.nil? then @admin_payment_total += ap.payment_amount end
    end
    @admin_payment_total
  end
  
  #adds up all the discounts for the invoice's reservation_carts
  def paid_discount_total
    @discount=nil
    self.reservation_carts.each do |ci|
      unless ci.coupon_id.nil? or ci.coupon_id==0
        unless ci.line_discount.nil? 
          if @discount.nil? then @discount=0 end
          @discount += ci.line_discount
        end
      end
    end
    @discount
  end

  #adds up all of the line price fields for invoice's reservation_carts
  def paid_subtotal
    @subtotal = nil
    self.reservation_carts.each do |rc|
      unless rc.line_price.nil? 
        if @subtotal.nil? then @subtotal=0 end
        @subtotal += rc.line_price
      end
    end
    @subtotal
  end
    
  #subtracts all discounts from all line prices on invoice's reservation_carts
  #   but doesn't let discounts result in a credit.
  #   use this only to calculate invoice balance with discount applied
  #   THIS IS ONLY LINE_PRICE MINUS DISCOUNT FROM RESERVATION_CARTS ZEROED IF RESULT IS NEGATIVE
  def paid_total_balance
      @total_price=self.paid_subtotal
      unless @total_price.nil? 
        pdtot = paid_discount_total
        pdtotal = pdtot.nil? ? 0.00 : pdtot
        @realTotal = @total_price - pdtotal #@total_discount
        if @realTotal > 0 then @total_price=@realTotal else @total_price=0 end
      end
      @total_price    
  end
  
  #This method will commit all prices and coupon discounts to the invoice AND carts so that we change the state to persistent
  #   instead of dynamic to query results. Line total and discount fields were added to the cart specifically for this 
  #   feature, so some legacy code doesn't leverage that change and will need to be refactored when possible
  #   TODO: Refactor discount_total and other code to set and leverage the fields on reservation_carts and payments   
  def commit_invoice_prices
    #get all the items that match this coupon.. THIS IS A PAYMENT TIME METHOD, in an attempt to have transaction agree with lines
    @discount_amount = 0.00
    
    ## clear the old coupons out
    self.reservation_carts.each do |ci|
      ci.line_discount=0
      ci.line_price=ci.reservation.event.price
      ci.coupon_id=nil
      ci.save
    end
    
    unless self.user_coupon_code.blank?
      # puts "we will apply discount for #{self.user_coupon_code} "
      coupon_collection = Coupon.where( "code = ?", self.user_coupon_code)
      if coupon_collection.empty?  #then we don't have a coupon any more, maybe it was deleted , changed or fraud?
        self.reservation_carts.each do |ci|
          ci.line_discount=0
          ci.line_price=ci.reservation.event.price
          ci.coupon_id=nil
          ci.save
        end       
      else # coupon collection empty
        coupon_object=coupon_collection.first
        # puts "we have a coupon : #{coupon_object.code}"
        if ((coupon_object.use_limit.to_i<1) or (coupon_object.use_limit.to_i>0 and coupon_object.has_remaining?)) and (coupon_object.is_valid_today?)
          @num_remaining=coupon_object.number_remaining      
            if coupon_object.event_restricted?
              self.reservation_carts.joins(:reservation => :event).where( :events => {:id => coupon_object.event_id}).each do |ci|
                working_cart_item = ReservationCart.find(ci[:id])
                @line_discount=0
                @line_price = 0
                if @num_remaining > 0
                  # puts "applying an event restricted coupon to a reservation : #{ci.reservation.event.eventname}"
                  if coupon_object.discount_type=='FIXED'
                    @line_discount = coupon_object.discount_value
                    @discount_amount += @line_discount #coupon_object.discount_value
                  else
                    @line_discount = (ci.reservation.event.price*(coupon_object.discount_value/100).round(2))
                    @discount_amount += @line_discount #(ci.reservation.event.price*(coupon_object.discount_value/100).round(2))
                  end
                  @num_remaining=@num_remaining-1
                  working_cart_item.line_discount = @line_discount
                  working_cart_item.coupon_id = coupon_object.id
                  working_cart_item.line_price = ci.reservation.event.price
                  working_cart_item.save
                end            
              end #end loop
            else #else not event restricted
              self.reservation_carts.each do |ci| 
                @line_discount = 0
                @line_price = 0         
                if @num_remaining > 0
                  # puts "applying a coupon to a reservation : #{ci.reservation.event.eventname}"
                  if coupon_object.discount_type=='FIXED'
                    @line_discount = coupon_object.discount_value
                    @discount_amount += @line_discount #coupon_object.discount_value
                  else
                    @line_discount = (ci.reservation.event.price*(coupon_object.discount_value/100).round(2))
                    @discount_amount += @line_discount #(ci.reservation.event.price*(coupon_object.discount_value/100).round(2))
                  end
                  ci.line_discount = @line_discount
                  ci.coupon_id = coupon_object.id
                  ci.line_price = ci.reservation.event.price
                  ci.save
                  @num_remaining=@num_remaining-1
                end                
              end #end loop
            end #event restricted?
        end #has remaining and valid today
      end #coupon collection empty?
    end #coupon code is nil  
  end

  
  def total_balance
    @total_price=0
    @total_discount=0
    self.reservation_carts.each do |ii|
      @total_price = @total_price + ii.reservation.event.price
    end
    realTotal = @total_price - discount_total #@total_discount
    if realTotal > 0 then realTotal else 0 end
  end  
end
