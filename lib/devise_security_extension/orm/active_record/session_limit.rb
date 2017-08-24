module Devise
  class SessionLimit < Devise.parent_model.constantize
    self.table_name = :devise_session_limits

    belongs_to :session_limitable, polymorphic: true, required: true
  end
end
