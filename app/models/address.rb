class Address < ActiveRecord::Base
  has_many :person_addresses
  has_many :people, :through => :person_addresses
   # validates :Street1,  :presence => true
   # validates :City,  :presence => true
   # validates :State,  :presence => true
   # validates :zipcode,  :presence => true
  def scphonenumber=(scphonenumber)
    write_attribute(:scphonenumber, scphonenumber.to_s.gsub(/[^0-9]/, "").to_i)
  end
end
