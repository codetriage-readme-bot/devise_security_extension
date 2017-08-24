module Devise
  class OldPassword < Devise.parent_model.constantize
    self.table_name = :devise_old_passwords

    belongs_to :password_archivable, polymorphic: true, required: true
  end
end
