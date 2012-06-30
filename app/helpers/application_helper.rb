module ApplicationHelper
  def link_to_add_fields(name, f, association)
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render(association.to_s.singularize + "_fields", :f => builder)
    end
    link_to_function(name, "add_fields(this," + "\"#{association}\",\"" + escape_javascript(fields) + "\")")
  end
  
  def to_magage pl, parent
    #l = Node.lookup(parent,pl.hash_str)
    #logger.info "HET"
    #logger.info pl.hash_str
    #logger.info parent.id
    #l
    Node.lookup(parent, pl.hash_str)
  end
  
end
