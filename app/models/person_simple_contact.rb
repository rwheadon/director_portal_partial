class PersonSimpleContact < ActiveRecord::Base
  belongs_to :person
  belongs_to :simple_contact  
end
