class Phone < ActiveRecord::Base

  def scphonenumber=(phoneNumber)
    write_attribute(:phoneNumber, scphonenumber.to_s.gsub(/[^0-9]/, "").to_i)
  end
end
