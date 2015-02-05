class Email < ActiveRecord::Base
  has_many :person_emails
  has_many :people, :through => :person_emails
end
