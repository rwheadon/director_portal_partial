class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  # devise :database_authenticatable, :confirmable, :recoverable, :rememberable, :trackable, :validatable, :timeoutable
  devise :database_authenticatable, :confirmable, :rememberable, :trackable, :validatable, :timeoutable
  # , :timeout_in => 60.minutes

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :role, :id
  has_many :people
  has_many :invoices
  
  #these roles are tightly coupled to controllers and views in a one to many stored in the user
  #influenced by ryan bates for simplicity sake until something more is needed
  #   http://railscasts.com/episodes/189-embedded-association
  #   admin = super user, see all, update all, create all, delete all
  #   registrar = see all, update all, create all
  #   event_manager (director) = see their own context(events) and can link reservations to resources, add any notes
  #   priviledged = sees all records for an assigned event and can add notes
  
  ROLES = %w[admin registrar director]
  
    def role?(role)    
      self.role == role.to_s
    end
  
  
end
