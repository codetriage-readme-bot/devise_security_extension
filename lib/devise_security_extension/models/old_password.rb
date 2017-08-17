class OldPassword < Devise.parent_model.constantize
  belongs_to :password_archivable, polymorphic: true
end
