class Organization < ActiveRecord::Base
  has_many :person_organizations
  has_many :people, :through => :person_organizations 
end
