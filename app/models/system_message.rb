class SystemMessage < ActiveRecord::Base
  attr_accessible :message, :reference_class_type, :reference_id, :calling_method, :exception_audit, :priority, :status, :last_modified_by, :last_modified_dt
end
