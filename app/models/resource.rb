class Resource < ActiveRecord::Base
  has_many :reservation_resources
  has_many :reservations, :through => :reservation_resources
  
  def available_cabins( eventId )
    @all_cabins = Resource.where('resourcetype = ?', 'Cabin')
    @available_cabins
    @all_cabins.each do |c|
        used_num = Reservation.where('event_id = ?', eventId ).where( 'cabin_id = ?', c.id ).count
        if used_num < c.occupancy 
          @available_cabins << c
        end
    end
    @available_cabins
  end
  
end