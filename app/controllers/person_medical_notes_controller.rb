class PersonMedicalNotesController < ApplicationController
  load_and_authorize_resource

  # GET /person_medical_notes/new
  # GET /person_medical_notes/new.json
  def new
    @person = Person.find(params[:person])
    @person_medical_note = PersonMedicalNote.new(:person_id => params[:person], :created_by => current_user.id, :notes => "
    Note By: #{current_user.email}
    Emergency Visit: No
    Delivered to Nurse By: #{@person.fullname}
    ---------------------------------------------------------    
    Chief Complaint:
    
    Begin Notes:
    
    
    ")

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @person }
    end
  end
  
  # POST /person_medical_notes
  # POST /person_medical_notes.json
  def create
    # @person = params[:person]
    @person_medical_note = PersonMedicalNote.new(params[:person_medical_note])
    puts "******************\n#{@person_medical_note.person}\n************************"
    respond_to do |format|
      
      if @person_medical_note.save
        format.html { redirect_to @person_medical_note.person, notice: 'Medical Note was successfully created.' }
        # format.json { render json: @person, status: :created, location: @person }
      else
        format.html { render action: "new" }
        # format.json { render json: @person.errors, status: :unprocessable_entity }
      end
    end
  end    
  
  
  
end