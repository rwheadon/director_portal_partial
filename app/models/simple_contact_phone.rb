class SimpleContactPhone < ActiveRecord::Base
  belongs_to :simple_contact
  
  #it's too late at this point for the default callbacks
  # before_save :format_phone
  # before_update :format_phone
  # before_validation :format_phone
  # so we override the default setter for the field
  def scphonenumber=(scphonenumber)
    scphone_calc = scphonenumber.to_s.gsub(/[^0-9]/, "").to_i
    unless scphone_calc == 0 or scphone_calc > 9999999999
      write_attribute(:scphonenumber, scphonenumber.to_s.gsub(/[^0-9]/, "").to_i)
    end
  end
  
  #this is left behind for posterity sake and as a personal reference in the project.
  def format_phone
    puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    puts ">>>>>>>>  formatting self.scphonenumber >>>>>>>>>>>>>>>>>>>>>"
    puts "before #{self.scphonenumber}"
    self.scphonenumber=self.scphonenumber.to_s.gsub(/[^0-9]/, "").to_i
    puts "after #{self.scphonenumber}"
    puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  end

end
