class UserProfile < ActiveRecord::Base
  belongs_to :user
  
  attr_accessible :user_id, :firstname, :lastname, :notes, :is_active, :staff_context_id
  
end
