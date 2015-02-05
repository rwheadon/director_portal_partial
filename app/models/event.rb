class Event < ActiveRecord::Base
  has_many :event_resources
  has_many :resources, :through => :event_resources
  has_many :reservations
  
  def event_dates
    "#{self.date_begin.strftime("%m/%d/%Y")}-#{self.date_end.strftime("%m/%d/%Y")}"
  end
  
  def event_with_dates
    "#{self.eventname} (#{self.event_dates})"
  end
  
  def event_with_dates_and_price
    "#{self.eventname} (#{self.event_dates}) / #{number_to_currency(self.price)}"
  end
  
  def still_open?
    self.date_begin >= Date.today
  end
  
  def registerable_events
    Event.where(:date_begin > @today)
  end
  
end
