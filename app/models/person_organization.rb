class PersonOrganization < ActiveRecord::Base
  belongs_to :person
  belongs_to :organization  
end
