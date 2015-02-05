class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    # users set role = 'registrar' where id=2
      user ||= User.new # guest user (not logged in)
      puts "#{user.email} is logged in as a #{user.role}"
      if user.role? :admin
        can :manage, :all
        
      elsif user.role? :registrar
        
        can :read, :all
        can :filter, Reservation
        can [:edit,:update], Reservation
        can [:read, :edit, :update], UserProfile
        can :check_in_reservation, Reservation
        can [:read, :edit, :update], UserProfile
        can [:new, :create], PersonMedicalNote
      elsif user.role? :director
        can :read, :all
        can :filter, Reservation
        can :check_in_reservation, Reservation
        can [:edit,:update], Reservation
      elsif user.role? :nurse
        can :read, :all
        can [:new, :create], PersonMedicalNote
      else
        #nada
      end
    #
    # The first argument to `can` is the action you are giving the user permission to do.
    # If you pass :manage it will apply to every action. Other common actions here are
    # :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. If you pass
    # :all it will apply to every resource. Otherwise pass a Ruby class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end