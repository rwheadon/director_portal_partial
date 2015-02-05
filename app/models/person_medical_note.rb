class PersonMedicalNote < ActiveRecord::Base
  belongs_to :person
  belongs_to :user, :foreign_key => "created_by"
  
  attr_accessible :person_id, :created_by, :notes
  
  def created_by_name
    uem="CREATED_BY-IS-MISSING"
    unless self.created_by.nil?
      #usr=User.find(self.created_by)
      usr=User.find(:first, :conditions=>"id=#{self.created_by}")
       unless usr.nil?
        uem=usr.email
      end
    end
    uem
  end
  
  # def created_by_name
  #   unless self.created_by.nil?
  #     usr=User.find(self.created_by)
  #     usr.email
  #   end
  # end
end
