class PeopleController < ApplicationController
  load_and_authorize_resource

  before_filter :authenticate_user!
  
  # GET /people/1
  # GET /people/1.json
  def show
    @person = Person.find(params[:id])
    @person.pct_complete = @person.requirement_progress
    @person.save
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @person }
    end
  end
  
  def index
    @currentuser=current_user.email
    # @people = Person.where( :user_id => current_user.id)
    # if current_user.role? :admin or current_user.role? :registrar
      @people = Person.all
    # end
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @people }
    end
  end

end