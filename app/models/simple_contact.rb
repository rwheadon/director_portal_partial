class SimpleContact < ActiveRecord::Base
  has_many :person_simple_contacts
  has_many :people, :through => :person_simple_contacts
  has_many :simple_contact_phones
  has_many :simple_contact_emails
  has_many :simple_contact_insurances
  accepts_nested_attributes_for :simple_contact_phones, :simple_contact_emails, :simple_contact_insurances, :allow_destroy => true 
end
