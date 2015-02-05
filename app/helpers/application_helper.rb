module ApplicationHelper
  def link_to_add_fields(name, f, association)
    #example input: link_to_add_fields "Add Phone", f, :simple_contact_phones
    # create the new object
    new_object = f.object.send(association).klass.new
    
    puts "we have created a new object #{association.inspect} with id:#{new_object.object_id}"
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s.singularize + "_fields", f: builder)
    end
    link_to(name, '#', class: "add_fields", data: {id: id, fields: fields.gsub("\n", "")})
  end
end
