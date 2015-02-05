include ActionView::Helpers::NumberHelper
class Reservation < ActiveRecord::Base
  belongs_to :person
  belongs_to :event
  has_many :reservation_resources
  has_many :resources, :through => :reservation_resources
  has_one :reservation_cart
  accepts_nested_attributes_for :resources,:reservation_resources, :allow_destroy => true
  validates_presence_of :event_id
  validates_presence_of :person_id
  
  attr_accessible :cabin_id, :checked_in
  
  scope :date_desc, order("reservations.created_at DESC")
  
  def is_purchasable?
    self.event.still_open?
  end
  
  def amount_due
    number_to_currency( self.event.price.to_f + self.amountpaid.to_f + all_discounts.to_f )
  end
  
  def all_discounts
    #in reality discount will be applied at checkout
     5 
  end
end
