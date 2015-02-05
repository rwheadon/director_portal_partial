class Person < ActiveRecord::Base
  has_many :person_addresses
  has_many :addresses, :through => :person_addresses
  has_many :person_emails
  has_many :emails, :through => :person_emails
  has_many :person_organizations
  has_many :organizations, :through => :person_organizations
  has_many :person_simple_contacts
  has_many :simple_contacts, :through => :person_simple_contacts
  has_many :person_medications
  has_many :person_allergies
  has_many :person_medical_notes
  has_many :reservations
  belongs_to :user
  validates_associated :addresses
  
  accepts_nested_attributes_for :addresses, 
    :emails, 
    :organizations, 
    :simple_contacts, 
    :person_medications, 
    :person_allergies,
    :person_medical_notes,
    :reservations
    
  def fullname
    fn = self.firstname || 'unknown_firstname'
    ln = self.lastname || 'unknown_lastname'
    [fn,ln].join(' ')
  end


 ################ PROGRESS TRACKING ####################  
   def person_basics_complete?
     # 10% person info firstname, lastname, gender, birthdate & at least one person address
       did_pass = (self.firstname.blank? || self.lastname.blank? || self.gender.blank? || self.birthdate.blank?) ? false : true
   end

   def person_has_valid_address?
     @matched_complete=false
     unless self.addresses.empty?
       self.addresses.each do |pa|
         unless (pa.Street1.blank?) || (pa.City.blank?) || (pa.State.blank?) || (pa.zipcode.blank?)
           @matched_complete=true
         end
       end
       # @progress_number = @matched_complete==true ? @progress_number + 10 : @progress_number
     end
     @matched_complete
   end

   def person_has_organization?
     @matched_complete=false
     unless self.organizations.empty?
       self.organizations.each do |org|
         unless(org.name.blank?)
           @matched_complete=true end
       end
       # @progress_number = @matched_complete==true ? @progress_number + 10 : @progress_number
     end
     @matched_complete
   end  

   def person_has_email?
     @matched_complete=false
     unless self.emails.empty?
       self.emails.each do |org|
         unless org.emailAddress.blank? then @matched_complete=true end
       end
       # @progress_number = @matched_complete==true ? @progress_number + 10 : @progress_number
     end
     @matched_complete
   end

   def person_has_parent?
     @matched_complete=false
     unless self.simple_contacts.empty?
       self.simple_contacts.each do |sc|
         if sc.contacttype=="parent" || sc.contacttype=="guardian"
           unless sc.firstname.blank? || sc.lastname.blank? || sc.relationship.blank? then @matched_complete=true end
         end
       end
       # @progress_number = @matched_complete==true ? @progress_number + 10 : @progress_number
     end    
     @matched_complete
   end

   def person_has_pickup?
     @matched_complete=false
     @matched_count = 0
     unless self.simple_contacts.empty?
       self.simple_contacts.each do |sc|
         if sc.contacttype=="pickup"
           unless sc.firstname.blank? || sc.lastname.blank? || sc.relationship.blank? then @matched_count += 1 end
         end
       end
       # @progress_number = @matched_complete==true ? @progress_number + 10 : @progress_number
       @matched_complete = @matched_count>=2 ? true : false
     end    
     @matched_complete    
   end

   def person_has_emergency_contact?
     @matched_complete=false
     @matched_count=0
     unless self.simple_contacts.empty?
       self.simple_contacts.each do |sc|
         if sc.contacttype=="emergency"
           unless sc.firstname.blank? || sc.lastname.blank? || sc.relationship.blank? then @matched_count += 1 end
         end
       end
       # @progress_number = @matched_complete==true ? @progress_number + 10 : @progress_number
       @matched_complete = @matched_count>=2 ? true : false
     end   
     @matched_complete 
   end

   def person_important_contacts_have_email?
     @checked_count=0
     @valid_count=0
     unless self.simple_contacts.empty?
       self.simple_contacts.each do |sc|
         if sc.contacttype=="parent" || sc.contacttype=="guardian"
           @found_emails=false
           @found_email_value=false
           @checked_count=@checked_count+1
           @found_emails = sc.simple_contact_emails.empty? ? false : true
           if @found_emails
             #we have email so now we need to see if one has a value
             sc.simple_contact_emails.each do |sce|
               unless sce.emailaddress.blank?
                 @found_email_value=true 
               end ## unless blank
             end #sc emails.each
             @valid_count = @found_email_value==true ? @valid_count + 1 : @valid_count
           end #  if @found_emails
         end # if sc is important type
       end # unless simplecontacts empty
       # @progress_number = @checked_count==@valid_count ? @progress_number + 10 : @progress_number
     end   
     (@checked_count==@valid_count) && (@checked_count>0)
   end

   def person_has_contact_with_insurance?
     @matched_complete=false
     unless self.simple_contacts.empty?
       self.simple_contacts.each do |sc|
         unless sc.simple_contact_insurances.empty?
           sc.simple_contact_insurances.each do |sci|
             if sci.is_primary==true
               @matched_complete=true 
             end
           end
         end
       end
       # @progress_number = @matched_complete==true ? @progress_number + 10 : @progress_number
     end   
     @matched_complete 
   end

   def person_contacts_have_phones?
     @required_phones_per_contact=2
     @checked_count=0
     @valid_count=0
     unless self.simple_contacts.empty?
       self.simple_contacts.each do |sc|
         @valid_count_for_contact=0
           if sc.contacttype == 'pickup'
             #rubber stamp as complete since this is a production on-the-fly business change >:-(
             @valid_count = @required_phones_per_contact
             @checked_count = @required_phones_per_contact
           else
             @found_phones=false
             # @found_phone_value=false
             @checked_count=@checked_count+1
             @found_phones = sc.simple_contact_phones.empty? ? false : true
             if @found_phones
               #we have phone so now we need to see if one has a value
               sc.simple_contact_phones.each do |sce|
                 unless sce.scphonenumber.blank?
                   @valid_count_for_contact=@valid_count_for_contact+1 
                 end
               end
               @valid_count = @valid_count_for_contact>=2 ? @valid_count + 1 : @valid_count
             end
           end
       end
       # @progress_number = @checked_count==@valid_count ? @progress_number + 10 : @progress_number
     end   
     (@checked_count==@valid_count) && (@checked_count>0)    
   end 
 ######################### End of progress builder #####################################

    def requirement_progress
      puts "****************** progress for #{self.fullname} ********************"
      @progress_number=0
      #this method is used to make sure all of the necessary requirements for a person are met before reservations take place. 
      #It probably should keep invoices from being paid for if the information is incorrect.
      # 10% basic name/gender/birthday info
        @progress_number = person_basics_complete? ? @progress_number + 10 : @progress_number
      # 10% one valid address
      @progress_number = person_has_valid_address? ? @progress_number + 10 : @progress_number     
      # 10% at least one person organization
      @progress_number = person_has_organization? ? @progress_number + 10 : @progress_number    
      # 10% at least one person email
      @progress_number = person_has_email? ? @progress_number + 10 : @progress_number
      # 10% at least one parent/guardian contact
      @progress_number = person_has_parent? ? @progress_number + 10 : @progress_number
      # 10% at least two emergency contact (in case parent can't be reached)
      @progress_number = person_has_emergency_contact? ? @progress_number + 10 : @progress_number
      # 10% at least one contact must have insurance information, this is the emergency room contact
      @progress_number = person_has_contact_with_insurance? ? @progress_number + 10 : @progress_number
      # 10% at least one email for each parent/guardian/emergency contact
      @progress_number = person_important_contacts_have_email? ? @progress_number + 10 : @progress_number
      # 10% at least 2 phone numbers on every contact
      @progress_number = person_contacts_have_phones? ? @progress_number + 10 : @progress_number
      # 10% at least Two pickup person
      @progress_number = person_has_pickup? ? @progress_number + 10 : @progress_number

      puts"#{@progress_number}"
      @progress_number
    end
  ################## END PROGRESS TRACKING ###########################
  
  
  
end