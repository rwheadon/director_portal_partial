class ReservationCart < ActiveRecord::Base
  # ReservationCart
  #   :reservation_id (link back to everything important)
  #   :status (new or paid)
  #   :reference_code (all cart items paid at one time will get this value, it's what we send the clearinghouse as a reference id)
  #     *schema will be <random(2).to_upper><user_id>-<yy><mm><dd>-<random(2).to_upper>-<hh><mm><nn>
  #   :invoice_id (the invoice it all translates into... this is what they will print) ;)
  belongs_to :reservation
  belongs_to :invoice
  
end
