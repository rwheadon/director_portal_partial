class Coupon < ActiveRecord::Base
  belongs_to :event
  has_many :reservation_carts
  validates :code, :uniqueness => true
  def is_valid_today?
    (self.effective_start_date <= Date.today) and (self.effective_end_date >= Date.today)
  end 
  
  def number_used
    used_count=0
    # Invoice.where(:user_coupon_code => self.code, :status => "paid").count
    ReservationCart.where(:coupon_id => self.id).each do |rc|
      if rc.invoice.status == 'paid'
        used_count+=1
      end
    end
    used_count
  end 
  
  def number_remaining
    if self.use_limit.to_i == 0
      99
    else
      realnum = self.use_limit - self.number_used
      if realnum < 0 
        0
      else
        realnum
      end 
    end
  end
  
  def has_remaining?
    self.number_remaining > 0
  end
  
  def is_valid_for_this_paid_transaction?( some_invoice )
    #if the coupon actually got applied then we have to assume everything is okay
    #TODO: Rework this so that the invoice actually holds some persistent information once paid, that way we one day can purge 
    #       old data
    (some_invoice.status == 'paid') and (some_invoice.user_coupon_code.upcase == self.code.upcase) ? true : false
  end
  
  def event_restricted?
    self.event_id.to_i > 0
  end
  
  def usable_coupon?
    is_valid_today? && has_remaining?
  end
  
  def valid_dates
    "#{self.effective_start_date.strftime("%m/%d/%Y")}-#{self.effective_end_date.strftime("%m/%d/%Y")}"
  end   
  def description_with_dates
    txt = "#{self.description} : valid #{self.valid_dates}"
    
    if self.use_limit.to_i>0
      #coupon_tag = @coupon.code_mask ? "**SPECIAL DISCOUNT**" : @coupon.code
      numused = number_used > self.use_limit ? self.use_limit : number_used
      txt += " #{numused} of #{self.use_limit} coupons have been claimed. (NOTE: This type of coupon is consumed at a per-line basis)"
    end
      
    txt
  end

end
